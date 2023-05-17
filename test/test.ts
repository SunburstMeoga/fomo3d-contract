import { assert, expect, use } from 'chai'
import { Contract, constants, BigNumber,utils,FixedNumber } from 'ethers'
import { MockProvider, deployContract, solidity } from 'ethereum-waffle'
import {Wallet} from 'ethers'

import Test from '../build/Test.json';

use(solidity)

const overrides = {
    gasLimit: 9999999
}

describe('test daemon', () => {
    
    let test: Contract
    
    const provider = new MockProvider()    
    
    const [wallet, wallet1, wallet2, wallet3, wallet4, wallet5] = provider.getWallets()

    beforeEach(async () => {
        test = await deployContract(wallet, Test)
    })
    
    it('重复合约创建测试', async () => {
      /*
        const v = constants.One.mul(10).pow(18)
        let ret = await test.Shang(v)
        console.log(utils.formatEther(ret))
        ret = utils.getContractAddress({
            from: '0x1e7e6f6e85668dd1783f3f94a45f71a716eaf5cb',
            nonce: 22
        })
        console.log(ret)
        */
       await test.begin(1)
       //console.log(await test.addr())
       await expect(test.begin(1)).to.be.reverted
       await test.begin(2)
       //console.log(await test.addr())
       //let ret = await provider.getBalance(wallet.address)
       //console.log(ret)
       let ret = BigNumber.from('0x11')
       console.log(ret)
    })
})