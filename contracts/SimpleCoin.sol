// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "./Ownable.sol";

// Features
// 1. Allowance facility - allow an account to manage only a specified number of coins of another account
// 2. Freezing accounts

contract SimpleCoin is Ownable {

    mapping (address => uint256) public coinBalance;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event FrozenAccount (address target, bool freeze);

    constructor(uint256 _initialSupply) { 
        mint(owner, _initialSupply);
    }

    function transfer (address _to, uint256 _amount) public {
        // Checks that the sender has the amount of coins
        require(coinBalance[msg.sender] >= _amount);
        // Checks that an arithmetic overflow hasn't been produced on the recipient's balance during the transfer operation. 
        // (this can happen if the balance, because of the amount received from the sender, becomes bigger than uint256)
        require(coinBalance[_to] + _amount >= coinBalance[_to]);

        coinBalance[msg.sender] -= _amount;
        coinBalance[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
    }

    function authorise (address _authorizedAccount, uint256 _allowance) public returns (bool success) {
        allowance[msg.sender][_authorizedAccount] = _allowance;
        return true;
    }

    function transferFrom (address _from, address _to, uint256 _amount) public returns (bool success) {
        require(_to != address(0)); // prevent transfer to 0x0 address, which is default address if not specified explicitly
        require(coinBalance[_from] > _amount); 
        require(coinBalance[_to] + _amount >= coinBalance[_to]);
        require(_amount <= allowance[_from][msg.sender]); // checks unused allowance

        coinBalance[_from] += _amount;
        coinBalance[_to] += _amount;
        allowance[_from][msg.sender] -= _amount;

        emit Transfer(_from, _to, _amount);

        return true;
    }

    function mint (address _recipient, uint256 _mintedAmount) onlyOwner public {
        coinBalance[_recipient] += _mintedAmount;
        emit Transfer(owner, _recipient, _mintedAmount);
    }

    function freezeAccount (address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenAccount(target, freeze);
    }
}



