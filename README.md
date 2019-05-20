# Ocean Demo

This is a simple bash script demo for the Ocean network. This demo exhibits block signing by a single node and whitelisting of transactions between a client and a main node. A demonstration of Ocean's advanced protocols is also included written in Python under [PROTOCOLS](PROTOCOLS/). The following instructions apply for all demos.

## Instructions
1. Download and install ocean on the same directory as ocean-demo 
2. Download the ocean-explorer and start the node server (`npm start`)
3. Clone ocean-demo

## Running the demo

Initiate the demo by running:

`source ./init.sh`

To stop all the ocean instances do:

`./stop.sh`

To restart all the ocean instances do (the signblockscript will have to be updated in the script):

`./start.sh`

The following aliases can be used to perform any command line operations available in the Ocean clients:

* e-cli (main signing node)
* e1-cli (client node)
* ee-cli (block explorer node with wallet disabled)

### Examples

- Send CBT from the main node to the client node

	`e-cli sendtoaddress $(e1-cli getnewaddress) 123`

- Generate block from the signing node

	`./main/new_block.sh`

- Generate block from the client node (not possible will give error)

	`./client-1/new_block.sh`

- Get the latest block from the explorer node

	`ee-cli getblock ($ee-cli getbestblockhash) true`

