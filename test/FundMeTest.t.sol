// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 Init_Balance = 1000 ether;
    uint256 SendAmount = 0.01 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, Init_Balance);
    }

    function testFundMinimumDollarisFive() public view {
        assertEq(fundMe.getMinimumUSD(), 5e18);
    }

    function testSenderisOwner() public view {
        // console.log(msg.sender);
        // console.log(address(this));
        // console.log(fundMe.i_owner());
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testAggregatorInterfaceVersion() public view {
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertTrue(version == 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.prank(USER);
        fundMe.fund{value: SendAmount}();
        assertEq(fundMe.getAddressToAmountFunded(USER), SendAmount);
        // vm.expectRevert();
        // fundMe.fund{value: 0.00005 ether}();
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        fundMe.fund{value: SendAmount}();
        
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
        // vm.expectRevert();
        // fundMe.fund{value: 0.00005 ether}();
    }
}
