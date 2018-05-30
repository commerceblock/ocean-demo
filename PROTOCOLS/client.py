#!/usr/bin/env python
from src.authproxy import AuthServiceProxy, JSONRPCException
import time
import multiprocessing
from src.util import *
from src.AssetIssuance import AssetIssuance

TOTAL = 2
INTERVAL = 10
ASSETS = ["BTC", "ETH"]
ISSUANCE = 1000000
REISSUANCE = 0

class Client(multiprocessing.Process):
    def __init__(self, elementsdir, signblockarg, myissuance=True):
        multiprocessing.Process.__init__(self)
        self.daemon = True
        self.stop_event = multiprocessing.Event()
        self.elements_dir = elementsdir
        self.elements_nodes = []
        self.elements_datadirs = []
        self.num_of_nodes = TOTAL
        self.assets = ASSETS
        self.my_issuance = myissuance
        self.issuers = []
        self.interval = INTERVAL
        self.signblockarg = signblockarg

        for i in range(0, self.num_of_nodes): # spawn elements signing node
            confdir="client"+str(i)+"/elements.conf"
            datadir="/tmp/"+''.join(random.choice('0123456789ABCDEF') for i in range(5))
            os.makedirs(datadir)
            self.elements_datadirs.append(datadir)
            shutil.copyfile(confdir, datadir+"/elements.conf")
            mainconf = loadConfig(confdir)
            print("Starting node {} with datadir {} and confdir {}".format(i, datadir, confdir))
            e = startelementsd(self.elements_dir, datadir, mainconf, signblockarg)
            time.sleep(10)
            if not self.my_issuance:
                issuer = AssetIssuance(e, self.interval)
                issuer.start()
                self.issuers.append(issuer)
            else:
                issue = e.issueasset(ISSUANCE, REISSUANCE, False)
                entry = "-assetdir="+issue["asset"]+":"+self.assets[i]
                e.stop()
                time.sleep(5)
                e = startelementsd(self.elements_dir, datadir, mainconf, signblockarg + " " + entry)
                time.sleep(10)
                print(e.listissuances())
            self.elements_nodes.append(e)

    def stop(self):
        for e in self.elements_nodes:
            e.stop()
        for datadir in self.elements_datadirs:
            shutil.rmtree(datadir)
        for issuer in self.issuers:
            issuer.stop()
        self.stop_event.set()

    def run(self): 
        myTurn = True
        while not self.stop_event.is_set():
            if self.my_issuance:
                addr = self.elements_nodes[0 if myTurn else 1].getnewaddress()
                time.sleep(2)
                self.elements_nodes[1 if myTurn else 0].sendtoaddress(addr, 1)
                time.sleep(2)
                self.elements_nodes[1 if myTurn else 0].sendtoaddress(addr, 2, "", "", False, self.assets[1 if myTurn else 0])
                time.sleep(2)
                myTurn = not myTurn
            
            time.sleep(self.interval)
            if self.stop_event.is_set():
                break

if __name__ == "__main__":
    path = "../../ocean/src/elementsd"
    c = Client(path)
    c.start()

    try:
        while 1:
            time.sleep(300)
       
    except KeyboardInterrupt:
        c.stop()
