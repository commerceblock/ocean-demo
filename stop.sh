shopt -s expand_aliases
OCEANPATH="../ocean/src"
alias e-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir-main"
alias e1-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir1"
alias ee-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir-explorer"
alias ewl-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir-wl"

e-cli stop; sleep 1
e1-cli stop; sleep 1
ee-cli stop; sleep 1
ewl-cli stop; sleep 1
