#!/bin/bash
#Local whitelisting 

printf "Clearing whitelists and adding server addresses to server whitelist\n"
e-cli clearwhitelist
e1-cli clearwhitelist
e-cli dumpderivedkeys keys.main
e-cli readwhitelist keys.main 

echo "Issuing assets"
issue=$(e-cli issueasset 10000 1 false)
asset=$(echo $issue | jq --raw-output '.asset')
printf "Issuance\n $issue\n"
printf "Asset $asset\n"
sleep 1

./main/new_block.sh 6; sleep 3

e-cli getwalletinfo

echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelist1.txt; wc -l whitelist1.txt

# Server registers new KYC public key
echo "Registering KYC public keys..."
tx=`e-cli topupkycpubkeys 100`
sleep 1
echo "Mining blocks..."
source main/new_block.sh 6; sleep 1

#echo "Registering KYC public keys..."
#tx=`e-cli topupkycpubkeys 100`
#sleep 1
#echo "Mining blocks..."
#source main/new_block.sh 1; sleep 1

echo "Client dumping kyc file..."
kycfile="kycfile.dat"
userOnboardPubKey=`e1-cli dumpkycfile $kycfile`

echo "finished dumping kyc file."
source main/new_block.sh 1 ; sleep 1


echo "Onboarding user addresses:"
e-cli onboarduser $kycfile; sleep 1

source main/new_block.sh 1 ; sleep 1

echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelist1.txt; wc -l whitelist1.txt

echo "Sending asset $asset from server to client."
e-cli sendtoaddress $(e1-cli getnewaddress) 80 "" "" false $asset
e-cli sendtoaddress $(e1-cli getnewaddress) 10 "" "" false $asset
e-cli getrawmempool
./main/new_block.sh 1
e-cli getblock $(e-cli getblockhash 3)


echo "whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt; sleep 1
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt; sleep 1

echo "sending funds to self"
e-cli sendtoaddress $(e-cli getnewaddress) 5000 "from" "me" false $asset
source main/new_block.sh 6 ; sleep 1

echo "sending funds to user"
e-cli sendtoaddress $(e1-cli getnewaddress) 100 "from" "me" false $asset

echo "User address self-registration: 100 addresses"
e1-cli sendaddtowhitelisttx 100 $asset; sleep 1
source main/new_block.sh 6; sleep 1
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
source main/new_block.sh 6; sleep 1
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt
echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt
