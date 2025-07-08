// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testFundMinimumDollarisFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testSenderisOwner() public view {
        // console.log(msg.sender);
        // console.log(address(this));
        // console.log(fundMe.i_owner());
        assertEq(fundMe.i_owner(), address(this));
    }

    function testAggregatorInterfaceVersion() public view {
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertTrue(version == 4);
    }
}
