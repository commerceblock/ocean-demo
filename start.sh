shopt -s expand_aliases
ELEMENTSPATH="../ocean/src"
alias e-dae="$ELEMENTSPATH/elementsd -datadir=$HOME/elementsdir-main"
alias e1-dae="$ELEMENTSPATH/elementsd -datadir=$HOME/elementsdir1"
alias ee-dae="$ELEMENTSPATH/elementsd -datadir=$HOME/elementsdir-explorer"

SIGNBLOCKARG="-signblockscript=5121030bddc5c46fb9cda35ce955441df1ceb46a947a75df87a2f2b287df3421bcea3151ae" ; sleep 1

e-dae $SIGNBLOCKARG ; sleep 5
e1-dae $SIGNBLOCKARG ; sleep 5
ee-dae $SIGNBLOCKARG ; sleep 5
