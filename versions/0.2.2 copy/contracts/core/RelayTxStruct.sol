pragma solidity 0.6.2;
pragma experimental ABIEncoderV2;

// @author Patrick McCorry & Chris Buckland (PISA Research)
// @title Relay
// @notice Relay tx data structure
contract RelayTxStruct {

    // @dev The relay transaction
    struct RelayTx {
        address payable from;
        uint96 compensation;
        address to;
        uint96 deadline;
        address relay;
        uint96 gasLimit;
        bytes data;
    }
    
    RelayTx relaytx;
    
    // @return Relay tx hash (bytes32)
    // @dev Pack the encoding when computing the ID.
    function computeRelayTxId(RelayTx memory self) public pure returns (bytes32) {
      return keccak256(
          abi.encode(
              self.from,
              self.compensation,
              self.to,
              self.deadline,
              self.relay,
              self.gasLimit,
              self.data
          )
      );
    }
    
    
    function computeRelayTxIdPacked(RelayTx memory self) public pure returns (bytes32) {
      return keccak256(
          abi.encode(
              self.from,
              self.compensation,
              self.to,
              self.deadline,
              self.relay,
              self.gasLimit,
              self.data
          )
      );
    }
    
    
    
    // testign layout in storage
    // before
    // tx cost: 173,542
    // exec cost: 146254
    // 
    // after optimisation:
    // tx cost: 118,839
    // exec cost: 91,423
    function newRelayTx(RelayTx memory self) public {
        relaytx = RelayTx({
            from: self.from,
            compensation: self.compensation,
            to: self.to,
            deadline: self.deadline,
            relay: self.relay,
            gasLimit: self.gasLimit,
            data: self.data
        });
    }
    
    // gas cost 1st:
    // tx cost: 31128
    // exec cost: 3840
    
/*    [
        "0xFA9bB9F357a7Ad9D86345e75118b16a98F61dA62", 
        "0xFA9bB9F357a7Ad9D86345e75118b16a98F61dA62", 
        "0xabcabc", 
        200000, 
        15000, 
        3000000, 
        "0xFA9bB9F357a7Ad9D86345e75118b16a98F61dA62"
    ]*/
    // ["0xFA9bB9F357a7Ad9D86345e75118b16a98F61dA62", "0xFA9bB9F357a7Ad9D86345e75118b16a98F61dA62", "0xabcabc", 200000, 15000, 3000000, "0xFA9bB9F357a7Ad9D86345e75118b16a98F61dA62"]
}