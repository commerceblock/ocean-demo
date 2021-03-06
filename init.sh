# INITIAL SETUP
rm -r ~/oceandir-main ; rm -r ~/oceandir-wl; rm -r ~/oceandir1 ; rm -r ~/oceandir-explorer
mkdir ~/oceandir-main ; mkdir ~/oceandir-wl; mkdir ~/oceandir1 ; mkdir ~/oceandir-explorer
mkdir -p ~/oceandir1/terms-and-conditions/ocean_main ; mkdir -p ~/oceandir-wl/terms-and-conditions/ocean_main; mkdir -p ~/oceandir-main/terms-and-conditions/ocean_main ; mkdir -p ~/oceandir-explorer/terms-and-conditions/ocean_main
mkdir -p ~/oceandir1/asset-mapping/ocean_main ; mkdir -p ~/oceandir-wl/asset-mapping/ocean_main ; mkdir -p ~/oceandir-main/asset-mapping/ocean_main ; mkdir -p ~/oceandir-explorer/asset-mapping/ocean_main

cp ./main/ocean.conf ~/oceandir-main/ocean.conf
cp ./whitelist/ocean.conf ~/oceandir-wl/ocean.conf
cp ./client-1/ocean.conf ~/oceandir1/ocean.conf
cp ./explorer/ocean.conf ~/oceandir-explorer/ocean.conf

cp latest.txt ~/oceandir-main/terms-and-conditions/ocean_main/latest.txt
cp latest.txt ~/oceandir-wl/terms-and-conditions/ocean_main/latest.txt
cp latest.txt ~/oceandir1/terms-and-conditions/ocean_main/latest.txt
cp latest.txt ~/oceandir-explorer/terms-and-conditions/ocean_main/latest.txt

cp latest.json ~/oceandir-main/asset-mapping/ocean_main/latest.json
cp latest.json ~/oceandir-wl/asset-mapping/ocean_main/latest.json
cp latest.json ~/oceandir1/asset-mapping/ocean_main/latest.json
cp latest.json ~/oceandir-explorer/asset-mapping/ocean_main/latest.json

source init-cli.sh

SIGNBLOCKARG="-signblockscript=512103e53077a217d461582ea5ccfab475db7d5cfe4361b6bae75db5bc9f42180e822251ae" ; sleep 1
KEY="KxEbs7nt255rVdSyZKzLyvL21EwW7j7D81dHhN16YauGf455ktnw"



# BLOCK SIGNING
echo "***** Block Signing *****"
e-dae $SIGNBLOCKARG ; sleep 10
echo "copying wallet file to wl node"

sleep 3
echo "importing sign block key"
e-cli importprivkey $KEY; sleep 3
./main/new_block.sh 1
printf "Generate a block from the main node:\ne-cli getblockcount -> "
e-cli getblockcount
printf "\n"

#Policy asset private keys
#source genPolicyAssets.sh
prvKeyFrz=L2ZF3zNoSJGXuwEHEstxAMWjBs5kvBqvVrWtT1aoEAV62Wi2cXRt
prvKeyBrn=KxgdtoMVWspjohkgDvDtVYfpjqepMaLpVaoE6zgVzKhcxsQDLa9Q
prvKeyWht=L4yQ56XpNhp5e4uLAAGk3H35s9rBgerizPuDJqCshUDiYA8REpuN
prvKeyInit=KzMAyD64aEiU9fEDDKvNBky48pvCbumJ4Y9FLmkjxHrfS8Yo7WdZ
prvKeyIssue=KwQT54eSXgjsb6wprShFtBQi7Aj56Sb2XPjnsnY9uMjYX16s7L32

echo "importing policy private keys"
e-cli importprivkey $prvKeyFrz  true; sleep 1;
e-cli importprivkey $prvKeyBrn  true; sleep 1;
e-cli importprivkey $prvKeyWht  true; sleep 1;
e-cli importprivkey $prvKeyInit  true; sleep 1;
e-cli importprivkey $prvKeyIssue  true; sleep 1;
e-cli getwalletinfo

echo "finished importing policy private keys"
e-cli stop

ewl-dae $SIGNBLOCKARG  ; sleep 10
ewl-cli stop; sleep 5
cp ~/oceandir-main/ocean_main/wallet.dat ~/oceandir-wl/ocean_main/wallet.dat

e-dae $SIGNBLOCKARG
echo "Main: $!"
e1-dae $SIGNBLOCKARG 
echo "Client 1: $!"
ewl-dae $SIGNBLOCKARG
echo "Whitelist: $!"
ee-dae $SIGNBLOCKARG ; sleep 10
echo "Explorer: $!"

#Print process ids
ps ux | grep oceand | grep datadir| awk '{print $2 " " $11 " " $12}'


wladdr=`ewl-cli getnewaddress`
e-cli validateaddress $wladdr

nblocks=6
echo "Mining $nblocks blocks"
source main/new_block.sh $nblocks

