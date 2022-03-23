//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;
// ---------------------------------------
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIPS/eip-20
// ---------------------------------------

interface ERC20Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function transfer(address to, uint256 tokens) external returns (bool success);

    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

/**
 * @title TToken
 * @dev ERC-20 compliant Test Token
 */
contract TToken is ERC20Interface {
    string public name = "TToken";
    string public symbol = "TTKN";
    uint256 public decimals = 0;
    uint256 public override totalSupply;

    address public founder;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    constructor() {
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    /**
     * @notice Gets the token balance for a given address.
     * @param tokenOwner Address whose balance we want to find out
     * @return balance Balance of the given address
     */
    function balanceOf(address tokenOwner) public view override returns (uint256 balance){
        return balances[tokenOwner];
    }


    /**
     * @notice Transfers an amount of tokens to a given address.
     * @param to Recipient address
     * @param tokens Amount of tokens to transfer
     * @return success True if the function exits without errors
     */
    function transfer(address to, uint256 tokens) public virtual override returns (bool success){
        /// @dev Make sure that the origin address has enough tokens to send.
        require(balances[msg.sender] >= tokens, "Origin address has not enough tokens to transfer");

        balances[to] += tokens;
        balances[msg.sender] -= tokens;

        emit Transfer(msg.sender, to, tokens);

        return true;
    }

    /**
     * @notice Returns the allowance for a given account.
     * @param tokenOwner Address that owns the tokens
     * @param spender Address that is allowed to spend tokens in owner's name
     * @return allowedAmount Allowance from the tokenOwner to the spender
     */
    function allowance(address tokenOwner, address spender) public view override returns (uint256 allowedAmount){
        return allowed[tokenOwner][spender];
    }

    /**
     * @notice Allow an address to spend a given amount of tokens in the owner's name.
     * @param spender Address to be allowed to spend tokens
     * @param tokens Amount of tokens allowed to spend
     * @return success True if the function exits without errors
     */
    function approve(address spender, uint256 tokens) public override returns (bool success){
        /// @dev Make sure that the origin address has enough tokens.
        require(balances[msg.sender] >= tokens, "Origin address has not enough tokens");

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;
    }

    /**
     * @notice Transfer tokens from another address' allowance.
     * @param from Address that owns the tokens
     * @param to Address that will receive the tokens
     * @return success True if the function exits without errors
     */
    function transferFrom(address from, address to, uint256 tokens) public virtual override returns (bool success){
        /// @dev Make sure that the receiving address has enough allowance.
        require(allowed[from][to] >= tokens, "Receiving address has not enough allowance");

        /// @dev Make sure that the origin address has enough tokens.
        require(balances[from] >= tokens, "Origin address has not enough tokens");

        balances[from] -= tokens;
        balances[to] += tokens;

        allowed[from][to] -= tokens;

        emit Transfer(from, to, tokens);

        return true;
    }
}
