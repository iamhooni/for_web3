// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// 안건마다 id, description, accept나 reject 수, starttime 변수를 선언하면 너무 많아지기 때문에 구조체로 처리해준다. 
contract votesys {
    struct Proposal{
        uint256 id;
        string description;
        uint accept;
        uint reject;
        uint starttime;
    }

// 위에서 생성한 구조체의 변수들을 활용하여 이 컨트랙트가 다루는 proposal을 선언한다.
    Proposal public proposal;
// 해당 주소로 하여금 투표권이 있는자 bool을 활용하여 매핑한다.
    mapping(address => bool) public voter;
// 해당 주소가 투표를 했는지 bool을 활용하여 매핑한다.
    mapping(address => bool) public voted;

// constructor 함수는 해당 컨트랙트가 처음 배포될 때 딱 한번만 실행되는 함수로 해당 코드에서는 owner와 투표자들을 지정하기 위해 활용된다. 
    constructor(address[] memory voters) {
// 이 컨트랙트를 배포한 지갑 주소를 소유자로 즉 이 컨트랙트를 만든 사람을 소유자로 지정한다.
        owner = msg.sender;
// for문을 활용하여 address 배열에 있는 주소에 투표권을 준다.
        for (uint i = 0; i < voters.length; i++) {
// voter[voter 배열에서 i 번째 주소]에 있는 사람은 투표권자라고 표시한다.
            voter[voters[i]] = true;
        }
// 해당 변수들을 포함한 Proposal 구조체를 컨트랙트 안의 proposal 변수에 저장한다.
        proposal = Proposal(id, description, 0, 0, timestamp);
    }
// 투표할 때 찬성인지 반대인지 결과를 내기 위한 vote 함수를 선언한다.
    function vote(bool support) public {
// require을 통해 투표권자가 맞는지 투표를 진행했는지 확인한다.
        require(voter[msg.sender], "Not voter");
        require(!voted[msg.sender], "Already voted");
// block,timestamp(지금 블록 시각)과 proposal.starttime(투표를 시작한 시간) + 5분을 더해 지금 시간이 5분 이내면 통과되고 5분을 지났다면 투표가 종료되며 실행 취소된다.
        require(block.timestamp <= proposal.starttime + 5 minutes, "Voting ended");

// 입력한 support(accept or reject)에 따라 1씩 증가하도록 한다.
        voted[msg.sender] = true;
        if (support) {
            proposal.accept++;
        } else {
            proposal.reject++;
        }
    }

// 결과를 출력하기 위해 해당 함수를 선언하고 return 값은 pending, accepted, rejected 중 하나이기 때문에 문자열로 return 한다. 
    function getProposalStatus() public view returns (string memory) {
// 만약 투표를 시작한 지 5분이 지나지 않았다면 pending(진행 중)을 return 한다.
        if (block.timestamp <= proposal.starttime + 5 minutes) {
            return "Pending";
        } else {
// 투표 결과 accept와 reject 수를 비교하여 결과를 출력한다. 
            if (proposal.accept > proposal.reject) {
                return "Accepted";
            } else {
                return "Rejected";
            }
        }
    }
}