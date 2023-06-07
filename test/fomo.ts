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
                /*
                let ret = await fomo3D.balanceOf(wallet.address)
                expect(ret).to.eq(hah0.mul(20).div(100))
                //await print(wallet)
                
                const hah1 = await fomo3D.calculateKeyPrice(keyNumber)
                expect(hah1).to.eq(constants.WeiPerEther.mul(101).div(100))
                await fomo3D.connect(wallet1).buyKeys(keyNumber,wallet.address,{...overrides,value: hah1})
                ret = await fomo3D.balanceOf(wallet.address)
                expect(ret).to.eq(hah0.add(hah1).mul(20).div(100))
                expect(await fomo3D.balanceOf(wallet1.address)).to.eq(0)
                //await print(wallet)
                
                const hah2 = await fomo3D.calculateKeyPrice(keyNumber)
                expect(hah2).to.eq(constants.WeiPerEther.mul(102).div(100))
                await fomo3D.connect(wallet2).buyKeys(keyNumber,wallet.address,{...overrides,value: hah2})
                ret = await fomo3D.balanceOf(wallet.address)

                await print(wallet1)
                */
                //const v1 = hah0.add(hah1).mul(20).div(100)
                //const v2 = hah2.mul(20).div(100)
                //console.log(ret.toString())
                //console.log(v1.add(v2).toString())
                /*
                const hah3 = await fomo3D.calculateKeyPrice(keyNumber)
                expect(hah3).to.eq(constants.WeiPerEther.mul(103).div(100))
                await fomo3D.connect(wallet3).buyKeys(keyNumber,wallet.address,{...overrides,value: hah3})
                let rc = await fomo3D.roundCount()
                expect(rc).to.eq(0)
                */

                //console.log(ret.toString())
                //ret = await fomo3D.Infos(wallet.address,0)
                //console.log(ret)
                //console.log((await provider.getBlock('latest')).timestamp)
                //await mineBlock(provider, (await provider.getBlock('latest')).timestamp + 3600)
                //console.log((await provider.getBlock('latest')).timestamp)
            })
        })
    })
})