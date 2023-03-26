// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./ReadONEssenceNFT.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";


contract ReadONEssenceFactory is AccessControlUpgradeable,UUPSUpgradeable{
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(ReadONEssenceNFT).creationCode));
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {        
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    // mapping(address => mapping(address => address)) public getEssence;
    address[] public allEssences;

    event EssenceCreated(address indexed _currency, uint256 indexed _price,string baseURI, address pair, uint);


    function allPairsLength() external view returns (uint) {
        return allEssences.length;
    }

    function createEssence(address _currency,uint256 _price,string memory _baseUri,address payable _recipient) external onlyRole(ADMIN_ROLE) returns (address essence) {
        essence = address(new ReadONEssenceNFT{salt: keccak256(abi.encode(_currency, _price, _baseUri,_recipient))}());
        ReadONEssenceNFT(essence).initialize(_currency, _price, _baseUri,_recipient);
        allEssences.push(essence);
        emit EssenceCreated(_currency, _price,_baseUri, essence, allEssences.length);
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
        override(AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}