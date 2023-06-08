addrs = []
KeysNumber_G = 0
HAH_G = 0

def Buy(addr):
    global KeysNumber_G
    global HAH_G
    
    if KeysNumber_G == 0:
        HAH_G = addr["HAH"]
        KeysNumber_G = addr["keyNumber"]
    else:
        HAH_G += addr["HAH"]
        m = addr["keyNumber"] * HAH_G / KeysNumber_G
        KeysNumber_G += addr["keyNumber"]
        HAH_G += m
        addr["mask"] += m
    addrs.append(addr)
    
def 分收益():
    for index, addr in enumerate(addrs):
        v = (HAH_G * addr["keyNumber"] / KeysNumber_G) - addr["mask"]
        print(f"{index}收益:{v}")
        
addr0 = {"keyNumber":1,"HAH":1,"mask":0}
Buy(addr0)
addr1 = {"keyNumber":2,"HAH":2,"mask":0}
Buy(addr1)
addr2 = {"keyNumber":3,"HAH":3,"mask":0}
Buy(addr2)
addr3 = {"keyNumber":4,"HAH":4,"mask":0}
Buy(addr3)
分收益()
