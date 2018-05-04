# ocean-demo

## Instructions
1. Download and install ocean on the same directory as ocean-demo 
2. Download the ocean explorer and start the node server (`npm start`)
3. Download the ocean-demo

## Demo Options

Initiate the demo by running:

`source ./init.sh`

To stop all the ocean instances do:

`./stop.sh`

To restart all the ocean instances do (the signblockscript will have to be specified in the script):

`./start.sh`

The following aliases can be used to perform any command line operations available in the elements/ocean clients:

* e-cli (main signing node)
* e1-cli (client node)
* ee-cli (block explorer node with wallet disabled)

Example usage:

- Send CBT from the main node to the client node

	`e-cli sendtoaddress $(e1-cli getnewaddress) 123`

- Generate block from the signing node

	`./main/new_block.sh`

- Generate block from the client node (not possible will give error)

	`./client-1/new_block.sh`

- Get the latest block from the explorer node

	`ee-cli getblock ($ee-cli getbestblockhash) true`


