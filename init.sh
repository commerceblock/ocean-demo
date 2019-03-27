# INITIAL SETUP
rm -r ~/oceandir-main ; rm -r ~/oceandir1 ; rm -r ~/oceandir-explorer
mkdir ~/oceandir-main ; mkdir ~/oceandir1 ; mkdir ~/oceandir-explorer
mkdir -p ~/oceandir1/terms-and-conditions/ocean_main ; mkdir -p ~/oceandir-main/terms-and-conditions/ocean_main ; mkdir -p ~/oceandir-explorer/terms-and-conditions/ocean_main
mkdir -p ~/oceandir1/asset-mapping/ocean_main ; mkdir -p ~/oceandir-main/asset-mapping/ocean_main ; mkdir -p ~/oceandir-explorer/asset-mapping/ocean_main

cp ./main/ocean.conf ~/oceandir-main/ocean.conf
cp ./client-1/ocean.conf ~/oceandir1/ocean.conf
cp ./explorer/ocean.conf ~/oceandir-explorer/ocean.conf

cp latest.txt ~/oceandir-main/terms-and-conditions/ocean_main/latest.txt
cp latest.txt ~/oceandir1/terms-and-conditions/ocean_main/latest.txt
cp latest.txt ~/oceandir-explorer/terms-and-conditions/ocean_main/latest.txt

cp latest.json ~/oceandir-main/asset-mapping/ocean_main/latest.json
cp latest.json ~/oceandir1/asset-mapping/ocean_main/latest.json
cp latest.json ~/oceandir-explorer/asset-mapping/ocean_main/latest.json

source init-cli.sh

SIGNBLOCKARG="-signblockscript=512103e53077a217d461582ea5ccfab475db7d5cfe4361b6bae75db5bc9f42180e822251ae" ; sleep 1
KEY="KxEbs7nt255rVdSyZKzLyvL21EwW7j7D81dHhN16YauGf455ktnw"



# BLOCK SIGNING
echo "***** Block Signing *****"
e-dae $SIGNBLOCKARG ; sleep 10
e-cli importprivkey $KEY; sleep 3
./main/new_block.sh
printf "Generate a block from the main node:\ne-cli getblockcount -> "
e-cli getblockcount
printf "\n"

#Policy asset private keys
#source genPolicyAssets.sh
prvKeyFrz=L2ZF3zNoSJGXuwEHEstxAMWjBs5kvBqvVrWtT1aoEAV62Wi2cXRt
prvKeyBrn=KxgdtoMVWspjohkgDvDtVYfpjqepMaLpVaoE6zgVzKhcxsQDLa9Q
prvKeyWht=L4yQ56XpNhp5e4uLAAGk3H35s9rBgerizPuDJqCshUDiYA8REpuN
prvKeyInit=L2k7Ra1aSSsvHTk2exUQnJxeTcyW6Wpo99RTUCFi3w2EPATzxMSr

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

#Initialize server whitelist
source functions.sh
sleep 1
printf "Dumping derived keys"
e-cli dumpderivedkeys keys.main
e1-cli dumpderivedkeys keys.client

printf "Adding server addresses to server whitelist."
e-cli readwhitelist keys.main 

echo "whitelist nlines:"
e-cli dumpwhitelist whitelist1.txt; wc -l whitelist1.txt

