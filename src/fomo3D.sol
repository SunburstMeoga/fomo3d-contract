//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}

contract Fomo3D {
    using SafeMath for uint256;

    uint256 public keyOwnPool; //key持有者的地址    
    uint256 public pool; //奖池
    uint256 public platformPool; //平台

    uint256 public roundTime;
    address public winner;
    uint256 public eth_v;
    uint256 public nextRound;
    uint256 public epoch;
    uint256 public keysTotal;

    struct Epoch {
        uint256 keyOwnPool;
        uint256 keysTotal;
    }
    mapping(uint256 => Epoch) epochs;
    address public owner;
    constructor() {
        initPriace();
        epoch = 0;
        owner = msg.sender;
    }

    function newPlay() private {
        initPriace();
        epoch++;
    }

    struct info {
        uint256 balance;
        uint8 team; //0.鱼 1.熊 2.蛇 3.牛
        uint256 epoch;
    }

    mapping(address => info) public infos;

    function buyKeys(uint256 value, uint8 team) public payable {
        address addr = msg.sender;
        uint256 eth_value = msg.value;
        uint key_v = getKeys(eth_value);
        infos[addr].balance = infos[addr].balance.add(value);
        infos[addr].team = team;
        assert(value <= key_v);
        keysTotal += value;
        updatePriace(eth_value);
        roundTime = block.timestamp;
        winner = addr;
        
        if (infos[addr].team == 0) {
            pool = pool.add(eth_value / 2); //50% 奖池
            keyOwnPool = keyOwnPool.add((eth_value * 30) / 100); //30% key持有者
            platformPool = platformPool.add((eth_value * 2) / 100); //2% 给平台
        } else if (infos[addr].team == 1) {
            pool = pool.add((eth_value * 43) / 100); //43%
            keyOwnPool = keyOwnPool.add((eth_value * 43) / 100); //30% key持有者
            platformPool = platformPool.add((eth_value * 2) / 100); //2% 给平台
        } else if (infos[addr].team == 2) {
            pool = pool.add(eth_value / 5); //20%
            keyOwnPool = keyOwnPool.add(eth_value / 10); //30% key持有者
            platformPool = platformPool.add((eth_value * 2) / 100); //2% 给平台
        } else {
            pool = pool.add((eth_value * 35) / 100); //35%
            keyOwnPool = keyOwnPool.add((eth_value * 8) / 100); //30% key持有者
            platformPool = platformPool.add((eth_value * 2) / 100); //2% 给平台
        }
    }

    function withdraw1() external {
        address addr = msg.sender;
        assert(
            addr == winner && roundTime + (3600 * 24) <= block.timestamp
        );
        
        if (infos[addr].epoch == epoch) {
            epochs[epoch] = Epoch({keyOwnPool:keyOwnPool,keysTotal:keysTotal});
            payable(addr).transfer(keyOwnPool.mul(infos[addr].balance) / keysTotal);
            keyOwnPool = 0;
            keysTotal = 0;
            newPlay();
            infos[addr].epoch = epoch;
            infos[addr].balance = 0;
        }
        
        if (infos[addr].team == 0) {
            payable(winner).transfer((pool * 15) / 100);
        } else {
            payable(winner).transfer((pool * 48) / 100);
        }
    }

    function withdraw2() external {
        address addr = msg.sender;
        if (infos[addr].epoch < epoch) {
            Epoch memory obj = epochs[infos[addr].epoch];
            payable(addr).transfer(obj.keyOwnPool.mul(infos[addr].balance) / obj.keysTotal);
            infos[addr].epoch = epoch;
            infos[addr].balance = 0;
        }
    }

    function withdrawPool(uint value) external {
        assert(owner == msg.sender && value <= pool);
        payable(owner).transfer(value);
        pool = pool.sub(value);
    }

    function withdrawPlatformPool(uint value) external {
        assert(owner == msg.sender && value < platformPool);
        payable(owner).transfer(value);
        platformPool = platformPool.sub(value);
    }

    function initPriace() private {
        eth_v = 1 ether;
    }

    function getKeys(uint256 v) public view returns (uint256) {
        return (1_000_000 ether * v) / eth_v;
    }

    function updatePriace(uint256 v) private {
        eth_v = eth_v.add(v);
    }
}
