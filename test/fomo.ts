import { assert, expect, use } from 'chai'
import { Contract, constants,utils } from 'ethers'
import { MockProvider, deployContract, solidity } from 'ethereum-waffle'

import Fomo3D from '../build/Fomo3D.json';

use(solidity)

const overrides = {
    gasLimit: 9999999
}

describe('fomo3D test', () => {
    let fomo3D: Contract

    const provider = new MockProvider()
    const [wallet, wallet1, wallet2, wallet3, wallet4, wallet5] = provider.getWallets()

    beforeEach(async () => {
        fomo3D = await deployContract(wallet, Fomo3D,[wallet.address])
    })

    it('用例1', async () => {
        describe('--------------------------------', () => {
            it('购买key测试', async () => {
                // 合约地址: 0xce6D840Cf15a89a231ef00aE1418E37ce43d5e1f
                const hah = await fomo3D.calculateKeyPrice(1)
                await fomo3D.buyKeys(1,wallet1.address,{...overrides,value: hah})
                const walletBuyKeys = await fomo3D.keyHolders(wallet.address)
                expect(walletBuyKeys).to.eq(1)
                console.log(`${wallet.address}购买数量: ${walletBuyKeys.toString()}`)
                const accumulatedHolderPrizeShare = await fomo3D.accumulatedHolderPrizeShare()
                const totalKeysSold = await fomo3D.totalKeysSold()
                const ret = accumulatedHolderPrizeShare.mul(walletBuyKeys).div(totalKeysSold)
                expect(ret).to.eq(hah.div(5))
                console.log(`${wallet.address}收益: ${ret.toString()}`)
                const spend = await fomo3D.accumulatedNewPlayerSpend(wallet.address)
                expect(spend).to.eq(hah)
                console.log(`${wallet.address}花费金额: ${spend.toString()}`)
            })
        })
    })
})