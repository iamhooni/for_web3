// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;


// bank 컨트랙트를 만들고 name, symbol, decimals, totalSupply들을 상태 변수로 선언한다. 상태 변수는 자동 getter를 만들어 주기 때문에 직접적으로 return을 안해줘도 된다. 추가적으로 상태 변수는 고정값이기 때문에 보통 바꿀일 없는 name, symbol, decimals에 사용해준다.
contract HooniToken {
    string public name = "hooni";
    string public symbol = "HNI";
    uint8 public decimals = 18;
    uint256 public totalSupply;

// key를 주소 value를 숫자로 하여 어느 주소가 토큰을 몇 개 가지고 있는지 매핑한다.
    mapping(address => uint256) public balanceOf;
// allowance[소유자][대리인] = 금액 형식으로 approve + transferFrom을 사용할 때 필요하기 때문에 이중 매핑한다. 예시로 A(나), B(지불자)가 있다고 치면 A가 approve(B, 100)을 하게 되면 allowance[A][B] = 100 이런식으로 기록된다.  
    mapping(address => mapping(address => uint256)) public allowance;

// mint 함수를 호출하여 원하는 양(amount)만큼 토큰을 새로 만든다. msg.sender(이 함수를 실행한 지갑 주소)와 balanceOf 함수를 사용하여 잔액에 amount 만큼 msg.sender의 잔액에 더한다. 추가적으로 컨트랙트 전체 발행량(totalSupply)도 amount 만큼 늘린다.
    function mint(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero!");
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
    }

//transfer를 활용하여 내가 가진 잔액만큼 출금하도록 하는데. 잔액이 충분한지는 require 함수를 활용하여 자신의 잔액에 맞게 출금하도록 한다. 추가로 가진 잔액보다 출금하려는 금액이 클 경우도 require를 통해 검증한다. 출금했다면 내가 가진 잔액에서 출금한 금액만큼 차감해준다.
   function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to == msg.sender, "You can only transfer to yourself");
        require(balanceOf[msg.sender] >= _value, "Not enough balance");

        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;

        return true;
    }

// 안쓰는 함수들은 빈 껍데기로 둔다.
    function approve(address _spender, uint256 _value) public returns (bool success) { }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) { }
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) { }
}