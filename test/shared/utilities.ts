import { MockProvider } from 'ethereum-waffle'

// await mineBlock(provider, (await provider.getBlock('latest')).timestamp + 3600)
export async function mineBlock(provider: MockProvider, timestamp: number): Promise<void> {
  await new Promise(async (resolve, reject) => {
    ;(provider.provider.sendAsync as any)(
      // evm_increaseTime
      { jsonrpc: '2.0', method: 'evm_increaseTime', params: [timestamp] },
      (error: any, result: any): void => {
        if (error) {
          reject(error)
        } else {
          resolve(result)
        }
      }
    )
  })

  await new Promise(async (resolve, reject) => {
    ;(provider.provider.sendAsync as any)(
      // evm_increaseTime
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

export const Sleep = (ms:any)=> {
  return new Promise(resolve=>setTimeout(resolve, ms))
}
