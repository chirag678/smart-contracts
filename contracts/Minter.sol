// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// The contract mints NFTs for people joining the waitlist
// 1. store the address and email (both should be unique)
// 2. store nft metadata in an NFT-Struct
// 3. Mint Function:
//    - create a new NFT -> _safeMint(_to, idOfNFT)

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import {Base64} from "./Base64.sol";

contract Minter is ERC721, ERC721URIStorage, Pausable, Ownable {
    using Strings for uint256;

    constructor() ERC721("Minter", "MNT") {}

    // waitlist NFT struct which stores email, name
    struct WaitlistNFT {
        string email; // unique
        string name;
    }

    WaitlistNFT[] private waitlist;

    mapping(address => uint) private addressToNFTIndex; // stores the unique ID of each NFT minted

    // function to add a new NFT to the waitlist
    function addToWaitlist(string memory _email, string memory _name)
        public
        returns (uint)
    {
        // add the new NFT to the waitlist
        waitlist.push(WaitlistNFT(_email, _name));
        //set token id
        uint _tokenId = waitlist.length - 1;
        // set the token id in the mapping
        addressToNFTIndex[msg.sender] = _tokenId;
        return _tokenId;
    }

    // function to format token URI
    function formatTokenURI(string memory imageURI, uint tokenId)
        public
        view
        returns (string memory)
    {
        string memory baseURL = "data:application/json;base64,";
        string memory json = string(
            abi.encodePacked(
                '{"name":"',
                waitlist[tokenId].name,
                '"email":"',
                waitlist[tokenId].email,
                '"image":"',
                imageURI,
                '"}'
            )
        );
        string memory jsonBase64Encoded = Base64.encode(bytes(json));
        return string(abi.encodePacked(baseURL, jsonBase64Encoded));
    }

    // function to convert svg string to base64 string
    function svgToImageURI(string memory __svg)
        public
        pure
        returns (string memory)
    {
        bytes memory svg = abi.encodePacked(
            '<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg" xmlns:xlink= "http://www.w3.org/1999/xlink"><circle cx="50" cy="50" r="40" stroke="green" stroke-width="4" fill="yellow" /></svg>'
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(
        address _to,
        string memory _email,
        string memory _name,
        string memory _svg
    ) public onlyOwner {
        uint _tokenId = addToWaitlist(_email, _name);
        string memory _imageURI = svgToImageURI(_svg);
        string memory tokenURIString = formatTokenURI(_imageURI, _tokenId);
        _safeMint(_to, _tokenId);
        _setTokenURI(_tokenId, tokenURIString);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
