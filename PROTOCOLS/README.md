# Protocol Demo

A demonstration of protocols used by the Ocean network, including federated signing and asset issuance.

## Instructions
1. Follow the instructions for the base demo
2. pip3 install requirements.txt
3. python3 demo.py

### MultiSig

Generate multisig script and keys using the MultiSig class (M out of N).

### Federated Signing

Implement federation signing using the BlockSigning class. Federation signing uses a Kafka broker. Nodes take turns proposing / signing blocks. One node will generate a new block hex and send it to a topic marked as 'new-block' in the Kafka broker. The rest of the nodes will fetch this and sign it, sending their signature to a topic marked as 'new-sigX', where X is the node id. The node that generated the block will collect the signatures, combine them and submit the block.

### Asset Issuance

Issue assets and generate transactions with these assets using the AssetIssuance class.
