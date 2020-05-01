pragma solidity 0.6.2;
pragma experimental ABIEncoderV2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-sdk/blob/master/packages/lib/contracts/Initializable.sol";
import "ILockable.sol";

contract LockableDeposit is ILockable, Initializable, Ownable {
    ILockable[] public lockables;
    uint public withdrawalPeriod;
    bool public withdrawalInitiated;
    uint public withdrawalBlock;

    event RequestWithdraw();
    event CompleteWithdraw();
    event LockableAdded(address lockable);

    function initialize(address payable _newOwner, uint _withdrawalPeriod) initializer onlyOwner public {
        transferOwnership(_newOwner);
        withdrawalPeriod = _withdrawalPeriod;
    }

    function addLockable(ILockable lockable) onlyOwner public {
        for(uint i = 0; i < lockables.length; i++) {
            require(lockables[i] != lockable, "Lockable already added to deposit.");
        }

        require(!lockable.isLocked(), "Cannot add already locked lockable.");

        lockables.push(lockable);
        emit LockableAdded(address(lockable));
    }

    function isLocked() override public view returns(bool) {
        for(uint i = 0; i < lockables.length; i++) {
            if(lockables[i].isLocked()) return true;
        }
        return false;
    }

    function requestWithdrawal() onlyOwner public {
        withdrawalInitiated = true;
        withdrawalBlock = block.number + withdrawalPeriod;
        emit RequestWithdraw();
    }

    function withdraw() onlyOwner public {
        require(withdrawalInitiated, "Withdrawal is not initiated.");
        require(block.number > withdrawalBlock, "Withdrawal block has not been reached.");
        require(!isLocked(), "Deposit is locked.");

        withdrawalInitiated = false;
        withdrawalBlock = 0;

        uint balance = address(this).balance;
        payable(owner()).transfer(balance);
        emit CompleteWithdraw();
    }

    receive() external payable {}
}
