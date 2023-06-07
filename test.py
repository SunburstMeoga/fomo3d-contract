totalKeysSold = 0
BASE_KEY_PRICE = 1
def calculateKeyPrice(numKeys):
    base_price = BASE_KEY_PRICE + BASE_KEY_PRICE * totalKeysSold / 100
    add = (BASE_KEY_PRICE / 100) * (numKeys - 1) * numKeys / 2
    return base_price * numKeys + add
# 7,16
def A():
    global totalKeysSold
    u = {}
    X = []
    Y = []
    for i in range(1,101):
        u[i] = {"A":0,"B":0}
        ret = calculateKeyPrice(100)
        u[i]["A"] = ret
        totalKeysSold += 100
        for j in range(1,i + 1):
            u[j]["B"] += ret * 0.2 / i
    for i in range(1,101):
        #if u[i]["A"] < u[i]["B"]:
        #    print('=======',i,u[i])
        #else:
        #    print(i,u[i])
        print(i,u[i]["B"]/u[i]["A"])
        X.append(i)
        Y.append(u[i]["B"]/u[i]["A"])
    return X,Y
# 13, 50
def B():
    global totalKeysSold
    u = {}
    s = 0
    WS = 0
    X = []
    Y = []
    for i in range(1,101):
        u[i] = {"A":0,"B":0,"C":0}
        ret = calculateKeyPrice(100)
        u[i]["A"] = ret
        totalKeysSold += 100
        s += ret * 0.2
        w = 100 / ret
        u[i]["C"] = w
        WS += w
    for i in range(1,101):
        u[i]["B"] = s / 100
        #u[i]["B"] = s * u[i]["C"] / WS
    for i in range(1,101):
        #if u[i]["A"] < u[i]["B"]:
        #    print('=======',i,u[i])
        #else:
        #    print(i,u[i])
        #print()
        print(i,u[i]["B"]/u[i]["A"])
        X.append(i)
        Y.append(u[i]["B"]/u[i]["A"])
    return X,Y
#a = {}
#a[0] = {"abc":123}
#print(a[0])
totalKeysSold = 0
X,Y = A()
print('==============================')
totalKeysSold = 0
X,Y = B()

#import numpy as np
import matplotlib.pyplot as plt
     
#x = (3,4,5)
#y1 = np.array([3,4,3])
     
plt.plot(X,Y) # 此时x不可省略
plt.show()
