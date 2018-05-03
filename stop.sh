shopt -s expand_aliases
ELEMENTSPATH="../ocean/src"
alias e-cli="$ELEMENTSPATH/elements-cli -datadir=$HOME/elementsdir-main"
alias e1-cli="$ELEMENTSPATH/elements-cli -datadir=$HOME/elementsdir1"
alias ee-cli="$ELEMENTSPATH/elements-cli -datadir=$HOME/elementsdir-explorer"

e-cli stop
e1-cli stop
ee-cli stop