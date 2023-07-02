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
- 0xe7c5F699d528716F4809029a4b518BEd6030BE21

### 个人账户查询
```js
function Infos2(address addr) public view returns(uint withd,uint spend,uint spend_s,uint numKey,uint numKey_s,uint utc)
```
- withd 提现的金额  
- spend 本轮花费的金额  
- spend_s 所有轮的花费金额汇总  
- numKey 本轮Key的数量  
- numKey_s 所有轮的Key数量汇总  
- utc 上次出块时间(无法得到当前准确时间)  

### 可提现金额
```js
function balanceOf(address addr) public view returns(uint)
```
### 全局游戏查询
```js
function rounds() public view returns(uint totalKeysSold,uint totalKeysSold_s,uint totalHAH,uint totalHAH_s) 
```
- totalKeysSold: 本轮卖出的Key数量
- totalKeysSold_s：所有轮卖出的Key数量合计
- totalHAH: 本轮购买Key花费的金额
- totalHAH_s:  所有轮购买Key花费金额合计

### 提现操作
```js
function withdrawal(uint v)
```
### 推广信息
```js
function Inviter(address addr) public view returns(uint Amount,uint Number)
```
- Amount: 推广的盈利金额
- Number: 推广的数量

### 当前轮指定地址的购买Keys收益
```js
function expectIncome(address addr) public view returns (uint) 
```
- addr: 指定地址 
- 返回值：收益大小 
