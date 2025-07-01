// 토큰은 그 자체로 데이터다 해당 토큰에서 누가 얼마나 가지고 있는지(balanceOf) 지금까지 얼마나 발행됐는지(totalSupply) 어디로 얼마가 이동했는지 라는 데이터들과 위 데이터들을 관리하는 규칙을 포함한다 mint - 데이터에 새 수량 추가 transfer - 내 잔액에서 뺴고 남한테 더하기 approve + transferFrom - 제 3자에게 꺼낼 권한 부여 컨트랙트는 토큳을 관리하는 프로그램이고 컨트랙트 함수는 API, 토큰은 그 프로그램이 다루는 데이터를 의미한다.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract iamhooni { 
// hooni라는 이름의 토큰을 발행하기 위해 contract를 사용한다. name 함수와 symbol 함수를 string memory와 함께 선언한다. returns (string)만 쓰면 에러가 뜨기 때문에 memory(함수 실행 중 임시로 값 저장)로 선언한다. 
    function name() public view returns (string memory) {
        return "hooni";
    }

    function symbol() public view returns (string memory) {
        return "HNI";
    }

//decimals 함수는 ERC20 토큰 표준에 따라 소수점 자리수를 알려주는 함수이다. 이더리움 기본 단위가 18자리라 return 18을 해줬다.
    function decimals() public view returns (uint8) {
        return 18;
    }

// mapping 함수는 특정 key에 맞춰 vlaue를 저장하는 연결표 역할을 한다. 지갑 주소라는 키에 uint256으로 얼마를 가지고 있는지 매핑하고 저장한다. 
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

// mint 함수는 토큰을 새로 찍어 총량을 늘리고 찍은 토큰을 특정 지갑 주소에 입금하는 함수다. mint 호출자로 하여금 원하는 주소에 원하는 수량의 토큰을 새로 만들어서 넣게 한다. totalSupply에 지금까지 발행된 전체 토큰 총량을 amount 만큼 더하고 발행된 토큰을 실제 받을 지갑 주소의 잔액에 더한다.(balanceOf[to] += amount;)
    function mint(address to, uint256 amount) public {
        totalSupply += amount;
        balanceOf[to] += amount;
    }

// transfer 함수는 내 지갑에서 다른 지갑으로 토큰을 보내는 함수로 balanceOf[msg.sender] 이 부분에서 msg.sender는 이 함수를 호출한 사람의 지갑 주소이고 balanceOf 함수로 인해 내 현재 잔액을 확인하고 require 함수를 통해 잔액이 보내려는 금액 이상인지 확인한다. 잔액이 충분하다면 지갑 잔액에서 _value 만큼 차감하고 balanceOf[_to] += value로 받는 사람 지갑 주소에 _value 만큼 더해 받는 사람 잔액이 늘어나게 한다.
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        return true;
    }

// 나머지 함수들은 실습 1단계에서 사용하지 않기 때문에 껍데기만 작성한다.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) { }
    function approve(address _spender, uint256 _value) public returns (bool success) { }
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) { }
}
