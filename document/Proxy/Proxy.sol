// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Proxy {
    address public implementation;//내가 연동할 주소 정보 
    uint public x = 0;


    // 로직으로 사용할 주소 스마트 컨트랙트 주소 설정 
    function setImplementation(address _addr) external {
        implementation = _addr;
    }

    // 실제로 실행
    function _delegate(address _addr) internal {
        //요청받은 데이터값을 그대로 복사 
        // 그냥 이게 상대방에 있는 그 함수를 이컨트랙트로 가져와서 실행시킨것 
        assembly{
            calldatacopy(0,0,calldatasize())
            let result := delegatecall(gas(),_addr,0,calldatasize(),0,0)

            returndatacopy(0,0,returndatasize())

            switch result
            case 0 {
                revert(0,returndatasize())
            }
            default {
                return (0,returndatasize())
            }


        }
    }
    /* 
    실제로 사용자가 사용하는 정보가 컨트랙트에는 없는 정보이기에 fallback으로 실행한다 .
    그러니 흐름을 보자면 
    프록시 컨트랙트에다가 implement함수를 호출하게되면 프록시 컨트랙트에는 없는 함수이기에 
    fallback으로 넘어가게 되고 폴백에서 delegate를 호출하여  implement컨트랙트의 함수를 호출시킨다.
    
    */
    fallback() external payable { 
        _delegate(implementation);
    }
}