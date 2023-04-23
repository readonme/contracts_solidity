// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


contract ReadONProfile is
Initializable,
ERC721,
ERC721Enumerable,
Pausable,
AccessControl,
ERC721Burnable
{
    event registerName(address indexed register,uint256 indexed tokenId,string name);

    uint8 internal constant _MIN_HANDLE_LENGTH = 5;
    uint8 internal constant _MAX_HANDLE_LENGTH = 20;

    using Strings for uint256;

    mapping(uint256 => bool) private taken;
    mapping(uint256 => string) public getNameById;

    uint256 public startTime;
    uint256 public deadline;

    bytes32 public constant PAUSE_ROLE = keccak256("PAUSE_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor() ERC721("ReadON ZKSync Profile", "RZP") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        deadline = block.timestamp + 31536000; //default one year
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://readon-api.readon.me/v1/era/meta/";
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        string memory baseURI = _baseURI();
        return
        bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenId.toString()))
        : "";
    }

    function pause() public onlyRole(PAUSE_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSE_ROLE) {
        _unpause();
    }

    function avaliable(string calldata name) public view returns (bool) {
        return !taken[uint256(keccak256(bytes(name)))];
    }

    function setStartTime(uint256 _startTime) public onlyRole(ADMIN_ROLE) {
        startTime = _startTime;
    }

    function setDeadline(uint256 _deadline) public onlyRole(ADMIN_ROLE) {
        deadline = _deadline;
    }

    function batchMint(
        address[] calldata receivers,
        string[] calldata names
    ) public onlyRole(ADMIN_ROLE) {
        require(receivers.length == names.length, "ReadON:Not Match");
        for (uint256 index = 0; index < receivers.length; index++) {
            __mint(names[index], receivers[index]);
        }
    }

    function mint(string calldata name) external {
        __mint(name, msg.sender);
    }

    function __mint(string calldata name, address receiver) internal {
        require(block.timestamp > startTime, "ReadON:Not Started");
        require(block.timestamp < deadline, "ReadON:Expired");
        _requiresValidName(name);
        uint256 realId = uint256(keccak256(bytes(name)));
        require(!taken[realId], "ReadON:Name Taken");
        _safeMint(receiver, realId);
        taken[realId] = true;
        getNameById[realId] = name;
        emit registerName(receiver,realId,name);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(
        bytes4 interfaceId
    )
    public
    view
    override(ERC721, ERC721Enumerable, AccessControl)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _requiresValidName(string calldata name) internal pure {
        bytes memory byteHandle = bytes(name);
        require(
            byteHandle.length <= _MAX_HANDLE_LENGTH && byteHandle.length >= _MIN_HANDLE_LENGTH,
            "ReadON:INVALID_LENGTH"
        );

        uint256 byteHandleLength = byteHandle.length;
        for (uint256 i = 0; i < byteHandleLength; ) {
            bytes1 b = byteHandle[i];
            require(
                (b >= "0" && b <= "9") || (b >= "a" && b <= "z") || b == "_",
                "ReadON:INVALID_CHARACTER"
            );
        unchecked {
            ++i;
        }
        }
    }
}
