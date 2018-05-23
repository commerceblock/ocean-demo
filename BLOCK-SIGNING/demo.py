#!/usr/bin/env python3
from authproxy import AuthServiceProxy, JSONRPCException
import os
import random
import sys
import time
import subprocess
import shutil
import logging
import json
from decimal import *
from pdb import set_trace
from kafka import KafkaConsumer, KafkaProducer
from Signer import BlockSigning
from MultiSig import MultiSig
from Client import Client
from util import *

ELEMENTS_PATH = "../../ocean/src/elementsd"

def main():
    num_of_nodes = 3
    num_of_sigs = 2
    keys = []
    signblockarg = ""
    if len(sys.argv) == 3: # generate new signing keys and multisig
        num_of_nodes = sys.argv[1]
        num_of_nodes = sys.argv[2]
        if num_of_sigs > num_of_nodes:
            raise ValueError("Num of sigs cannot be larger than num of nodes")

        print("Generating {} of {} multisig".format(num_of_sigs, num_of_nodes))
        sig = MultiSig(num_of_nodes, num_of_sigs, "../main/elements.conf", ELEMENTS_PATH)
        sig.generate()
        # THIS NEWLY GENERATED KEYS WILL HAVE TO BE COPIED TO OTHER NODES IN THE DEMO
        keys = sig.privkeys
        print(keys)
        signblockarg = "-signblockscript={}".format(sig.multisig["redeemScript"])
        print("Generated: {}".format(signblockarg))
    else: # use hardcoded keys and multisig
        print("Using hardcoded keys and multisig")

        keys = ['Kz4aMbbciZrjrNBi4rwwrTemGKbj9qCdVVRKXAvyt1YK1mPFpRG8',
                'Ky4A1C5xeTDSR4SWey6Lees9WHjGTfgVAK3vWngCjWQDFs5UqHx3',
                'L5dPkjz7hzhGCfYAd19fDWsetdCCwUPRPtt3bLh7SSTrh3DFNY34']

        signblockarg = "-signblockscript=522103d517f6e9affa60000a08d478970e6bbfa45d63b1967ed1e066dd46b802edb2a62102afc18e8a7ff988ca1ae7b659cb09a79852d301c2283e18cba1faf7a0b020b1a22102edd8080e31f05c68cf68a97782ac97744e86ba19dfd3ba68e597f10868ee5bc453ae"

    elements_nodes = []
    elements_datadirs = []
    for i in range(0, num_of_nodes): # spawn elements signing node
        confdir="main"+str(i)+"/elements.conf"
        datadir="/tmp/"+''.join(random.choice('0123456789ABCDEF') for i in range(5))
        os.makedirs(datadir)
        elements_datadirs.append(datadir)
        shutil.copyfile(confdir, datadir+"/elements.conf")
        mainconf = loadConfig(confdir)
        print("Starting node {} with datadir {} and confdir {}".format(i, datadir, confdir))
        e = startelementsd(datadir, mainconf, signblockarg)
        time.sleep(10)
        elements_nodes.append(e)
        e.importprivkey(keys[i])
        time.sleep(2)

    '''
    logging.basicConfig(
            format='%(asctime)s.%(msecs)s:%(name)s:%(thread)d:%(levelname)s:%(process)d:%(message)s',
            level=logging.INFO
            )
    '''

    # EXPLORER FULL NODE
    explorer_datadir="/tmp/"+''.join(random.choice('0123456789ABCDEF') for i in range(5))
    os.makedirs(explorer_datadir)
    shutil.copyfile("explorer/elements.conf", explorer_datadir+"/elements.conf")
    explconf = loadConfig("explorer/elements.conf")
    ee = startelementsd(explorer_datadir, explconf, signblockarg)
    time.sleep(5)

    node_signers = []
    for i in range(0, num_of_nodes):
        node = BlockSigning(i, elements_nodes[i], num_of_nodes)
        node_signers.append(node)

    for node in node_signers:
        node.start()

    client = Client()
    client.start()

    try:
        while 1:
            print("**EXPLORER**\nblockcount: {} latestblockhash: {}".format(ee.getblockcount(), ee.getbestblockhash()))
            time.sleep(180)
       
    except KeyboardInterrupt:
        for node in node_signers:
            node.stop()

        for elements in elements_nodes:
            elements.stop()

        ee.stop()
        client.stop()

        for datadir in elements_datadirs:
            shutil.rmtree(datadir)

if __name__ == "__main__":
    main()
