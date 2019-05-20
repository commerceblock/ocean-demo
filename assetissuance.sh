# ASSET ISSUANCE
echo "***** Asset Issuance *****"

issue=$(e-cli issueasset 100 1 false)
asset=$(echo $issue | jq --raw-output '.asset')
printf "Issuance\n $issue\n"
printf "Asset $asset\n"

./main/new_block.sh 10; sleep 3

e-cli sendtoaddress $(e1-cli getnewaddress) 80 "" "" false $asset
e-cli sendtoaddress $(e1-cli getnewaddress) 10 "" "" true $asset
e-cli getrawmempool
./main/new_block.sh 10
e-cli getblock $(e-cli getblockhash 3)

