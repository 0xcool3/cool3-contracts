// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Compatibility.sol";
enum Operation {
    Call,
    DelegateCall
}

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract Governor is Compatibility {
    event ProposalCreated(
        uint indexed proposalIndex,
        address proposer,
        string title,
        uint256 startTime,
        uint256 endTime
    );
    event Voted(
        address indexed voter,
        uint proposalIndex,
        bool voteYes,
        uint256 tokens
    );
    event TokensWithdrawn(
        address indexed voter,
        uint proposalIndex,
        uint256 tokens
    );

    struct Proposal {
        string title;
        string description;
        bytes transactionData;
        bytes32 transactionDataHash;
        uint256 startTime;
        uint256 endTime;
        uint256 totalTokensYes;
        uint256 totalTokensNo;
        bool isExcuted;
    }

    Proposal[] public proposals;
    mapping(address => mapping(uint => uint256)) public voterTokens;

    uint256 public constant MINIMUM_DELAY = 1 days;
    uint256 public constant MINIMUM_VOTING_PERIOD = 1 weeks;

    string public name;
    IERC20 public token;
    uint256 public minimumTokensToCreateProposal;
    uint256 public minimumTotalVotes;

    constructor(
        string memory _name,
        IERC20 _token,
        uint256 _minimumTokensToCreateProposal,
        uint256 _minimumTotalVotes
    ) {
        initialize(
            _name,
            _token,
            _minimumTokensToCreateProposal,
            _minimumTotalVotes
        );
    }

    function initialize(
        string memory _name,
        IERC20 _token,
        uint256 _minimumTokensToCreateProposal,
        uint256 _minimumTotalVotes
    ) public {
        require(address(token) == address(0), "AlreadyInitialized");
        name = _name;
        token = _token;
        minimumTokensToCreateProposal = _minimumTokensToCreateProposal;
        minimumTotalVotes = _minimumTotalVotes;
    }

    function isProposalPassed(uint _proposalIndex) public view returns (bool) {
        require(_proposalIndex < proposals.length, "Proposal does not exist.");
        Proposal memory prop = proposals[_proposalIndex];

        bool isVotingEnded = block.timestamp > prop.endTime;
        bool hasEnoughVotes = prop.totalTokensYes + prop.totalTokensNo >=
            minimumTotalVotes;
        bool hasMoreYesVotes = prop.totalTokensYes > prop.totalTokensNo;

        return isVotingEnded && hasEnoughVotes && hasMoreYesVotes;
    }

    function createProposal(
        string memory _title,
        string memory _description,
        bytes memory _transactionData,
        bytes32 _transactionDataHash,
        uint256 _delay,
        uint256 _votingPeriod
    ) public {
        require(
            token.balanceOf(msg.sender) >= minimumTokensToCreateProposal,
            "Insufficient tokens to create a proposal."
        );
        require(_delay >= MINIMUM_DELAY, "Delay must be at least one day.");
        require(
            _votingPeriod >= MINIMUM_VOTING_PERIOD,
            "Voting period must be at least one week."
        );

        // Verify that the hash of the transaction data matches the provided hash
        require(
            keccak256(_transactionData) == _transactionDataHash,
            "Transaction data does not match provided hash."
        );

        uint256 startTime = block.timestamp + _delay;
        uint256 endTime = startTime + _votingPeriod;

        proposals.push(
            Proposal({
                title: _title,
                description: _description,
                transactionData: _transactionData,
                transactionDataHash: _transactionDataHash,
                startTime: startTime,
                endTime: endTime,
                totalTokensYes: 0,
                totalTokensNo: 0,
                isExcuted: false
            })
        );

        require(
            token.transferFrom(
                msg.sender,
                address(this),
                minimumTokensToCreateProposal
            ),
            "Failed to lock tokens"
        );

        voterTokens[msg.sender][
            proposals.length - 1
        ] += minimumTokensToCreateProposal;

        emit ProposalCreated(
            proposals.length - 1,
            msg.sender,
            _title,
            startTime,
            endTime
        );
    }

    function getProposalCount() public view returns (uint) {
        return proposals.length;
    }

    function getProposal(
        uint _proposalIndex
    )
        public
        view
        returns (
            string memory,
            string memory,
            bytes memory,
            bytes32,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        require(_proposalIndex < proposals.length, "Proposal does not exist.");
        Proposal memory prop = proposals[_proposalIndex];
        return (
            prop.title,
            prop.description,
            prop.transactionData,
            prop.transactionDataHash,
            prop.startTime,
            prop.endTime,
            prop.totalTokensYes,
            prop.totalTokensNo
        );
    }

    function vote(uint _proposalIndex, bool _voteYes, uint256 _tokens) public {
        require(_proposalIndex < proposals.length, "Proposal does not exist.");
        require(
            block.timestamp >= proposals[_proposalIndex].startTime,
            "Voting has not started yet."
        );
        require(
            block.timestamp < proposals[_proposalIndex].endTime,
            "Voting has ended."
        );
        require(
            token.transferFrom(msg.sender, address(this), _tokens),
            "Failed to lock tokens"
        );

        voterTokens[msg.sender][_proposalIndex] += _tokens;

        if (_voteYes) {
            proposals[_proposalIndex].totalTokensYes += _tokens;
        } else {
            proposals[_proposalIndex].totalTokensNo += _tokens;
        }
        emit Voted(msg.sender, _proposalIndex, _voteYes, _tokens);
    }

    function withdrawTokens(uint _proposalIndex) public {
        require(_proposalIndex < proposals.length, "Proposal does not exist.");
        require(
            block.timestamp > proposals[_proposalIndex].endTime,
            "Voting has not ended yet."
        );
        uint256 lockedTokens = voterTokens[msg.sender][_proposalIndex];
        require(lockedTokens > 0, "No tokens to withdraw.");

        voterTokens[msg.sender][_proposalIndex] = 0;
        require(
            token.transfer(msg.sender, lockedTokens),
            "Failed to transfer tokens."
        );
        emit TokensWithdrawn(msg.sender, _proposalIndex, lockedTokens);
    }

    function execute(uint256 _proposalIndex) external payable {
        require(_proposalIndex < proposals.length, "Proposal does not exist.");
        require(
            isProposalPassed(_proposalIndex),
            "Proposal has not passed yet."
        );

        Proposal memory prop = proposals[_proposalIndex];
        require(
            prop.isExcuted == false,
            " Proposal has already been executed."
        );
        bytes memory transactionData = prop.transactionData;

        address to;
        uint256 value;
        bytes memory data;
        Operation operation;

        (to, value, data, operation) = abi.decode(
            transactionData,
            (address, uint256, bytes, Operation)
        );

        if (operation == Operation.DelegateCall) {
            assembly {
                let success := delegatecall(
                    gas(),
                    to,
                    add(data, 0x20),
                    mload(data),
                    0,
                    0
                )
                returndatacopy(0, 0, returndatasize())
                switch success
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
            }
        } else {
            assembly {
                let success := call(
                    gas(),
                    to,
                    value,
                    add(data, 0x20),
                    mload(data),
                    0,
                    0
                )
                returndatacopy(0, 0, returndatasize())
                switch success
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
            }
        }
    }
}
