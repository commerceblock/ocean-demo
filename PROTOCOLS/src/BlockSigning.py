#!/usr/bin/env python
from src.authproxy import JSONRPCException
import threading
import multiprocessing
import json
from kafka import KafkaConsumer, KafkaProducer
from time import sleep, time

KAFKA_SERVER = 'localhost:9092'
TOPIC_NEW_BLOCK = 'new-block'
TOPIC_NEW_SIG = 'new-sig'
TOTAL = 5
INTERVAL = 30

class Producer(threading.Thread):
    def __init__(self, height, block):
        threading.Thread.__init__(self)
        self.stop_event = threading.Event()
        self.daemon = True
        self.new_height = height + 1
        self.block = block
        self.producer = KafkaProducer(bootstrap_servers=KAFKA_SERVER)

    def stop(self):
        self.stop_event.set()

    def run(self):
        self.producer.send(TOPIC_NEW_BLOCK, 
                    key=str.encode('{}'.format(self.new_height)),
                    value=str.encode(self.block))

        while not self.stop_event.is_set():
            sleep(1)

        self.producer.close()

class Consumer(threading.Thread):
    def __init__(self, id, height, elements):
        threading.Thread.__init__(self)
        self.stop_event = threading.Event()
        self.daemon = True
        self.sig_topic = TOPIC_NEW_SIG + "{}".format(id)
        self.height = height
        self.elements = elements
        self.consumer = KafkaConsumer(bootstrap_servers=KAFKA_SERVER,
                             auto_offset_reset='earliest',
                             consumer_timeout_ms=1000)

    def stop(self):
        self.stop_event.set()

    def run(self):
        self.consumer.subscribe([TOPIC_NEW_BLOCK])

        while not self.stop_event.is_set():
            for message in self.consumer:
                new_height = int(message.key.decode())
                if new_height > self.height: # just in case to avoid old messages
                    new_block = message.value.decode()
                    try:
                        sign = self.elements.signblock(new_block)
                        reply = {'key': new_height, 'sig': sign}
                        producer = KafkaProducer(bootstrap_servers=KAFKA_SERVER,
                                                 value_serializer=lambda v: json.dumps(v).encode('utf-8'))
                        producer.send(self.sig_topic, reply)
                        producer.close()
                    except JSONRPCException as error:
                        print(error)
                            
            if self.stop_event.is_set():
                    break

        self.consumer.close()

class BlockSigning(multiprocessing.Process):
    def __init__(self, id, elements, num_of_nodes):
        multiprocessing.Process.__init__(self)
        self.stop_event = multiprocessing.Event()
        self.daemon = True
        self.elements = elements
        self.interval = INTERVAL

        global TOTAL
        TOTAL = num_of_nodes
        self.id = id % TOTAL
        self.sig_topics = [TOPIC_NEW_SIG + "{}".format(i) for i in range(0,TOTAL)]

    def stop(self):
        self.stop_event.set()

    def run(self):
        while not self.stop_event.is_set():
            sleep(self.interval - time() % self.interval)
            start_time = int(time())
            step = int(time()) % (self.interval * TOTAL) / self.interval

            height = self.elements.getblockcount()
            block = ""
            print("blockcount:{}".format(height))
                
            if self.id != int(step): 
                # NOT OUR TURN - SEND SIGNATURE ONLY
                print("node {} - consumer step".format(self.id))
                c = Consumer(self.id, height, self.elements)
                c.start()
                sleep(self.interval / 3)
                c.stop()
                sleep(self.interval / 2 - (time() - start_time))
            else:
                # FIRST PROPAGATE THE BLOCK
                print("node {} - producer step".format(self.id))
                block = self.elements.getnewblockhex()
                p = Producer(height, block)
                p.start()
                sleep(self.interval / 3)
                p.stop()
                sleep(self.interval / 2 - (time() - start_time))

                # THEN COLLECT SIGNATURES AND SUBMIT BLOCK
                master_consumer = KafkaConsumer(bootstrap_servers=KAFKA_SERVER,
                                         auto_offset_reset='earliest',
                                         consumer_timeout_ms=1000,
                                         value_deserializer=lambda m: json.loads(m.decode('utf-8')))
                master_consumer.subscribe(self.sig_topics)

                sigs = []
                sigs.append(self.elements.signblock(block))
                try:
                    for message in master_consumer:
                        if message.topic in self.sig_topics and int(message.value.get("key", ""))>height:
                            sigs.append(message.value.get("sig", ""))
                except Exception as ex:
                    print("serialization failed {}".format(ex))

                blockresult = self.elements.combineblocksigs(block, sigs)
                signedblock = blockresult["hex"]
                try:
                    self.elements.submitblock(signedblock)
                    print("node {} - submitted block {}".format(self.id, signedblock))
                except JSONRPCException as error:
                    print("failed signing: {}".format(error))