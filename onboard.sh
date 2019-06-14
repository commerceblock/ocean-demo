#!/bin/bash
# Server registers new KYC public key
registerKYCPubKey

echo "Client dumping kyc file..."
kycfile="kycfile.dat"
userOnboardPubKey=`e1-cli dumpkycfile $kycfile`
echo "finished dumping kyc file."
source main/new_block.sh 6 ; sleep 3
echo "Onboarding user addresses:"
e-cli onboarduser $kycfile; sleep 5

source main/new_block.sh 6 ; sleep 5


echo "whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt; sleep 1
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt; sleep 1

echo "sending funds to user"
e-cli sendtoaddress $(e1-cli getnewaddress) 100

source main/new_block.sh 6 ; sleep 5

echo "User address self-registration: 100 addresses"
e1-cli sendaddtowhitelisttx 100 "CBT"; sleep 5

clientAddress1=`e1-cli getnewaddress`
clientPubKey1=`e1-cli validateaddress $clientAddress1 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`
clientAddress2=`e1-cli getnewaddress`
clientPubKey2=`e1-cli validateaddress $clientAddress2 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`
clientAddress3=`e1-cli getnewaddress`
clientPubKey3=`e1-cli validateaddress $clientAddress3 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`

clientTweakedPubKey1=`e1-cli validateaddress $clientAddress1 | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`
clientTweakedPubKey2=`e1-cli validateaddress $clientAddress2 | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`
clientTweakedPubKey3=`e1-cli validateaddress $clientAddress3 | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`

source main/new_block.sh 6; sleep 1

printf "Creating a p2sh address for whitelisting\n"
multiTweakedKeysArray="[\"$clientTweakedPubKey1\",\"$clientTweakedPubKey2\",\"$clientTweakedPubKey3\"]"
multiInputs="2 $multiTweakedKeysArray"
multiAddress1=`e1-cli createmultisig $multiInputs | grep \"address\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`
printf "Adding the created p2sh to the whitelist\n"
multiArray="[\"$clientPubKey1\",\"$clientPubKey2\",\"$clientPubKey3\"]"
echo $multiAddress1
echo $multiArray
echo $kycKey

printf "mempool: "
e1-cli getrawmempool
printf "\n"
#e-cli addmultitowhitelist $multiAddress1 $multiArray 2 $kycKey
onb=`e1-cli sendaddmultitowhitelisttx $multiAddress1 $multiArray 2 "CBT"`

source main/new_block.sh 6; sleep 1

printf "mempool: "
e1-cli getrawmempool
printf "\n"

test=`e-cli getrawtransaction $onb`

echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt
echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt

echo "User address self-registration: 100 addresses"
e1-cli sendaddtowhitelisttx 100 "CBT"; sleep 5
source main/new_block.sh 6; sleep 1
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt
echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt

echo "User address self-registration: 100 addresses"
e1-cli sendaddtowhitelisttx 100 "CBT"; sleep 5
source main/new_block.sh 6; sleep 1
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt
echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt
