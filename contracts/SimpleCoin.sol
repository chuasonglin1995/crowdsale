// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract SimpleCoin {

    mapping (address => uint256) public coinBalance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(uint256 _initialSupply) { 
        coinBalance[msg.sender] = _initialSupply;
    }

    function transfer (address _to, uint256 _amount) public {
        // Checks that the sender has the amount of coins
        require(coinBalance[msg.sender] >= _amount);
        // Checks that an arithmetic overflow hasn't been produced on the recipient's balance during the transfer operation. 
        // (this can happen if the balance, because of the amount received from the sender, becomes bigger than uint256)
        require(coinBalance[_to] + _amount >= coinBalance[_to]);

        coinBalance[msg.sender] -= _amount;
        coinBalance[_to] += _amount;
    }
}



