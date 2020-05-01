pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "https://github.com/OpenZeppelin/openzeppelin-sdk/blob/master/packages/lib/contracts/Initializable.sol";
import { OpenZeppelinUpgradesECDSA as ECDSA } from "ECDSA.sol";

import "Relay.sol";
import "RelayTxStruct.sol";
import "ILockable.sol";

contract Adjudicator is RelayTxStruct, ILockable, Initializable {

    using ECDSA for bytes32;

    bool private locked;
    function isLocked() override public view returns(bool) {
        return locked;
    }

    enum CompensationStatus { NONE, PENDING, COMPENSATED, RESOLVED }

    mapping(bytes32 => CompensationRecord) public compensationRecords;

    Relay public relay;
    address public receiptSigner;

    uint public compensationPeriod;

    struct CompensationRecord {
        CompensationStatus status;
        uint deadline;
    }

    event RequestCompensation(bytes32 indexed relayTxId, address user, uint compensation, uint deadline);
    event CompensationIssued(bytes32 indexed relayTxId, address relayer, address user, uint compensation);
    event Locked();

    function initialize(Relay _relay, address _receiptSigner, uint _compensationPeriod) initializer public {
        relay = _relay;
        compensationPeriod = _compensationPeriod;
        receiptSigner = _receiptSigner;
    }
    
    function requestCompensation(RelayTx memory _relayTx, bytes memory _sig) public {

        require(_relayTx.relay == address(relay), "Mismatching relay address in the relay tx.");
        require(block.number > _relayTx.deadline, "The relayer still has time to finish the job.");
        require(_relayTx.compensation != 0, "No compensation promised to customer in relay tx.");

        uint intervalHalf = relay.getInterval()/2;

        require(_relayTx.deadline + intervalHalf > block.number, "Record may no longer exist in the registry.");

        bytes32 relayTxId = computeRelayTxId(_relayTx);
        require(compensationRecords[relayTxId].status == CompensationStatus.NONE, "Cannot request compensation twice.");

        require(receiptSigner == relayTxId.toEthSignedMessageHash().recover(_sig), "Relayer did not sign the receipt.");

        require(!checkDataRegistryRecord(relayTxId, _relayTx.deadline), "No compensation as relay transaction was completed in time.");

        compensationRecords[relayTxId].status = CompensationStatus.PENDING;
        compensationRecords[relayTxId].deadline = block.number + compensationPeriod;

        emit RequestCompensation(relayTxId, _relayTx.from, _relayTx.compensation, compensationRecords[relayTxId].deadline);
    }

    function checkDataRegistryRecord(bytes32 _relayTxId, uint _deadline) internal view returns (bool) {
        uint shards = relay.getTotalShards();
        for(uint i=0; i<shards; i++) {

            uint response = relay.fetchRecord(i, _relayTxId);

            if (response > 0) {
                if(_deadline >= response) {
                    return true;
                }
            }
        }

       return false;
    }

    function issueCompensation(RelayTx memory _relayTx) public payable {
        bytes32 relayTxId = computeRelayTxId(_relayTx);
        require(compensationRecords[relayTxId].status == CompensationStatus.PENDING, "Compensation record must be in PENDING mode.");
        require(_relayTx.compensation == msg.value, "Relayer must compensate the exact value.");
        compensationRecords[relayTxId].status = CompensationStatus.COMPENSATED;
        emit CompensationIssued(relayTxId, msg.sender, _relayTx.from, msg.value);
    }

    function withdrawCompensation(RelayTx memory _relayTx) public {
        bytes32 relayTxId = computeRelayTxId(_relayTx);
        require(compensationRecords[relayTxId].status == CompensationStatus.COMPENSATED, "Compensation record must be in COMPENSATED mode.");
        compensationRecords[relayTxId].status = CompensationStatus.RESOLVED;
        uint toSend = _relayTx.compensation;
        _relayTx.from.transfer(toSend);
    }

    function lock(RelayTx memory _relayTx) public {
        bytes32 relayTxId = computeRelayTxId(_relayTx);
        require(compensationRecords[relayTxId].status == CompensationStatus.PENDING, "CompensationStatus must still be PENDING.");
        require(block.number > compensationRecords[relayTxId].deadline, "Deadline for compensation must have passed.");

        // damnation.😱
        locked = true;
        emit Locked();
    }
}
