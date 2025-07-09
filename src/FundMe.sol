// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PriceConverter, AggregatorV3Interface} from "./PriceConverter.sol";

error Fundme__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    address private immutable i_owner;
    uint256 private constant MINIMUM_USD = 5 * 10 ** 18;

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert Fundme__NotOwner();
        _;
    }

    function fund() public payable {
        uint256 usdvalue = msg.value.getConversionRate(s_priceFeed);
        if (usdvalue <= MINIMUM_USD) {
            revert("You need to spend more ETH!");
        }
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public payable onlyOwner{
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!success) {
            revert("Call failed");
        }
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
    /**
     * Getter Functions
     */
    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }

    function getMinimumUSD() public pure returns (uint256) {
        return MINIMUM_USD;
    }

}
