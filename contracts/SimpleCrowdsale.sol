// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "./ReleasableSimpleCoin.sol";
import "./Ownable.sol";

contract SimpleCrowdsale is Ownable {
    uint256 public startTime;
    uint256 public endTime;
    uint256 public weiTokenPrice;
    uint256 public weiInvestmentObjective;

    mapping (address => uint256) public investmentAmountOf;
    uint256 public investmentReceived;
    uint256 public investmentRefunded;

    bool public isFinalized;
    bool public isRefundingAllowed;

    ReleasableSimpleCoin public crowdsaleToken;

    constructor(uint256 _startTime, uint256 _endTime, uint256 _weiTokenPrice, uint256 _weiInvestmentObjective) payable {
        require(_startTime >= block.timestamp);
        require(_endTime >= _startTime);
        require(_weiTokenPrice != 0);
        require(_weiInvestmentObjective != 0);

        startTime = _startTime;
        endTime = _endTime;
        weiTokenPrice = _weiTokenPrice;
        weiInvestmentObjective = _weiInvestmentObjective;

        crowdsaleToken = new ReleasableSimpleCoin(0);
        isFinalized = false;
    }

    event LogInvestment(address indexed investor, uint256 value);
    event LogTokenAssignment(address indexed investor, uint256 numTokens);
    event Refund(address investor, uint256 value);

    function invest() public payable {
        require(isValidInvestment(msg.value));

        address investor = msg.sender;
        uint256 investment = msg.value;

        investmentAmountOf[investor] += investment;
        investmentReceived += investment;

        assignTokens(investor, investment);
        emit LogInvestment(investor, investment);
    }

    function isValidInvestment(uint256 _investment) internal view returns (bool) {
        bool nonZeroInvestment = _investment != 0;
        bool withinCrowdsalePeriod = block.timestamp >= startTime && block.timestamp <= endTime;

        return nonZeroInvestment && withinCrowdsalePeriod;
    }

    function assignTokens(address _beneficiary, uint256 _investment) internal {
        uint256 _numberOfTokens = calculateNumberOfTokens(_investment);
        crowdsaleToken.mint(_beneficiary, _numberOfTokens);
    }

    function calculateNumberOfTokens(uint256 _investment) internal returns (uint256) {
        return _investment / weiTokenPrice;
    }

    function finalize() onlyOwner public {
        if (isFinalized) revert();
        
        bool isCrowdsaleComplete = block.timestamp > endTime;
        bool isInvestmentObjectiveMet = investmentReceived >= weiInvestmentObjective;

        if (isCrowdsaleComplete) {
            if (isInvestmentObjectiveMet) {
                crowdsaleToken.release();
            } else {
                isRefundingAllowed = true;
            }

            isFinalized = true;
        }
    }

    function refund() public {
        if (!isRefundingAllowed) revert();

        address payable investor = payable(msg.sender);
        uint256 investment = investmentAmountOf[investor];
        if (investment == 0) revert();
        investmentAmountOf[investor] = 0;
        investmentRefunded += investment;
        emit Refund(msg.sender, investment);

        investor.transfer(investment);
    }
}