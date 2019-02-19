shopt -s expand_aliases
OCEANPATH="../ocean/src"
alias e-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir-main"
alias e1-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir1"
alias ee-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir-explorer"

SIGNBLOCKARG="-signblockscript=512102906c00cd4f362514e4d20669a664cd94947b580c1f082c45c2df00c247ed515a51ae" ; sleep 1

e-dae $SIGNBLOCKARG ; sleep 5
e1-dae $SIGNBLOCKARG ; sleep 5
ee-dae $SIGNBLOCKARG ; sleep 5
