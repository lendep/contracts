// SPDX-License-Identifier: MIT

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

    function decimals() external view returns (uint8);

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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev 已弃用。
     * 此函数存在与 {IERC20-approve} 中发现的问题类似的问题，不鼓励使用。
     *
     * 如果可能，请改用 {safeIncreaseAllowance} 和 {safeDecreaseAllowance}。
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
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
    using SafeERC20 for IERC20;

    // 每个用户的信息。
    struct UserInfo {
        uint256 amount; // 用户提供了多少 LP 代币。
        uint256 rewardDebt; // 用户已经获取的奖励
        uint256 totalReward; // 累计获得的奖励
        //
        // 我们在这里做一些花哨的数学运算。
        // 基本上，在任何时间点，有权授予用户但待分配的 SUSHI 数量为：
        //
        //   pending reward = (user.amount * pool.accSushiPerShare) - user.rewardDebt
        //
        // 每当用户将 LP 代币存入或提取到池中时。这是发生的事情：
        //   1. 池的 `accSushiPerShare`（和 `lastRewardBlock`）得到更新。
        //   2. 用户收到发送到他/她的地址的待处理奖励。
        //   3. 用户的“金额”得到更新。
        //   4. 用户的“rewardDebt”得到更新。
    }

    // 每个池的信息。
    struct PoolInfo {
        IERC20 lpToken; // LP 代币合约地址。
        uint256 decimals; // LP 代币的精度
        uint256 totalPower;
        uint256 allocPoint; // 分配给此池的分配点数。 SUSHI 分配每个块。
        uint256 lastRewardTime; // SUSHI 分配发生的最后一个块号。
        uint256 accSushiPerShare; // 质押一个LPToken的全局收益
    }


    // The SUSHI TOKEN!
    IERC20 public token;

    uint256 public powerPerPrice = 1e18; // 1 Power的价格
    uint256 public lastPriceUpdateTime; // 上次更新价格的时间
    uint256 public depreciationPerDayBps = 30; // 0.3% = 30/10000
    uint256 public constant PRICE_DENOMINATOR = 10000;

    // 初始每10分钟奖励50个
    uint256 public constant INITIAL_REWARD = 50e18; // 50个token，18位精度
    uint256 public BlockRewards = 50e18;
    uint256 public constant REWARD_INTERVAL = 600; // 10分钟=600秒
    uint256 public tokenPerSecond = INITIAL_REWARD / REWARD_INTERVAL;
    uint256 public constant HALVING_INTERVAL = 210000 * 600; // 2100000分钟=126000000秒

    uint256 private constant INVITE_REWARD_RATE_BASIS_POINTS = 10000;
    uint256 private constant BURN_RATE_BASIS_POINTS = 1000;
    uint256 public inviteRewardRate = 500; // 邀请人奖励比例 1000/10000 = 10%
    uint256 public burnRate = 1000; // 烧伤比例门槛 1000/1000 = 100% 邀请人和下级的算力比必须大于等于这个比例才能拿满奖励
    address public fundAddress; // 基金地址
    

    
    address public operator;
    uint256 public nextNodeId = 1;
    bool public createNodePublic = false; // 是否公开创建矿池
    mapping(uint256 => address) public nodes;
    mapping(address => uint256) public userNode; 

    mapping(address => address) public inviter; //邀请人
    mapping(address => uint256) public inviteCount; //邀请人好友数
    mapping(address => uint256) public totalInviteReward; //累计奖励

    // 每个池的信息。
    PoolInfo[] public poolInfo;
    // 每个持有 LP 代币的用户的信息。
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(address => uint256) public Pid;
    // 总分配点数。 必须是所有池中所有分配点的总和。
    uint256 public totalAllocPoint = 0;
    // SUSHI 挖矿开始时的时间戳。
    uint256 public startTime;

    event Deposit(
        address indexed user,
        uint256 indexed pid,
        uint256 amount,
        uint256 powerAmount
    );
    event Withdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount,
        uint256 powerAmount
    );
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount,
        uint256 powerAmount
    );
    event BindInviter(address indexed user, address indexed inviter);
    event InviteReward(
        uint256 indexed pid,
        address indexed user,
        address indexed inviter,
        uint256 amount
    );
    event TakeUserReward(
        uint256 indexed pid,
        address indexed user,
        uint256 amount
    );
    
    event OperatorSet(address indexed operator);

    constructor(address _token, uint256 _startTime, address _fundAddress) {
        token = IERC20(_token);
        startTime = _startTime;
        fundAddress = _fundAddress;
        lastPriceUpdateTime = startTime;
    }

    function setInviteRewardRate(uint256 _inviteRewardRate) external onlyOwner {
        require(
            _inviteRewardRate <= INVITE_REWARD_RATE_BASIS_POINTS,
            "Invalid invite reward rate"
        );
        inviteRewardRate = _inviteRewardRate;
    }

    modifier onlyOperator() {
        require(msg.sender == operator, "Not operator");
        _;
    }

    function setOperator(address _operator) external onlyOwner {
        operator = _operator;
        emit OperatorSet(_operator);
    }

    function setCreateNodePublic() external onlyOwner {
        createNodePublic = !createNodePublic;
    }

    function CreateNode(address user) public returns (uint256){
        if(!createNodePublic)
        {
            require(msg.sender == operator,"Not operator");
        }
        uint256 NodeId = nextNodeId++;

        nodes[NodeId]  = user;
        return NodeId;
    }

    function joinNode(uint256 id) public returns (bool){
        require(nodes[id] != address(0),"node not exist");
        userNode[msg.sender] = id;
        return true;
    }

    function transferNode(uint256 id,address user) public returns (bool){
        require(nodes[id] != msg.sender,"permission denied");
        nodes[id] = user;
        return true;
    }


    function setFundAddress(address _fundAddress) external onlyOwner {
        require(_fundAddress != address(0), "Invalid fund address");
        fundAddress = _fundAddress;
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

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // 将新的 lp 添加到池中。 只能由所有者调用。
    // XXX 不要多次添加相同的 LP 令牌。 如果你这样做，奖励会被搞砸。
    // _allocPoint 分配点
    // _withUpdate 是否马上更新所有池的奖励变量。 小心汽油消费！
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        require(Pid[address(_lpToken)] == 0); //防呆，避免重复添加池

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardTime = block.timestamp > startTime
            ? block.timestamp
            : startTime;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                decimals:10 ** _lpToken.decimals(),
                allocPoint: _allocPoint,
                lastRewardTime: lastRewardTime,
                accSushiPerShare: 0,
                totalPower: 0
            })
        );

        Pid[address(_lpToken)] = poolInfo.length;
    }

    // 更新给定池的 token 分配点。 只能由所有者调用。
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // 查看功能以查看前端待处理的 SUSHI。
    function pendingSushi(
        uint256 _pid,
        address _user
    ) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSushiPerShare = pool.accSushiPerShare;
        if (block.timestamp > pool.lastRewardTime && pool.totalPower != 0) {
            // 倍数
            uint256 timeElapsed = block.timestamp - pool.lastRewardTime;
            // sushi奖励 = 倍数x每块产出x池的分配点/总的分配点
            uint256 sushiReward = timeElapsed
                .mul(currentRewardPerSecond())
                .mul(pool.allocPoint)
                .div(totalAllocPoint);
            // 每股累积 SUSHI = 当前值+（sushi奖励x1万亿/LP流动性）
            accSushiPerShare = accSushiPerShare.add(
                sushiReward.mul(1e12).div(pool.totalPower)
            );
        }
        return user.amount.mul(accSushiPerShare).div(1e12).sub(user.rewardDebt);
    }

    // 更新所有池的奖励变量。 小心汽油消费！
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // 更新给定池的奖励变量以保持最新。
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardTime) {
            return;
        }
        if (pool.totalPower == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }
        uint256 timeElapsed = block.timestamp - pool.lastRewardTime;
        uint256 sushiReward = timeElapsed
            .mul(currentRewardPerSecond())
            .mul(pool.allocPoint)
            .div(totalAllocPoint);
        token.mint(address(this), sushiReward);
        // 给masterchef铸币 奖励数额
        pool.accSushiPerShare = pool.accSushiPerShare.add(
            sushiReward.mul(1e12).div(pool.totalPower)
        );
        pool.lastRewardTime = block.timestamp;
    }

    function bindInviter(address _inviter) external {
        require(inviter[msg.sender] == address(0), "Already bound");
        require(_inviter != address(0), "Invalid inviter");
        require(inviter[_inviter] != msg.sender, "Inviter cannot be same as user");
        require(_inviter != msg.sender, "Inviter cannot be self");

        inviter[msg.sender] = _inviter;
        inviteCount[_inviter] += 1;
        emit BindInviter(msg.sender, _inviter);
    }

    function updatePrice() public {
        if (block.timestamp <= lastPriceUpdateTime) return;

        uint256 elapsed = block.timestamp - lastPriceUpdateTime;

        // 每秒线性摊：powerPerPrice += powerPerPrice * (bps/天) * 秒数 / 86400
        uint256 delta = (powerPerPrice * depreciationPerDayBps * elapsed) /
            (PRICE_DENOMINATOR * 86400);

        if (delta > 0) {
            powerPerPrice += delta;
        }
        lastPriceUpdateTime = block.timestamp;
        //每天自动提现一次
        // if (block.timestamp - lastwithdrawTime >= 86400) {
        //     withdraw();
        // }
    }

    // 将 LP 代币存入 MasterChef 以分配 SUSHI。
    function deposit(uint256 _pid, uint256 _amount) public {
        require(_amount > 0, "Invalid amount");
        require(userNode[msg.sender] >0 ,"ust join a pool to mine");

        updatePrice();
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(pool.accSushiPerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            _processUserRewardAndFee(_pid, pending, msg.sender);
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );

        // 更新矿池总算力
        uint256 powerAmount = (_amount * powerPerPrice) / pool.decimals;
        pool.totalPower = pool.totalPower.add(powerAmount);
        user.amount = user.amount.add(powerAmount);
        user.rewardDebt = user.amount.mul(pool.accSushiPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount, powerAmount);
    }

    // 从 MasterChef 中提现 LP 代币。
    function withdraw(uint256 _pid, uint256 _powerAmount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(_powerAmount > 0, "Invalid power amount");
        require(user.amount >= _powerAmount, "withdraw: not good");
        updatePrice();
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accSushiPerShare).div(1e12).sub(
            user.rewardDebt
        );
        _processUserRewardAndFee(_pid, pending, msg.sender);

        // 更新矿池总算力
        uint256 _amount = (_powerAmount * pool.decimals) / powerPerPrice;
        pool.totalPower = pool.totalPower.sub(_powerAmount);
        user.amount = user.amount.sub(_powerAmount);
        user.rewardDebt = user.amount.mul(pool.accSushiPerShare).div(1e12);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount, _powerAmount);
    }

    // 提现而不关心奖励。 仅限紧急情况。
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount > 0, "Invalid user amount");

        uint256 _amount = (user.amount * pool.decimals) / powerPerPrice;
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit EmergencyWithdraw(msg.sender, _pid, _amount, user.amount);
        // 更新矿池总算力
        pool.totalPower = pool.totalPower.sub(user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // 直接领取收益
    function takerWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(pool.accSushiPerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            _processUserRewardAndFee(_pid, pending, msg.sender);
        }
        user.rewardDebt = user.amount.mul(pool.accSushiPerShare).div(1e12);
    }

    // 处理用户收益和手续费的内部函数
    function _processUserRewardAndFee(
        uint256 _pid,
        uint256 pending,
        address userAddress
    ) internal {
        uint256 baseInviteReward = (pending * inviteRewardRate) /
            INVITE_REWARD_RATE_BASIS_POINTS;
        uint256 toUser = pending - baseInviteReward;

        if (inviter[userAddress] != address(0) && inviteRewardRate > 0) {
            address inviterAddress = inviter[userAddress];
            uint256 userPower = userInfo[_pid][userAddress].amount;
            uint256 inviterPower = userInfo[_pid][inviterAddress].amount;

            if (inviterPower > 0 && userPower > 0) {
                uint256 finalInviteReward = 0;

                if (
                    burnRate > 0 &&
                    (inviterPower  < userPower)
                ) {
                    // 触发烧伤
                    finalInviteReward =
                        (baseInviteReward * inviterPower ) / userPower;

                    uint256 burnAmount = baseInviteReward - finalInviteReward;
                    if (burnAmount > 0) {
                        safeSushiTransfer(fundAddress, burnAmount);
                    }
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
                        _pid,
                        userAddress,
                        inviterAddress,
                        finalInviteReward
                    );
                }
            }
        }

        if (toUser > 0) {
            userInfo[_pid][userAddress].totalReward = userInfo[_pid][
                userAddress
            ].totalReward.add(toUser);
            safeSushiTransfer(userAddress, toUser);
            emit TakeUserReward(_pid, userAddress, toUser);
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

    function takeWithdrawFee(uint256 _pid) public {
        PoolInfo memory pool = poolInfo[_pid];
        uint256 balance = pool.lpToken.balanceOf(address(this));
        uint256 totalRefundBalance = (pool.totalPower * pool.decimals) /
            powerPerPrice;
        if (balance > totalRefundBalance) {
            pool.lpToken.safeTransfer(
                address(fundAddress),
                balance - totalRefundBalance
            );
        }
    }
}
