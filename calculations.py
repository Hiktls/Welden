from matplotlib import pyplot as plt
import time
import math
import random


math.ln = lambda x : math.log(x, math.e)
prod = lambda q,b : math.e ** (q/b)

def lmsrPrice(weights:list):
    b = 235
    
    return [prod(weights[0],b)/(prod(weights[0],b)+prod(weights[1],b)),prod(weights[1],b)/(prod(weights[0],b)+prod(weights[1],b))]


def calculateSpread(pool):
    spreadFactor = 0.095
    a = spreadFactor / (pool[0] + pool[1])**(1/2)
    b = 0.02 * 1.96


    s = max(0.01,a+b)
    return round(s,2)

def calculateWeight(pool:list):
    if pool[0] == 0:
        pool[0] = 1
    if pool[0] ==0:
        pool[1] = 1

    return [(pool[0]**1)/((pool[0]**1)+(pool[1]**1)) , (pool[1]**1)/((pool[0]**1)+(pool[1]**1))]

def calculateAsk(spread,weight:list):
    return [round(weight[0]*(1+spread),3),round(weight[1]*(1+spread),3)]

def calculateBid(spread,weight:list):
    return [round(weight[0]*(1-spread),3),round(weight[1]*(1-spread),3)]


def marketLeftover(bidVolume,spread):
    total = sum(bidVolume)
    return spread * 2 * total

def simulate(startPool,duration,volumeRate):
    print("Simulation start")
    volume = [[0,0],[0,0]]
    for i in range(duration):
        spread = calculateSpread(startPool)
        ask = calculateAsk(spread,calculateWeight(pool))
        bid = calculateBid(spread,calculateWeight(pool))

        a = random.randint(0,1)
        b = random.randint(0,1)

        volume[a][b] +=   random.choice([1,-1]) * random.randint(0,volumeRate)
        volume[b][a] +=  random.choice([1,-1])* random.randint(0,volumeRate)

        pool[a] += random.choice([1,-1]) * random.randint(0,volumeRate)
        pool[b] += random.choice([1,-1]) * random.randint(0,volumeRate)


        print("Current ASK:",ask)
        print("Current BID:",bid)

        print("SPREAD:",spread)
        print("POOL:",pool)
        time.sleep(0.5)



volume = [[5000,200],[200,300]]
pool = [500,500]


p = lmsrPrice([500,300])

print(p)