// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Fomo3D is ReentrancyGuard, Pausable{
    using SafeMath for uint256;

    // 最后⼀个购买钥匙的参与者的地址。
    address payable public lastBuyer;
    // 最后⼀次购买钥匙的时间戳。这也被⽤作倒计时时钟。
    uint public lastBuyTimestamp;
    // 每个key所消耗的时间数
    uint public constant TIMER_INCREMENT = 30; // 30 seconds per key
    // 基本价格
    uint public constant BASE_KEY_PRICE = 1 ether;
    // 当前要分配给赢家的奖⾦
    uint public pot;
    // 当前轮次中售出的钥匙总数。
    uint public totalKeysSold;
    // 完成的轮次数。
    uint public roundCount = 0;
    // 平台地址
    address payable public platformAddress;
    // 地址买了多少
    mapping(address => uint) public keyHolders;

    // 各个地址的权重
    mapping(address => uint) public keyHoldersWeight;
    // 总权重
    uint public totalWeight;
    uint public totalHHA;
    uint public totalKeys;
    address public upAddr;
    uint public upKeys;
    // 更新权重和金额
    function UpdateWeight(address addr,uint keys,uint hah) private {
        if (totalKeysSold == keys) {
            // 第一次
            addr = msg.sender;
            upAddr = addr;
            upKeys = keys;

            totalKeys = keys;
            keyHoldersWeight[addr] = hah;
            totalWeight = hah;
            totalHHA = hah;
        } else {
            // 后面的N次
            totalKeys += upKeys;
            uint w = totalWeight.mul(upKeys).div(totalKeys);
            keyHoldersWeight[upAddr] = keyHoldersWeight[upAddr].add(w);
            totalWeight += w;
            totalHHA += hah;

            upAddr = addr;
            upKeys = keys;
        }
    }

    // 所有钥匙持有者的地址数组
    address[] public keyHolderAddresses;
    
    // 平台金额
    uint public accumulatedPlatformShare;
    // key持有者总金额
    uint public accumulatedHolderPrizeShare;
    // 邀请者的金额
    mapping(address => uint) public accumulatedInviterShares;
    
    // 玩家花费的金额
    mapping(address => uint) public accumulatedNewPlayerSpend;

    event KeyPurchased(address indexed buyer, uint amount, uint numKeys, address indexed inviter);

    constructor(/*address payable _platformAddress*/) {
        platformAddress = payable(msg.sender);
    }
    
    function calculateKeyPrice(uint256 numKeys) public view returns (uint256) {
        if (numKeys == 0) {
            return 0;
        }
        uint256 keyPrice = 0;
        uint tks = totalKeysSold;
        if (block.timestamp > lastBuyTimestamp) {
            tks = 0;
        }
        uint base_price = BASE_KEY_PRICE + BASE_KEY_PRICE * tks / 100;
        uint add = (BASE_KEY_PRICE / 100) * (numKeys - 1) * numKeys / 2;
        keyPrice = base_price * numKeys + add;
        return keyPrice;
    }

    function buyKeys(uint256 numKeys, address payable inviter) public payable whenNotPaused nonReentrant {
        require(numKeys > 0, "Invalid number of keys.");

        if (block.timestamp > lastBuyTimestamp) {
            _distributePrize();
        }
        
        uint256 keyPrice = calculateKeyPrice(numKeys);
        require(msg.value >= keyPrice, "Insufficient payment to buy the keys.");
        accumulatedNewPlayerSpend[msg.sender] = accumulatedNewPlayerSpend[msg.sender].add(msg.value);
        
        if (keyHolders[msg.sender] == 0) {
            keyHolderAddresses.push(msg.sender);
        }
        keyHolders[msg.sender] = keyHolders[msg.sender].add(numKeys);
        totalKeysSold += numKeys;

        // 50%给奖池
        pot = pot.add(msg.value.mul(50).div(100));

        // 20%给持有者
        uint PrizeShare = msg.value.mul(20).div(100);
        if (inviter == address(0)) {
            // 如果没有上级，算持有者的20%
            PrizeShare +=  msg.value.mul(5).div(100);
        } else {
            accumulatedInviterShares[inviter] = accumulatedInviterShares[inviter].add(msg.value.mul(5).div(100));
        }
        accumulatedHolderPrizeShare += PrizeShare;
        
        // 10%给平台
        accumulatedPlatformShare += msg.value.mul(10).div(100);
        
        // 15%给空投池
        uint random = uint(keccak256(abi.encodePacked(block.timestamp))) % totalKeysSold;
        uint keys = 0;
        
        for (uint i = 0; i < keyHolderAddresses.length; i++) {
            address addr = keyHolderAddresses[i];
            keys += keyHolders[addr];
            if (keys >= random) {
                address payable lotteryWinner = payable(addr);
                lotteryWinner.transfer(msg.value.mul(15).div(100));
            }
        }
        
        UpdateWeight(lastBuyer,numKeys,PrizeShare);

        lastBuyer = payable(msg.sender);
        if (block.timestamp > lastBuyTimestamp) {
            lastBuyTimestamp = block.timestamp + 24 * 3600;
        } else {
            lastBuyTimestamp += numKeys * TIMER_INCREMENT;
            if (lastBuyTimestamp > block.timestamp + 24 * 3600) {
                lastBuyTimestamp = block.timestamp + 24 * 3600;
            }
        }
        emit KeyPurchased(msg.sender, msg.value, numKeys, inviter);
    }

    // 
    function _distributePrize() private {
        require(block.timestamp > lastBuyTimestamp, "Game is still ongoing.");
        // 中奖者
        lastBuyer.transfer(pot.mul(70).div(100));
        platformAddress.transfer(pot.mul(10).div(100));
        pot = pot.mul(20).div(100);
        
        // 平台
        platformAddress.transfer(accumulatedPlatformShare);
        accumulatedPlatformShare = 0;

        for (uint i = 0; i < keyHolderAddresses.length; i++) {
            address holderAddress = keyHolderAddresses[i];
            
            // 20%的发放
            uint256 holderPrizeShare = accumulatedHolderPrizeShare.mul(keyHoldersWeight[holderAddress]).div(totalWeight);
            payable(holderAddress).transfer(holderPrizeShare);
            keyHoldersWeight[holderAddress] = 0;

            // 推荐者
            if (accumulatedInviterShares[holderAddress] > 0) {
                payable(holderAddress).transfer(accumulatedInviterShares[holderAddress]);
                accumulatedInviterShares[holderAddress] = 0;
            }
            // 购买的数量
            keyHolders[holderAddress] = 0;
            // 购买的花费
            accumulatedNewPlayerSpend[holderAddress] = 0;
        }
        totalWeight = 0;
        totalHHA = 0;
        totalKeys = 0;

        accumulatedHolderPrizeShare = 0;
        // Reset game state
        lastBuyer = payable(address(0));
        lastBuyTimestamp = 0;
        totalKeysSold = 0;
        keyHolderAddresses = new address[](0);
        roundCount++;
        emit RoundEnded(roundCount);
    }

    event RoundEnded(uint roundNumber);
}