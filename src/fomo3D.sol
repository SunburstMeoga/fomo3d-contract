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
    // 平台地址
    address payable public platformAddress;
    // 当前要分配给赢家的奖⾦
    uint public pot;

    // 完成的轮次数。
    uint public roundCount = 0;
    
    // 轮信息
    struct round_info {
        // 当前轮次中售出的钥匙总数。
        uint totalKeysSold;
        // 20%的地址持有者数量
        uint totalHAH;
    }

    mapping(uint256 => round_info) public roundInfos;
    
    struct player_info {
        // 花费金额
        uint spend;
        // 地址购买数量
        uint numKeys;
    }

    // 地址信息
    struct address_info {
        // 周期玩家信息
        mapping(uint => player_info) players;
        // 提现金额
        uint withdrawalAmount;
    }
    
    mapping(address => address_info) private addressInfos;

    function Infos(address addr,uint round) public view returns(uint withd,uint spend,uint numKeys) {
        withd = addressInfos[addr].withdrawalAmount;
        spend = addressInfos[addr].players[round].spend;
        numKeys = addressInfos[addr].players[round].numKeys;
    }

    function balanceOf(address addr) public view returns(uint) {
        uint v = 0;
        for (uint i = 0; i <= roundCount; i++) {
            uint v_temp = addressInfos[addr].players[i].numKeys.mul(roundInfos[i].totalHAH).div(roundInfos[i].totalKeysSold);
            v = v.add(v_temp);
        }
        v = v.sub(addressInfos[addr].withdrawalAmount);
        return v;
    }

    function withdrawal(uint v) public {
        assert(balanceOf(msg.sender) >= v);
        addressInfos[msg.sender].withdrawalAmount = addressInfos[msg.sender].withdrawalAmount.add(v);
        payable(msg.sender).transfer(v);
    }

    // 所有钥匙持有者的地址数组
    address[] public keyHolderAddresses;
    
    address private upAddr;
    uint private upKeys;

    // 更新权重和金额
    function updateWeight(address addr,uint keys,uint hah) private {
        if (upKeys == 0) {
            // 第一次
            roundInfos[roundCount].totalHAH = hah;
            addressInfos[addr].players[roundCount].weight = hah;
            roundInfos[roundCount].totalWeight = hah;  
        } else {
            // 第一次以后
            uint w = roundInfos[roundCount].totalWeight.mul(upKeys).div(roundInfos[roundCount].totalKeysSold - keys);
            addressInfos[upAddr].players[roundCount].weight += w;
            roundInfos[roundCount].totalWeight += w;
            roundInfos[roundCount].totalHAH += hah;
        }
        upAddr = addr;
        upKeys = keys;
    }
    
    event KeyPurchased(address indexed buyer, uint amount, uint numKeys, address indexed inviter);

    constructor(/*address payable _platformAddress*/) {
        platformAddress = payable(msg.sender);
    }
    
    function calculateKeyPrice(uint256 numKeys) public view returns (uint256) {
        if (numKeys == 0) {
            return 0;
        }
        uint256 keyPrice = 0;
        uint tks = roundInfos[roundCount].totalKeysSold;
        if (block.timestamp > lastBuyTimestamp) {
            tks = 0;
        }
        uint base_price = BASE_KEY_PRICE + BASE_KEY_PRICE * tks / 100;
        uint add = (BASE_KEY_PRICE / 100) * (numKeys - 1) * numKeys / 2;
        keyPrice = base_price * numKeys + add;
        return keyPrice;
    }
    mapping(address => uint256) private inviterAmount;
    mapping(address => uint256) private inviterNumber;
    function Inviter(address addr) public view returns(uint,uint) {
        return (inviterAmount[addr],inviterNumber[addr]);
    }

    function buyKeys(uint256 numKeys, address payable inviter) public payable whenNotPaused nonReentrant {
        require(numKeys > 0 && numKeys <= 2880, "Invalid number of keys.");
        if (block.timestamp > lastBuyTimestamp && roundInfos[roundCount].totalKeysSold > 0) {
            _distributePrize();
        }
        uint256 keyPrice = calculateKeyPrice(numKeys);
        require(msg.value >= keyPrice, "Insufficient payment to buy the keys.");
        addressInfos[msg.sender].players[roundCount].spend += msg.value;
        if (addressInfos[msg.sender].players[roundCount].numKeys == 0) {
            keyHolderAddresses.push(msg.sender);
        }
        addressInfos[msg.sender].players[roundCount].numKeys += numKeys;
        roundInfos[roundCount].totalKeysSold += numKeys;
        
        // 50%给奖池
        pot = pot.add(msg.value.mul(50).div(100));
        
        // 20%给持有者
        uint PrizeShare = msg.value.mul(20).div(100);
        if (inviter == address(0)) {
            // 如果没有上级，算持有者的20%
            PrizeShare += msg.value.mul(5).div(100);
        } else {
            payable(inviter).transfer(msg.value.mul(5).div(100));
            inviterAmount[inviter] += msg.value.mul(5).div(100);
            inviterNumber[inviter] += 1;
        }
        updateWeight(msg.sender,numKeys, PrizeShare);

        // 10%给平台
        payable(platformAddress).transfer(msg.value.mul(10).div(100));
        
        // 15%给空投池
        uint random = uint(keccak256(abi.encodePacked(block.timestamp))) % roundInfos[roundCount].totalKeysSold;
        uint keys = 0;
        
        for (uint i = 0; i < keyHolderAddresses.length; i++) {
            address addr = keyHolderAddresses[i];
            keys += addressInfos[msg.sender].players[roundCount].numKeys;
            if (keys >= random) {
                payable(addr).transfer(msg.value.mul(15).div(100));
            }
        }
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
        keyHolderAddresses = new address[](0);
        roundCount++;
        // 
        lastBuyer = payable(address(0));
        lastBuyTimestamp = 0;
        upAddr = address(0);
        upKeys = 0;
       
        emit RoundEnded(roundCount);
    }
    event RoundEnded(uint roundNumber);
}