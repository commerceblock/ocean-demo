# INITIAL SETUP
rm -r ~/oceandir-main ; rm -r ~/oceandir1 ; rm -r ~/oceandir-explorer
mkdir ~/oceandir-main ; mkdir ~/oceandir1 ; mkdir ~/oceandir-explorer
mkdir ~/oceandir1/terms-and-conditions ; mkdir ~/oceandir-main/terms-and-conditions ; mkdir ~/oceandir-explorer/terms-and-conditions
mkdir ~/oceandir1/asset-mapping ; mkdir ~/oceandir-main/asset-mapping ; mkdir ~/oceandir-explorer/asset-mapping

cp ./main/ocean.conf ~/oceandir-main/ocean.conf
cp ./client-1/ocean.conf ~/oceandir1/ocean.conf
cp ./explorer/ocean.conf ~/oceandir-explorer/ocean.conf

cp latest.txt ~/oceandir-main/terms-and-conditions/latest.txt
cp latest.txt ~/oceandir1/terms-and-conditions/latest.txt
cp latest.txt ~/oceandir-explorer/terms-and-conditions/latest.txt

cp latest.json ~/oceandir-main/asset-mapping/latest.json
cp latest.json ~/oceandir1/asset-mapping/latest.json
cp latest.json ~/oceandir-explorer/asset-mapping/latest.json

shopt -s expand_aliases

OCEANPATH="../ocean/src"

alias e-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir-main"
alias e-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir-main"
alias e1-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir1"
alias e1-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir1"
alias ee-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir-explorer"
alias ee-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir-explorer"

SIGNBLOCKARG="-signblockscript=512103c4ef1e6deaccbe3b5125321c9ae35966effd222c7d29fb7a13d47fb45ebcb7bf51ae" ; sleep 1
KEY="KwehQp1fsgrNGj38HFE4xbgW42PyZFa5QF4EpDoJco4Tq5g9xXUq"



# BLOCK SIGNING
echo "***** Block Signing *****"
e-dae $SIGNBLOCKARG ; sleep 10
e-cli importprivkey $KEY; sleep 3
./main/new_block.sh
printf "Generate a block from the main node:\ne-cli getblockcount -> "
e-cli getblockcount
printf "\n"

#Policy asset private keys
prvKeyFrz=cSwvPTiFNFg9XAb64rTaMkihTxH9K5uCtTvrh2DTNzYCQuP93bbF
prvKeyBrn=cPs1eRScTdbkgXEnC279akg656DhUhc61wkY3XMnFjE72fevxZxm
prvKeyWht=cNCQhCnpnzyeYh48NszsTJC2G4HPoFMZguUnUgBpJ5X9Vf2KaPYx
prvKeyInit=cUHtn9aX8W73nQZH9x7f7zmckjWxtw2aJGs8qMnz7H761yCHLQvy

e-cli importprivkey $prvKeyFrz  true; sleep 3;
e-cli importprivkey $prvKeyBrn  true; sleep 3;
e-cli importprivkey $prvKeyWht  true; sleep 3;
e-cli importprivkey $prvKeyInit  true; sleep 3;

e1-dae $SIGNBLOCKARG ; sleep 3
ee-dae $SIGNBLOCKARG ; sleep 3

printf "Block broadcast to client node:\ne1-cli getblockcount -> "
e1-cli getblockcount
printf "\n"

./client-1/new_block.sh
printf "Client node cannot generate a new block. Block cound has not increased:\ne-cli getblockcount -> "
e-cli getblockcount
printf "\n"

