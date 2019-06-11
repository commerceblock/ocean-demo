echo "Blacklisting client1 addresses"

addr1=`e1-cli getnewaddress`
kycpubkey1=`e-cli getkycpubkey $addr1`
txhx=`e-cli blacklistkycpubkey $kycpubkey1`

source main/new_block.sh 1; sleep 1

echo "whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt; sleep 1
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt; sleep 1

echo "Whitelisting client1 addresses again"

txhx=`e-cli whitelistkycpubkeys [\"$kycpubkey1\"]`

source main/new_block.sh 1; sleep 1

echo "whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt; sleep 1
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelistClient.txt; wc -l whitelistClient.txt; sleep 1