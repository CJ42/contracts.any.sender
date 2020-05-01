pragma solidity 0.6.2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-sdk/blob/master/packages/lib/contracts/Initializable.sol";


contract PaymentDeposit is Initializable, Ownable {

    event Deposit(address indexed sender, uint amount);

    event Withdraw(address indexed sender, uint amount);
    
    function initialize(address _newOwner) internal initializer onlyOwner {
        transferOwnership(_newOwner);
    }

    function depositFor(address recipient) public payable { 
        require(msg.value > 0, "No value provided to depositFor.");
        emit Deposit(recipient, msg.value);
    }

    function deposit() public payable {
        require(msg.value > 0, "No value provided to deposit.");
        emit Deposit(msg.sender, msg.value);
    }

    receive() external payable {
        require(msg.value > 0, "No value provided to fallback.");
        emit Deposit(msg.sender, msg.value);
    }

    function send(address payable recipient, uint amount) onlyOwner public {
        recipient.transfer(amount);
        emit Withdraw(recipient, amount);
    }

    function migrate(address payable recipient, uint amount, PaymentDeposit otherDeposit) onlyOwner public {
        require(address(this).balance >= amount, "Not enough balance to migrate.");
        otherDeposit.depositFor.value(amount)(recipient);
        emit Withdraw(recipient, amount);
    }
}