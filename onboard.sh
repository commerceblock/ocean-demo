#!/bin/bash
# Server registers new KYC public key
echo "Registering KYC public keys..."
tx=`e-cli topupkycpubkeys 100`
sleep 1
echo "Mining blocks..."
source main/new_block.sh 6; sleep 1

echo "Registering KYC public keys..."
tx=`e-cli topupkycpubkeys 100`
sleep 1
echo "Mining blocks..."
source main/new_block.sh 6; sleep 1

echo "Client dumping kyc file..."
kycfile="kycfile.dat"
userOnboardPubKey=`e1-cli dumpkycfile $kycfile`
echo "finished dumping kyc file."
source main/new_block.sh 6 ; sleep 1
echo "Onboarding user addresses:"
e-cli onboarduser $kycfile; sleep 1

source main/new_block.sh 6 ; sleep 1


echo "whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt; sleep 1
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt; sleep 1

echo "sending funds to user"
e-cli sendtoaddress $(e1-cli getnewaddress) 100

source main/new_block.sh 6 ; sleep 1

echo "User address self-registration: 100 addresses"
e1-cli sendaddtowhitelisttx 100 "ISSUANCE"; sleep 1
source main/new_block.sh 6; sleep 1
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt
echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt

echo "User address self-registration: 100 addresses"
e1-cli sendaddtowhitelisttx 100 "ISSUANCE"; sleep 1
source main/new_block.sh 6; sleep 1
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt
echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt

echo "User address self-registration: 100 addresses"
e1-cli sendaddtowhitelisttx 100 "ISSUANCE"; sleep 1
source main/new_block.sh 6; sleep 1
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt
echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt
