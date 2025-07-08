// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PriceConverter, AggregatorV3Interface} from "./PriceConverter.sol";

error Fundme__NotOwner();

contract FundMe {
    address public immutable i_owner;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert Fundme__NotOwner();
        _;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function fund() public payable {
        if (msg.value >= MINIMUM_USD) {
            revert("You need to spend more ETH!");
        }
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function withdraw() public payable {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
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
}
