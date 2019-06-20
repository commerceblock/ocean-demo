echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt
echo "wlnode whitelist nlines:"
ewl-cli dumpwhitelist whitelist_wl.txt; wc -l whitelist_wl.txt
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelist1.txt; wc -l whitelist1.txt

echo "Restarting client node..."
e1-cli stop; sleep 5
e1-dae $SIGNBLOCKARG ; sleep 10
echo "client whitelist nlines:"
e1-cli dumpwhitelist whitelist1.txt; wc -l whitelist1.txt

echo "Restarting server node..."
e-cli stop; sleep 5
e-dae $SIGNBLOCKARG ; sleep 10
echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt

echo "Restarting wl node..."
ewl-cli stop; sleep 5
e-dae $SIGNBLOCKARG ; sleep 10
echo "server whitelist nlines:"
e-cli dumpwhitelist whitelist.txt; wc -l whitelist.txt


