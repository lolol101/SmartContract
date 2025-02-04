// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Bitcoin is ERC20 {
    uint256 private currencyPrice;
    address private creator;

    constructor() ERC20("Bitcoin", "BTC") {}

    function mintToCreator(address creator_) public {
        require(creator == address(0), "Creator is already defined");
        creator = creator_;
        _mint(msg.sender, 1000000000 ether);
    }

    function getCurrency() public pure returns(uint256) {
        return 29.580631 ether;
    }
}

contract XRP is ERC20 {
    uint256 private currencyPrice;
    address private creator;

    constructor() ERC20("XRP", "XRP") {}

    function mintToCreator(address creator_) public {
        require(creator == address(0), "Creator is already defined");
        creator = creator_;
        _mint(msg.sender, 1000000000 ether);
    }

    function getCurrency() public pure returns(uint256) {
        return 0.0002511 ether;
    }
}

contract Tether is ERC20 {
    uint256 private currencyPrice;
    address private creator;

    constructor() ERC20("Tether", "USDT") {}

    function mintToCreator(address creator_) public {
        require(creator == address(0), "Creator is already defined");
        creator = creator_;
        _mint(msg.sender, 1000000000 ether);
    }

    function getCurrency() public pure returns(uint256) {
        return 0.000300 ether;
    }
}

contract BinanceCoin is ERC20 {
    uint256 private currencyPrice;
    address private creator;

    constructor() ERC20("Binance Coin", "BNB") {}

    function mintToCreator(address creator_) public {
        require(creator == address(0), "Creator is already defined");
        creator = creator_;
        _mint(msg.sender, 1000000000 ether);
    }

    function getCurrency() public pure returns(uint256) {
        return 0.199594 ether;
    }
}