// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract LendingProtocol is ERC20, Ownable {
    using SafeERC20 for IERC20;

    modifier onlyOperator() {
        require(
            msg.sender == operator || msg.sender == owner(),
            "Not authorized"
        );
        _;
    }

    // 代币合约地址
    address public immutable usdt;
    address public immutable collateralToken;

    // USDT 精度值（e.g. 1e6）
    uint256 public immutable usdtPrecision;
    // 抵押代币精度值（固定1e18）
    uint256 public constant COLLATERAL_PRECISION = 1e18;

    // 价格预言机相关
    uint256 public collateralPrice; // 抵押代币价格（以 USDT 计价，使用 USDT 精度）
    uint256 public lastPriceUpdateTime; // 价格更新时间
    uint256 public lastAprUpdateTime; // apr更新时间
    address public operator; // 操作员地址
    uint256 public maxPriceChangeBps = 1000; // 单次最多±10%

    // 借贷参数（可修改）
    uint256 public ltv = 5000; // 50% 贷款价值比
    uint256 public liquidationThreshold = 7500; // 75% 清算阈值
    uint256 public liquidationBonus = 500; // 5% 清算奖励
    uint256 public constant PRECISION = 10000; // 精度
    uint256 public apr = 500; // 5% 年化利率
    uint256 public constant SECONDS_PER_YEAR = 365 * 24 * 60 * 60; // 一年的秒数

    // 全局利息累积系数
    uint256 public accInterestPerDebt = 1e18; // 全局利息累积系数（18位精度）
    uint256 public lastUpdateTime; // 最后更新利息的时间

    // LP代币利息累积系数
    uint256 public accInterestPerLP = 1e18; // LP代币利息累积系数（18位精度）
    uint256 public lastLPUpdateTime; // LP利息最后更新时间

    // LP池总USDT数量
    uint256 public totalLPUSDT;

    // 用户借贷信息
    struct UserPosition {
        uint256 collateralAmount; // 抵押代币数量
        uint256 debtShares; // 债务凭证数量（类似LP凭证）
        uint256 originalDebtPrincipal; // 原始借贷本金（USDT，用于计算利息）
        bool exists; // 是否存在借贷记录
    }

    // 用户借贷映射
    mapping(address => UserPosition) public userPositions;

    // 总抵押品数量
    uint256 public totalCollateral;
    // 总债务凭证数量
    uint256 public totalDebtShares;

    // 事件
    event Deposited(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount);
    event Repaid(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Liquidated(
        address indexed user,
        address indexed liquidator,
        uint256 collateralAmount,
        uint256 debtAmount
    );
    event PriceUpdated(uint256 newPrice, uint256 timestamp, address operator);
    event OperatorUpdated(address oldOperator, address newOperator);
    event LtvUpdated(uint256 oldLtv, uint256 newLtv);
    event LiquidationThresholdUpdated(
        uint256 oldThreshold,
        uint256 newThreshold
    );
    event LiquidationBonusUpdated(uint256 oldBonus, uint256 newBonus);
    event AprUpdated(uint256 oldApr, uint256 newApr);
    event USDTDeposited(
        address indexed user,
        uint256 usdtAmount,
        uint256 lpAmount
    );
    event USDTWithdrawnByUser(
        address indexed user,
        uint256 lpAmount,
        uint256 usdtAmount
    );

    /**
     * @dev 构造函数
     * @param _usdt USDT 合约地址
     * @param _usdtPrecision USDT 精度值 (e.g. 1e6)
     * @param _collateralToken 抵押代币合约地址
     * @param _collateralPrice 抵押代币价格, (以 USDT 计价, e.g. 1e6 = 1 USDT)
     */
    constructor(
        address _usdt,
        uint256 _usdtPrecision,
        address _collateralToken,
        uint256 _collateralPrice
    ) ERC20("Lending Protocol LP Token", "LPLP") Ownable(msg.sender) {
        usdt = _usdt;
        collateralToken = _collateralToken;
        usdtPrecision = _usdtPrecision;
        collateralPrice = _collateralPrice;
        lastPriceUpdateTime = block.timestamp;
        operator = msg.sender;

        // 初始化利息累积系数
        lastUpdateTime = block.timestamp;
        lastLPUpdateTime = block.timestamp;
    }

    // ============ USDT存款和LP代币功能 ============

    /**
     * @dev 存入USDT获得LP代币
     * @param amount 存入的USDT数量
     */
    function depositUSDT(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");

        // 更新LP利息
        _updateLPInterest();

        // 转移USDT到合约
        IERC20(usdt).safeTransferFrom(msg.sender, address(this), amount);

        // 计算LP代币数量（考虑精度差异：USDT是6位，LP代币是18位）
        uint256 lpAmount = (amount * (1e18 / usdtPrecision) * 1e18) /
            getCurrentAccInterestPerLP();

        // 铸造LP代币给用户
        _mint(msg.sender, lpAmount);
        totalLPUSDT += amount;

        emit USDTDeposited(msg.sender, amount, lpAmount);
    }

    /**
     * @dev 用LP代币提取USDT
     * @param lpAmount 要销毁的LP代币数量
     */
    function withdrawUSDT(uint256 lpAmount) external {
        require(lpAmount > 0, "LP amount must be greater than 0");
        require(balanceOf(msg.sender) >= lpAmount, "Insufficient LP balance");

        // 更新LP利息
        _updateLPInterest();

        // 计算可提取的USDT数量（包含利息）
        uint256 usdtAmount = (lpAmount * getCurrentAccInterestPerLP()) / 1e18/ (1e18 / usdtPrecision);
        require(totalLPUSDT >= usdtAmount, "Insufficient USDT in pool");

        // 销毁LP代币
        _burn(msg.sender, lpAmount);
        totalLPUSDT -= usdtAmount;

        // 转移USDT给用户
        IERC20(usdt).safeTransfer(msg.sender, usdtAmount);

        emit USDTWithdrawnByUser(msg.sender, lpAmount, usdtAmount);
    }

    /**
     * @dev 抵押代币
     * @param amount 抵押代币数量
     */
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");

        // 更新全局利息累积系数
        _updateGlobalInterest();

        // 转移抵押代币到合约
        IERC20(collateralToken).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        // 更新用户抵押信息
        if (!userPositions[msg.sender].exists) {
            userPositions[msg.sender] = UserPosition(0, 0, 0, true);
        }
        userPositions[msg.sender].collateralAmount += amount;
        totalCollateral += amount;

        emit Deposited(msg.sender, amount);
    }

    /**
     * @dev 借出 USDT
     * @param amount 借出数量
     */
    function borrow(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(userPositions[msg.sender].exists, "User position not exists");

        // 更新全局利息
        _updateGlobalInterest();
        // 更新LP利息
        _updateLPInterest();

        uint256 collateralValue = getCollateralValue(
            userPositions[msg.sender].collateralAmount
        );
        uint256 currentDebt = getCurrentDebt(msg.sender);
        uint256 newDebt = currentDebt + amount;

        // 检查借贷后是否超过 LTV
        require(collateralValue * ltv >= newDebt * PRECISION, "Exceeds LTV");

        // 检查LP池中可借出的USDT数量
        require(totalLPUSDT >= amount, "Insufficient USDT in LP pool");

        // 计算需要增加的债务凭证数量
        uint256 sharesToAdd = (amount * (1e18 / usdtPrecision)) /
            getCurrentAccInterestPerDebt();

        // 更新用户债务凭证
        userPositions[msg.sender].debtShares += sharesToAdd;
        userPositions[msg.sender].originalDebtPrincipal += amount; // 记录原始借贷本金
        totalDebtShares += sharesToAdd;

        // 更新 LP 池总 USDT 数量
        totalLPUSDT -= amount;

        // 转移 USDT 给用户
        IERC20(usdt).safeTransfer(msg.sender, amount);

        emit Borrowed(msg.sender, amount);
    }

    /**
     * @dev 偿还债务
     * @param amount 偿还数量
     */
    function repay(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(userPositions[msg.sender].exists, "User position not exists");

        // 更新全局利息
        _updateGlobalInterest();
        // 更新LP利息
        _updateLPInterest();

        uint256 currentDebt = getCurrentDebt(msg.sender);
        require(currentDebt >= amount, "Repay amount exceeds debt");

        // 转移 USDT 到合约
        IERC20(usdt).safeTransferFrom(msg.sender, address(this), amount);

        // 使用公共函数更新用户债务
        _updateUserDebt(msg.sender, amount, currentDebt);

        // 更新 LP 池总 USDT 数量（包含利息）
        totalLPUSDT += amount;

        emit Repaid(msg.sender, amount);
    }

    /**
     * @dev 提取抵押品
     * @param amount 提取数量
     */
    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(userPositions[msg.sender].exists, "User position not exists");
        require(
            userPositions[msg.sender].collateralAmount >= amount,
            "Insufficient collateral"
        );

        // 更新全局利息
        _updateGlobalInterest();

        uint256 remainingCollateral = userPositions[msg.sender]
            .collateralAmount - amount;
        uint256 collateralValue = getCollateralValue(remainingCollateral);
        uint256 debtAmount = getCurrentDebt(msg.sender);

        // 检查提取后是否超过 LTV
        if (debtAmount > 0) {
            require(
                collateralValue * ltv >= debtAmount * PRECISION,
                "Withdrawal would exceed LTV"
            );
        }

        // 更新用户抵押信息
        userPositions[msg.sender].collateralAmount = remainingCollateral;
        totalCollateral -= amount;

        // 转移抵押代币给用户
        IERC20(collateralToken).safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev 清算用户
     * @param user 被清算用户地址
     * @param debtAmount 偿还的债务数量
     */
    function liquidate(address user, uint256 debtAmount) external {
        require(userPositions[user].exists, "User position not exists");
        require(debtAmount > 0, "Debt amount must be greater than 0");

        // 更新全局利息
        _updateGlobalInterest();
        // 更新LP利息
        _updateLPInterest();

        uint256 currentDebt = getCurrentDebt(user);
        require(currentDebt >= debtAmount, "Debt amount exceeds user debt");

        uint256 collateralValue = getCollateralValue(
            userPositions[user].collateralAmount
        );

        // 检查是否需要清算（超过清算阈值）
        require(
            collateralValue * liquidationThreshold < currentDebt * PRECISION,
            "Position not liquidatable"
        );

        // 计算清算奖励：USDT数量除以价格得到抵押物数量，然后加上清算奖励
        uint256 baseCollateralAmount = (debtAmount * COLLATERAL_PRECISION) /
            collateralPrice; // 基础抵押物数量
        uint256 collateralAmount = (baseCollateralAmount *
            (PRECISION + liquidationBonus)) / PRECISION; // 加上清算奖励
        require(
            userPositions[user].collateralAmount >= collateralAmount,
            "Insufficient collateral for liquidation"
        );

        // 转移 USDT 到合约
        IERC20(usdt).safeTransferFrom(msg.sender, address(this), debtAmount);

        // 使用公共函数更新用户债务
        _updateUserDebt(user, debtAmount, currentDebt);

        // 更新 LP 池总 USDT 数量（包含利息）
        totalLPUSDT += debtAmount;

        // 更新抵押品信息
        userPositions[user].collateralAmount -= collateralAmount;
        totalCollateral -= collateralAmount;

        // 转移抵押代币给清算人
        IERC20(collateralToken).safeTransfer(msg.sender, collateralAmount);

        emit Liquidated(user, msg.sender, collateralAmount, debtAmount);
    }

    /**
     * @dev 获取用户健康因子
     * @param user 用户地址
     * @return 健康因子（百分比）
     */
    function getHealthFactor(address user) external view returns (uint256) {
        if (
            !userPositions[user].exists || userPositions[user].debtShares == 0
        ) {
            return type(uint256).max; // 无债务时健康因子为最大值
        }

        uint256 collateralValue = getCollateralValue(
            userPositions[user].collateralAmount
        );
        uint256 debtValue = getCurrentDebt(user); // 使用当前债务（包含利息）

        // 先乘后除，减少精度丢失，使用固定的10000作为精度
        return (collateralValue * liquidationThreshold * 10000) / debtValue;
    }

    /**
     * @dev 获取用户可借数量
     * @param user 用户地址
     * @return 可借数量（USDT）
     */
    function getMaxBorrowable(address user) external view returns (uint256) {
        if (!userPositions[user].exists) {
            return 0;
        }

        uint256 collateralValue = getCollateralValue(
            userPositions[user].collateralAmount
        );
        uint256 maxBorrowValue = (collateralValue * ltv) / PRECISION;
        uint256 currentDebt = getCurrentDebt(user); // 使用当前债务（包含利息）

        if (maxBorrowValue <= currentDebt) {
            return 0;
        }

        return maxBorrowValue - currentDebt;
    }

    /**
     * @dev 获取用户可提取数量
     * @param user 用户地址
     * @return 可提取数量（抵押代币）
     */
    function getMaxWithdrawable(address user) external view returns (uint256) {
        if (!userPositions[user].exists) {
            return 0;
        }

        if (userPositions[user].debtShares == 0) {
            return userPositions[user].collateralAmount;
        }

        uint256 collateralValue = getCollateralValue(
            userPositions[user].collateralAmount
        );
        uint256 debtValue = getCurrentDebt(user); // 使用当前债务（包含利息）
        uint256 minCollateralValue = (debtValue * PRECISION) / ltv;

        if (collateralValue <= minCollateralValue) {
            return 0;
        }

        uint256 excessValue = collateralValue - minCollateralValue;
        return (excessValue * COLLATERAL_PRECISION) / collateralPrice;
    }

    /**
     * @dev 设置操作员地址
     * @param newOperator 新的操作员地址
     */
    function setOperator(address newOperator) external onlyOwner {
        require(newOperator != address(0), "Invalid operator address");
        address oldOperator = operator;
        operator = newOperator;
        emit OperatorUpdated(oldOperator, newOperator);
    }

    /**
     * @dev 操作员手动更新抵押代币价格
     * @param newPrice 新价格（以 USDT 计价，使用 USDT 精度）
     */
    function updatePrice(uint256 newPrice) external onlyOperator {
        require(newPrice > 0, "Price must be greater than 0");
        uint256 old = collateralPrice;
        if (old > 0) {
            uint256 diff = old > newPrice ? old - newPrice : newPrice - old;
            require(
                (diff * 10000) / old <= maxPriceChangeBps,
                "Price jump too large"
            );
        }

        collateralPrice = newPrice;
        lastPriceUpdateTime = block.timestamp;

        emit PriceUpdated(newPrice, block.timestamp, msg.sender);
    }

    /**
     * @dev 操作员手动更新apr,一小时一次
     * @param newApr 新apr,单次变化幅度最多1%
     */
    function updateApr(uint256 newApr) external onlyOperator {
        require(newApr <= PRECISION, "Invalid APR");
        require(block.timestamp - lastAprUpdateTime >= 3600, "Once an hour");
        // 在修改 APR 前，先更新全局利息累积系数（结算旧 APR 的利息）
        _updateGlobalInterest();
        // 更新LP利息
        _updateLPInterest();
        uint256 old = apr;
        if (old > 0) {
            uint256 diff = old > newApr ? old - newApr : newApr - old;
            require(diff <= 100, "Apr jump too large");
        }
        apr = newApr;
        lastAprUpdateTime = block.timestamp;
        emit AprUpdated(old, newApr);
    }

    /**
     * @dev 获取抵押代币价格
     * @return 价格（以 USDT 计价，使用 USDT 精度）
     */
    function getPrice() external view returns (uint256) {
        return collateralPrice;
    }

    /**
     * @dev 计算抵押代币的 USDT 价值
     * @param collateralAmount 抵押代币数量（18位小数）
     * @return USDT 价值（使用 USDT 精度）
     */
    function getCollateralValue(
        uint256 collateralAmount
    ) public view returns (uint256) {
        // collateralAmount 是 18 位小数，collateralPrice 使用 USDT 精度
        // 结果应该是 USDT 精度，所以需要除以 COLLATERAL_PRECISION
        return (collateralAmount * collateralPrice) / COLLATERAL_PRECISION;
    }

    /**
     * @dev 计算用户当前债务（包含利息）
     * @param user 用户地址
     * @return 当前债务数量（USDT）
     */
    function getCurrentDebt(address user) public view returns (uint256) {
        if (
            !userPositions[user].exists || userPositions[user].debtShares == 0
        ) {
            return 0;
        }

        uint256 currentAccInterestPerDebt = getCurrentAccInterestPerDebt();
        // 向上取整，避免 0 假象
        return
            (userPositions[user].debtShares *
                currentAccInterestPerDebt +
                1e18 -
                1) / 1e18;
    }

    /**
     * @dev 计算用户当前总债务（本金+利息）
     * @param user 用户地址
     * @return 总债务数量（USDT）
     */
    function getTotalDebt(address user) public view returns (uint256) {
        return getCurrentDebt(user);
    }

    /**
     * @dev 获取全网总债务（包含利息）
     * @return 全网总债务数量（USDT）
     */
    function getGlobalTotalDebt() public view returns (uint256) {
        uint256 currentAccInterestPerDebt = getCurrentAccInterestPerDebt();
        return (totalDebtShares * currentAccInterestPerDebt) / 1e18;
    }

    /**
     * @dev 计算当前应该的全局利息累积系数（公共函数）
     * @return 当前利息累积系数
     */
    function getCurrentAccInterestPerDebt() public view returns (uint256) {
        uint256 currentAccInterestPerDebt = accInterestPerDebt;
        uint256 timeElapsed = block.timestamp - lastUpdateTime;
        if (timeElapsed > 0) {
            uint256 interestRate = (apr * 1e18 * timeElapsed) /
                (PRECISION * SECONDS_PER_YEAR);
            currentAccInterestPerDebt =
                (currentAccInterestPerDebt * (1e18 + interestRate)) /
                1e18;
        }
        return currentAccInterestPerDebt;
    }

    /**
     * @dev 更新全局利息累积系数（内部函数）
     */
    function _updateGlobalInterest() internal {
        uint256 timeElapsed = block.timestamp - lastUpdateTime;
        if (timeElapsed > 0) {
            uint256 interestRate = (apr * 1e18 * timeElapsed) /
                (PRECISION * SECONDS_PER_YEAR);
            accInterestPerDebt =
                (accInterestPerDebt * (1e18 + interestRate)) /
                1e18;
            lastUpdateTime = block.timestamp;
        }
    }

    /**
     * @dev 内部函数：更新用户债务信息
     * @param user 用户地址
     * @param repayAmount 偿还的USDT数量
     * @param currentDebt 用户当前债务
     */
    function _updateUserDebt(
        address user,
        uint256 repayAmount,
        uint256 currentDebt
    ) internal {
        // 计算需要减少的债务凭证数量
        uint256 sharesToRemove = (repayAmount * (1e18 / usdtPrecision)) /
            getCurrentAccInterestPerDebt();
        uint256 shares = userPositions[user].debtShares;
        uint256 userOriginalPrincipal = userPositions[user]
            .originalDebtPrincipal;

        // 更新用户债务凭证和原始本金记录
        if (repayAmount + 1 >= currentDebt || sharesToRemove >= shares) {
            // 清零分支：完全偿还
            userPositions[user].debtShares = 0;
            userPositions[user].originalDebtPrincipal = 0;
            totalDebtShares -= shares;
        } else {
            // 正常分支：部分偿还
            userPositions[user].debtShares = shares - sharesToRemove;
            uint256 principalToRemove = (repayAmount * userOriginalPrincipal) /
                currentDebt;
            userPositions[user].originalDebtPrincipal -= principalToRemove;
            totalDebtShares -= sharesToRemove;
        }
    }

    /**
     * @dev 更新LP利息累积系数（内部函数）
     */
    function _updateLPInterest() internal {
        uint256 timeElapsed = block.timestamp - lastLPUpdateTime;
        if (timeElapsed > 0 && totalDebtShares > 0) {
            uint256 currentTotalDebt = (totalDebtShares *
                getCurrentAccInterestPerDebt()) / 1e18;
            uint256 interestRate = (apr * 1e18 * timeElapsed) /
                (PRECISION * SECONDS_PER_YEAR);
            uint256 interestAmount = (currentTotalDebt * interestRate) / 1e18;

            if (totalSupply() > 0) {
                uint256 lpInterestValue = interestAmount *
                    (1e18 / usdtPrecision);
                accInterestPerLP =
                    (accInterestPerLP * totalSupply() + lpInterestValue) /
                    totalSupply();
            }

            lastLPUpdateTime = block.timestamp;
        }
    }

    /**
     * @dev 管理员更新贷款价值比
     * @param newLtv 新的贷款价值比（百分比）
     */
    function updateLtv(uint256 newLtv) external onlyOwner {
        require(newLtv > 0 && newLtv <= liquidationThreshold, "Invalid LTV");
        uint256 oldLtv = ltv;
        ltv = newLtv;
        emit LtvUpdated(oldLtv, newLtv);
    }

    /**
     * @dev 管理员更新清算阈值
     * @param newLiquidationThreshold 新的清算阈值（百分比）
     */
    function updateLiquidationThreshold(
        uint256 newLiquidationThreshold
    ) external onlyOwner {
        require(
            newLiquidationThreshold > ltv &&
                newLiquidationThreshold <= PRECISION,
            "Invalid liquidation threshold"
        );
        uint256 oldThreshold = liquidationThreshold;
        liquidationThreshold = newLiquidationThreshold;
        emit LiquidationThresholdUpdated(oldThreshold, newLiquidationThreshold);
    }

    /**
     * @dev 管理员更新清算奖励
     * @param newLiquidationBonus 新的清算奖励（百分比）
     */
    function updateLiquidationBonus(
        uint256 newLiquidationBonus
    ) external onlyOwner {
        require(
            newLiquidationBonus <= PRECISION / 2,
            "Invalid liquidation bonus"
        );
        uint256 oldBonus = liquidationBonus;
        liquidationBonus = newLiquidationBonus;
        emit LiquidationBonusUpdated(oldBonus, newLiquidationBonus);
    }

    // ============ LP代币相关视图函数 ============

    /**
     * @dev 获取LP代币当前价值（包含累积利息）
     * @param lpAmount LP代币数量
     * @return USDT价值
     */
    function getLPValue(uint256 lpAmount) external view returns (uint256) {
        uint256 currentAccInterestPerLP = getCurrentAccInterestPerLP();
        return (lpAmount * currentAccInterestPerLP) / 1e18;
    }

    /**
     * @dev 计算当前LP利息累积系数
     * 基于时间驱动的利息计算，借款后立即开始计息
     */
    function getCurrentAccInterestPerLP() public view returns (uint256) {
        uint256 currentAccInterestPerLP = accInterestPerLP;
        uint256 timeElapsed = block.timestamp - lastLPUpdateTime;
        if (timeElapsed > 0 && totalDebtShares > 0) {
            uint256 currentTotalDebt = (totalDebtShares *
                getCurrentAccInterestPerDebt()) / 1e18;
            uint256 interestRate = (apr * 1e18 * timeElapsed) /
                (PRECISION * SECONDS_PER_YEAR);
            uint256 interestAmount = (currentTotalDebt * interestRate) / 1e18;

            if (totalSupply() > 0) {
                uint256 lpInterestValue = interestAmount *
                    (1e18 / usdtPrecision);
                currentAccInterestPerLP =
                    (currentAccInterestPerLP *
                        totalSupply() +
                        lpInterestValue) /
                    totalSupply();
            }
        }
        return currentAccInterestPerLP;
    }

    /**
     * @dev 获取用户LP代币的当前价值
     * @param user 用户地址
     * @return LP代币的USDT价值
     */
    function getUserLPValue(address user) external view returns (uint256) {
        uint256 currentAccInterestPerLP = getCurrentAccInterestPerLP();
        return (balanceOf(user) * currentAccInterestPerLP) / 1e18;
    }

    /**
     * @dev 获取LP代币年化收益率
     * @return 年化收益率（基点，如500表示5%）
     */
    function getLPAPY() external view returns (uint256) {
        if (totalSupply() == 0 || totalLPUSDT == 0) {
            return 0;
        }

        // 计算当前LP代币总价值（18位精度）
        uint256 currentAccInterestPerLP = getCurrentAccInterestPerLP();
        uint256 totalLPValue18 = (totalSupply() * currentAccInterestPerLP) /
            1e18;

        // 转换为USDT精度进行比较
        uint256 totalLPValueUSDT = totalLPValue18 / (1e18 / usdtPrecision);
        if (totalLPValueUSDT <= totalLPUSDT) {
            return 0;
        }

        // 计算年化收益率
        uint256 profit = totalLPValueUSDT - totalLPUSDT;
        return (profit * PRECISION) / totalLPUSDT;
    }
}
