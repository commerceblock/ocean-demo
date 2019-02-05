# WHITELISTING
echo "***** Whitelisting *****"
printf "Transaction fails whitelist check:\ne-cli sendtoaddress \$(e1-cli getnewaddress) 100 -> "
echo "CBT balance and N_unspent before:"
e-cli getwalletinfo | jq -r ".balance" | jq -r ".CBT"
e-cli listunspent | grep vout | wc -l
txid=`e-cli sendtoaddress $(e1-cli getnewaddress) 100` ; sleep 5
echo "e-cli getrawmempool: (transaction should not appear in mempool)"
e-cli getrawmempool
echo "getting 5 new blocks."
./main/new_block.sh 5
echo "CBT balance and N_unspent after. Output was removed from local wallet list of unspent outputs."
e-cli getwalletinfo | jq -r ".balance" | jq -r ".CBT"
e-cli listunspent | grep vout | wc -l

#Abandon the failed transaction to redeem the unspent output.
echo "Abandoning the failed transaction in order to redeem the unspent output."
e-cli abandontransaction $txid
echo "CBT balance and N_unspent:"
e-cli getwalletinfo | jq -r ".balance" | jq -r ".CBT"
e-cli listunspent | grep vout | wc -l
printf "\n"


e-cli dumpderivedkeys keys.main
e1-cli dumpderivedkeys keys.client
e-cli readwhitelist keys.main
e-cli readwhitelist keys.client
#rm keys.main ; rm keys.client

printf "Transaction added to mempool after reading main node and client node derived keys:\ne-cli sendtoaddress \$(e1-cli getnewaddress) 100 -> "
echo "CBT balance before:"
e-cli getwalletinfo | jq -r ".balance" | jq -r ".CBT"
e-cli sendtoaddress $(e1-cli getnewaddress) 100
echo "CBT balance after:"
e-cli getwalletinfo | jq -r ".balance" | jq -r ".CBT"
echo "e-cli getrawmempool:"
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

printf "Clear the whitelist"
e-cli clearwhitelist
printf "Dump the whitelist"
e-cli dumpwhitelist keys.cleared
printf "Get number of lines in whitelist file"
wc -l keys.cleared
#rm keys.cleared

printf "Transaction fails whitelist check:\ne-cli sendtoaddress \$(e1-cli getnewaddress) 100 -> "
txid=`e-cli sendtoaddress $(e1-cli getnewaddress) 100`
./main/new_block.sh
echo "e-cli getrawmempool:"
e-cli getrawmempool
echo "Abandoning the failed transaction."
e-cli abandontransaction $txid
printf "\n"

