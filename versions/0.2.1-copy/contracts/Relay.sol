pragma solidity 0.6.2;
pragma experimental ABIEncoderV2;

import "./DataRegistry.sol";
import "./RelayTxStruct.sol";
import "./PaymentDeposit.sol";

contract Relay is DataRegistry, RelayTxStruct, PaymentDeposit {
    mapping(address => bool) public relayers;

    event RelayExecuted(bytes32 indexed relayTxId, bool success, address indexed from, address indexed to, uint gasUsed, uint gasPrice);
    event RelayerInstalled(address relayer);
    event RelayerUninstalled(address relayer);
    event OutOfCoins();


    function initialize(address _newOwner, uint _shardInterval) public initializer onlyOwner {
        PaymentDeposit.initialize(_newOwner);
        DataRegistry.initialize(_shardInterval);
    }
 
    function execute(RelayTx memory _relayTx, bool _gasRefund) public {
        uint gasStarted = gasleft();

        require(relayers[msg.sender], "Relayer must call this function.");
        require(_relayTx.relay == address(this), "Relay tx MUST be for this relay contract.");

        bytes32 relayTxId = computeRelayTxId(_relayTx);
        
        if(_relayTx.compensation != 0) {
            setRecord(relayTxId, block.number);
        }

        // what is happening here?
        require(gasleft() > (_relayTx.gasLimit + _relayTx.gasLimit / 63) + 1000, "Not enough gas supplied.");

        (bool success,) = _relayTx.to.call.gas(_relayTx.gasLimit)(_relayTx.data);

        uint gasUsed = gasStarted - gasleft() +
                            (msg.data.length * 16) +
                            2355 +
                            21000;

        if(_gasRefund) {
            gasUsed += (9000 + 1000);
            if(!msg.sender.send(gasUsed*tx.gasprice)) {
                emit OutOfCoins();
            }
        }

        emit RelayExecuted(relayTxId, success, _relayTx.from, _relayTx.to, gasUsed, tx.gasprice);
    }

    function installRelayer(address _relayer) onlyOwner public {
        require(!relayers[_relayer], "Relayer is already installed.");
        require(_relayer != address(this), "The relay contract cannot be installed as a relayer.");

        relayers[_relayer] = true;
        emit RelayerInstalled(_relayer);
    }

    function uninstallRelayer(address _relayer) onlyOwner public {
        require(relayers[_relayer], "Relayer must be installed.");

        relayers[_relayer] = false;
        emit RelayerUninstalled(_relayer);
    }
}