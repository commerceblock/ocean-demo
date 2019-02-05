#This script demonstates the whitelist database io
#Required: cb_idcheck python package
#To run:
#1) Copy whitelistdb.sh (this file) to the ocean-demo dir
#2) cd to ocean-demo
#3) > source setup.sh 
#4) > source blocksigning.sh
#4) > source whitelisting2.sh


echo "***** Whitelisting database*****"
printf "Transaction fails whitelist check:\ne-cli sendtoaddress \$(e1-cli getnewaddress) 100 -> "
printf "\n"
e-cli sendtoaddress $(e1-cli getnewaddress) 100
echo "e-cli getrawmempool"
e-cli getrawmempool
printf "\n"

printf "dumpderviedkeys (main)"
printf "\n"
e-cli dumpderivedkeys keys.main
printf "dumpderviedkeys (client)"
printf "\n"
e1-cli dumpderivedkeys keys.client

e-cli readwhitelist keys.client
e-cli readwhitelist keys.main
e1-cli readwhitelist keys.client
e1-cli readwhitelist keys.main

printf "Transaction added to mempool after reading main node and client node derived keys:\ne-cli sendtoaddress \$(e1-cli getnewaddress) 100 -> "
e-cli sendtoaddress $(e1-cli getnewaddress) 100
echo "e-cli getrawmempool"
e-cli getrawmempool
printf "\n"
./main/new_block.sh 10
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




