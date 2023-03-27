//SPDX-License-Identifier: MIT
 pragma solidity ^0.8.0;

import "@celo-org/mento/contracts/mento/MentoBridge.sol";
import "@celo-org/mento/contracts/mento/MentoToken.sol";


contract MySidechain {
    MentoBridge public bridge;
    MentoToken public token;

    constructor(address _bridgeAddress) {
        bridge = MentoBridge(_bridgeAddress);
        token = new MentoToken("My Sidechain Token", "MST");
    }


    function deposit(uint256 amount) public {
        token.mint(msg.sender, amount);
        token.approve(address(bridge), amount);
        bridge.deposit(token, amount);
    }

    
    function withdraw(uint256 amount) public {
        bridge.withdraw(token, amount);
        token.burn(msg.sender, amount);
    }
}
