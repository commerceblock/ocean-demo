#!/bin/bash
if [ $# -ne 1 ]
then
echo "Usage: new_block.sh <nblocks>"
exit 1
fi

shopt -s expand_aliases

OCEANPATH="../ocean/src"

alias cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir-main"

for i in $(eval echo "{1..$1}")
do
echo "Block $i"
# Let's propose and accept some blocks, e1 is master!
NEW_BLOCK=`cli getnewblockhex`
sleep 1
BLOCKSIG=`cli signblock $NEW_BLOCK`
sleep 1
SIGNED_BLOCK=`cli combineblocksigs $NEW_BLOCK \[\"$BLOCKSIG\"\] | jq -r '.hex'`
sleep 1
cli submitblock $SIGNED_BLOCK
sleep 1
done