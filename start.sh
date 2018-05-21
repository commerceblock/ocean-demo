shopt -s expand_aliases
ELEMENTSPATH="../ocean/src"
alias e-dae="$ELEMENTSPATH/elementsd -datadir=$HOME/elementsdir-main"
alias e1-dae="$ELEMENTSPATH/elementsd -datadir=$HOME/elementsdir1"
alias ee-dae="$ELEMENTSPATH/elementsd -datadir=$HOME/elementsdir-explorer"

SIGNBLOCKARG="-signblockscript=512102906c00cd4f362514e4d20669a664cd94947b580c1f082c45c2df00c247ed515a51ae" ; sleep 1

e-dae $SIGNBLOCKARG ; sleep 5
e1-dae $SIGNBLOCKARG ; sleep 5
ee-dae $SIGNBLOCKARG ; sleep 5
