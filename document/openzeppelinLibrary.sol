// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/Math.sol";

contract SafeMath {
    using Math for uint256;
    uint256 public a = 5;
    uint256 public b = 5;
    uint256 public c = 7;
    uint256 public d = 0;

    function add() public view returns(bool,uint256){
         return a.tryAdd(b);
    }

    function sub() public view returns(bool,uint256){
        return  a.trySub(b);
    }

    function sub2() public view returns(bool,uint256){
         return a.trySub(c);
    }

    function mul() public view returns(bool,uint256){
        return  a.tryMul(b);
    }

    function div() public view returns(bool,uint256){
        return  a.tryDiv(b);
    }

    function div2() public view returns(bool,uint256){
       return   a.tryDiv(d);
    }
}
