# INITIAL SETUP
rm -r ~/oceandir-main ;
mkdir ~/oceandir-main ;

cp ./main/ocean.conf ~/oceandir-main/ocean.conf
cp latest.txt ~/oceandir1/terms-and-conditions/ocean_test/latest.txt

shopt -s expand_aliases

OCEANPATH="../ocean/src"

alias e-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir-main"
alias e-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir-main"

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
