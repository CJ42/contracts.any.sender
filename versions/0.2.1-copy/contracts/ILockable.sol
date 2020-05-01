pragma solidity 0.6.2;


interface ILockable {

    function isLocked() external view returns(bool);
}