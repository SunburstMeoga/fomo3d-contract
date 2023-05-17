// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Fomo3D is ReentrancyGuard, Pausable{
    using SafeMath for uint256;

    address payable public lastBuyer;
    uint public lastBuyTimestamp;
    uint public constant TIMER_INCREMENT = 30; // 30 seconds per key
    uint public constant MAX_KEYS_PER_PURCHASE = 2880;
    uint public constant BASE_KEY_PRICE = 0.01 ether;
    uint public pot;
    uint public totalKeysSold;
    uint public roundCount = 0;

    address payable public platformAddress;
    mapping(address => uint) public keyHolders;
    address[] public keyHolderAddresses;
    
    uint public accumulatedPlatformShare;
    uint public accumulatedHolderPrizeShare;
    mapping(address => uint) public accumulatedInviterShares;
    mapping(address => uint) public accumulatedNewPlayerShares;

    event KeyPurchased(address indexed buyer, uint amount, uint numKeys, address indexed inviter);

    constructor(address payable _platformAddress) {
        platformAddress = _platformAddress;
    }

    uint256 constant ONE = 1 << 128;

    function log2(uint256 x) public pure returns (uint256 y) {
        assert(x > 0);
        y = (x > 1) ? 1 : 0;
        for (uint256 i = 128; i > 0; i >>= 1) {
            if (x >= (ONE << (y + i))) {
                y = y + i;
            }
        }
        return y;
    }

    function log10(uint256 x) public pure returns (uint256) {
        return log2(x) * 10000 / 33219; // log2(10) * 10000
    }

    function calculateKeyPrice(uint256 numKeys) public view returns (uint256) {
        uint256 keyPrice = BASE_KEY_PRICE;
        for (uint256 i = 0; i < numKeys; i++) {
            keyPrice += BASE_KEY_PRICE * (1 + 50 * log10(100 * (1 + 10 * (totalKeysSold + i)))) / 100;
        }
        return keyPrice;
    }
    
    function buyKeys(uint256 numKeys, address payable inviter) public payable whenNotPaused nonReentrant {
        
        if (block.timestamp > lastBuyTimestamp) {
            _distributePrize();
        }

        require(numKeys > 0 && numKeys <= MAX_KEYS_PER_PURCHASE, "Invalid number of keys.");
        
        uint256 keyPrice = calculateKeyPrice(numKeys);
        require(msg.value >= keyPrice, "Insufficient payment to buy the keys.");

        // Calculate shares
        uint256 platformShare = msg.value.mul(10).div(100);
        uint256 inviterShare = 0;
        uint256 newPlayerShare = 0;
        uint256 holderPrizeShare = msg.value.mul(20).div(100);

        if (inviter == address(0)) {
            // If no inviter, additional 5% goes to holder prize
            holderPrizeShare = holderPrizeShare.add(msg.value.mul(5).div(100));
        } else {
            inviterShare = msg.value.mul(3).div(100);
            newPlayerShare = msg.value.mul(2).div(100);
            accumulatedInviterShares[inviter] = accumulatedInviterShares[inviter].add(inviterShare);
            accumulatedNewPlayerShares[msg.sender] = accumulatedNewPlayerShares[msg.sender].add(newPlayerShare);
        }

        uint256 lotteryShare = msg.value.mul(15).div(100);
        uint256 potShare = msg.value.mul(50).div(100);

        // Accumulate shares
        accumulatedPlatformShare = accumulatedPlatformShare.add(platformShare);
        accumulatedHolderPrizeShare = accumulatedHolderPrizeShare.add(holderPrizeShare);

        // Randomly select a lottery winner and transfer the prize
        uint randomIndex = uint(keccak256(abi.encodePacked(block.timestamp/*, block.difficulty*/))) % keyHolderAddresses.length;
        address payable lotteryWinner = payable(keyHolderAddresses[randomIndex]);
        lotteryWinner.transfer(lotteryShare);

        // Update pot and key holder's balance
        pot = pot.add(potShare);

        // Add new buyer to key holders if not already a holder
        if (keyHolders[msg.sender] == 0) {
            keyHolderAddresses.push(msg.sender);
        }

        // Update key holder's balance
        keyHolders[msg.sender] = keyHolders[msg.sender].add(numKeys);

        lastBuyer = payable(msg.sender);
        lastBuyTimestamp = block.timestamp + numKeys * TIMER_INCREMENT;

        totalKeysSold += numKeys;

        emit KeyPurchased(msg.sender, msg.value, numKeys, inviter);
        
    }


    function _distributePrize() private {
        require(block.timestamp > lastBuyTimestamp, "Game is still ongoing.");

        // Distribute pot to last buyer
        lastBuyer.transfer(pot);

        // Distribute accumulated shares
        platformAddress.transfer(accumulatedPlatformShare);
        accumulatedPlatformShare = 0;

        for (uint i = 0; i < keyHolderAddresses.length; i++) {
            address holderAddress = keyHolderAddresses[i];

            // Calculate and distribute holder prize share
            uint256 holderPrizeShare = accumulatedHolderPrizeShare.mul(keyHolders[holderAddress]).div(totalKeysSold);
            payable(holderAddress).transfer(holderPrizeShare);

            // Distribute inviter share
            if (accumulatedInviterShares[holderAddress] > 0) {
                payable(holderAddress).transfer(accumulatedInviterShares[holderAddress]);
                accumulatedInviterShares[holderAddress] = 0;
            }

            // Distribute new player share
            if (accumulatedNewPlayerShares[holderAddress] > 0) {
                payable(holderAddress).transfer(accumulatedNewPlayerShares[holderAddress]);
                accumulatedNewPlayerShares[holderAddress] = 0;
            }
        }
        accumulatedHolderPrizeShare = 0;


        // Reset game state
        lastBuyer = payable(address(0));
        lastBuyTimestamp = 0;
        pot = 0;
        totalKeysSold = 0;
        keyHolderAddresses = new address[](0);
        roundCount++;

        emit RoundEnded(roundCount);
    }

    event RoundEnded(uint roundNumber);
}