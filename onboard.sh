#!/bin/bash
#Local whitelisting 

echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelist1.txt; wc -l whitelist1.txt

# Server registers new KYC public key
echo "serving topping up kyc pubkeys"
tx1=`e-cli topupkycpubkeys 100`
source main/new_block.sh 1; sleep 1
echo "getting wallet info."
e-cli getwalletinfo

echo "Client dumping kyc file..."
kycfile="kycfile.dat"
userOnboardPubKey=`e1-cli dumpkycfile $kycfile`

echo "finished dumping kyc file."
source main/new_block.sh 1 ; sleep 1

echo "Onboarding user addresses:"
e-cli onboarduser $kycfile; sleep 5

source main/new_block.sh 1 ; sleep 1

echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt
echo "wlnode whitelist nlines:"
ewl-cli dumpwhitelist whitelist_wl.txt; wc -l whitelist_wl.txt
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelist1.txt; wc -l whitelist1.txt

echo "Server dumping kyc file..."
kycfile_serv="kycfile_serv.dat"
userOnboardPubKey_serv=`e-cli dumpkycfile $kycfile_serv`

echo "finished dumping kyc file."
source main/new_block.sh 1 ; sleep 1

echo "Onboarding server addresses:"
e-cli onboarduser $kycfile_serv; sleep 1

source main/new_block.sh 1 ; sleep 1

echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelist1.txt; wc -l whitelist1.txt


echo "Issuing assets"
issue=$(e-cli issueasset 10000 1 false)
asset=$(echo $issue | jq --raw-output '.asset')
printf "Issuance\n $issue\n"
printf "Asset $asset\n"
sleep 1

./main/new_block.sh 1; sleep 3

e-cli getwalletinfo; sleep 1

echo "Sending asset $asset from server to client."
e-cli sendtoaddress $(e1-cli getnewaddress) 80 "" "" false $asset; sleep 3
e-cli sendtoaddress $(e1-cli getnewaddress) 10 "" "" true $asset; sleep 3
e-cli getrawmempool
./main/new_block.sh 1
e-cli getblock $(e-cli getblockhash 3)

echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt
echo "wlnode whitelist nlines:"
ewl-cli dumpwhitelist whitelist_wl.txt; wc -l whitelist_wl.txt
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelist1.txt; wc -l whitelist1.txt

echo "User address self-registration: 100 addresses"
e1-cli sendaddtowhitelisttx 100 $asset; sleep 1

source main/new_block.sh 1; sleep 1

e1-cli dumpwhitelist whitelistClient-2.txt; wc -l whitelistClient-2.txt; sleep 1

clientAddress1=`e1-cli getnewaddress`
clientPubKey1=`e1-cli validateaddress $clientAddress1 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`
clientAddress2=`e1-cli getnewaddress`
clientPubKey2=`e1-cli validateaddress $clientAddress2 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`
clientAddress3=`e1-cli getnewaddress`
clientPubKey3=`e1-cli validateaddress $clientAddress3 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`

clientTweakedPubKey1=`e1-cli validateaddress $clientAddress1 | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`
clientTweakedPubKey2=`e1-cli validateaddress $clientAddress2 | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`
clientTweakedPubKey3=`e1-cli validateaddress $clientAddress3 | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`

source main/new_block.sh 1; sleep 1

printf "Creating a p2sh address for whitelisting\n"
multiTweakedKeysArray="[\"$clientTweakedPubKey1\",\"$clientTweakedPubKey2\",\"$clientTweakedPubKey3\"]"
multiInputs="2 $multiTweakedKeysArray"
multiAddress1=`e1-cli createmultisig $multiInputs | grep \"address\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`
printf "Adding the created p2sh to the whitelist\n"
multiArray="[\"$clientPubKey1\",\"$clientPubKey2\",\"$clientPubKey3\"]"
echo $multiAddress1
echo $multiArray

printf "mempool: "
e1-cli getrawmempool
printf "\n"
onb=`e1-cli sendaddmultitowhitelisttx $multiAddress1 $multiArray 2 "$asset"`

source main/new_block.sh 6; sleep 1

printf "mempool: "
e1-cli getrawmempool
printf "\n"

