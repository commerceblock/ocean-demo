#This script demonstates the whitelist database io
#Required: cb_idcheck python package
#To run:
#1) Copy whitelistdb.sh (this file) to the ocean-demo dir
#2) cd to ocean-demo
#3) > source setup.sh 
#4) > source blocksigning.sh
#4) > source whitelisting2.sh


echo "***** Whitelisting database*****"
#e-cli clearwhitelist
#printf "Transaction fails whitelist check:\ne-cli sendtoaddress \$(e1-cli getnewaddress) 100 -> "
#printf "\n"
#e-cli sendtoaddress $(e1-cli getnewaddress) 100
#echo "e-cli getrawmempool"
#e-cli getrawmempool
#printf "\n"

printf "dumpderviedkeys (main)"
printf "\n"
e-cli dumpderivedkeys keys.main
#cat keys.main

printf "dumpderviedkeys (client)"
printf "\n"
e1-cli dumpderivedkeys keys.client
#cat keys.client
e1-cli readwhitelist keys.client
e1-cli readwhitelist keys.main
e-cli readwhitelist keys.client
e-cli readwhitelist keys.main


printf "Getting KYC key and raw public key from main."
printf "\n"
kycKey=`e-cli getnewaddress`
kycDerivedPubKey=`e-cli validateaddress $kycKey | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\"//p'`
kycPubKey=`e-cli validateaddress $kycKey | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`
printf "Getting address and raw public key from client."
printf "\n"
clientAddress1=`e1-cli getnewaddress`
clientPubKey1=`e1-cli validateaddress $clientAddress1 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`
clientAddress2=`e1-cli getnewaddress`
clientPubKey2=`e1-cli validateaddress $clientAddress2 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`
clientAddress3=`e1-cli getnewaddress`
clientPubKey3=`e1-cli validateaddress $clientAddress3 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`

main/new_block.sh 10
printf "Main wallet balance:"
e-cli getbalance

printf "Pay funds to client address 1."
printf "\n"
e-cli sendtoaddress $clientAddress1 100 "from" "me" false "CBT"
e-cli sendtoaddress $clientAddress1 100 
main/new_block.sh 10
main/new_block.sh 10
printf "Main wallet balance:"
e-cli getbalance
printf "Client wallet balance:"
e1-cli getbalance


#printf "Clear whitelist."
#e-cli clearwhitelist
#e1-cli clearwhitelist

printf "Add client addresses 1 to 3  to local memory whitelists."
printf "Adding client addresses to whitelist."
printf "\n"
e-cli addtowhitelist $clientAddress1 $clientPubKey1 $kycKey
e-cli addtowhitelist $clientAddress2 $clientPubKey2 $kycKey
e-cli addtowhitelist $clientAddress3 $clientPubKey3 $kycKey
e1-cli addtowhitelist $clientAddress1 $clientPubKey1 $kycKey
e1-cli addtowhitelist $clientAddress2 $clientPubKey2 $kycKey
e1-cli addtowhitelist $clientAddress3 $clientPubKey3 $kycKey

printf "Client request to register 10 new addresses."
printf "\n"
#e1-cli sendaddtowhitelisttx $clientAddress1 "CBT" "1" $kycPubKey
#e1-cli sendaddtowhitelisttx $clientAddress1 "CBT" "1" $kycDerivedPubKey

printf "Transaction added to mempool after reading main node and client node derived keys:\ne-cli sendtoaddress \$(e1-cli getnewaddress) 100 -> "
printf "\n"
#e-cli sendtoaddress $(e1-cli getnewaddress) 100
echo "e-cli getrawmempool"
#e-cli getrawmempool
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

main/new_block.sh 10
e-cli dumpwhitelist whitelist.txt
cat whitelist.txt