# INITIAL SETUP
rm -r ~/elementsdir-main ; rm -r ~/elementsdir1 ; rm -r ~/elementsdir-explorer
mkdir ~/elementsdir-main ; mkdir ~/elementsdir1 ; mkdir ~/elementsdir-explorer
mkdir ~/elementsdir1/terms-and-conditions ; 

cp ./main/elements.conf ~/elementsdir-main/elements.conf
cp ./client-1/elements.conf ~/elementsdir1/elements.conf
cp ./explorer/elements.conf ~/elementsdir-explorer/elements.conf
cp latest.txt ~/elementsdir1/terms-and-conditions/latest.txt

shopt -s expand_aliases

ELEMENTSPATH="../ocean/src"

alias e-cli="$ELEMENTSPATH/elements-cli -datadir=$HOME/elementsdir-main"
alias e-dae="$ELEMENTSPATH/elementsd -datadir=$HOME/elementsdir-main"
alias e1-cli="$ELEMENTSPATH/elements-cli -datadir=$HOME/elementsdir1"
alias e1-dae="$ELEMENTSPATH/elementsd -datadir=$HOME/elementsdir1"
alias ee-cli="$ELEMENTSPATH/elements-cli -datadir=$HOME/elementsdir-explorer"
alias ee-dae="$ELEMENTSPATH/elementsd -datadir=$HOME/elementsdir-explorer"

e-dae ; sleep 5

# Generate sing block script 
ADDR1=$(e-cli getnewaddress) ; sleep 1
VALID1=$(e-cli validateaddress $ADDR1) ; sleep 1
PUBKEY1=$(echo $VALID1 | python3 -c "import sys, json; print(json.load(sys.stdin)['pubkey'])") ; sleep 1
KEY1=$(e-cli dumpprivkey $ADDR1) ; sleep 1

e-cli stop ; sleep 1

SIGNBLOCKARG="-signblockscript=5121$(echo $PUBKEY1)51ae" ; sleep 1

# Wipe out the chain and wallet to get funds with new genesis block
# You can not swap out blocksigner sets as of now for security reasons,
# so we start fresh on a new chain.
rm -r ~/elementsdir-main ;
mkdir ~/elementsdir-main ; mkdir ~/elementsdir-main/terms-and-conditions ; 
cp ./main/elements.conf ~/elementsdir-main/elements.conf; cp latest.txt ~/elementsdir-main/terms-and-conditions/latest.txt

# TODO: ASSET ISSUANCE 


# BLOCK SIGNING
echo ""
echo "***** Block Signing *****"
e-dae $SIGNBLOCKARG ; sleep 5
e-cli importprivkey $KEY1 ; sleep 1
./main/new_block.sh
printf "Generate a block from the main node:\ne-cli getblockcount -> "
e-cli getblockcount

e1-dae $SIGNBLOCKARG ; sleep 5
ee-dae $SIGNBLOCKARG ; sleep 5
printf "Block broadcast to client node:\ne1-cli getblockcount -> "
e1-cli getblockcount

./client-1/new_block.sh
printf "Client node cannot generate a new block:\ne-cli getblockcount -> "
e-cli getblockcount


# WHITELISTING
echo ""
echo "***** Whitelisting *****"
printf "Transaction fails whitelist check:\ne-cli sendtoaddress \$(e1-cli getnewaddress) 100 -> "
e-cli sendtoaddress $(e1-cli getnewaddress) 100
echo "e-cli getrawmempool"
e-cli getrawmempool

e-cli dumpderivedkeys keys.main
e1-cli dumpderivedkeys keys.client
e-cli readwhitelist keys.main
e-cli readwhitelist keys.client
rm keys.main ; rm keys.client

printf "Transaction added to mempool after reading main node and client node derived keys:\ne-cli sendtoaddress \$(e1-cli getnewaddress) 100 -> "
e-cli sendtoaddress $(e1-cli getnewaddress) 100
echo "e-cli getrawmempool"
e-cli getrawmempool
