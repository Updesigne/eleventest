// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract VoteBuidl {
    struct Proposing_User {
        address addr;
        bytes32 name;
        uint agree;
        uint disagree;
    }

    struct Delegation {
        address addr;
        uint agree;
        uint disagree;
    }

    struct Voting {
        address addr;
        bool voted;
        uint index;
    }

    struct Delegation_Voting{
        address addr;
        bool voted;
        uint index;
    }

    address public immutable i_Owner;

    bytes32 Username;
    
     uint public deployTimer;
    uint public proposalTimer;
    uint public oneMinute= 1 minutes;
    Proposing_User[] public proposing__User;

    mapping(address => Voting) public voting__;
    mapping(address => Delegation_Voting) public Delegation_voting_;

    mapping(address => uint) private balance;


    // Funder & Address
    address[] public funders;

    mapping (address => uint) Addressfunders;
    // End
    
    uint public constant MINIMUM_USD =  50 * 1e18;

    Delegation[] public __delegation;

    function OnlyOwner() private view returns (bool) {
        return msg.sender == i_Owner;
    }

    modifier OnlyOwner_() {
       require(msg.sender==i_Owner);
        _;
    }

    error ProposalEnded();

    //For the freezing of addresses
    mapping(address => bool) FrozenAccount;

    event FrozenAccountEvent(address target, bool frozen);

    constructor() {
        i_Owner = msg.sender;
    }

    function Setname(bytes32 _name) public{
        Username = _name;
    }//////////////////////

    function ProposedUser() public {
       address _addr = msg.sender;
        
            proposing__User.push(
                Proposing_User({
                    addr: _addr,
                    name: Username,
                    agree: 0,
                    disagree: 0
                })
            );
       //////////

        //Duration of the proposals are for 7 days
        deployTimer = block.timestamp;
        proposalTimer = deployTimer + 7 days;
    }

    function DelegateRequest() public {
       address __addr = msg.sender;
    
            __delegation.push(
                Delegation({addr: __addr, 
                agree:0,
                disagree:0})
            );
        
    }

    function Vote_Agree(uint __index) public {
        uint timeVoted = block.timestamp;
        uint OneM = timeVoted + 1 minutes;
        address _addr = msg.sender;
        Voting storage Voter = voting__[msg.sender];
        require(!Voter.voted, "You have already voted");
        require(msg.sender==_addr);
       // require(!FreezeAccount && UnFreezeAccount);
        require(deployTimer < proposalTimer);
        if (deployTimer> (proposalTimer)) {
           revert ProposalEnded();
        }
         if(timeVoted > OneM){
            Voter.voted = false;
        }
        Voter.voted = true;
        proposing__User[__index].agree += 1;
        
    }

    function Vote_Disagree(uint __index) public {
    address _addr = msg.sender;
        Voting storage Voter = voting__[msg.sender];
        require(!Voter.voted, "You have already voted");
        require(msg.sender==_addr);
        //require(!FreezeAccount && UnFreezeAccount);
        require(block.timestamp < proposalTimer);
        if (block.timestamp > (proposalTimer)) {
           revert ProposalEnded();
        }
        Voter.voted = true;
        if(block.timestamp>1 minutes){
            Voter.voted = false;
        }
        proposing__User[__index].disagree += 1;
    }


    //Delegate Request Votes

    function Vote_Agree_Delegation(uint __index) public {
        address _addr = msg.sender;
        Delegation_Voting storage Voter = Delegation_voting_[msg.sender];
        require(!Voter.voted, "You have already voted");
        require(msg.sender==_addr);
        //require(!FreezeAccount && UnFreezeAccount);
        require(block.timestamp < proposalTimer);
        if (block.timestamp > (proposalTimer)) {
           revert ProposalEnded();
        }
        Voter.voted = true;
        if(block.timestamp > 1 days){
            Voter.voted = false;
        }
       // require(!FreezeAccount && UnFreezeAccount);
       
        
        __delegation[__index].agree += 1;
        }

    function Vote_Disagree_Delegation(uint __index) public {
        address _addr = msg.sender;
        Delegation_Voting storage Voter = Delegation_voting_[msg.sender];
        require(!Voter.voted, "You have already voted");
        require(msg.sender==_addr);
        //require(!FreezeAccount && UnFreezeAccount);
        require(block.timestamp < proposalTimer);
        if (block.timestamp > (proposalTimer)) {
           revert ProposalEnded();
        }
        Voter.voted = true;
        if(block.timestamp>1 minutes){
            Voter.voted = false;
        }
       // require(!FreezeAccount && UnFreezeAccount);
       
        
        __delegation[__index].disagree += 1;
    }

    // function FreezeAccount(address target, bool freeze) public OnlyOwner_ {
    //     FrozenAccount storage Froze = FrozenAccount[target];
    //     require(Froze==false);
    //     Froze = true;
    //     emit FrozenAccountEvent(target, freeze);
    // }

    // function UnFreezeAccount(address target, bool freeze) public OnlyOwner_ {
    //     FrozenAccount storage Froze = FrozenAccount[target];
    //     require(Froze==false);
    //     Froze = !freeze;
    //     emit FrozenAccountEvent(target, freeze);
    // }

    function ProposalFunding() public payable {
        require(balance[msg.sender] + msg.value >= balance[msg.sender]);
        balance[msg.sender] += msg.value;
        funders.push(msg.sender);
        Addressfunders[msg.sender] += msg.value;

    }

    function FundingBalance() OnlyOwner_ public view returns (uint) {
        uint balances = address(this).balance;
        return balances;
    }

    function MoveableFunds() public OnlyOwner_ {
        for (uint i = 0; i < funders.length; i++) {
            address funder = funders[i];
            Addressfunders[funder] = 0;       
        }
        // reset funders arrays
        funders = new address[](0);

       
        (bool successcall,) = payable(msg.sender).call{value: address(this).balance}("");
        require(successcall,"Call Failed");
    }

    fallback() external payable{
        ProposalFunding();
    }

    receive() external payable{
        ProposalFunding();
    }

   

     

}
