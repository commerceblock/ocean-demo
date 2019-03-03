#!/bin/bash
source functions.sh
sleep 1
printf "Dumping derived keys"
e-cli dumpderivedkeys keys.main
e1-cli dumpderivedkeys keys.client

printf "Getting KYC key and raw public key from main."
printf "\n"
kycKey=`e-cli getnewaddress`
kycKey2=`e-cli getnewaddress`
kycPubKey=`e-cli validateaddress $kycKey | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`

printf "Adding server addresses to server whitelist."
e-cli readwhitelist keys.main $kyckey2 

echo "kycKey: $kycKey"
echo "kycPubKey: $kycPubKey"
echo "whitelist nlines:"
e-cli dumpwhitelist whitelist1.txt; wc -l whitelist1.txt

# Server registers new KYC public key
registerKYCPubKey

echo "Client dumping kyc file..."
kycfile="kycfile.dat"
userOnboardPubKey=`e1-cli dumpkycfile $kycfile`
echo "finished dumping kyc file."



echo "Onboarding user addresses:"
sleep 5;
e-cli onboarduser $kycfile "CBT"; sleep 5

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
}
