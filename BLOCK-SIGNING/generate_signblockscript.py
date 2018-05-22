#!/usr/bin/env python3
from authproxy import AuthServiceProxy, JSONRPCException
import os
import random
import sys
import time
import subprocess
import shutil
from decimal import *
from pdb import set_trace
ELEMENTSPATH="../ocean/src"

if len(sys.argv) == 2:
    ELEMENTSPATH=sys.argv[0]
else:
    ELEMENTSPATH="./../ocean/src"

def startelementsd(datadir, conf, args=""):
    subprocess.Popen(("../ocean/src/elementsd  -datadir="+datadir+" "+args).split(), stdout=subprocess.PIPE)
    return AuthServiceProxy("http://"+conf["rpcuser"]+":"+conf["rpcpassword"]+"@127.0.0.1:"+conf["rpcport"])

def loadConfig(filename):
    conf = {}
    with open(filename) as f:
        for line in f:
            if len(line) == 0 or line[0] == "#" or len(line.split("=")) != 2:
                continue
            conf[line.split("=")[0]] = line.split("=")[1].strip()
    conf["filename"] = filename
    return conf

def sync_all(e1, e2):
    totalWait = 10
    while e1.getblockcount() != e2.getblockcount() or len(e1.getrawmempool()) != len(e2.getrawmempool()):
        totalWait -= 1
        if totalWait == 0:
            raise Exception("Nodes cannot sync blocks or mempool!")
        time.sleep(1)
    return

## Preparations
main_datadir="/tmp/"+''.join(random.choice('0123456789ABCDEF') for i in range(5))
client_datadir="/tmp/"+''.join(random.choice('0123456789ABCDEF') for i in range(5))

os.makedirs(main_datadir)
os.makedirs(client_datadir)

shutil.copyfile("elements.conf", main_datadir+"/elements.conf")
shutil.copyfile("elements-client.conf", client_datadir+"/elements.conf")

mainconf = loadConfig("elements.conf")
clientconf = loadConfig("elements-client.conf")

signblockarg="-signblockscript=512103c4ef1e6deaccbe3b5125321c9ae35966effd222c7d29fb7a13d47fb45ebcb7bf51ae"
key="KwehQp1fsgrNGj38HFE4xbgW42PyZFa5QF4EpDoJco4Tq5g9xXUq"

e = startelementsd(main_datadir, mainconf, signblockarg)
time.sleep(5)
e1 = startelementsd(client_datadir, clientconf, signblockarg)
time.sleep(5)
e.importprivkey(key)

# Let's set it to something more interesting... 2-of-2 multisig

# First lets get some keys from both clients to make our block "challenge"
addr1 = e.getnewaddress()
addr2 = e1.getnewaddress()
valid1 = e.validateaddress(addr1)
pubkey1 = valid1["pubkey"]
valid2 = e1.validateaddress(addr2)
pubkey2 = valid2["pubkey"]

key1 = e.dumpprivkey(addr1)
key2 = e1.dumpprivkey(addr2)
signblockarg="-signblockscript=5221"+pubkey1+"21"+pubkey2+"52ae"

print(key1)
print(key2)
print(signblockarg)

e.stop()
e1.stop()
time.sleep(2)
shutil.rmtree(main_datadir)
shutil.rmtree(client_datadir)