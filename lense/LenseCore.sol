// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";




contract LenseCore is
Initializable,
OwnableUpgradeable,
UUPSUpgradeable
{
    using SafeERC20 for IERC20;
    address public token;
    uint256 public feePrice;

    //upgrade info
    mapping(uint256 => uint256) public depositMap;//eg: tier => price

    event ClaimCredit(
        address indexed user
    );

    event Deposit(
        address indexed user,
        uint256 indexed tier,
        uint256 indexed amount
    );

    event SetToken(address indexed admin,address token);
    event SetFeePrice(address indexed admin,uint256 feePrice);
    event SetDepositMap(address indexed admin,uint256 indexed tier,uint256 indexed price);

    event PayForOnce(
        address indexed user
    );


    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    function setToken(address _token) external onlyOwner {
        require(_token!=address(0),"invalid token");
        token = _token;
        emit SetToken(msg.sender,_token);
    }

    function setFeePrice(uint256 _feePrice) external onlyOwner {
        feePrice = _feePrice;
        emit SetFeePrice(msg.sender,_feePrice);
    }

    function claimCredit() external {
        emit ClaimCredit(msg.sender);
    }

    function setDepositMap(uint256 tier,uint256 price) external onlyOwner {
        require(price>0, "invalid price");
        depositMap[tier] = price;
        emit SetDepositMap(msg.sender,tier,price);
    }

    function deposit(uint256 tier) external {
        uint256 amount = depositMap[tier];
        require(amount>0,"tier not exist");
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        emit Deposit(msg.sender,tier,amount);
    }

    function payForOnce() external {
        IERC20(token).safeTransferFrom(msg.sender, address(this), feePrice);
        emit PayForOnce(msg.sender);
    }

    function withdrawTokens(address beneficiary) public onlyOwner {

        IERC20(token).safeTransfer(
            beneficiary,
            IERC20(token).balanceOf(address(this))
        );

    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    override
    onlyOwner
    {}
}
