#!/bin/bash
#Local whitelisting 

echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelist1.txt; wc -l whitelist1.txt

# Server registers new KYC public key
echo "Registering KYC public keys..."
tx1=`e-cli topupkycpubkeys 1000`
echo $tx1
sleep 1
echo "Mining blocks..."
source main/new_block.sh 1; sleep 1

e-cli getwalletinfo

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

echo "whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt; sleep 1
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt; sleep 1

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
