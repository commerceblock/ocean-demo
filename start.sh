shopt -s expand_aliases
OCEANPATH="../ocean/src"
alias e-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir-main"
alias e1-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir1"
alias ee-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir-explorer"
alias ewl-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir-wl"

SIGNBLOCKARG="-signblockscript=5121027d85472b0d42ba60e3b1030b07127f534c9858779fab474c04fcecf9f6c7ae9e51ae" ; sleep 1

e-dae $SIGNBLOCKARG ; sleep 5
e1-dae $SIGNBLOCKARG ; sleep 5
ee-dae $SIGNBLOCKARG ; sleep 5
ewl-dae $SIGNBLOCKARG ; sleep 5
