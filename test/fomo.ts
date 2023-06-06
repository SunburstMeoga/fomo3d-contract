import { assert, expect, use } from 'chai'
import { Contract, constants,utils } from 'ethers'
import { MockProvider, deployContract, solidity } from 'ethereum-waffle'
import { mineBlock } from './shared/utilities'

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
        fomo3D = await deployContract(wallet, Fomo3D,[])
    })

    it('购买key测试', async () => {
        describe('--------------------------------', () => {
            it('购买key测试', async () => {
                const keyNumber = 1
                let hah = await fomo3D.calculateKeyPrice(keyNumber)
                console.log(hah.toString())
                await fomo3D.buyKeys(keyNumber,wallet.address,{...overrides,value: hah})
                let ret = await fomo3D.roundCount()
                console.log(ret.toString())
                ret = await fomo3D.Infos(wallet.address,0)
                //console.log(ret)
                console.log((await provider.getBlock('latest')).timestamp)
                await mineBlock(provider, (await provider.getBlock('latest')).timestamp + 3600)
                console.log((await provider.getBlock('latest')).timestamp)
                /*
                let totalWeight = await fomo3D.totalWeight()
                let totalHHA = await fomo3D.totalHHA()
                let w = await fomo3D.keyHoldersWeight(wallet.address)
                console.log(totalWeight.toString())
                console.log(totalHHA.toString())
                console.log(w.toString())

                hah = await fomo3D.calculateKeyPrice(keyNumber)
                console.log(hah.toString())
                await fomo3D.connect(wallet1).buyKeys(keyNumber,wallet1.address,{...overrides,value: hah})
                */
                /*
                totalWeight = await fomo3D.totalWeight()
                totalHHA = await fomo3D.totalHHA()
                w = await fomo3D.keyHoldersWeight(wallet.address)
                console.log(totalWeight.toString())
                console.log(totalHHA.toString())
                console.log(w.toString())
                */
                //console.log('1',hah.toString())
                //hah = await fomo3D.calculateKeyPrice(2)
                //console.log('2',hah.toString())
                //hah = await fomo3D.calculateKeyPrice(3)
                //console.log('3',hah.toString())
                //hah = await fomo3D.calculateKeyPrice(100)
                //console.log('4',hah.toString())
                /*
                await fomo3D.buyKeys(keyNumber,wallet1.address,{...overrides,value: hah})
                const walletBuyKeys = await fomo3D.keyHolders(wallet.address)
                expect(walletBuyKeys).to.eq(keyNumber)
                console.log(`${wallet.address}购买数量: ${walletBuyKeys.toString()}`)
                
                const accumulatedHolderPrizeShare = await fomo3D.accumulatedHolderPrizeShare()
                const totalKeysSold = await fomo3D.totalKeysSold()
                const ret = accumulatedHolderPrizeShare.mul(walletBuyKeys).div(totalKeysSold)
                console.log(`${wallet.address}收益: ${ret.toString()}`)
                const spend = await fomo3D.accumulatedNewPlayerSpend(wallet.address)
                console.log(`${wallet.address}花费金额: ${spend.toString()}`)
                const rrr = await fomo3D.calculateKeyPrice(8000)
                console.log(rrr)
                */
            })
        })
    })
})