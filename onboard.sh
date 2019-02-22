source main/new_block.sh
sleep 1

printf "Getting KYC key and raw public key from main."
printf "\n"
kycKey=`e-cli getnewaddress`
kycDerivedPubKey=`e-cli validateaddress $kycKey | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\"//p'`
kycPubKey=`e-cli validateaddress $kycKey | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`

onboardKey=`e-cli getnewaddress`
onboardDerivedPubKey=`e-cli validateaddress $onboardKey | grep \"derivedpubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\"//p'`
onboardPubKey=`e-cli validateaddress $onboardKey | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`

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

#Whitelist only the signing node
e-cli clearwhitelist
e1-cli clearwhitelist
e-cli readwhitelist keys.main $kyckey2 

e-cli dumpwhitelist whitelist1.txt; wc -l whitelist1.txt

# Client dumps kyc file
e1-cli dumpkycfile "kycfile.dat" "$onboardPubKey"

kycfile="kycfile.dat"

# Server registers new KYC public key
let flvalue=0
let wlvalue=0
let ntx=0;
declare -i ntx

#The initial whitelist tokens destination
wfcd=76a914ddb13d1080354c1871123a4ca916ef38030c12c988ac
flcd=76a914a54de47fa542d4913bc17a80c7854c2235385d9d88ac
#Get the whitetoken asset ID
#genhash=`e1-cli getblockhash 0`

#for tx in `e1-cli getblock $genhash | jq --raw-output '.tx[]'`
#do 
#echo "tx: $tx"
#rawtx=`e-cli getrawtransaction $tx`
#decoded=`e-cli decoderawtransaction $rawtx`
#scriptpubkeyhex=`echo $decoded | jq --raw-output '.vout [0].scriptPubKey.hex'`
#if [[ "$scriptpubkeyhex" != "$wfcd" ]]; then
#continue
#fi
#wlasset=`echo $decoded | jq --raw-output '.vout [0].asset'`
#echo "Whitelist asset: $wlasset"
#wltxid=`echo $decoded | jq --raw-output '.txid'`
#wlvalue=`echo $decoded | jq --raw-output '.vout [0].value'`
#done



while [[ ($wlvalue == 0) || ($flvalue == 0) ]]
do
txinfo=`e-cli listunspent | jq --argjson NTX $ntx '.[$NTX] | {txid: .txid, asset: .asset, amount: .amount, vout: .vout, sequence: .sequence, scriptPubKey: .scriptPubKey, asset: .asset, address: .address, spendable : .spendable }'`
scriptPubKey=`echo $txinfo | jq --raw-output '.scriptPubKey'`
spendable=`echo $txinfo | jq --raw-output '.spendable'`

if [[ ("$spendable" != "true") ]]; then
let ntx=$ntx+1
continue
fi

if [[ ("$scriptPubKey" == "$wfcd") && ($wlvalue == 0) ]];then
    let wlvalue=`echo $txinfo | jq --raw-output '.amount'`
    wlasset=`echo $txinfo | jq --raw-output '.asset'`
    wlinputs=`echo $txinfo | jq --raw-output '[{txid: .txid, vout: .vout}]'`
    wlinputs2=`echo $wlinputs | tr -d '[:space:]'`
    wlinputs=$wlinputs2
    echo "White list inputs: $wlinputs"
fi
if [[ ("$scriptPubKey" == "$flcd") && ($flvalue == 0) ]];then
    let flvalue=`echo $txinfo | jq --raw-output '.amount'`
    flasset=`echo $txinfo | jq --raw-output '.asset'`
    flinputs=`echo $txinfo | jq --raw-output '[{txid: .txid, vout: .vout}]'`
    flinputs2=`echo $flinputs | tr -d '[:space:]'`
    flinputs=$flinputs2
    echo "Freeze list inputs: $flinputs"
fi
let ntx=$ntx+1
done



#Add address to freeze list
policyaddress=`e-cli getnewaddress`
validateaddress=`e-cli validateaddress $policyaddress`
policypubkey=`echo $validateaddress | jq --raw-output '.pubkey'`

freezeaddress=`e1-cli getnewaddress`

floutputs="[{\"pubkey\":\"$policypubkey\",\"value\":$flvalue,\"address\":\"$freezeaddress\"}]"
echo $floutputs

echo "Creating freezelist tx:"

tx=`e-cli createrawpolicytx $flinputs $floutputs 0 $flasset`

echo $tx

echo "Signing tx:"

txs=`e-cli signrawtransaction $tx`

echo $txs

echo "Getting hex:"

txsh=`echo $txs | jq --raw-output '.hex'`

echo $txsh

echo "Sending tx:"

#e-cli sendrawtransaction $txsh


#Generate a public key for the policy wallet                                                                                                                                      
policyaddress=`e-cli getnewaddress`
validateaddress=`e-cli validateaddress $policyaddress`
policypubkey=`echo $validateaddress | jq --raw-output '.pubkey'`

wloutputs="[{\"pubkey\":\"$policypubkey\",\"value\":$wlvalue,\"userkey\":\"$kycPubKey\"}]"
#wloutputs="[{\"pubkey\":\"$policypubkey\",\"value\":$wlvalue,\"address\":\"$freezeaddress\"}]"
echo $outputs

echo "Creating tx:"

tx=`e-cli createrawpolicytx $wlinputs $wloutputs 0 $wlasset`

echo $tx

echo "Signing tx:"

txs=`e-cli signrawtransaction $tx`

echo $txs

echo "Getting hex:"

txsh=`echo $txs | jq --raw-output '.hex'`

echo $txsh

echo "Sending tx:"

e-cli sendrawtransaction $txsh

sleep 5
source main/new_block.sh 6

echo "Onboarding user addresses:"

e-cli onboarduser $kycfile "CBT"

source main/new_block.sh 6

echo "whitelist nlines:"
e-cli dumpwhitelist whitelist2.txt; wc -l whitelist2.txt