//import { Contract } from 'ethers'
//import { Web3Provider } from 'ethers/providers'
//import { BigNumber, bigNumberify, keccak256, defaultAbiCoder, toUtf8Bytes, solidityPack } from 'ethers/utils'

//export const MINIMUM_LIQUIDITY = bigNumberify(10).pow(3)
import { MockProvider } from 'ethereum-waffle'

export async function mineBlock(provider: MockProvider, timestamp: number): Promise<void> {
  await new Promise(async (resolve, reject) => {
    ;(provider.provider.sendAsync as any)(
      { jsonrpc: '2.0', method: 'evm_mine', params: [timestamp] },
      (error: any, result: any): void => {
        if (error) {
          reject(error)
        } else {
          resolve(result)
        }
      }
    )
  })
}
