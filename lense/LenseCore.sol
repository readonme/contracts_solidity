// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";




contract LenseCore is
Initializable,
OwnableUpgradeable,
UUPSUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
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

    event PayForOnce(
        address indexed user
    );


    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function setToken(address _token) external onlyOwner {
        token = _token;
    }

    function setFeePrice(uint256 _feePrice) external onlyOwner {
        feePrice = _feePrice;
    }

    function claimCredit() external {
        emit ClaimCredit(msg.sender);
    }

    function setDepositMap(uint256 tier,uint256 price) external onlyOwner {
        depositMap[tier] = price;
    }

    function deposit(uint256 tier) external {
        uint256 amount = depositMap[tier];
        require(amount>0,"tier not exist");
        IERC20Upgradeable(token).safeTransferFrom(msg.sender, address(this), amount);
        emit Deposit(msg.sender,tier,amount);
    }

    function payForOnce() external {
        IERC20Upgradeable(token).safeTransferFrom(msg.sender, address(this), feePrice);
        emit PayForOnce(msg.sender);
    }

    function withdrawTokens(address beneficiary) public onlyOwner {
        require(
            IERC20Upgradeable(token).transfer(
                beneficiary,
                IERC20Upgradeable(token).balanceOf(address(this))
            )
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
