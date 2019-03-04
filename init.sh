# INITIAL SETUP
rm -r ~/oceandir-main ; rm -r ~/oceandir1 ; rm -r ~/oceandir-explorer
mkdir ~/oceandir-main ; mkdir ~/oceandir1 ; mkdir ~/oceandir-explorer
mkdir -p ~/oceandir1/terms-and-conditions/ocean_test ; mkdir -p ~/oceandir-main/terms-and-conditions/ocean_test ; mkdir -p ~/oceandir-explorer/terms-and-conditions/ocean_test
mkdir -p ~/oceandir1/asset-mapping/ocean_test ; mkdir -p ~/oceandir-main/asset-mapping/ocean_test ; mkdir -p ~/oceandir-explorer/asset-mapping/ocean_test

cp ./main/ocean.conf ~/oceandir-main/ocean.conf
cp ./client-1/ocean.conf ~/oceandir1/ocean.conf
cp ./explorer/ocean.conf ~/oceandir-explorer/ocean.conf

cp latest.txt ~/oceandir-main/terms-and-conditions/ocean_test/latest.txt
cp latest.txt ~/oceandir1/terms-and-conditions/ocean_test/latest.txt
cp latest.txt ~/oceandir-explorer/terms-and-conditions/ocean_test/latest.txt

cp latest.json ~/oceandir-main/asset-mapping/ocean_test/latest.json
cp latest.json ~/oceandir1/asset-mapping/ocean_test/latest.json
cp latest.json ~/oceandir-explorer/asset-mapping/ocean_test/latest.json

shopt -s expand_aliases

OCEANPATH="../ocean/src"

alias e-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir-main"
alias e-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir-main"
alias e1-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir1"
alias e1-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir1"
alias ee-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir-explorer"
alias ee-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir-explorer"

SIGNBLOCKARG="-signblockscript=5121027d85472b0d42ba60e3b1030b07127f534c9858779fab474c04fcecf9f6c7ae9e51ae" ; sleep 1
KEY="cQ26YCNFdihkhmrtwpixkDxXECuPMRNSDBZu84HyWBV984RaCXmc"



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

