#!/usr/bin/env python
from authproxy import AuthServiceProxy, JSONRPCException
import multiprocessing
from util import *

class Client(multiprocessing.Process):
    def __init__(self):
        multiprocessing.Process.__init__(self)
        self.daemon = True
        self.stop_event = multiprocessing.Event()
        self.elements_nodes = []
        self.elements_datadirs = []
        self.num_of_nodes = 2
        self.interval = 300

        signblockarg = "-signblockscript=522103d517f6e9affa60000a08d478970e6bbfa45d63b1967ed1e066dd46b802edb2a62102afc18e8a7ff988ca1ae7b659cb09a79852d301c2283e18cba1faf7a0b020b1a22102edd8080e31f05c68cf68a97782ac97744e86ba19dfd3ba68e597f10868ee5bc453ae"
        
        self.assets = ["BTC", "ETH"]

        for i in range(0, self.num_of_nodes): # spawn elements signing node
            confdir="client"+str(i)+"/elements.conf"
            datadir="/tmp/"+''.join(random.choice('0123456789ABCDEF') for i in range(5))
            os.makedirs(datadir)
            self.elements_datadirs.append(datadir)
            shutil.copyfile(confdir, datadir+"/elements.conf")
            mainconf = loadConfig(confdir)
            print("Starting node {} with datadir {} and confdir {}".format(i, datadir, confdir))
            e = startelementsd(datadir, mainconf, signblockarg)
            time.sleep(10)
            issue = e.issueasset(1000000, 0, False)
            entry = "-assetdir="+issue["asset"]+":"+self.assets[i]
            e.stop()
            time.sleep(5)
            e = startelementsd(datadir, mainconf, signblockarg + " " + entry)
            time.sleep(10)
            print(e.listissuances())
            self.elements_nodes.append(e)

    def stop(self):
        for e in self.elements_nodes:
            e.stop()
        for datadir in self.elements_datadirs:
            shutil.rmtree(datadir)
        self.stop_event.set()

    def run(self): 
        myTurn = True
        while not self.stop_event.is_set():
            addr = self.elements_nodes[0 if myTurn else 1].getnewaddress()
            time.sleep(5)
            #self.elements_nodes[1 if myTurn else 0].sendtoaddress(addr, 1)
            time.sleep(5)
            self.elements_nodes[1 if myTurn else 0].sendtoaddress(addr, 2, "", "", False, self.assets[1 if myTurn else 0])
            time.sleep(2)
            myTurn = not myTurn
            
            time.sleep(self.interval)
            if self.stop_event.is_set():
                break
