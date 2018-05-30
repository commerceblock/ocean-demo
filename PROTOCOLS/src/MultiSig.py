#!/usr/bin/env python3
from src.authproxy import AuthServiceProxy, JSONRPCException
import os
import random
import sys
import time
import shutil
import subprocess
from src.util import *

class MultiSig():
    def __init__(self, nodes, sigs, datadir, elementsdir):
        self.num_of_nodes = nodes
        self.num_of_sigs = sigs
        self.datadir = datadir
        self.elements_dir = elementsdir
        self.privkeys = []
        self.multisig = ""

    def generate(self):
        pubkeys = []
        for i in range(0, self.num_of_nodes):
            temp_datadir = "/tmp/"+''.join(random.choice('0123456789ABCDEF') for i in range(5))
            os.makedirs(temp_datadir)
            shutil.copyfile(self.datadir, temp_datadir+"/elements.conf")
            conf = loadConfig(self.datadir)
            e = startelementsd(self.elements_dir, temp_datadir, conf)
            time.sleep(5)

            addr = e.getnewaddress()
            time.sleep(1)
            validate_addr = e.validateaddress(addr)
            time.sleep(1)
            pubkeys.append(validate_addr["pubkey"])
            self.privkeys.append(e.dumpprivkey(addr))
            time.sleep(1)
            e.stop()
            time.sleep(2)
            shutil.rmtree(temp_datadir)


        temp_datadir = "/tmp/"+''.join(random.choice('0123456789ABCDEF') for i in range(5))
        os.makedirs(temp_datadir)
        shutil.copyfile(self.datadir, temp_datadir+"/elements.conf")
        conf = loadConfig(self.datadir)
        e = startelementsd(self.elements_dir, temp_datadir, conf)
        time.sleep(5)
        self.multisig = e.createmultisig(self.num_of_sigs, pubkeys)

        e.stop()
        shutil.rmtree(temp_datadir)
