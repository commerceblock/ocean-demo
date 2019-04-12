#!/bin/bash
# Server registers new KYC public key
registerKYCPubKey

echo "Client dumping kyc file..."
kycfile="kycfile.dat"
userOnboardPubKey=`e1-cli dumpkycfile $kycfile`
echo "finished dumping kyc file."

echo "Onboarding user addresses:"
sleep 5;
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

echo "User address self-registration: 100 addresses"
e1-cli sendaddtowhitelisttx 100 "CBT"; sleep 5
source main/new_block.sh 6; sleep 1
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt
echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt
