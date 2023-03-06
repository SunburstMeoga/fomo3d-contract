import { assert, expect, use } from 'chai'
import { Contract, constants } from 'ethers'
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
        fomo3D = await deployContract(wallet, Fomo3D)
    })

    it('用例1', async () => {
        describe('--------------------------------', () => {
            it('购买', async () => {
                const eth_v = constants.WeiPerEther
                const keys = await fomo3D.getKeys(eth_v)
                expect(keys).to.eq(constants.WeiPerEther.mul(1000000))
                await fomo3D.buyKeys(keys, 1, { ...overrides, value: eth_v })
                expect(await provider.getBalance(fomo3D.address)).to.eq(eth_v)
            })

            it('竞争', async () => {
                const eth_v = constants.WeiPerEther
                const keys = await fomo3D.getKeys(eth_v)
                await fomo3D.connect(wallet1).buyKeys(keys, 1, { ...overrides, value: eth_v })
                expect(await provider.getBalance(fomo3D.address)).to.eq(eth_v.mul(2))
                const balance0 = (await fomo3D.infos(wallet.address)).balance
                const balance1 = (await fomo3D.infos(wallet1.address)).balance
                expect(balance0).to.gt(balance1)
            })

            it('提现', async () => {
                let timestamp = (await provider.getBlock('latest')).timestamp + 24 * 60 * 60
                await provider.send('evm_setTime', [timestamp * 1000])
                await provider.send('evm_mine', [timestamp])
                await expect(fomo3D.withdraw1()).to.be.reverted
                let old_v = await provider.getBalance(wallet1.address)
                await fomo3D.connect(wallet1).withdraw1()
                let new_v = await provider.getBalance(wallet1.address)
                assert(new_v > old_v)
                let ret = await fomo3D.infos(wallet.address)
                expect(ret.epoch).to.eq(0)
                await fomo3D.withdraw2()
                ret = await fomo3D.infos(wallet.address)
                expect(ret.epoch).to.eq(1)
            })
        })
    })
})