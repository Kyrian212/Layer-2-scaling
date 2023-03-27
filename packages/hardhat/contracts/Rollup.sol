//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@ethersproject/contracts/token/ERC20/IERC20.sol";
import "@optimism/sol-calls/contracts/OVM_CrossDomainMessenger.sol";


contract Rollup {
    address public l2Bridge;
    mapping(address => uint256) public balances;

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);

    constructor(address _l2Bridge) {
        l2Bridge = _l2Bridge;
    }



    function deposit(uint256 amount) external {
        // Transfer Celo tokens from the user to the Rollup contract
        IERC20 celo = IERC20(0x471EcE3750Da237f93B8E339c536989b8978a438);
        celo.transferFrom(msg.sender, address(this), amount);

        
        // Increase the user's balance on the Rollup contract
        balances[msg.sender] += amount;      
        emit Deposit(msg.sender, amount);


        // Send a message to the L2 bridge to notify it of the deposit
        OVM_CrossDomainMessenger(l2Bridge).sendMessage(
            abi.encodeWithSignature("deposit(address,uint256)", msg.sender, amount),
            0
        );
    }



    function withdraw(uint256 amount) external {
        // Check that the user has enough balance on the Rollup contract
        require(balances[msg.sender] >= amount, "insufficient balance");


        // Decrease the user's balance on the Rollup contract
        balances[msg.sender] -= amount;


        // Transfer Celo tokens from the Rollup contract to the user
        IERC20 celo = IERC20(0x471EcE3750Da237f93B8E339c536989b8978a438);
        celo.transfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);

        
        // Send a message to the L2 bridge to notify it of the withdrawal
        OVM_CrossDomainMessenger(l2Bridge).sendMessage(
            abi.encodeWithSignature("withdraw(address,uint256)", msg.sender, amount),
            0
        );
    }
}