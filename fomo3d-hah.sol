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

contract Fomo3dHAH {
    using SafeMath for uint256;
    uint256 public keyPrice; //六位小数
    uint256 public pool; //奖池
    uint256 public keyOwnPool; //key持有者的地址
    uint256 public platformPool; //平台
    uint256 public roundTime;
    address public winner;
    uint256 public key_v;
    uint256 public eth_v;
    uint256 public nextRound;

    // // 构造函数
    constructor() {
        // payable 表示合约地址可以接收转账
        keyPrice = 1000000; // 获取转给合约地址的金额
    }

    //判断是否为合约开发者
    // modifier isHuman() {
    //     require(msg.sender == owner, "Not Owner!");
    //     _;
    // }
    //购买key，并返回购买的key的数量(向当前合约转入eth)

    struct info {
        uint256 balance;
        uint8 team; //0.鱼 1.熊 2.蛇 3.牛
        uint256 eth;
    }
    mapping(address => info) infos;

    function buyKeys(uint256 value, uint8 team) public payable {
        infos[msg.sender].balance = infos[msg.sender].balance.add(msg.value);
        infos[msg.sender].team = team;
        assert(value * keyPrice * 10**12 <= msg.value);
        roundTime = block.timestamp;
        winner = msg.sender;
        if (infos[msg.sender].team == 0) {
            pool = pool.add(value / 2); //50% 奖池
            keyOwnPool = keyOwnPool.add((value * 30) / 100); //30% key持有者
            platformPool = platformPool.add((value * 2) / 100); //2% 给平台
        } else if (infos[msg.sender].team == 1) {
            pool = pool.add((value * 43) / 100); //43%
            keyOwnPool = keyOwnPool.add((value * 43) / 100); //30% key持有者
            platformPool = platformPool.add((value * 2) / 100); //2% 给平台
        } else if (infos[msg.sender].team == 2) {
            pool = pool.add(value / 5); //20%
            keyOwnPool = keyOwnPool.add(value / 10); //30% key持有者
            platformPool = platformPool.add((value * 2) / 100); //2% 给平台
        } else {
            pool = pool.add((value * 35) / 100); //35%
            keyOwnPool = keyOwnPool.add((value * 8) / 100); //30% key持有者
            platformPool = platformPool.add((value * 2) / 100); //2% 给平台
        }
    }

    function withdraw() external payable {
        assert(
            msg.sender == winner && roundTime + (3600 * 24) > block.timestamp
        );
        if (infos[msg.sender].team == 0) {
            payable(winner).transfer((pool * 15) / 100);
        } else {
            payable(winner).transfer((pool * 48) / 100);
        }
    }

    function payTeam() public view returns (info memory) {
        return infos[msg.sender];
    }

    //获取合约余额
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    //获取合约地址
    function getAddress() public view returns (address) {
        return address(this);
    }

    function initPriace() private {
        key_v = 1_000_000 ether;
        eth_v = 1 ether;
    }

    function getKeys(uint256 v) private view returns (uint256) {
        return (key_v * v) / eth_v;
    }

    function updatePriace(uint256 v) private {
        eth_v = eth_v.add(v);
    }
}
