// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ReadonERC721BurnableUpgradeable.sol";
import "./ReadonERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";


contract ReadONEssenceNFT is
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
    uint256 private currentIndex;

    address public collectCurrency;
    uint256 public collectPrice;
    string private baseURI;
    address payable private  recipient;



    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _currency,uint256 _price,string memory _baseUri,address payable _recipient) public initializer {
        collectCurrency = _currency;
        collectPrice = _price;
        baseURI=_baseUri;
        recipient = _recipient;
        __ERC721_init("ReadON Essence NFT", "REN");
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

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function collect() external payable {
        if(collectCurrency==address(0)){
            require(msg.value==collectPrice,"inssufient fee");
            AddressUpgradeable.sendValue(recipient, collectPrice);
        }else{
            require(IERC20Upgradeable(collectCurrency).transferFrom(msg.sender,recipient, collectPrice), 'unable to transfer');
        }
        _safeMint(msg.sender, currentIndex++);
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
