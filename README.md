# Any.Sender: UI + Contract Optimisations

This is a forked repo of the contracts for [any.sender](https://github.com/PISAresearch/docs.any.sender), the accountable transaction relaying service.

I have forked the repo to use it for my personal training / learning and contribute to the project.

THe objectives for this project so far are:

- build a UI in React
- analyse + optimise the contracts (for gas cost eventually)

# Contract Storage Layout

## RelayTxStruct.sol

|Slot Nb|Size    |Description|
|-------|--------|-----------|
|Slot 0 |20 bytes|`address to`|
|Slot 1 |20 bytes|`address from`|
|Slot 2 |variable, but 2 slots at least|`bytes data` + length of the bytes array|
|Slot 3 |32 bytes|`uint deadline`|
|Slot 4 |32 bytes|`uint compensation`|
|Slot 5 |32 bytes|`uint gas_limit`|
|Slot 6 |20 bytes|`address relay`|

# Performance / Gas Calculation

## Current 

**Computing the hash**
- Tx cost: 31,595
- Execution cost: 4,307

**Writing in storage**

Creating a variable of the struct type + a function to set this variable, we can calculate the gas cost for writing data in storage.

- Tx cost: 173,542
- Execution cost: 146,253

## Optimised

We can restructure the members of the struct to pack multiple values in one storage slot. This makes also writing operations to contract's storage cheaper.

```solidity
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
```

|Slot nb |20 bytes|12 bytes|
|--------|--------|-------|
|slot 0  |`from`  |`compensation`|
|slot 1  |`to`    |`deadline`|
|slot 2  |`relay` |`gas_limit`|
|slot 3  |`data`  |
