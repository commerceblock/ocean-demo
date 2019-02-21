source main/new_block.sh
sleep 1

printf "Getting KYC key and raw public key from main."
printf "\n"
kycKey=`e-cli getnewaddress`
kycDerivedPubKey=`e-cli validateaddress $kycKey | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\"//p'`
kycPubKey=`e-cli validateaddress $kycKey | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`
printf "Getting address and raw public key from client."
printf "\n"
clientAddress1=`e1-cli getnewaddress`
clientPubKey1=`e1-cli validateaddress $clientAddress1 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`
clientAddress2=`e1-cli getnewaddress`
clientPubKey2=`e1-cli validateaddress $clientAddress2 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`
clientAddress3=`e1-cli getnewaddress`
clientPubKey3=`e1-cli validateaddress $clientAddress3 | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p'| sed -En 's/\"//p'`

echo "kycKey: $kycKey"
echo "kycPubKey: $kycPubKey"
echo "kycDerivedPubKey: $kycDerivedPubKey"
echo "whitelist nlines:"
e-cli dumpwhitelist whitelist1.txt; wc -l whitelist1.txt

# Client dumps kyc file
e1-cli dumpkycfile "kycfile.dat" "$kycPubKey"

# Server registers new KYC public key
let amount=0
let ntx=0;
declare -i ntx

#The initial whitelist tokens destination
wfcd=76a914ddb13d1080354c1871123a4ca916ef38030c12c988ac
#Get the whitetoken asset ID
genhash=`e1-cli getblockhash 0`

for tx in `e1-cli getblock $genhash | jq --raw-output '.tx[]'`
do 
echo "tx: $tx"
rawtx=`e-cli getrawtransaction $tx`
decoded=`e-cli decoderawtransaction $rawtx`
scriptpubkeyhex=`echo $decoded | jq --raw-output '.vout [0].scriptPubKey.hex'`
if [ $scriptpubkeyhex -ne $wlcd ]
then
continue
fi
wlasset=`echo $decoded | jq --raw-output '.vout [0].asset'`
echo "Whitelist asset: $wlasset"
wltxid=`echo $decoded | jq --raw-output '.txid'`
wlvalue=`echo $decoded | jq --raw-output '.vout [0].value'`
done



#while [ $amount -eq 0 ]
#do
#txinfo=`e-cli listunspent | jq --argjson NTX $ntx '.[$NTX] | {txid: .txid, asset: .asset, amount: .amount, vout: .vout, sequence: .sequence, scriptPubKey: .scriptPubKey, asset: .asset, address: .address}'`
#echo $txinfo
#asset=`echo $txinfo | jq '.asset'`
#scriptPubKey=`echo $txinfo | jq '.asset'`
#if [ $scriptPubKey -ne $wlInitScriptPubKey ]
#then
#continue
#fi
#let amount=`echo $txinfo | jq '.amount'`
#let ntx=$ntx+1
#done

#inputs=`echo $txinfo | jq '[{txid: .txid, vout: .vout, asset: .asset}]'`
#inputs2=`echo $inputs | tr -d '[:space:]'`
#inputs=$inputs2
#echo $inputs

inputs="[{txid:\"$wltxid\",vout:\"0\",asset:\"$wlasset\"}]"



#Generate a public key for the policy wallet                                                                                                                                      
policyaddress=`e-cli getnewaddress`
validateaddress=`e-cli validateaddress $policyaddress`
policypubkey=`echo $validateaddress | jq --raw-output '.pubkey'`

outputs="[{\"pubkey\":\"$policypubkey\",\"value\":$amount,\"userkey\":\"$kycPubKey\"}]"
echo $outputs

echo "Creating tx:"

tx=`e-cli createrawpolicytx \"$inputs\" \"$outputs\"`

echo $wltx1

echo "Signing tx:"

txs=`e-cli signrawtransaction $tx`

echo $txs

echo "Getting hex:"

txsh=`echo $txs | jq --raw-output '.hex' | sed -e 's/^"//' -e 's/"$//'`

echo $txsh

echo "Sending tx:"

e-cli sendrawtransaction $txsh

sleep 5
source main/new_block.sh 6;
echo "whitelist nlines:"
e-cli dumpwhitelist whitelist2.txt; wc -l whitelist2.txt