//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./TToken.sol";

/**
 * @title TTokenICO
 * @dev Test Initial Coin Offering for Test Token
 */
contract TTokenICO is TToken {
    enum State {beforeStart, running, afterEnd, halted}

    address public admin;
    address payable public deposit;
    uint256 public tokenPrice = 0.001 ether; // 1 ETH == 1000 TTKN
    uint256 public hardCap = 300 ether;
    uint256 public raisedAmount;
    uint256 public saleStart = block.timestamp;
    uint256 public saleEnd = block.timestamp + 604800; // ICO ends in a week
    uint256 public tokenTradeStart = saleEnd + 604800; // Token becomes transferable one week after the sale
    uint256 public maximumInvestment = 5 ether;
    uint256 public minimumInvestment = 0.1 ether;
    State public icoState;

    constructor(address payable _deposit) {
        deposit = _deposit;
        admin = msg.sender;
        icoState = State.beforeStart;
    }

    event Invest(address investor, uint256 value, uint256 ttokens);

    /**
     * @dev Restrict a function to be callable only for the admin
     */
    modifier adminOnly() {
        /// @dev Make sure that the origin address is the admin's
        require(msg.sender == admin);
        _;
    }

    /**
     * @notice Halt the ICO. Only the admin can do this.
     */
    function halt() public adminOnly {
        icoState = State.halted;
    }

    /**
     * @notice Resume the ICO. Only the admin can do this.
     */
    function resume() public adminOnly {
        icoState = State.running;
    }

    /**
     * @notice Change the deposit address. Only the admin can do this.
     * @param newDeposit New deposit address
     */
    function changeDepositAddress(address payable newDeposit) public adminOnly {
        deposit = newDeposit;
    }

    /**
     * @notice Get the current state of the ICO.
     * @return state The current state of the ICO
     */
    function getCurrentState() public view returns(State state){
        if(icoState == State.halted){
            return State.halted;
        }else if(block.timestamp < saleStart){
            return State.beforeStart;
        }else if(block.timestamp >= saleStart && block.timestamp <= saleEnd){
            return State.running;
        }else{
            return State.afterEnd;
        }
    }

    /**
     * @notice Invest eth in this contract and get TTKNs in return (1 ETH = 1000 TTKN)
     * @return success True if the function exits without errors
     */
    function invest() public payable returns(bool success){
        icoState = getCurrentState();

        /// @dev Make sure that the ICO is active
        require(icoState == State.running, "ICO isn't active");

        /// @dev Make sure that the investment is within the allowed range
        require(msg.value >= minimumInvestment && msg.value <= maximumInvestment, "Investment out of range");

        /// @dev Make sure that the investment doesn't exceed the cap
        require((raisedAmount + msg.value) <= hardCap, "Investment exceeds the ICO's cap");

        raisedAmount += msg.value;
        uint256 ttokens = msg.value / tokenPrice;

        balances[msg.sender] += ttokens;
        balances[founder] -= ttokens;
        deposit.transfer(msg.value);

        emit Invest(msg.sender, msg.value, ttokens);

        return true;
    }

    /**
     * @notice Transfers an amount of tokens to a given address.
     * @param to Recipient address
     * @param tokens Amount of tokens to transfer
     * @return success True if the function exits without errors
     */
    function transfer(address to, uint256 tokens) public override returns (bool success){
        /// @dev Make sure that the tokens aren't transferable until one week afther the ICO ends
        require(block.timestamp > tokenTradeStart, "TTKN will be available for transfers one week after the end of the ICO");

        super.transfer(to, tokens);

        return true;
    }

    /**
     * @notice Transfer tokens from another address' allowance.
     * @param from Address that owns the tokens
     * @param to Address that will receive the tokens
     * @return success True if the function exits without errors
     */
    function transferFrom(address from, address to, uint256 tokens) public override returns (bool success){
        /// @dev Make sure that the tokens aren't transferable until one week afther the ICO ends
        require(block.timestamp > tokenTradeStart, "TTKN will be available for transfers one week after the end of the ICO");

        super.transferFrom(from, to, tokens);

        return true;
    }

    /**
     * @notice Burn a given amount of tokens.
     * @return success True if the function exits without errors
     */
    function burn() public returns (bool success) {
        icoState = getCurrentState();

        /// @dev Only burn the tokens after the ICO is ended
        require(icoState == State.afterEnd);

        balances[founder] = 0;

        return true;
    }

    /**
     * @notice Invest eth in this contract and get TTKNs in return (1 ETH = 1000 TTKN)
     * @dev Calls the invest() function
     */
    receive() external payable {
        invest();
    }
}
