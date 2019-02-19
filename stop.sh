shopt -s expand_aliases
OCEANPATH="../ocean/src"
alias e-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir-main"
alias e1-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir1"
alias ee-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir-explorer"

e-cli stop
e1-cli stop
ee-cli stop
