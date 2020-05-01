pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-sdk/blob/master/packages/lib/contracts/Initializable.sol";


contract DataShard is Initializable, Ownable {
   uint public creationBlock;

   mapping (bytes32 => uint) records;

   function initialize(address _newOwner) public initializer onlyOwner {
       creationBlock = block.number;
       transferOwnership(_newOwner);
   }

   function kill() public onlyOwner {
       selfdestruct(payable(owner()));
   }

   function getCreationBlock() public view returns (uint) {
       return creationBlock;
   }

   function fetchRecord(bytes32 _id) public view returns (uint) {
       return records[_id];
   }

   function setRecord(bytes32 _id, uint _timestamp) external onlyOwner {
      require(records[_id] == 0, "Record already set.");
      records[_id] = _timestamp;
   }
}

contract DataRegistry is Initializable {

   mapping (uint => address) public dataShards;
   uint public interval; // Approximately 6000 blocks a day
   uint constant TOTAL_SHARDS = 2; // Total number of data shards in rotation

   function getInterval() public view returns (uint) {
      return interval;
   }

   function getTotalShards() public pure returns (uint) {
      return TOTAL_SHARDS;
   }

   function initialize(uint _interval) internal initializer {
      interval = _interval;

      for(uint i = 0; i < TOTAL_SHARDS; i++) {
         DataShard ds = new DataShard();
         ds.initialize(address(this));
         dataShards[i] = address(ds);
      }
   }

   function resetDataShard() public returns (DataShard) {
      if(block.number - DataShard(dataShards[0]).getCreationBlock() >= interval) {
          address toDelete = dataShards[1];
          dataShards[1] = dataShards[0];
          DataShard ds = new DataShard();
          ds.initialize(address(this));
          dataShards[0] = address(ds);
          DataShard(toDelete).kill();
      }
   }

   function getLatestDataShard() public view returns (address) {
      return dataShards[0];
   }

   function fetchRecord(uint _dataShard, bytes32 _id) public view returns (uint) {
      if(dataShards[_dataShard] != address(0)) {
          DataShard rc = DataShard(dataShards[_dataShard]);
          return rc.fetchRecord(_id);
      }
   }

   function setRecord(bytes32 _id, uint _timestamp) internal  {
      address dataShardAddr = getLatestDataShard();
      DataShard rc = DataShard(dataShardAddr);
      rc.setRecord(_id, _timestamp);
   }
}
