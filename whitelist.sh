# WHITELISTING
echo "***** Whitelisting *****"
printf "Dumping derived keys"
e-cli dumpderivedkeys keys.main
e1-cli dumpderivedkeys keys.client

printf "Transaction fails whitelist check:\ne-cli sendtoaddress \$(e1-cli getnewaddress) 100 -> "
e-cli sendtoaddress $(e1-cli getnewaddress) 100
echo "e-cli getrawmempool"
e-cli getrawmempool
printf "\n"

printf "Getting KYC key and raw public key from main."
printf "\n"
kycKey=`e-cli getnewaddress`
kycDerivedPubKey=`e-cli validateaddress $kycKey | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\"//p'`
kycPubKey=`e-cli validateaddress $kycKey | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`

kycKey2=`e-cli getnewaddress`
kycDerivedPubKey2=`e-cli validateaddress $kycKey | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\"//p'`
kycPubKey2=`e-cli validateaddress $kycKey | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`

printf "Adding client and server addresses to whitelists."
e-cli readwhitelist keys.main $kyckey2 
e-cli readwhitelist keys.client $kycKey
e1-cli readwhitelist keys.main $kyckey2
e1-cli readwhitelist keys.client $kycKey
#rm keys.main ; rm keys.client

printf "Getting address and raw public key from client."
printf "\n"
clientAddress1=`e1-cli getnewaddress`
clientPubKey1=`e1-cli validateaddress $clientAddress1 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`
clientAddress2=`e1-cli getnewaddress`
clientPubKey2=`e1-cli validateaddress $clientAddress2 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`
clientAddress3=`e1-cli getnewaddress`
clientPubKey3=`e1-cli validateaddress $clientAddress3 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`

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

