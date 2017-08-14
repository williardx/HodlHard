pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract HodlToken is StandardToken {

    string public name = "Hodl Tokens"; 
    uint8 public decimals = 18;
    string public symbol = "HODL"; 
    string public version = "H0.1"; 
    
    mapping(address => Deposit[]) public ethDeposits;

    struct Deposit {
        bytes32 id;
        address depositor;
        uint amount;
        uint withdrawDate;
        bool isWithdrawn;
    }

    // We use DepositEvent as a hack to retrieve deposit IDs later on
    // since we can't return a dynamically-sized list of deposits
    event DepositEvent(
        address indexed depositor,
        bytes32 depositId,
        uint amount,
        uint withdrawDate
    );

    event WithdrawEvent(
        address indexed withdrawer,
        bytes32 depositId,
        uint amount
    );

    function() public payable {
        deposit();
    }

    function deposit() public payable returns (bool success) {
        require(msg.value > 0);
        uint withdrawDate = block.timestamp + (1 minutes);
        bytes32 depositId = sha256(uint(msg.sender) + withdrawDate);
        Deposit memory d = Deposit(
            depositId, msg.sender, msg.value, withdrawDate, false
        );
        ethDeposits[msg.sender].push(d);
        DepositEvent(msg.sender, depositId, msg.value, withdrawDate);
        balances[msg.sender] += msg.value;
        return true;
    }

    function _withdraw(Deposit d) internal returns (bool success) {
        require(balances[msg.sender] > 0 && msg.sender == d.depositor);
        
        // Don't let users withdraw before due date or withdraw the same
        // deposit twice
        if (block.timestamp < d.withdrawDate || d.isWithdrawn) {
            return false;
        }
        
        d.isWithdrawn = true;
        balances[msg.sender] -= d.amount;
        msg.sender.transfer(d.amount);
        WithdrawEvent(msg.sender, d.id, d.amount);
        return true;
    }

    function withdrawOne(bytes32 depositId) public returns (bool success) {
        Deposit[] deposits = ethDeposits[msg.sender];
        for (var i = 0; i < deposits.length; i++) {
            if (deposits[i].id == depositId) {
                return _withdraw(deposits[i]);
            }
        }
        return false;
    }

    function withdrawAll() public returns (bool success) {
        Deposit[] deposits = ethDeposits[msg.sender];
        for (var i = 0; i < deposits.length; i++) {
            _withdraw(deposits[i]);
        }
        return true;
    }

    function transfer(address to, uint256 value) returns (bool) {
        // Don't trade your tokens, just hodl!
        hodl();
    }

    function transferFrom(address from, address to, uint256 value) returns (bool) {
        // Don't trade your tokens, just hodl!
        hodl();
    }

    function hodl() {
        throw;
    }

}
