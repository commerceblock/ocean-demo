#!/bin/bash
shopt -s expand_aliases

OCEANPATH="../ocean/src"

alias e-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir-main"
alias e-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir-main; echo $!"
alias e1-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir1"
alias e1-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir1; echo $!"
alias ewl-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir-wl"
alias ewl-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir-wl; echo $!"
alias ee-cli="$OCEANPATH/ocean-cli -datadir=$HOME/oceandir-explorer"
alias ee-dae="$OCEANPATH/oceand -datadir=$HOME/oceandir-explorer; echo $!"