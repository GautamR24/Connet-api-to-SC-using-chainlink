// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/*

*importing chainlink contracts
 */
// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract BullBear is ERC721,ERC721Enumerable,ERC721URIStorage, AutomationCompatibleInterface, Ownable 
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 public interval;
    uint256 public lastTimeStamp;

    AggregatorV3Interface public priceFeed;
    int256 public currentPrice;

    //ipfs URIs for the dynaminc nft graphics/metadata

    string[] bullUrisIpfs = [
        "https://ipfs.io/ipfs/QmRXyfi3oNZCubDxiVFre3kLZ8XeGt6pQsnAQRZ7akhSNs?filename=gamer_bull.json",
        "https://ipfs.io/ipfs/QmRJVFeMrtYS2CUVUM2cHJpBV5aX2xurpnsfZxLTTQbiD3?filename=party_bull.json",
        "https://ipfs.io/ipfs/QmdcURmN1kEEtKgnbkVJJ8hrmsSWHpZvLkRgsKKoiWvW9g?filename=simple_bull.json"
    ];
    string[] bearUrisIpfs = [
        "https://ipfs.io/ipfs/Qmdx9Hx7FCDZGExyjLR6vYcnutUR8KhBZBnZfAPHiUommN?filename=beanie_bear.json",
        "https://ipfs.io/ipfs/QmTVLyTSuiKGUEmb88BgXG3qNC8YgpHZiFbjHrXKH3QHEu?filename=coolio_bull.json",
        "https://ipfs.io/ipfs/QmbKhBXVWmwrYsTPFYfroR2N7NAekAMxHUVg2CWks7i9qj?filename=simple_bear.json"
    ];

    event tokensUpdated(string marketTrend);

    
   

    constructor(uint256 updateInterval, address _priceFeed)
        ERC721("Bull&Bear", "BBTK")
    {
        //sets the keeper update interval
        interval = updateInterval;
        lastTimeStamp = block.timestamp;

        /*
         * set the price feed address to BTC/USD price Feed contract address : https://goerli.etherscan.io/address/0xA39434A63A52E749F02807ae27335515BA4b07F7
         * or the mockPriced Contract
         */

        priceFeed = AggregatorV3Interface(_priceFeed);
        currentPrice = getLatestPrice();
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        //defaults to gamer nft
        string memory defaultUri = bullUrisIpfs[0];
        _setTokenURI(tokenId, defaultUri);
    }


    /**
    below funtions need to overidden to work with chainlink */

    function checkUpkeep(bytes calldata ) external view override returns(bool upKeepNeeded, bytes memory /*performData*/){
        if(upKeepNeeded = (block.timestamp - lastTimeStamp) > interval){
            return (true,bytes(" "));
        }
        else{
            return (false,bytes(" "));
        }
    }

    function performUpkeep(bytes calldata) external override{
        if((block.timestamp - lastTimeStamp) > interval){
            lastTimeStamp = block.timestamp;
            int latestPrice = getLatestPrice();

            if(latestPrice == currentPrice){
                return;
            }
            if(latestPrice < currentPrice){
                //Bear
                updateAllTokenUris("bear");

            }else{
                //Bull
                updateAllTokenUris("bull");
            }
            currentPrice = latestPrice;
        }
    }

    function getLatestPrice() public view returns(int){
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) =priceFeed.latestRoundData();
        //example price returned 3034715771688
        return price;
    }

    function updateAllTokenUris(string memory trend) internal{
        if(compareStrings("bear", trend)){
            for(uint i=0;i<_tokenIdCounter.current();i++){
                _setTokenURI(i, bearUrisIpfs[0]);
            }

        }else{
            for(uint i=0;i<_tokenIdCounter.current();i++){
                _setTokenURI(i, bullUrisIpfs[0]);
            }
        }
        emit tokensUpdated(trend);
    }

    function setInterval(uint newInterval) public onlyOwner{
        interval = newInterval;
    }

    function setPriceFeed(address newFeed) public onlyOwner{
        priceFeed = AggregatorV3Interface(newFeed);
    }

    //Helpers

    function compareStrings(string memory a, string memory b) internal pure returns(bool){
        return(keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b))) ; 
    }


    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
