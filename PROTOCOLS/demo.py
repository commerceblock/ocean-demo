#!/usr/bin/env python3
import os
import random
import sys
import time
import shutil
import logging
import json
import util
from decimal import *
from pdb import set_trace
from MultiSig import MultiSig
from BlockSigning import BlockSigning
from test_framework.authproxy import AuthServiceProxy, JSONRPCException
from client import Client

ELEMENTS_PATH = "../../ocean/src/elementsd"
ENABLE_LOGGING = False
BLOCK_TIME = 60
GENERATE_KEYS = False

def main():
    # GENERATE KEYS AND SINGBLOCK SCRIPT FOR SIGNING OF NEW BLOCKS
    num_of_nodes = 3
    num_of_sigs = 2
    num_of_clients = 2
    keys = []
    signblockarg = ""
    coinbasearg = ""
    issuecontrolarg = ""
    coindestarg = ""
    coindestkey = ""

    if GENERATE_KEYS:  # generate new signing keys and multisig
        if num_of_sigs > num_of_nodes:
                raise ValueError("Num of sigs cannot be larger than num of nodes")
        block_sig = MultiSig(num_of_nodes, num_of_sigs)
        keys = block_sig.wifs
        signblockarg = "-signblockscript={}".format(block_sig.script)
        coinbasearg = "-con_mandatorycoinbase={}".format(block_sig.script)

        issue_sig = MultiSig(1, 1)
        coindestkey = issue_sig.wifs[0]
        coindestarg = "-initialfreecoinsdestination={}".format(issue_sig.script)
        issuecontrolarg = "-issuecontrolscript={}".format(issue_sig.script)

        with open('federation_data.json', 'w') as data_file:
            data = {"keys" : keys, "signblockarg" : signblockarg, "coinbasearg": coinbasearg, "coindestkey" : coindestkey,
                "coindestarg": coindestarg, "issuecontrolarg": issuecontrolarg}
            json.dump(data, data_file)

    else:   # use hardcoded keys and multisig
        with open('federation_data.json') as data_file:
            data = json.load(data_file)
        keys = data["keys"]
        signblockarg = data["signblockarg"]
        coinbasearg = data["coinbasearg"]
        issuecontrolarg = data["issuecontrolarg"]
        coindestarg = data["coindestarg"]
        coindestkey = data["coindestkey"]

    extra_args =  "{} {} {} {}".format(signblockarg, coinbasearg, issuecontrolarg, coindestarg)

    # INIT THE OCEAN MAIN NODES
    elements_nodes = []
    tmpdir="/tmp/"+''.join(random.choice('0123456789ABCDEF') for i in range(5))
    for i in range(0, num_of_nodes):
        datadir = tmpdir + "/main" + str(i)
        os.makedirs(datadir)

        confdir="main"+str(i)+"/elements.conf"
        shutil.copyfile(confdir, datadir+"/elements.conf")
        mainconf = util.loadConfig(confdir)

        print("Starting node {} with datadir {} and confdir {}".format(i, datadir, confdir))
        e = util.startelementsd(ELEMENTS_PATH, datadir, mainconf, extra_args)
        time.sleep(5)
        elements_nodes.append(e)
        e.importprivkey(keys[i])
        time.sleep(2)

    if ENABLE_LOGGING:
        logging.basicConfig(
                format='%(asctime)s.%(msecs)s:%(name)s:%(thread)d:%(levelname)s:%(process)d:%(message)s',
                level=logging.INFO
                )

    # EXPLORER FULL NODE
    explorer_datadir=tmpdir+"/explorer"
    os.makedirs(explorer_datadir)
    shutil.copyfile("explorer/elements.conf", explorer_datadir+"/elements.conf")
    explconf = util.loadConfig("explorer/elements.conf")
    ee = util.startelementsd(ELEMENTS_PATH, explorer_datadir, explconf, extra_args)
    time.sleep(5)

    node_signers = []
    for i in range(num_of_nodes):
        node = BlockSigning(i, elements_nodes[i], num_of_nodes, BLOCK_TIME)
        node_signers.append(node)
        node.start()

    client = Client(ELEMENTS_PATH, num_of_clients, extra_args, True, coindestkey)
    client.start()

    try:
        while 1:
            time.sleep(300)

    except KeyboardInterrupt:
        for node in node_signers:
            node.stop()

        for elements in elements_nodes:
            elements.stop()

        ee.stop()
        client.stop()

        shutil.rmtree(tmpdir)

if __name__ == "__main__":
    main()
