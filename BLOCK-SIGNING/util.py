#!/usr/bin/env python3
from authproxy import AuthServiceProxy, JSONRPCException
import os
import random
import sys
import time
import subprocess
import shutil

ELEMENTS_PATH = "../../ocean/src/elementsd"

def startelementsd(datadir, conf, args=""):
    subprocess.Popen((ELEMENTS_PATH+"  -datadir="+datadir+" "+args).split(), stdout=subprocess.PIPE)
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