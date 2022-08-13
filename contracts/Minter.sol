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
        private
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

    // function to change the name of a NFT in the waitlist
    function changeName(uint _tokenId, string memory _name)
        public
    {
        // check if the NFT is in the waitlist
        require(_tokenId < waitlist.length, "Invalid NFT ID");
        // change the name of the NFT
        waitlist[_tokenId].name = _name;
    }

    // function to format token URI
    function formatTokenURI(string memory imageURI, uint tokenId)
        private
        view
        returns (string memory)
    {
        string memory baseURL = "data:application/json;base64,";
        string memory json = string(
            abi.encodePacked(
                '{"name":"',
                waitlist[tokenId].name,
                '","email":"',
                waitlist[tokenId].email,
                '","image":"',
                imageURI,
                '"}'
            )
        );
        string memory jsonBase64Encoded = Base64.encode(bytes(json));
        return string(abi.encodePacked(baseURL, jsonBase64Encoded));
    }

    // function to convert svg string to base64 string
    function svgToImageURI(string memory _name, string memory _id)
        private
        pure
        returns (string memory)
    {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="290" height="500" viewBox="0 0 290 500" fill="url(#grad1)"><defs><linearGradient id="grad1" x1="0%" y1="0%" x2="0%" y2="100%"><stop offset="0%" style="stop-color:rgb(0,100,0);stop-opacity:1" /><stop offset="100%" style="stop-color:rgb(0,0,100);stop-opacity:1" /></linearGradient><filter id="f1"></filter><clipPath id="corners"><rect width="290" height="500" rx="42" ry="42"/></clipPath><path id="text-path-a" d="M40 12 H250 A28 28 0 0 1 278 40 V460 A28 28 0 0 1 250 488 H40 A28 28 0 0 1 12 460 V40 A28 28 0 0 1 40 12 z"/><path id="minimap" d="M234 444C234 457.949 242.21 463 253 463"/><filter id="top-region-blur"><feGaussianBlur in="SourceGraphic" stdDeviation="24"/></filter><linearGradient id="grad-up" x1="1" x2="0" y1="1" y2="0"><stop offset="0.0" stop-color="white" stop-opacity="1"/><stop offset=".9" stop-color="white" stop-opacity="0"/></linearGradient><linearGradient id="grad-down" x1="0" x2="1" y1="0" y2="1"><stop offset="0.0" stop-color="white" stop-opacity="1"/><stop offset="0.9" stop-color="white" stop-opacity="0"/></linearGradient><mask id="fade-up" maskContentUnits="objectBoundingBox"><rect width="1" height="1" fill="url(#grad-up)"/></mask><mask id="fade-down" maskContentUnits="objectBoundingBox"><rect width="1" height="1" fill="url(#grad-down)"/></mask><mask id="none" maskContentUnits="objectBoundingBox"><rect width="1" height="1" fill="white"/></mask><linearGradient id="grad-symbol"><stop offset="0.7" stop-color="white" stop-opacity="1"/><stop offset=".95" stop-color="white" stop-opacity="0"/></linearGradient><mask id="fade-symbol" maskContentUnits="userSpaceOnUse"><rect width="290px" height="200px" fill="url(#grad-symbol)"/></mask></defs><g clip-path="url(#corners)"><rect fill="c02aaa" x="0px" y="0px" width="290px" height="500px"/><rect style="filter: url(#f1)" x="0px" y="0px" width="290px" height="500px"/><g style="filter:url(#top-region-blur); transform:scale(1.5); transform-origin:center top;"><rect fill="none" x="0px" y="0px" width="290px" height="500px"/></g><rect x="0" y="0" width="290" height="500" rx="42" ry="42" fill="rgba(0,0,0,0)" stroke="rgba(255,255,255,0.2)"/></g><text text-rendering="optimizeSpeed"><textPath startOffset="-100%" fill="white" font-family="monospace" font-size="10px" xlink:href="#text-path-a">0x2260fac5e5542a773aa44fbcfedf7c193bc2c599 WBTC<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite"/> </textPath><textPath startOffset="0%" fill="white" font-family="monospace" font-size="10px" xlink:href="#text-path-a">0x2260fac5e5542a773aa44fbcfedf7c193bc2c599 WBTC<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite"/></textPath><textPath startOffset="50%" fill="white" font-family="monospace" font-size="10px" xlink:href="#text-path-a">0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 WETH<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite"/></textPath><textPath startOffset="-50%" fill="white" font-family="monospace" font-size="10px" xlink:href="#text-path-a">0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 WETH<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite"/></textPath></text><g mask="url(#fade-symbol)"><rect fill="none" x="0px" y="0px" width="290px" height="200px"/><text y="70px" x="32px" fill="white" font-family="monospace" font-weight="200" font-size="36px">',
            _name,
            '</text><text y="115px" x="32px" fill="white" font-family="monospace" font-weight="200" font-size="18px">Something</text></g><rect x="16" y="16" width="258" height="468" rx="26" ry="26" fill="rgba(0,0,0,0)" stroke="rgba(255,255,255,0.2)"/><g mask="url(#none)" style="transform:translate(72px,189px)"></g><g style="transform:translate(29px, 384px)"><rect width="98px" height="26px" rx="8px" ry="8px" fill="rgba(0,0,0,0.6)"/><text x="12px" y="17px" font-family="monospace" font-size="12px" fill="white"><tspan fill="rgba(255,255,255,0.6)">ID: </tspan>',
            _id,
            "</text></g></svg>"
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
        string memory _name
    ) public whenNotPaused {
        uint _tokenId = addToWaitlist(_email, _name);
        _safeMint(_to, _tokenId);
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

    function tokenURI(uint256 _tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        require(_tokenId < waitlist.length, "Invalid token");
        string memory _imageURI = svgToImageURI(waitlist[_tokenId].name, _tokenId.toString());
        string memory tokenURIString = formatTokenURI(_imageURI, _tokenId);
        return tokenURIString;
    }
}
