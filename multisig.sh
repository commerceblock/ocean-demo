# INITIAL SETUP
rm -r ~/elementsdir-main ; 
mkdir ~/elementsdir-main ; 

cp ./main/elements.conf ~/elementsdir-main/elements.conf
cp latest.txt ~/elementsdir1/terms-and-conditions/latest.txt

shopt -s expand_aliases

ELEMENTSPATH="../ocean/src"

alias e-cli="$ELEMENTSPATH/elements-cli -datadir=$HOME/elementsdir-main"
alias e-dae="$ELEMENTSPATH/elementsd -datadir=$HOME/elementsdir-main"

e-dae ; sleep 5

# Generate sing block script 
ADDR1=$(e-cli getnewaddress) ; sleep 1
VALID1=$(e-cli validateaddress $ADDR1) ; sleep 1
PUBKEY1=$(echo $VALID1 | python3 -c "import sys, json; print(json.load(sys.stdin)['pubkey'])") ; sleep 1
KEY1=$(e-cli dumpprivkey $ADDR1) ; sleep 1

e-cli stop ; sleep 1

SIGNBLOCKARG="-signblockscript=5121$(echo $PUBKEY1)51ae" ; sleep 1
echo "SINGBLOCKSCRIPT: " + $SIGNBLOCKARG
echo "KEY: " + $KEY1
