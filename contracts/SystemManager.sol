// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "hardhat/console.sol";

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}


// FOR NOW: Options are limited to 2.
struct Market {
    uint id;
    string marketName;
    address owner;
    uint restrict;
    bool resolved;
    uint outcome; // 0: No outcome, 1: YES, 2: NO
}

struct Resolution {
    uint marketId;
    uint outcome;
    address resolver;
    uint yes;
    uint no;
}

contract SystemManager {
    // -1: Banned
    // 0: User
    // 1: Admin
    // 2: Headmaster
    mapping(address => uint) public restrictions;

    uint shareAdjuster = 2;    

    mapping(uint => Market) public markets;

    Resolution[] public resolutions;

    IERC20 public usdt;

    constructor(address _usdt) {
        restrictions[msg.sender] = 2;
        usdt = IERC20(_usdt);
    }

    function getBalance(address wallet) public view returns (uint) {
        return usdt.balanceOf(wallet);
    }

    function addAdmin(address member) public {
        require(restrictions[msg.sender] == 2,"You are not the headmaster.");
        restrictions[member] = 1;
    } 

    function addHeadmaster(address member) public {
        require(restrictions[msg.sender] == 2,"You are not the headmaster.");
        restrictions[member] = 2;
    }

    function sendUSDT(address recp, uint amount) public returns (bool){
        require(restrictions[msg.sender] >= 1,"You are not allowed to transfer USDT.");
        require(usdt.balanceOf(address(this)) >= amount, "Insufficient USDT balance.");
        require(usdt.transfer(recp, amount), "Transfer failed.");
        return true;
    }

    function receiveUSDT(address sender,uint amount) public returns (bool){
        require(restrictions[msg.sender] >= 1,"You are not allowed to transfer USDT.");
        require(usdt.balanceOf(sender) >= amount, "Insufficient USDT balance.");
        require(usdt.transferFrom(sender,address(this), amount), "Transfer failed.");
        return true;
    }
    
    function openResolution(uint marketID,uint outcome, address resolver) public returns (uint) {
        require(restrictions[msg.sender] >= 1,"Users cant make direct transactions.");
        require(markets[marketID].resolved == false, "Market already resolved.");
        require(outcome == 1 || outcome == 2, "Invalid outcome.");
        
        Resolution memory newResolution = Resolution({
            marketId: marketID,
            outcome: outcome,
            resolver: resolver,
            yes: 0,
            no:0 
        });

        resolutions.push(newResolution);
        return resolutions.length - 1; // Return the index of the new resolution
    }

    function voteResolution(uint resolutionID,uint outcome) public {
        require(restrictions[msg.sender] >= 1,"Users cant make direct transactions.");
        require(resolutionID < resolutions.length, "Invalid resolution ID.");
        require(outcome == 1 || outcome == 2, "Invalid outcome.");

        Resolution storage resolution = resolutions[resolutionID];
        require(resolution.outcome == 0, "Resolution already voted on.");

        if (outcome == 1) {
            resolution.yes += 1;
        } else if (outcome == 2) {
            resolution.no += 1;
        }

        resolutions[resolutionID] = resolution;
    }


    function closeResolution(uint resolutionID) public returns (string memory) {
        require(restrictions[msg.sender] >= 1,"Users cant make direct transactions.");
        require(resolutionID < resolutions.length, "Invalid resolution ID.");
        
        Resolution storage resolution = resolutions[resolutionID];
        require(resolution.outcome == 0, "Resolution already closed.");

        if (resolution.yes > resolution.no) {
            resolution.outcome = 1; // YES
            return "YES";
        } else if (resolution.no > resolution.yes) {
            resolution.outcome = 2; // NO
            return "NO";
        } else {
            resolution.outcome = 0; // No outcome
            return "None";
        }

    }
 
}
