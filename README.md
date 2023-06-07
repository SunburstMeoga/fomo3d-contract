## fomo3D
### 生成单文件合约
``` shell
npx waffle flatten

```

### 编译合约
``` shell
yarn build

```


### 测试用例
``` shell
yarn test

```
### 新合约地址
0x68D733268C56EE4d3Cd3e6867f00ffdDA21D4D89
个人账户查询
function Infos(address addr) public view returns(uint withd,uint spend,uint spend_s,uint numKey,uint numKey_s,uint expectIncome)
withd 提现的金额
spend 本轮花费的金额
spend_s 所有轮的花费金额汇总
numKey 本轮Key的数量
numKey_s 所有轮的Key数量汇总
expectIncome 预估收益 

可提现金额
function balanceOf(address addr) public view returns(uint)
全局游戏查询
function rounds() public view returns(uint totalKeysSold,uint totalKeysSold_s,uint totalHAH,uint totalHAH_s) 
totalKeysSold: 本轮卖出的Key数量
totalKeysSold_s：所有轮卖出的Key数量合计
totalHAH: 本轮购买Key花费的金额
totalHAH_s:  所有轮购买Key花费金额合计


