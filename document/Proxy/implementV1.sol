// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ImpleV1{
    address public implementation;//내가 연동할 주소 정보 
    uint public x;

    function inc() external {
        x +=1;
    }
}