#!/bin/bash
if [ $# -ne 1 ]
then
nblocks=1
else
nblocks=$1
fi

shopt -s expand_aliases

OCEANPATH="../ocean/src"

alias cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir-main"



for i in $(eval echo "{1..$nblocks}")
do
# Let's propose and accept some blocks, e1 is master!
NEW_BLOCK=`cli getnewblockhex`
BLOCKSIG=`cli signblock $NEW_BLOCK`
SIGNED_BLOCK=`cli combineblocksigs $NEW_BLOCK \[\"$BLOCKSIG\"\] | jq -r '.hex'`
cli submitblock $SIGNED_BLOCK
sleep 1
done