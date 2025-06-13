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
    string description;
    uint[2] vol;
    uint[2] weights;
    uint[2] ask;
    uint[2] bid;
    string[] names;
    address owner;
    uint restrict;
    bool isResolved;
    string resolveMsg;
}

contract SystemManager {
    // -1: Banned
    // 0: User
    // 1: Admin
    // 2: Headmaster
    mapping(address => uint) private restrictions;

    uint shareAdjuster = 2;    

    Market[] public markets;

    IERC20 public usdt;

    uint magnitudeConstant = 10000;

    constructor() {
        restrictions[msg.sender] = 2;
    }

    function getBalance(address wallet) public view returns (uint) {
        return usdt.balanceOf(wallet);
    }

    function addAdmin(address member) public {
        require(restrictions[msg.sender] == 2,"You are not the headmaster.");
        restrictions[member] = 1;
    } 


    function calculateWeightDist(uint[2] memory n) view private returns (uint[2] memory){
        uint E = 27813;
        
        uint B = 1;

        console.log(E**(n[0]/B));
        uint[2] memory weights;
        uint numerator0 = E ** (n[0]/B) * magnitudeConstant;
        uint numerator1 =  E ** (n[1]/B) * magnitudeConstant;
        console.log(numerator0);
        uint denominator = numerator0 + numerator1;
        console.log(denominator);

        // To avoid integer division truncation, multiply numerator first
        weights[0] = numerator0  * magnitudeConstant/ denominator;
        weights[1] = numerator1  * magnitudeConstant/ denominator;



        return weights;
    }

    function addMarket(string calldata name, string calldata description, string[] calldata options) public {
        require(restrictions[msg.sender] > 0,"Markets can only be added by admins.");
        require(options.length == 2,"Market options are limited to 2 for now.");

        uint[2] memory weightDist;
        uint[2] memory volInit;

        weightDist[0] = 0;
        weightDist[1] = 0;
        

        weightDist = calculateWeightDist(weightDist);

        console.log(weightDist[0],weightDist[1]);

        uint[2][2] memory prices = calculatePrice(weightDist,volInit);
        Market memory newMark = Market({
            id: 0,
            marketName: name,
            description: description,
            vol: volInit,
            weights: weightDist,
            ask: prices[0],
            bid:prices[1],
            names: options,
            owner: address(this),
            restrict:1,
            isResolved:false,
            resolveMsg:""
        });
        console.log(newMark.weights[0]);

        markets.push(newMark);
       
    }


    function resolveMarket(Market memory m,uint[] memory winnerWeight) public {
        require(m.restrict >= restrictions[msg.sender],"You are not eligible to resolve this market.");
        require(m.isResolved == false,"This market is already resolved.");



    }

    function listMarkets() public view returns (Market[] memory) {
        return markets;
    }

    function calculateMarketSpread(uint[2] memory vol) pure private returns (uint){
        
        uint spreadFactor = 950;
        uint a = spreadFactor / ((vol[0] + vol[1])**(2));
        uint b = 392;

        return (a + b);
    }

    function calculatePrice(uint[2] memory weights,uint[2] memory volume) pure private returns (uint[2][2] memory) {

        uint spread = calculateMarketSpread(volume);
        
        console.log(spread);
        uint[2][2] memory res;

        res[0] = [weights[0] + spread,weights[1]+spread];
        res[1] = [weights[0]-spread,weights[1]-spread];
        return res;
    }

 
}
