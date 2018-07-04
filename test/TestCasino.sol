pragma solidity ^0.4.24;

import 'truffle/Assert.sol';
import 'truffle/DeployedAddresses.sol';
import '../contracts/Casino.sol';

contract TestCasino {

    //uint public initialBalance = 1 ether;

    function testOwnerOfDeployedContract() public {
        Casino casino = Casino(DeployedAddresses.Casino());
        address expectedOwner = msg.sender;
        // every public var has .var() getter 
        Assert.equal(casino.owner(),expectedOwner,"Owner should be set to deployer of contract");

    }

    function () public payable{

    }
}
