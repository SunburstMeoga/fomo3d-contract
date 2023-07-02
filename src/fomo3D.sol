// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Fomo3D is ReentrancyGuard, Pausable {
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
        // 总金额
        uint totalAmount;
    }

    mapping(uint256 => round_info) public roundInfos;

    function rounds()
        public
        view
        returns (
            uint totalKeysSold,
            uint totalKeysSold_s,
            uint totalHAH,
            uint totalHAH_s
        )
    {
        totalKeysSold = roundInfos[roundCount].totalKeysSold;
        totalHAH = roundInfos[roundCount].totalAmount;
        for (uint i = 0; i <= roundCount; i++) {
            totalKeysSold_s += roundInfos[i].totalKeysSold;
            totalHAH_s += roundInfos[i].totalAmount;
        }
    }

    struct player {
        // 花费金额
        uint spend;
        // 地址购买数量
        uint numKeys;
        //
        uint mask;
    }

    // 地址信息
    struct address_info {
        // 周期玩家信息
        mapping(uint => player) players;
        // 提现金额
        uint withdrawalAmount;
        // 汇总金额
        uint summaryAmount;
        // 汇总周期
        uint summaryRound;
    }

    mapping(address => address_info) public addressInfos;

    function Infos1(
        address addr,
        uint r
    ) public view returns (player memory p) {
        p = addressInfos[addr].players[r];
    }

    function Infos2(
        address addr
    )
        public
        view
        returns (
            uint withd,
            uint spend,
            uint spend_s,
            uint numKey,
            uint numKey_s,
            //uint expectIncome,
            uint utc
        )
    {
        utc = block.timestamp;
        withd = addressInfos[addr].withdrawalAmount;
        spend = addressInfos[addr].players[roundCount].spend;
        numKey = addressInfos[addr].players[roundCount].numKeys;
        for (uint i = 0; i <= roundCount; i++) {
            spend_s += addressInfos[addr].players[i].spend;
            numKey_s += addressInfos[addr].players[i].numKeys;
        }
    }

    function expectIncome(address addr) public view returns (uint) {
        round_info memory r0 = roundInfos[roundCount];
        player memory p = addressInfos[addr].players[roundCount];
        return r0.totalHAH.mul(p.numKeys).div(r0.totalKeysSold).sub(p.mask);
    }

    function balanceOf(address addr) public view returns (uint) {
        address_info storage ai = addressInfos[addr];
        uint v = ai.summaryAmount;
        for (uint i = ai.summaryRound; i < roundCount; i++) {
            round_info memory r = roundInfos[i];
            player memory p = addressInfos[addr].players[i];
            uint v_temp = r.totalHAH.mul(p.numKeys).div(r.totalKeysSold).sub(
                p.mask
            );
            v = v.add(v_temp);
        }
        round_info memory r0 = roundInfos[roundCount];
        if (r0.totalKeysSold > 0) {
            player memory p = addressInfos[addr].players[roundCount];
            uint v_temp = r0.totalHAH.mul(p.numKeys).div(r0.totalKeysSold).sub(
                p.mask
            );
            v = v.add(v_temp);
        }
        v = v.sub(addressInfos[addr].withdrawalAmount);
        return v;
    }

    function withdrawal(uint v) public {
        address addr = msg.sender;
        assert(balanceOf(addr) >= v);
        addressInfos[addr].withdrawalAmount = addressInfos[addr]
            .withdrawalAmount
            .add(v);
        payable(addr).transfer(v);
        if (roundCount > addressInfos[addr].summaryRound) {
            uint v0 = addressInfos[addr].summaryAmount;
            for (
                uint i = addressInfos[addr].summaryRound;
                i < roundCount;
                i++
            ) {
                round_info memory r = roundInfos[i];
                player memory p = addressInfos[addr].players[i];
                uint v_temp = r
                    .totalHAH
                    .mul(p.numKeys)
                    .div(r.totalKeysSold)
                    .sub(p.mask);
                v0 = v0.add(v_temp);
            }
            addressInfos[addr].summaryAmount = v0;
            addressInfos[addr].summaryRound = roundCount;
        }
    }

    // 所有钥匙持有者的地址数组
    address[] public keyHolderAddresses;

    event KeyPurchased(
        address indexed buyer,
        uint amount,
        uint numKeys,
        address indexed inviter
    );

    constructor() /*address payable _platformAddress*/ {
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
        uint base_price = BASE_KEY_PRICE + (BASE_KEY_PRICE * tks) / 100;
        uint add = ((BASE_KEY_PRICE / 100) * (numKeys - 1) * numKeys) / 2;
        keyPrice = base_price * numKeys + add;
        return keyPrice;
    }

    mapping(address => uint256) private inviterAmount;
    mapping(address => uint256) private inviterNumber;

    function Inviter(
        address addr
    ) public view returns (uint amount, uint number) {
        amount = inviterAmount[addr];
        number = inviterNumber[addr];
    }

    function buyKeys(
        uint256 numKeys,
        address payable inviter
    ) public payable whenNotPaused nonReentrant {
        address addr = msg.sender;
        uint v = msg.value;
        require(numKeys > 0 && numKeys <= 2880, "Invalid number of keys.");
        if (
            block.timestamp > lastBuyTimestamp &&
            roundInfos[roundCount].totalKeysSold > 0
        ) {
            _distributePrize();
        }
        uint256 keyPrice = calculateKeyPrice(numKeys);
        require(v >= keyPrice, "Insufficient payment to buy the keys.");
        roundInfos[roundCount].totalAmount += v;
        addressInfos[addr].players[roundCount].spend += v;
        if (addressInfos[addr].players[roundCount].numKeys == 0) {
            keyHolderAddresses.push(addr);
        }

        // 50%给奖池
        pot = pot.add(v.mul(50).div(100));

        // 20%给持有者
        uint PrizeShare = v.mul(20).div(100);
        if (inviter == address(0)) {
            // 如果没有上级，算持有者的20%
            PrizeShare += v.mul(5).div(100);
        } else {
            payable(inviter).transfer(v.mul(5).div(100));
            inviterAmount[inviter] += v.mul(5).div(100);
            inviterNumber[inviter] += 1;
        }
        // 20%收益分发
        {
            if (roundInfos[roundCount].totalKeysSold == 0) {
                roundInfos[roundCount].totalHAH = PrizeShare;
                roundInfos[roundCount].totalKeysSold = numKeys;

                addressInfos[addr].players[roundCount].numKeys = numKeys;
            } else {
                roundInfos[roundCount].totalHAH += PrizeShare;
                uint m = numKeys.mul(roundInfos[roundCount].totalHAH) /
                    roundInfos[roundCount].totalKeysSold;
                roundInfos[roundCount].totalKeysSold += numKeys;
                roundInfos[roundCount].totalHAH += m;
                addressInfos[addr].players[roundCount].mask += m;
                addressInfos[addr].players[roundCount].numKeys += numKeys;
            }
        }

        // 10%给平台
        payable(platformAddress).transfer(v.mul(10).div(100));

        // 15%给空投池
        uint random = uint(keccak256(abi.encodePacked(block.timestamp))) %
            roundInfos[roundCount].totalKeysSold;
        uint keys = 0;

        for (uint i = 0; i < keyHolderAddresses.length; i++) {
            address addr1 = keyHolderAddresses[i];
            keys += addressInfos[addr1].players[roundCount].numKeys;
            if (keys >= random) {
                payable(addr1).transfer(v.mul(15).div(100));
            }
        }
        lastBuyer = payable(addr);
        if (block.timestamp > lastBuyTimestamp) {
            lastBuyTimestamp = block.timestamp + 24 * 3600;
        } else {
            lastBuyTimestamp += numKeys * TIMER_INCREMENT;
            if (lastBuyTimestamp > block.timestamp + 24 * 3600) {
                lastBuyTimestamp = block.timestamp + 24 * 3600;
            }
        }
        emit KeyPurchased(addr, v, numKeys, inviter);
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

        emit RoundEnded(roundCount);
    }

    event RoundEnded(uint roundNumber);
}
