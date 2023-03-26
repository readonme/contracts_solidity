// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

interface ReadonNFT {
    function safeMint(address to, uint256 tokenId) external;
}

contract ReadONMysteryCaseRecruitable is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, PausableUpgradeable, AccessControlUpgradeable, ERC721BurnableUpgradeable, UUPSUpgradeable,ReentrancyGuardUpgradeable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    event Recruit(
        address indexed customer,
        uint256 indexed caseId,
        uint256 glassedId
    );

    uint256 public glassesCurrentIndex;
    uint256 public glassesMax;
    address public glassesToken; //glass
    uint256 public openTime;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC721_init("ReadON Mystery Case", "Case");
        __ERC721Enumerable_init();
        __Pausable_init();
        __AccessControl_init();
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        glassesCurrentIndex = 1;
        glassesMax = 5000;
    }

    function setToken(address _glasses) external onlyRole(DEFAULT_ADMIN_ROLE) {
        glassesToken = _glasses;
    }

    function setOpenTime(uint256 _openTime) external onlyRole(DEFAULT_ADMIN_ROLE) {
        openTime = _openTime;
    }

    function recruit(uint256 caseTokenId) public nonReentrant {
        require(block.timestamp > openTime, "ReadON:Event not started!");
        require(glassesCurrentIndex <= glassesMax, "ReadON:sold out!");
        burn(caseTokenId);
        ReadonNFT(glassesToken).safeMint(msg.sender, glassesCurrentIndex);
        emit Recruit(msg.sender, caseTokenId, glassesCurrentIndex);
        glassesCurrentIndex++;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://readon-api.xiequan.info/v1/nft/bsc/glasses/case/";
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function safeMint(address to, uint256 tokenId) public onlyRole(MINTER_ROLE) {
        _safeMint(to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
