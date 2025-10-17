// SPDX-License-Identifier: MIT
// File: contracts\MasterChef.sol

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function mint(address _to, uint256 _amount) external;

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @dev 封装了 Solidity 的算术运算并添加了溢出检查。
 *
 * Solidity 中的算术运算会溢出溢出。
 * 这很容易导致错误，因为程序员通常因为溢出会引发错误，这是高级编程语言中的普遍情况。
 * “SafeMath”通过在操作溢出时恢复事务来恢复这种直觉。
 *
 * 使用这个库而不是未经检查的操作可以消除一整类错误，因此建议始终使用它。
 */
library SafeMath {
    /**
     * @dev 返回两个无符号整数的相加，在溢出时恢复。
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev 返回两个无符号整数相除的余数。 (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @dev 地址类型相关函数集合
 */
library Address {
    /**
     * @dev 如果 `account` 是合约，则返回 true。
     *
     * [IMPORTANT]
     * ====
     * 假设此函数返回 false 的地址是外部账户 (EOA) 而不是合约是不安全的。
     *
     * 其中，对于以下类型的地址，`isContract` 将返回 false：
     *
     *  - 外部账户
     *  - 施工合约
     *  - 将创建合约的地址
     *  - 合约存在但被销毁的地址
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev 替代 Solidity 的 `transfer`：将 `amount` wei 发送给 `recipient`，
     * 转发所有可用的 gas 并在出现错误时恢复。
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library TransferHelper {
    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// 请注意，它是可拥有的，并且拥有者拥有巨大的权力。
// 一旦 SUSHI 被充分分配并且社区可以表现出自我管理，所有权将转移到治理智能合约。
//
contract MasterChef is Ownable {
    using SafeMath for uint256;

    // 每个用户的信息。
    struct UserInfo {
        uint256 amount; // 用户提供了多少 PowerToken。
        uint256 rewardDebt; // 用户已经获取的奖励
        uint256 totalReward; // 累计获得的奖励
        //
        // 我们在这里做一些花哨的数学运算。
        // 基本上，在任何时间点，有权授予用户但待分配的 SUSHI 数量为：
        //
        //   pending reward = (user.amount * pool.accRewardPerShare) - user.rewardDebt
        //
        // 每当用户将 PowerToken 存入或提取到池中时。这是发生的事情：
        //   1. 池的 `accRewardPerShare`（和 `lastRewardTime`）得到更新。
        //   2. 用户收到发送到他/她的地址的待处理奖励。
        //   3. 用户的“金额”得到更新。
        //   4. 用户的“rewardDebt”得到更新。
    }

    // 每个池的信息。
    struct PoolInfo {
        address powerToken; // PowerToken 合约地址。
        uint256 lastRewardTime; //  分配发生的最后一个时间戳。
    }

    // 礦池結構
    struct Pool {
        address creator;
        uint256 totalPower;
        uint256 createdAt;
        uint256 allocPoint; // 分配點數，等於 totalPower
        uint256 accRewardPerShare; // 累積每份算力的收益
        uint256 lastRewardTime; // 上次更新收益的時間
    }
    mapping(uint256 => Pool) public pools; // poolId => Pool
    mapping(string => uint256) public poolIdByCommand; // command => poolId
    mapping(uint256 => string) public commandByPoolId; // poolId => command
    uint256 public nextPoolId = 1;
    mapping(address => uint256) public userPool; // user => poolId (0表示未加入)
    uint256 public totalAllocPoint; // 總分配點數

    // The SUSHI TOKEN!
    IERC20 public token;

    // 初始每10分鐘獎勵50個
    uint256 public constant INITIAL_REWARD = 50e18; // 50個token，18位精度
    uint256 public BlockRewards = 50e18;
    uint256 public constant REWARD_INTERVAL = 600; // 10分鐘=600秒
    uint256 public tokenPerSecond = INITIAL_REWARD / REWARD_INTERVAL;
    uint256 public constant HALVING_INTERVAL = 210000 * 600; // 2100000分钟=126000000秒

    address public Operator; // 操作员
    bool public createPoolPublic = false; // 是否公开创建矿池

    // 单一池信息
    PoolInfo public poolInfo;
    // 每个持有 PowerToken 的用户的信息。
    mapping(address => UserInfo) public userInfo;

    uint256 private constant INVITE_REWARD_RATE_BASIS_POINTS = 10000;
    uint256 private constant BURN_RATE_BASIS_POINTS = 1000;
    uint256 public inviteRewardRate = 500; // 邀请人奖励比例 500/10000 = 5%
    uint256 public burnRate = 1500; // 烧伤比例门槛 1000/1000 = 100% 邀请人和下级的算力比必须大于这个比例才能拿满奖励

    mapping(address => address) public inviter; //邀请人
    mapping(address => uint256) public inviteCount; //邀请人好友数
    mapping(address => uint256) public totalInviteReward; //累计奖励

    // SUSHI 挖矿开始时的时间戳。
    uint256 public startTime;
    // 活躍礦工數量
    uint256 public activeMiners;

    event OperatorSet(address indexed operator);
    event CreatePoolPublicSet(bool indexed createPoolPublic);
    event TransferPool(
        uint256 poolId,
        address indexed oldCreator,
        address indexed newCreator
    );
    event CreatePool(address indexed creator, uint256 poolId);

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event SetPoolCommand(uint256 poolId, string command);
    event JoinPool(address indexed user, uint256 poolId);
    event LeavePool(address indexed user);
    event TakeUserReward(address indexed user, uint256 amount);
    event TakeFee(address indexed user, uint256 amount);
    event BindInviter(address indexed user, address indexed inviter);
    event InviteReward(
        address indexed user,
        address indexed inviter,
        uint256 amount
    );

    constructor(IERC20 _minetoken, uint256 _startTime, address _powerToken) {
        token = _minetoken;
        startTime = _startTime;
        poolInfo = PoolInfo({
            powerToken: _powerToken,
            lastRewardTime: _startTime
        });
    }

    function setOperator(address _operator) external onlyOwner {
        Operator = _operator;
        emit OperatorSet(_operator);
    }

    function setCreatePoolPublic() external onlyOwner {
        createPoolPublic = !createPoolPublic;
        emit CreatePoolPublicSet(createPoolPublic);
    }

    function setInviteRewardRate(uint256 _inviteRewardRate) external onlyOwner {
        require(
            _inviteRewardRate <= INVITE_REWARD_RATE_BASIS_POINTS,
            "Invalid invite reward rate"
        );
        inviteRewardRate = _inviteRewardRate;
    }

    function setBurnRate(uint256 _burnRate) external onlyOwner {
        burnRate = _burnRate;
    }

    function Halving() public {
        BlockRewards = currentRewardPerInterval();
    }

    // 返回当前每10分钟的奖励（已考虑减半）
    function currentRewardPerInterval() public view returns (uint256) {
        uint256 elapsed = block.timestamp - startTime;
        uint256 halvings = elapsed / HALVING_INTERVAL;
        return INITIAL_REWARD >> halvings; // 每减半一次奖励除以2
    }

    // 返回当前每秒奖励（动态计算）
    function currentRewardPerSecond() public view returns (uint256) {
        return BlockRewards / REWARD_INTERVAL;
    }

    // 修改pendingSushi和updatePool逻辑，动态获取每秒奖励
    function pendingSushi(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 poolId = userPool[_user];

        if (poolId == 0 || user.amount == 0) {
            return 0;
        }

        Pool storage pool = pools[poolId];
        uint256 accRewardPerShare = pool.accRewardPerShare;

        // 計算礦池的額外收益（從上次更新到現在）
        if (
            block.timestamp > pool.lastRewardTime &&
            pool.allocPoint > 0 &&
            totalAllocPoint > 0
        ) {
            uint256 timeElapsed = block.timestamp - pool.lastRewardTime;
            uint256 poolTimeReward = (timeElapsed *
                currentRewardPerSecond() *
                pool.allocPoint) / totalAllocPoint;

            if (pool.totalPower > 0) {
                accRewardPerShare = accRewardPerShare.add(
                    poolTimeReward.mul(1e12).div(pool.totalPower)
                );
            }
        }

        return
            user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt);
    }

    // 更新池的奖励变量以保持最新。
    function updatePool() public {
        PoolInfo storage pool = poolInfo;
        if (block.timestamp <= pool.lastRewardTime) {
            return;
        }
        uint256 powerSupply = IERC20(pool.powerToken).balanceOf(address(this));
        if (powerSupply == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }
        uint256 timeElapsed = block.timestamp - pool.lastRewardTime;
        uint256 sushiReward = timeElapsed * currentRewardPerSecond();
        token.mint(address(this), sushiReward);
        pool.lastRewardTime = block.timestamp;
    }

    // 檢查並更新礦池的分配點數（如果算力占比低於1%則設為0）
    function updatePoolAllocPoint(uint256 poolId) public {
        require(poolId > 0 && poolId < nextPoolId, "Invalid pool ID");
        require(pools[poolId].creator != address(0), "Pool does not exist");

        Pool storage pool = pools[poolId];
        uint256 oldAllocPoint = pool.allocPoint;

        if (totalAllocPoint == 0) {
            pool.allocPoint = pool.totalPower;
            totalAllocPoint = pool.allocPoint;
            return;
        }

        // 計算算力占比（以基點為單位，1% = 100基點）
        uint256 powerPercentage = 0;
        if (totalAllocPoint > 0) {
            powerPercentage = (pool.totalPower * 10000) / totalAllocPoint; // 10000 = 100%
        }

        // 如果算力占比低於1%（100基點），則allocPoint設為0
        if (powerPercentage < 100) {
            pool.allocPoint = 0;
        } else {
            pool.allocPoint = pool.totalPower;
        }

        // 更新總分配點數
        if (pool.allocPoint != oldAllocPoint) {
            totalAllocPoint = totalAllocPoint - oldAllocPoint + pool.allocPoint;
        }
    }

    // 更新指定礦池的收益分配
    function updatePoolReward(uint256 poolId) public {
        require(poolId > 0 && poolId < nextPoolId, "Invalid pool ID");
        require(pools[poolId].creator != address(0), "Pool does not exist");

        Pool storage pool = pools[poolId];
        uint256 currentTime = block.timestamp;
        if (pool.allocPoint == 0) pool.lastRewardTime = currentTime;
        if (pool.allocPoint == 0 || totalAllocPoint == 0) {
            return;
        }

        if (currentTime > pool.lastRewardTime) {
            uint256 timeElapsed = currentTime - pool.lastRewardTime;
            uint256 poolTimeReward = (timeElapsed *
                currentRewardPerSecond() *
                pool.allocPoint) / totalAllocPoint;

            if (pool.totalPower > 0) {
                pool.accRewardPerShare = pool.accRewardPerShare.add(
                    poolTimeReward.mul(1e12).div(pool.totalPower)
                );
            }
            pool.lastRewardTime = currentTime;
        }
    }

    function _createPool(address creator) internal returns (uint256) {
        require(userPool[creator] == 0, "Already in a pool");
        uint256 poolId = nextPoolId++;
        pools[poolId] = Pool({
            creator: creator,
            totalPower: 0,
            createdAt: block.timestamp,
            allocPoint: 0,
            accRewardPerShare: 0,
            lastRewardTime: block.timestamp
        });
        userPool[creator] = poolId;
        emit CreatePool(creator, poolId);
        return poolId;
    }

    // 操作员创建矿池
    function createPoolByOperator(address newCreator) external {
        require(msg.sender == Operator, "Not operator");
        require(newCreator != address(0), "Invalid new creator");
        _createPool(newCreator);
    }

    // 創建礦池
    function createPool() external returns (uint256) {
        require(createPoolPublic || msg.sender == Operator, "Not authorized");
        return _createPool(msg.sender);
    }

    // 转移矿池
    function transferPool(uint256 poolId, address newCreator) external {
        require(pools[poolId].creator == msg.sender, "Not creator");
        pools[poolId].creator = newCreator;
        emit TransferPool(poolId, msg.sender, newCreator);
    }

    function setPoolCommand(uint256 poolId, string memory command) external {
        require(pools[poolId].creator == msg.sender, "Not creator");
        require(bytes(command).length != 0, "Invalid command");
        require(poolIdByCommand[command] == 0, "Command already exists");
        poolIdByCommand[command] = poolId;
        commandByPoolId[poolId] = command;
        emit SetPoolCommand(poolId, command);
    }

    function bindInviter(address _inviter) external {
        require(inviter[msg.sender] == address(0), "Already bound");
        require(_inviter != address(0), "Invalid inviter");
        require(inviter[_inviter] != msg.sender, "Inviter cannot be self");
        inviter[msg.sender] = _inviter;
        inviteCount[_inviter] += 1;
        emit BindInviter(msg.sender, _inviter);
    }

    // 加入礦池
    function joinPool(uint256 poolId) public {
        require(userPool[msg.sender] == 0, "Already in a pool");
        require(pools[poolId].creator != address(0), "Pool not exist");
        userPool[msg.sender] = poolId;
        emit JoinPool(msg.sender, poolId);
    }

    function joinPoolByCommand(string memory command) external {
        require(poolIdByCommand[command] != 0, "Invalid command");
        joinPool(poolIdByCommand[command]);
    }

    // 離開礦池（必須沒有算力）
    function leavePool() external {
        require(userPool[msg.sender] != 0, "Not in a pool");
        require(
            userInfo[msg.sender].amount == 0,
            "Must withdraw all power before leaving pool"
        );
        userPool[msg.sender] = 0;
        emit LeavePool(msg.sender);
    }

    // 修改deposit，存入時更新礦池總算力
    function deposit(uint256 _amount) public {
        require(userPool[msg.sender] != 0, "Must join a pool to mine");
        require(block.timestamp >= startTime);

        uint256 poolId = userPool[msg.sender];

        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        // 更新用戶所在礦池的收益
        updatePoolReward(poolId);

        if (user.amount == 0 && _amount > 0) {
            activeMiners += 1;
        }
        Pool storage userPoolData = pools[poolId];
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(userPoolData.accRewardPerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            // 處理用戶收益和手續費
            _processUserRewardAndFee(pending, msg.sender, userPoolData.creator);
        }
        TransferHelper.safeTransferFrom(
            pool.powerToken,
            msg.sender,
            address(this),
            _amount
        );
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(userPoolData.accRewardPerShare).div(
            1e12
        );
        // 更新礦池總算力和分配點數
        pools[poolId].totalPower += _amount;
        updatePoolAllocPoint(poolId);
        emit Deposit(msg.sender, _amount);
    }

    // 修改withdraw，提取時更新礦池總算力
    function withdraw(uint256 _amount) public {
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool();

        uint256 poolId = userPool[msg.sender];
        // 更新用戶所在礦池的收益
        updatePoolReward(poolId);

        Pool storage userPoolData = pools[poolId];
        uint256 pending = user
            .amount
            .mul(userPoolData.accRewardPerShare)
            .div(1e12)
            .sub(user.rewardDebt);
        // 處理用戶收益和手續費
        _processUserRewardAndFee(pending, msg.sender, userPoolData.creator);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(userPoolData.accRewardPerShare).div(
            1e12
        );
        TransferHelper.safeTransfer(pool.powerToken, msg.sender, _amount);
        // 更新礦池總算力和分配點數
        if (poolId != 0) {
            pools[poolId].totalPower -= _amount;
            updatePoolAllocPoint(poolId);
        }
        if (user.amount == 0 && _amount > 0) {
            activeMiners -= 1;
        }
        emit Withdraw(msg.sender, _amount);
    }

    // 修改emergencyWithdraw，提取時更新礦池總算力
    function emergencyWithdraw() public {
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[msg.sender];
        TransferHelper.safeTransfer(
            pool.powerToken,
            address(msg.sender),
            user.amount
        );
        emit EmergencyWithdraw(msg.sender, user.amount);
        // 更新礦池總算力和分配點數
        uint256 poolId = userPool[msg.sender];
        if (poolId != 0) {
            pools[poolId].totalPower -= user.amount;
            updatePoolAllocPoint(poolId);
        }
        if (user.amount > 0) {
            activeMiners -= 1;
        }
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // 修改takerWithdraw，僅加入礦池時扣5%給礦池創建者，未加入礦池不能挖礦也不能提現
    function takerWithdraw() public {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();

        uint256 poolId = userPool[msg.sender];
        Pool storage userPoolData = pools[poolId];
        if (user.amount > 0) {
            require(poolId != 0, "Must join a pool to withdraw");

            // 更新用戶所在礦池的收益
            updatePoolReward(poolId);

            uint256 pending = user
                .amount
                .mul(userPoolData.accRewardPerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            // 處理用戶收益和手續費，手續費給礦池創建者
            _processUserRewardAndFee(pending, msg.sender, userPoolData.creator);
        }
        user.rewardDebt = user.amount.mul(userPoolData.accRewardPerShare).div(
            1e12
        );
    }

    // 處理用戶收益和手續費的內部函數
    function _processUserRewardAndFee(
        uint256 pending,
        address userAddress,
        address feeTo
    ) internal {
        if (pending > 0) {
            uint256 fee = (pending * 5) / 100; // 5% 手續費
            uint256 toUser = pending - fee;

            if (inviter[userAddress] != address(0) && inviteRewardRate > 0) {
                address inviterAddress = inviter[userAddress];
                uint256 userPower = userInfo[userAddress].amount;
                uint256 inviterPower = userInfo[inviterAddress].amount;

                if (inviterPower > 0 && userPower > 0) {
                    uint256 baseInviteReward = (pending * inviteRewardRate) /
                        INVITE_REWARD_RATE_BASIS_POINTS;
                    uint256 finalInviteReward = 0;

                    // 核心烧伤逻辑 inviterPower / userPower < burnRate / 1000
                    // (50*500/100)/1000
                    if (
                        burnRate > 0 &&
                        (inviterPower * BURN_RATE_BASIS_POINTS <
                            userPower * burnRate)
                    ) {
                        // 触发烧伤
                        finalInviteReward =
                            (baseInviteReward *
                                inviterPower *
                                BURN_RATE_BASIS_POINTS) /
                            (userPower * burnRate);
                    } else {
                        finalInviteReward = baseInviteReward;
                    }

                    if (finalInviteReward > 0) {
                        if (finalInviteReward > toUser) {
                            finalInviteReward = toUser;
                        }

                        toUser = toUser - finalInviteReward;
                        totalInviteReward[inviterAddress] = totalInviteReward[
                            inviterAddress
                        ].add(finalInviteReward);
                        safeSushiTransfer(inviterAddress, finalInviteReward);
                        emit InviteReward(
                            userAddress,
                            inviterAddress,
                            finalInviteReward
                        );
                    }
                }
            }

            if (toUser > 0) {
                userInfo[userAddress].totalReward = userInfo[userAddress]
                    .totalReward
                    .add(toUser);
                safeSushiTransfer(userAddress, toUser);
                emit TakeUserReward(userAddress, toUser);
            }

            if (fee > 0 && feeTo != address(0)) {
                safeSushiTransfer(feeTo, fee);
                emit TakeFee(feeTo, fee);
            }
        }
    }

    // 安全的sushi转账功能，以防万一如果舍入错误导致池没有足够的寿司。
    function safeSushiTransfer(address _to, uint256 _amount) internal {
        uint256 sushiBal = token.balanceOf(address(this));
        if (_amount > sushiBal) {
            token.transfer(_to, sushiBal);
        } else {
            token.transfer(_to, _amount);
        }
    }

    // 查詢活躍礦工數量
    function getActiveMiners() external view returns (uint256) {
        return activeMiners;
    }

    // 查詢用戶累計收益
    function getTotalReward(address user) external view returns (uint256) {
        return userInfo[user].totalReward;
    }

    // 查詢總分配點數
    function getTotalAllocPoint() external view returns (uint256) {
        return totalAllocPoint;
    }

    // 查詢礦池收益信息
    function getPoolRewardInfo(
        uint256 poolId
    )
        external
        view
        returns (
            uint256 allocPoint,
            uint256 accRewardPerShare,
            uint256 lastRewardTime,
            uint256 totalPower
        )
    {
        Pool storage pool = pools[poolId];
        return (
            pool.allocPoint,
            pool.accRewardPerShare,
            pool.lastRewardTime,
            pool.totalPower
        );
    }

    // 查詢礦池算力占比（以基點為單位，1% = 100基點）
    function getPoolPowerPercentage(
        uint256 poolId
    ) external view returns (uint256) {
        require(poolId > 0 && poolId < nextPoolId, "Invalid pool ID");
        require(pools[poolId].creator != address(0), "Pool does not exist");

        Pool storage pool = pools[poolId];
        if (totalAllocPoint == 0) {
            return 0;
        }
        return (pool.totalPower * 10000) / totalAllocPoint; // 10000 = 100%
    }

    // 手動更新指定礦池的分配點數（管理員功能）
    function updatePoolAllocPointManually(uint256 poolId) external {
        require(poolId > 0 && poolId < nextPoolId, "Invalid pool ID");
        require(pools[poolId].creator != address(0), "Pool does not exist");
        updatePoolAllocPoint(poolId);
    }

    // 批量更新礦池收益（可選，用於管理員或緊急情況）
    function updateMultiplePoolsReward(uint256[] calldata poolIds) external {
        for (uint256 i = 0; i < poolIds.length; i++) {
            uint256 poolId = poolIds[i];
            if (
                poolId > 0 &&
                poolId < nextPoolId &&
                pools[poolId].creator != address(0)
            ) {
                updatePoolReward(poolId);
            }
        }
    }
}
