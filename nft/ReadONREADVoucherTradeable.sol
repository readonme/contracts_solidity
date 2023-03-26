// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ReadonERC721BurnableUpgradeable.sol";
import "./ReadonERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TradeableReadONREADVoucher is
    Initializable,
    ReadonERC721Upgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    ReadonERC721BurnableUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    uint256 public totalSupply;

    mapping(uint256 => Reward) public voucherData;
    struct Reward {
        uint256 amount;
        bool status;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function setClaimed(uint256 tokenId) external onlyRole(ADMIN_ROLE) {
        voucherData[tokenId].status=false;
    }

    function initialize() public initializer {
        __ERC721_init("Tradable READ Voucher: 5", "TRV5");
        __Pausable_init();
        __AccessControl_init();
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://readon-api.readon.me/v1/nft/arbitrum1/voucher/read/";
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function safeMint(
        address to,
        uint256 tokenId
    ) public onlyRole(MINTER_ROLE) {
        _safeMint(to, tokenId);
        voucherData[tokenId] = Reward(5 * 10 ** 18, true);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
        if (from == address(0)) {
            totalSupply++;
        }
        if (to == address(0)) {
            totalSupply--;
        }
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ReadonERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setName(string memory _tName) public override onlyRole(ADMIN_ROLE) {
        super.setName(_tName);
    }
    
    function setSymbol(string memory _tSymbol) public override onlyRole(ADMIN_ROLE) {
       super.setSymbol(_tSymbol);
    }

}
