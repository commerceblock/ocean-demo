e1-cli sendtoaddress $clientAddress1 100
sleep 1
source main/new_block.sh
sleep 1

#e-cli clearwhitelist
#e1-cli clearwhitelist

#printf "Add client addresses 1 to 3  to local memory whitelists."
#printf "Adding client addresses to whitelist."
#printf "\n"
#e-cli addtowhitelist $clientAddress1 $clientPubKey1 $kycKey
#e-cli addtowhitelist $clientAddress2 $clientPubKey2 $kycKey
#e-cli addtowhitelist $clientAddress3 $clientPubKey3 $kycKey
#e1-cli addtowhitelist $clientAddress1 $clientPubKey1 $kycKey
#e1-cli addtowhitelist $clientAddress2 $clientPubKey2 $kycKey
#e1-cli addtowhitelist $clientAddress3 $clientPubKey3 $kycKey

echo "kycKey: $kycKey"
echo "kycPubKey: $kycPubKey"
echo "kycDerivedPubKey: $kycDerivedPubKey"
echo "whitelist nlines:"
e-cli dumpwhitelist whitelist1.txt; wc -l whitelist1.txt
e1-cli sendaddtowhitelisttx "CBT" "10" "$kycPubKey"

sleep 5
source main/new_block.sh 6; 
echo "whitelist nlines:"
e-cli dumpwhitelist whitelist2.txt; wc -l whitelist2.txt