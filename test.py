def FunA(a):
    for i in range(1,21):
        负利息 = a * 0.01
        a = a - 负利息 - 1
        print(f'第{i}年负利息{负利息},剩余金额:{a}')

def FunB(a):
    tv = 0
    for i in range(1,21):
        有效时间 = i - tv
        负利息 = 1 * 0.01 * 有效时间
        tv = (i - tv) * (1 / a) + tv
        a = a - 负利息 - 1
        print(f'第{i}年负利息{负利息},剩余金额:{a}')
        #print(tv)

A = 100
FunA(A)
FunB(A)

# 负利率年化为:1%，秒化为:0.01 / (365 * 24 * 3600) = 0.00000000031709791983764585
# 