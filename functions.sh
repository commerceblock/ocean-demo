#The initial whitelist tokens destination
wfcd=76a9144ff9b5c6885f87fb5519cc45c1474f301a73224a88ac

function registerKYCPubKey {
let wlvalue=0
let ntx=0;

txinfo=`e-cli listunspent | jq -c --raw-output --arg SCRIPTPUBKEY "$wfcd" '[.[] | select (.scriptPubKey == $SCRIPTPUBKEY) | select(.spendable == true)][0]'`

let wlvalue=`echo $txinfo | jq --raw-output '.amount'`
wlasset=`echo $txinfo | jq --raw-output '.asset'`
wlinputs=`echo $txinfo | jq --raw-output '[{txid: .txid, vout: .vout}]'`
wlinputs2=`echo $wlinputs | tr -d '[:space:]'`
wlinputs=$wlinputs2
echo "White list inputs: $wlinputs"

echo "Generate a public key for the policy wallet"                                                                                                                                      
policyaddress=`e-cli getnewaddress`
validateaddress=`e-cli validateaddress $policyaddress`
policypubkey=`echo $validateaddress | jq --raw-output '.pubkey'`

printf "Getting KYC key and raw public key from main."
printf "\n"
kycKey=`e-cli getnewaddress`
kycKey2=`e-cli getnewaddress`
kycPubKey=`e-cli validateaddress $kycKey | grep \"pubkey\" | awk '{ print $2 }' | sed -En 's/\"//p' | sed -En 's/\",//p'`

echo "kycKey: $kycKey"
echo "kycPubKey: $kycPubKey"

wloutputs="[{\"pubkey\":\"$policypubkey\",\"value\":$wlvalue,\"userkey\":\"$kycPubKey\"}]"

echo "Creating tx:"

tx=`e-cli createrawpolicytx $wlinputs $wloutputs 0 $wlasset`

echo $tx

echo "Signing tx:"

txs=`e-cli signrawtransaction $tx`


echo "Getting tx hex:"

txsh=`echo $txs | jq --raw-output '.hex'`

echo "Sending tx:"

wltxid=`e-cli sendrawtransaction $txsh`
sleep 1
source main/new_block.sh; sleep 1
}

function getWhitelistAsset {
e-cli listunspent | jq -c --raw-output --arg SCRIPTPUBKEY "$wfcd" '[.[] | select (.scriptPubKey == $SCRIPTPUBKEY) | select(.spendable == true)][0] .asset' 
}

function blacklistKYC {
if [[ "$#" -ne "1" ]]; then
    echo "Usage: blacklistKYC <txid>"
    return -1
fi

#txinfo=`e-cli listunspent | jq -c --arg ASSET "$1" --arg KYCPUBKEY "$2" '.[] | select (.asset == $ASSET) | select (.scriptPubKey | contains($KYCPUBKEY)'`
#txinfo=`echo $txinfo | jq -c --arg KYCPUBKEY "$2" '.[] | select (.scriptPubKey | contains($KYCPUBKEY))'`

#{txid: .txid, asset: .asset, amount: .amount, vout: .vout, sequence: .sequence, scriptPubKey: .scriptPubKey, asset: .asset, address: .address, spendable : .spendable }'`

tx=`e-cli getrawtransaction $1`
wltxdc=`e-cli decoderawtransaction $tx`
echo $wltxdc
wlvout=`echo $wltxdc | jq --raw-output '.vout'`
echo $wlvout
echo $wlvout | jq -c '.[] | select (.scriptPubKey.type == "multisig") .scriptPubKey.asm' | awk '{print $3}'
wlvoutn=`echo $wlvout | jq -c '.[] | select (.scriptPubKey.type == "multisig") .n'`
#wltxid=`echo $wltxdc | jq --raw-output '.txid'`
blvalue=`echo $wlvout | jq -c '.[] | select (.scriptPubKey.type == "multisig") .value'`


#blankPubKey="000000000000000000000000000000000000000000000000000000000000000000"


blinputs="[{\"txid\":\"$wltxid\",\"vout\":$wlvoutn}]"
#bloutputs="[{\"pubkey\":\"$policypubkey\",\"value\":$blvalue,\"userkey\":\"blankPubKey\"}]"
bloutputs="[{\"pubkey\":\"$policypubkey\",\"value\":$blvalue}]"

echo "Creating blacklist tx:"

bltx=`e-cli createrawpolicytx $blinputs $bloutputs 0 $wlasset`

echo "Signing tx:"

bltxs=`e-cli signrawtransaction $bltx`


echo "Getting tx hex:"

bltxsh=`echo $bltxs | jq --raw-output '.hex'`

echo "Sending tx:"

e-cli sendrawtransaction $bltxsh
sleep 1
source main/new_block.sh 6; sleep 1
}

