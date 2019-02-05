# INITIAL SETUP
rm -r ~/elementsdir-main ; rm -r ~/elementsdir1 ; rm -r ~/elementsdir-explorer
mkdir ~/elementsdir-main ; mkdir ~/elementsdir1 ; mkdir ~/elementsdir-explorer
mkdir ~/elementsdir1/terms-and-conditions ; mkdir ~/elementsdir-main/terms-and-conditions ; mkdir ~/elementsdir-explorer/terms-and-conditions
mkdir ~/elementsdir1/asset-mapping ; mkdir ~/elementsdir-main/asset-mapping ; mkdir ~/elementsdir-explorer/asset-mapping

cp ./main/elements.conf ~/elementsdir-main/elements.conf
cp ./client-1/elements.conf ~/elementsdir1/elements.conf
cp ./explorer/elements.conf ~/elementsdir-explorer/elements.conf

cp latest.txt ~/elementsdir-main/terms-and-conditions/latest.txt
cp latest.txt ~/elementsdir1/terms-and-conditions/latest.txt
cp latest.txt ~/elementsdir-explorer/terms-and-conditions/latest.txt

cp latest.json ~/elementsdir-main/asset-mapping/latest.json
cp latest.json ~/elementsdir1/asset-mapping/latest.json
cp latest.json ~/elementsdir-explorer/asset-mapping/latest.json

shopt -s expand_aliases

ELEMENTSPATH="../ocean/src"

alias e-cli="$ELEMENTSPATH/elements-cli -datadir=$HOME/elementsdir-main"
alias e-dae="$ELEMENTSPATH/elementsd -datadir=$HOME/elementsdir-main"
alias e1-cli="$ELEMENTSPATH/elements-cli -datadir=$HOME/elementsdir1"
alias e1-dae="$ELEMENTSPATH/elementsd -datadir=$HOME/elementsdir1"
alias ee-cli="$ELEMENTSPATH/elements-cli -datadir=$HOME/elementsdir-explorer"
alias ee-dae="$ELEMENTSPATH/elementsd -datadir=$HOME/elementsdir-explorer"

SIGNBLOCKARG="-signblockscript=512103c4ef1e6deaccbe3b5125321c9ae35966effd222c7d29fb7a13d47fb45ebcb7bf51ae" ; sleep 1
KEY="KwehQp1fsgrNGj38HFE4xbgW42PyZFa5QF4EpDoJco4Tq5g9xXUq"

# BLOCK SIGNING
echo "***** Block Signing *****"
e-dae $SIGNBLOCKARG ; sleep 5
e-cli importprivkey $KEY ; sleep 1
./main/new_block.sh
printf "Generate a block from the main node:\ne-cli getblockcount -> "
e-cli getblockcount
printf "\n"

e1-dae $SIGNBLOCKARG ; sleep 5
ee-dae $SIGNBLOCKARG ; sleep 5
printf "Block broadcast to client node:\ne1-cli getblockcount -> "
e1-cli getblockcount
printf "\n"

./client-1/new_block.sh
printf "Client node cannot generate a new block. Block cound has not increased:\ne-cli getblockcount -> "
e-cli getblockcount
printf "\n"

# WHITELISTING
echo "***** Whitelisting *****"
printf "Transaction fails whitelist check:\ne-cli sendtoaddress \$(e1-cli getnewaddress) 100 -> "
e-cli sendtoaddress $(e1-cli getnewaddress) 100
echo "e-cli getrawmempool"
e-cli getrawmempool
printf "\n"

e-cli dumpderivedkeys keys.main
e1-cli dumpderivedkeys keys.client
e-cli readwhitelist keys.main
e-cli readwhitelist keys.client
rm keys.main ; rm keys.client

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

# ASSET ISSUANCE
echo "***** Asset Issuance *****"

issue=$(e-cli issueasset 100 1 false)
asset=$(echo $issue | jq --raw-output '.asset')
printf "Issuance\n $issue\n"
printf "Asset $asset\n"

e-cli sendtoaddress $(e1-cli getnewaddress) 80 "" "" false $asset
e-cli sendtoaddress $(e1-cli getnewaddress) 10 "" "" true $asset
e-cli getrawmempool
./main/new_block.sh 10
e-cli getblock $(e-cli getblockhash 3)

#WHITELISTING 2

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

