import { expect, use } from 'chai'
import { Contract, constants } from 'ethers'
import { MockProvider,deployContract, createFixtureLoader, solidity } from 'ethereum-waffle'

import Fomo3D from '../build/Fomo3D.json';

use(solidity)

const overrides = {
    gasLimit: 9999999
}

describe('fomo3D test', () => {
    let fomo3D : Contract

    const provider = new MockProvider()
    const [wallet, wallet1, wallet2, wallet2_new, wallet3, wallet4, wallet5] = provider.getWallets()

    beforeEach(async () => {
        fomo3D = await deployContract(wallet, Fomo3D)
    })

    it('用例1', async () => {
        describe('--------------------------------', () => {
            it('购买', async () => {
                expect(fomo3D.address).to.eq('0xA193E42526F1FEA8C99AF609dcEabf30C1c29fAA')
            })

            it('竞争', async () => {
                expect(fomo3D.address).to.eq('0xA193E42526F1FEA8C99AF609dcEabf30C1c29fAA')
            })
        
            it('提现', async () => { 
                expect(fomo3D.address).to.eq('0xA193E42526F1FEA8C99AF609dcEabf30C1c29fAA')
            })
        })
    })
})