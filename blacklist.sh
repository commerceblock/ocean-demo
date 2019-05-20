source functions.sh

#kycpubkey=`e-cli dumpkycpubkey $userOnboardPubKey`
blacklistKYC $wltxid

source main/new_block.sh; sleep 3
source main/new_block.sh; sleep 3

echo "whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt; sleep 1
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt; sleep 1
