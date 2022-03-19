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

    event Transfer(address indexed from, address indexed to, uint256 tokens);
}

/**
 * @title TToken
 * @dev ERC-20 compliant Test Token.
 */
contract TToken is ERC20Interface {
    string public name = "TToken";
    string public symbol = "TTKN";
    uint256 public decimals = 0;
    uint256 public override totalSupply;

    address public founder;
    mapping(address => uint256) public balances;

    constructor() {
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    /**
     * @notice Gets the token balance for a given address.
     * @param tokenOwner Address whose balance we want to find out.
     */
    function balanceOf(address tokenOwner) public view override returns (uint256 balance){
        return balances[tokenOwner];
    }


    /**
     * @notice Transfers an amount of tokens to a given address.
     * @param to Recipient address.
     * @param tokens Amount of tokens to transfer.
     */
    function transfer(address to, uint256 tokens) public override returns (bool success){
        // @dev Make sure that the origin address has enough tokens to send.
        require(balances[msg.sender] >= tokens);

        balances[to] += tokens;
        balances[msg.sender] -= tokens;

        emit Transfer(msg.sender, to, tokens);

        return true;
    }
}
