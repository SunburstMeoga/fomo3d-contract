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
    for i in range(1,101):
        u[i] = {"A":0,"B":0}
        ret = calculateKeyPrice(100)
        u[i]["A"] = ret
        totalKeysSold += 100
        for j in range(1,i + 1):
            u[j]["B"] += ret * 0.2 / i
    for i in range(1,101):
        if u[i]["A"] < u[i]["B"]:
            print('=======',i,u[i])
        else:
            print(i,u[i])
# 13, 50
def B():
    global totalKeysSold
    u = {}
    s = 0
    for i in range(1,101):
        u[i] = {"A":0,"B":0}
        ret = calculateKeyPrice(100)
        u[i]["A"] = ret
        totalKeysSold += 100
        s += ret
    for i in range(1,101):
        u[i]["B"] = s / 100
    for i in range(1,101):
        if u[i]["A"] < u[i]["B"]:
            print('=======',i,u[i])
        else:
            print(i,u[i])
#a = {}
#a[0] = {"abc":123}
#print(a[0])
totalKeysSold = 0
B()
#print('==============================')
#totalKeysSold = 0
#B()