clientAddress4=`e1-cli getnewaddress`
clientPubKey4=`e1-cli validateaddress $clientAddress4 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`
clientAddress5=`e1-cli getnewaddress`
clientPubKey5=`e1-cli validateaddress $clientAddress5 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`
clientAddress6=`e1-cli getnewaddress`
clientPubKey6=`e1-cli validateaddress $clientAddress6 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`

clientTweakedPubKey4=`e1-cli validateaddress $clientAddress4 | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`
clientTweakedPubKey5=`e1-cli validateaddress $clientAddress5 | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`
clientTweakedPubKey6=`e1-cli validateaddress $clientAddress6 | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`

multiTweakedKeysArray2="[\"$clientTweakedPubKey4\",\"$clientTweakedPubKey5\",\"$clientTweakedPubKey6\"]"
multiInputs2="2 $multiTweakedKeysArray2"
multiAddress2=`e1-cli createmultisig $multiInputs2 | grep \"address\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`
multiArray2="[\"$clientPubKey4\",\"$clientPubKey5\",\"$clientPubKey6\"]"

multiTweakedKeysArray3="[\"$clientTweakedPubKey6\",\"$clientTweakedPubKey5\",\"$clientTweakedPubKey4\"]"
multiInputs3="2 $multiTweakedKeysArray3"
multiAddress3=`e1-cli createmultisig $multiInputs3 | grep \"address\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`
multiArray3="[\"$clientPubKey6\",\"$clientPubKey5\",\"$clientPubKey4\"]"

multiTweakedKeysArray4="[\"$clientTweakedPubKey1\",\"$clientTweakedPubKey5\"]"
multiInputs4="2 $multiTweakedKeysArray4"
multiAddress4=`e1-cli createmultisig $multiInputs4 | grep \"address\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`
multiArray4="[\"$clientPubKey1\",\"$clientPubKey5\"]"

multiTweakedKeysArray5="[\"$clientTweakedPubKey2\",\"$clientTweakedPubKey5\",\"$clientTweakedPubKey6\"]"
multiInputs5="2 $multiTweakedKeysArray5"
multiAddress5=`e1-cli createmultisig $multiInputs5 | grep \"address\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`
multiArray5="[\"$clientPubKey2\",\"$clientPubKey5\",\"$clientPubKey6\"]"

pubkeyPairs="[{\"address\":\"$clientAddress4\",\"pubkey\":\"$clientPubKey4\"},{\"address\":\"$clientAddress5\",\"pubkey\":\"$clientPubKey5\"}]"
multiList="[{\"nmultisig\":2,\"pubkeys\":$multiArray2},{\"nmultisig\":2,\"pubkeys\":$multiArray3},{\"nmultisig\":2,\"pubkeys\":$multiArray4},{\"nmultisig\":2,\"pubkeys\":$multiArray5}]"

echo "Manually creating a KYC file and onboarding it..."
kycfile_man="kycfile_man.dat"
userOnboardPubKey_man=`e-cli createkycfile $kycfile_man $pubkeyPairs $multiList`

sleep 10

e-cli onboarduser $kycfile_man; sleep 1

source main/new_block.sh 1 ; sleep 1

iswl=`e-cli querywhitelist $clientAddress4`
iswl2=`e-cli querywhitelist $clientAddress5`
iswl3=`e-cli querywhitelist $multiAddress2`
iswl4=`e-cli querywhitelist $multiAddress3`
iswl5=`e-cli querywhitelist $multiAddress4`
iswl6=`e-cli querywhitelist $multiAddress5`

echo $iswl
echo $iswl2
echo $iswl3
echo $iswl4
echo $iswl5
echo $iswl6

test=`e-cli getrawtransaction $onb`

echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt
echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt

echo "User address self-registration: 100 addresses"
e1-cli sendaddtowhitelisttx 100 $asset; sleep 1
source main/new_block.sh 6; sleep 1
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt
echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt

echo "User address self-registration: 100 addresses"
e1-cli sendaddtowhitelisttx 100 $asset; sleep 1
source main/new_block.sh 1; sleep 1
echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt
echo "wlnode whitelist nlines:"
ewl-cli dumpwhitelist whitelist_wl.txt; wc -l whitelist_wl.txt
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelist1.txt; wc -l whitelist1.txt

