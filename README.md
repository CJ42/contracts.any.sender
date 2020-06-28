# Any.Sender: UI + Contract Optimisations

This is a forked repo of the contracts for [any.sender](https://github.com/PISAresearch/docs.any.sender), the accountable transaction relaying service.

I have forked the repo to use it for my personal training / learning and contribute to the project.

THe objectives for this project so far are:

- build a UI in React
- analyse + optimise the contracts (for gas cost eventually)

# Smart Contracts Architecture

<a href="https://ibb.co/8gLmMTK"><img src="https://i.ibb.co/tpTHBkm/Screenshot-2020-06-28-at-11-30-33.png" alt="Screenshot-2020-06-28-at-11-30-33" border="0"></a>

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
|slot 3  |`data`  |`data`|

## Summary

Below are stats for running the two previous functions with the optimised struct. Both `abi.encode` and `abi.encodePacked` are compared.

Both normal and packed encoding do not affect to generated hash. The same hash is produced, whether `abi.encode` and `abi.encodePacked`.

We can conclude that packed encoding is not necessary, since the data is already tightly packed.
`abi.encodePacked` is only beneficial for the last variable `data`, by removing trailing zeros for instance between the data and bytes length.


**Computing the hash**

Parameters are:
- address: any
- compensation: 2,000,000
- deadline: 15,000
- gas_limit: 3,000,000

using **`abi.encode`**
||gas cost|Gas cost reduction (%)|
|------|------|-----|
|Tx cost|31,208|-1.22%|
|Execution cost|3,920|-8.98%|

using **`abi.encodePacked`**

||gas cost|gas cost reduction (%)|
|------|------|--------|
|Tx cost|31,186|-1.29%|
|Execution cost|3,898|-9.49%|


**Writing to storage**

||gas cost|gas cost reduction (%)|
|------|------|--------|
|Tx cost|118,839|-31.52%|
|Execution cost|91,423|-37.49%|

## Decoded input

The tuple looks like this (decoded input)

```
address /* ... */,
{
    "_hex": "compensation"
},
address /* ... */,
{
    "_hex": "deadline"
},
address /* ... */,
{
    "_hex": "gas_limit"
},
"data"
```
