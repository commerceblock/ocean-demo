#!/usr/bin/env python3
from authproxy import AuthServiceProxy, JSONRPCException
import os
import random
import sys
import time
import subprocess
import shutil
import BlockSigner
import logging
import json
from decimal import *
from pdb import set_trace
from kafka import KafkaConsumer, KafkaProducer
from BlockSigner import BlockSigning

def startelementsd(datadir, conf, args=""):
    subprocess.Popen(("../../ocean/src/elementsd  -datadir="+datadir+" "+args).split(), stdout=subprocess.PIPE)
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

def generate_block(e1, e2):
    blockhex = e1.getnewblockhex()
    e1.getblockcount() == 0
    e1.submitblock(blockhex)
    e1.getblockcount() == 0

    sign1 = e1.signblock(blockhex)
    sign2 = e2.signblock(blockhex)
    blockresult = e2.combineblocksigs(blockhex, [sign1, sign2])

    blockresult["complete"] == True
    signedblock = blockresult["hex"]
    e2.submitblock(signedblock)

    e1.getblockcount() == 1
    e1.getblockcount() == 1

if __name__ == "__main__":
    ## Preparations
    main_datadir="/tmp/"+''.join(random.choice('0123456789ABCDEF') for i in range(5))
    client_datadir="/tmp/"+''.join(random.choice('0123456789ABCDEF') for i in range(5))
    explorer_datadir="/tmp/"+''.join(random.choice('0123456789ABCDEF') for i in range(5))

    os.makedirs(main_datadir)
    os.makedirs(client_datadir)
    os.makedirs(explorer_datadir)

    shutil.copyfile("../main/elements.conf", main_datadir+"/elements.conf")
    shutil.copyfile("../client-1/elements.conf", client_datadir+"/elements.conf")
    shutil.copyfile("../explorer/elements.conf", explorer_datadir+"/elements.conf")

    mainconf = loadConfig("../main/elements.conf")
    clientconf = loadConfig("../client-1/elements.conf")
    explconf = loadConfig("../explorer/elements.conf")

    key = "L1tqiDcvS6wz2gVSa1sx2cuDUoomUsidzCHHZA25xTeNk1k5y8W5"
    key1 = "L1b1FzNjKXYomwAE9dUwyG6SMxuGqBPsiGp6pgbVWheQCiCZi8pu"
    signblockarg="-signblockscript=5221037052cdb7b5bd6cdc8a449ab2b9a35f7a361df9735ea09b8ade1d2d2ead71b6852103d65d1b9ded117646890cbab2995a0cd503b0791284fdb64668724a729732b52452ae"

    e = startelementsd(main_datadir, mainconf, signblockarg)
    time.sleep(5)
    e1 = startelementsd(client_datadir, clientconf, signblockarg)
    time.sleep(5)
    ee = startelementsd(explorer_datadir, explconf, signblockarg)
    time.sleep(5)
    e.importprivkey(key)
    e1.importprivkey(key1)

    # Generate no longer works, even if keys are in wallet
    try:
        e.generate(1)
        raise Exception("Generate shouldn't work")
    except JSONRPCException:
        pass

    try:
        e1.generate(1)
        raise Exception("Generate shouldn't work")
    except JSONRPCException:
        pass

    # Let's propose and accept some blocks, e1 is master!
    for i in range(1,2):
        generate_block(e, e1)

    node = BlockSigning(1, e)
    node1 = BlockSigning(0, e1)

    try:
        '''
        logging.basicConfig(
            format='%(asctime)s.%(msecs)s:%(name)s:%(thread)d:%(levelname)s:%(process)d:%(message)s',
            level=logging.INFO
            )
        '''
        node.start()
        node1.start()
        while 1:
            time.sleep(100)       
    except KeyboardInterrupt:
        node.stop()
        node1.stop()
        e.stop()
        e1.stop()
        ee.stop()
        time.sleep(2)
        shutil.rmtree(main_datadir)
        shutil.rmtree(client_datadir)
        shutil.rmtree(explorer_datadir)
