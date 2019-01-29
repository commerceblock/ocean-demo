#This script demonstates the whitelist database io
#Required: cb_idcheck python package
#To run:
#1) Copy whitelistdb.sh (this file) to the ocean-demo dir
#2) cd to ocean-demo
#3) > source init.sh 
#4) > source whitelistdb.sh


echo "***** Whitelisting database*****"
e-cli clearwhitelist
printf "Transaction fails whitelist check:\ne-cli sendtoaddress \$(e1-cli getnewaddress) 100 -> "
e-cli sendtoaddress $(e1-cli getnewaddress) 100
echo "e-cli getrawmempool"
e-cli getrawmempool
printf "\n"

e-cli dumpderivedkeys keys.main
e1-cli dumpderivedkeys keys.client

printf "Adding keys to the mongodb whitelist database."
python ../cb_idcheck/cb_idcheck/demo/whitelistdb.py
printf "Reading all keys from database and adding to node whitelist"
python ../cb_idcheck/cb_idcheck/demo/get_whitelist.py > keys.whitelistdb
e-cli readwhitelist keys.whitelistdb

rm keys.main ; rm keys.client; rm keys.whitelistdb


printf "Transaction added to mempool after reading main node and client node derived keys:\ne-cli sendtoaddress \$(e1-cli getnewaddress) 100 -> "
e-cli sendtoaddress $(e1-cli getnewaddress) 100
echo "e-cli getrawmempool"
e-cli getrawmempool
printf "\n"

./main/new_block.sh
printf "Generate a block and clean mempool\n"
printf "blockcount: "
e-cli getblockcount
printf "\n"
printf "block: "
e-cli getblock $(e-cli getblockhash 2)
printf "\n"
printf "mempool: "
e-cli getrawmempool
printf "\n"
