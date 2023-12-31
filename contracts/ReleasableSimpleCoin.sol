// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "./SimpleCoin.sol";

contract ReleasableSimpleCoin is SimpleCoin {
    bool public released = false;

    modifier isReleased() {
        if (!released) {
            revert();
        }
        _; // Control is passed back to the function here
    }

    constructor(uint256 _initialSupply) SimpleCoin(_initialSupply) {}

    function release() public {
        released = true;
    }

    function transfer(address _to, uint256 _amount) public override isReleased {
        super.transfer(_to, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) public override isReleased returns (bool) {
        super.transferFrom(_from, _to, _amount);
    }

}