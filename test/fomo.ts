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

    async function print(w: any) {
        const rc = await fomo3D.roundCount()
        //const ret1 = await fomo3D.Infos(w.address,rc)
        //console.log('withd:',ret1.withd.toString())
        //console.log('weight:',ret1.weight.toString())
        //console.log('spend:',ret1.spend.toString())
        //console.log('numKeys:',ret1.numKeys.toString())
        console.log('--------------------------------------')
        const ret2 = await fomo3D.roundInfos(rc)
        //console.log('totalKeysSold',ret2.totalKeysSold.toString())
        //console.log('totalWeight',ret2.totalWeight.toString())
        console.log('totalHAH',ret2.totalHAH.toString())
    }

    beforeEach(async () => {
        fomo3D = await deployContract(wallet, Fomo3D,[])
    })

    it('购买key测试', async () => {
        describe('--------------------------------', () => {
            it('购买key测试', async () => {
                const keyNumber = 1
                const hah0 = await fomo3D.calculateKeyPrice(keyNumber)
                expect(hah0).to.eq(constants.WeiPerEther)
                await fomo3D.buyKeys(keyNumber,wallet.address,{...overrides,value: hah0})
                
                let ret = await fomo3D.balanceOf(wallet.address)
                expect(ret).to.eq(hah0.mul(20).div(100))

                const hah1 = await fomo3D.calculateKeyPrice(keyNumber)
                await fomo3D.connect(wallet1).buyKeys(keyNumber,wallet.address,{...overrides,value: hah1})
                
                const hah2 = await fomo3D.calculateKeyPrice(keyNumber)
                await fomo3D.connect(wallet2).buyKeys(keyNumber,wallet.address,{...overrides,value: hah2})

                const hah3 = await fomo3D.calculateKeyPrice(keyNumber)
                await fomo3D.connect(wallet3).buyKeys(keyNumber,wallet.address,{...overrides,value: hah3})
                
                ret = await fomo3D.balanceOf(wallet.address)
                console.log('w0',ret.toString())
                await fomo3D.withdrawal(ret.div(2),overrides)
                ret = await fomo3D.balanceOf(wallet.address)
                console.log('w0',ret.toString())                

                ret = await fomo3D.balanceOf(wallet1.address)
                console.log('w1',ret.toString())

                ret = await fomo3D.balanceOf(wallet2.address)
                console.log('w2',ret.toString())

                ret = await fomo3D.balanceOf(wallet3.address)
                console.log('w3',ret.toString())

                ret = await fomo3D.roundCount()
                console.log('roundCount:',ret.toString())
                ret = await fomo3D.calculateKeyPrice(keyNumber)
                console.log('price:',ret.toString())
                await mineBlock(provider, (await provider.getBlock('latest')).timestamp + 3600 * 25)
                
                ret = await fomo3D.roundCount()
                console.log('roundCount:',ret.toString())
                ret = await fomo3D.calculateKeyPrice(keyNumber)
                console.log('price:',ret.toString())
                await fomo3D.connect(wallet1).buyKeys(keyNumber,wallet.address,{...overrides,value: ret})

                ret = await fomo3D.roundCount()
                console.log('roundCount:',ret.toString())
                ret = await fomo3D.calculateKeyPrice(keyNumber)
                console.log('price:',ret.toString())
                console.log("-----------------------------------------------")                
                ret = await fomo3D.balanceOf(wallet1.address)
                console.log('w1',ret.toString())

                ret = await fomo3D.addressInfos(wallet1.address)
                console.log('addressInfos:',ret.toString())

                await fomo3D.connect(wallet1).withdrawal(6,overrides)

                ret = await fomo3D.balanceOf(wallet1.address)
                console.log('w1',ret.toString())

                ret = await fomo3D.addressInfos(wallet1.address)
                console.log('addressInfos:',ret.toString())

                ret = await fomo3D.calculateKeyPrice(keyNumber)
                await fomo3D.connect(wallet1).buyKeys(keyNumber,wallet.address,{...overrides,value: ret})

                ret = await fomo3D.balanceOf(wallet1.address)
                console.log('w1',ret.toString())

                ret = await fomo3D.addressInfos(wallet1.address)
                console.log('addressInfos:',ret.toString())
                await mineBlock(provider, (await provider.getBlock('latest')).timestamp + 3600 * 25)
                ret = await fomo3D.calculateKeyPrice(keyNumber)
                await fomo3D.connect(wallet1).buyKeys(keyNumber,wallet.address,{...overrides,value: ret})

                ret = await fomo3D.balanceOf(wallet1.address)
                console.log('w1',ret.toString())

                ret = await fomo3D.addressInfos(wallet1.address)
                console.log('addressInfos:',ret.toString())
                
                await fomo3D.connect(wallet1).withdrawal(10,overrides)

                ret = await fomo3D.balanceOf(wallet1.address)
                console.log('w1',ret.toString())

                ret = await fomo3D.addressInfos(wallet1.address)
                console.log('addressInfos:',ret.toString())

                ret = await fomo3D.Infos2(wallet1.address)
                console.log(ret.withd)

                ret = await fomo3D.expectIncome(wallet1.address)
                console.log('当前KeyNumber收益:',ret.toString())
            })
        })
    })
})