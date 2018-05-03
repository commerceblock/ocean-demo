shopt -s expand_aliases

ELEMENTSPATH="../ocean/src"

alias cli="$ELEMENTSPATH/elements-cli -datadir=$HOME/elementsdir1"

# Let's propose and accept some blocks, e1 is master!
NEW_BLOCK=`cli getnewblockhex`
sleep 1
BLOCKSIG=`cli signblock $NEW_BLOCK`
sleep 1
SIGNED_BLOCK=`cli combineblocksigs $NEW_BLOCK \[\"$BLOCKSIG\"\] | jq -r '.hex'`
sleep 1
cli submitblock $SIGNED_BLOCK
sleep 1