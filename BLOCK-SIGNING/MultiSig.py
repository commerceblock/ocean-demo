#!/usr/bin/env python3
from authproxy import AuthServiceProxy, JSONRPCException
import os
import random
import sys
import time
import shutil
import subprocess

class MultiSig():
    def __init__(self, nodes, sigs, datadir, elements):
        self.num_of_nodes = nodes
        self.num_of_sigs = sigs
        self.datadir = datadir
        self.elements = elements
        self.privkeys = []
        self.multisig = ""

    def startelementsd(self, datadir, conf, args=""):
        subprocess.Popen((self.elements + "  -datadir="+datadir+" "+args).split(), stdout=subprocess.PIPE)
        return AuthServiceProxy("http://"+conf["rpcuser"]+":"+conf["rpcpassword"]+"@127.0.0.1:"+conf["rpcport"])

    def loadConfig(self, filename):
        conf = {}
        with open(filename) as f:
            for line in f:
                if len(line) == 0 or line[0] == "#" or len(line.split("=")) != 2:
                    continue
                conf[line.split("=")[0]] = line.split("=")[1].strip()
        conf["filename"] = filename
        return conf

    def generate(self):
        pubkeys = []
        for i in range(0, self.num_of_nodes):
            temp_datadir = "/tmp/"+''.join(random.choice('0123456789ABCDEF') for i in range(5))
            os.makedirs(temp_datadir)
            shutil.copyfile(self.datadir, temp_datadir+"/elements.conf")
            conf = self.loadConfig(self.datadir)
            e = self.startelementsd(temp_datadir, conf)
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
        conf = self.loadConfig(self.datadir)
        e = self.startelementsd(temp_datadir, conf)
        time.sleep(5)
        self.multisig = e.createmultisig(self.num_of_sigs, pubkeys)

        e.stop()
        shutil.rmtree(temp_datadir)
