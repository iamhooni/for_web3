// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Multisig {
// owner 변수에 처음 배포한 사람의 주소(관리자)를 넣어줌
    address public owner;
// Proposal 구조체를 통해 id, to, value, data, accept, reject를 한 덩어리로 묶는다.
    struct Proposal {
        uint id;
        address to;
        uint value;
        bytes data;
        uint accept;
        uint reject;
    }

    Proposal public proposal;
// 해당 주소가 투표자가 맞는지 매핑을 통해 확인한다.
    mapping(address => bool) public voter;
// 해당 주소(사람)이 이미 이 안건에 대해 서명했는지를 매핑하여 중복 서명을 방지한다.
    mapping(address => bool) public signed;

// constructor 함수로 voter들의 주소를 배열로 받고, 다른 변수들의 정보를 받는다.
    constructor(address[] memory voters, uint _id, address _to, uint _value, bytes memory _data) {
// 이 컨트랙트를 배포한 사람을 owner로 저장한다.
        owner = msg.sender;
        for (uint i = 0; i < voters.length; i++) {
            voter[voters[i]] = true;
        }
// Proposal 구조체를 통해 변수를 통합한 안건 하나를 만든다. 뒤에 0, 0은 찬성 반대 표로 투표 시작전엔 0으로 시작한다.
        proposal = Proposal(_id, _to, _value, _data, 0, 0);
    }

// vote 함수로 투표를 진행하는데 bool support로 찬성, 반대표를 받는 것 뿐만아니라 bytes memory signature로 외부에서 만든 전자 서명도 받는다.
    function vote(bool support, bytes memory signature) public {
// digest는 안건 정보로 만든 고유한 해시값으로 해당 안건 정보를 하나로 묶고(abi.encodePacked()), keccak256으로 암호화 해시를 만든다.
        bytes32 digest = keccak256(abi.encodePacked(proposal.id, proposal.to, proposal.value, proposal.data));
// recover 함수로 서명을 복원하여 이 서명을 만든 사람이 누구인지 주소를 알아낸다. 이때 복원된 주소가 바로 signer이다. 
        address signer = recover(digest, signature);

// require 로 투표자가 맞는지와 중복 투표 여부를 확인한다.
        require(voter[signer], "Not voter");
        require(!signed[signer], "Already signed");

// 투표(서명)을 완료했다고 기록한다.
        signed[signer] = true;

// support 값이 찬성인지 반대인지 그 사람의 표를 반영한다. 
        if (support) {
            proposal.accept++;
        } else {
            proposal.reject++;
        }
    }
// recover 함수는 서명을 가지고 누가 서명했는지 주소를 복원하는데 지갑이 만든 서명과 원본 해시를 받아 서명한 사람이 누구인지 주소를 복원해서 돌려주는 역할을 한다.
    function recover(bytes32 digest, bytes memory signature) internal pure returns (address) {
// ECDSA 서명은 r,s,v 라는 파트로 구성되어 있는데 r,s,v가 있으면 서명한 사람의 주소를 복원할 수 있다. -> signature를 3개로 쪼갤 준비를 한다.
        bytes32 r;
        bytes32 s;
        uint8 v;
// assembly, mload, add를 활용하여 서명을 3개 파트로 나눈다. 
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
// eth 지갑은 메시지에 해당 prefix를 붙여서 해시하는데 digest 앞에 이 prefix를 붙여 다시 keccak256 해시를 만든다. 
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", digest));
// ecrecover는 ECDSA 서명을 복원하는 Ethereum 내장함수로 ethSignedMessageHash + v + s + r를 조합하여 signer의 주소를 찾는다. signer의 주소를 받아 진짜 투표권자가 맞는지 확인하기 위해 해당 주소를 복원한다.
        return ecrecover(ethSignedMessageHash, v, s, r);
    }
// execute 함수를 선언하여 안건에 적힌 트랜잭션을 실행하게 한다.
    function execute() public {
// require를 통해 찬성표가 반대표보다 많을 때 실행하게 한다.
        require(proposal.accept > proposal.reject, "Not enough accept votes");
// 트랜잭션이 실행되면 목표 주소로 돈을 보내게 된다.
        (bool success, ) = proposal.to.call{value: proposal.value}(proposal.data);
// require로 실패하면 롤백하게 한다.
        require(success, "Execution failed");
    }

    receive() external payable {}
}
