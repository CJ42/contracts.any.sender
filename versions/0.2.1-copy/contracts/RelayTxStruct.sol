pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


contract RelayTxStruct {

    struct RelayTx {
        address to;
        address payable from;
        bytes data;
        uint deadline;
        uint compensation;
        uint gasLimit;
        address relay;
    }

    function computeRelayTxId(RelayTx memory self) public pure returns (bytes32) {
      return keccak256(abi.encode(self.to, self.from, self.data, self.deadline, self.compensation, self.gasLimit, self.relay));
    }
}