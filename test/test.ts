import { assert, expect, use } from 'chai'
import { Contract, constants, BigNumber,utils,FixedNumber } from 'ethers'
import { MockProvider, deployContract, solidity } from 'ethereum-waffle'
import {Wallet} from 'ethers'

import Test from '../build/Test.json';

use(solidity)

const overrides = {
    gasLimit: 9999999
}

describe('基本测试', () => {
    
    let test: Contract
    
    //const provider = new MockProvider()    
    
    //const [wallet, wallet1, wallet2, wallet3, wallet4, wallet5] = provider.getWallets()

    beforeEach(async () => {
        //test = await deployContract(wallet, Test)
    })
    
    it('随机数测试', async () => {
      /*
        await test.begin()
        const bn = await test.bn()
        const c_bn = await provider.getBlockNumber()
        for (let i = 0; i <= bn - c_bn; i++) {
            await wallet.sendTransaction({
                "to": wallet.address,
                "value": constants.WeiPerEther,
            });
        }
        */
        let obj1 = FixedNumber.from('2')
        let obj2 = FixedNumber.from('3')
        console.log(utils.parseEther(obj1.divUnsafe(obj2).toString()).toString())
    })
})