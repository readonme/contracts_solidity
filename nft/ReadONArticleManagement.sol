// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ReadONArticleManagement
 is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    mapping(string => Article) public articleData;

    struct Article {
        mapping(address => bool) audiences;
        address owner;
        string key;
        string arHash;
        bool status;
    }

    struct ArticleKey{
        string key;
        string arHash;
    }

    function AddOrUpdateArticle(string memory key,string memory arHash) public {
        Article storage article = articleData[arHash];
        if (!article.status) {
            article.owner = msg.sender;
            article.status=true;
        }else{
            require(article.owner==msg.sender,"ReadON:not author");
        }
        article.key = key;
        article.arHash = arHash;
    }

    function AddArticleAudience(string memory arHash,address audience) public {
        require(audience!=address(0),"ReadON:empty address");
        require(articleData[arHash].owner==msg.sender,"ReadON:not author");
        articleData[arHash].audiences[audience]=true;
    }

    function GetArticleInfo(string memory arHash) view public returns (ArticleKey memory ak) {
        if(articleData[arHash].audiences[msg.sender]){
            return ArticleKey(articleData[arHash].key,articleData[arHash].arHash);
        }
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }


    function initialize() public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
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
        override
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
