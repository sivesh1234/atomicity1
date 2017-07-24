import argparse
import os
from google.cloud import pubsub

os.environ["GOOGLE_CLOUD_PROJECT"] = 'Small-Vivacity-Projects'
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = './backend/secrets/Small-Vivacity-Projects-f502d9066757.json'
pubsub_client = pubsub.Client().from_service_account_json('./backend/secrets/Small-Vivacity-Projects-f502d9066757.json')
#topic = pubsub_client.topic(topic)



def receive_message(topic_name, subscription_name):
    """Receives a message from a pull subscription."""
    pubsub_client = pubsub.Client()
    topic = pubsub_client.topic(topic_name)
    subscription = topic.subscription(subscription_name)

    # Change return_immediately=False to block until messages are
    # received.
    results = subscription.pull(return_immediately=True,max_messages=10)
    
    print('Received {} messages.'.format(len(results)))

    #for ack_id, message in results:
     #   print('* {}: {}, {}'.format(
      #     message.message_id, message.data, message.attributes))
    for ack_id, message in results:
        print('* {}: {}'.format(
            message.message_id, message.data))
        alpha = '* {}: {}'.format(message.message_id, message.data)
        with open("gcp_output.txt", mode='a') as file:
            file.write(alpha)
    # Acknowledge received messages. If you do not acknowledge, Pub/Sub will
    # redeliver the message.
    if results:
        subscription.acknowledge([ack_id for ack_id, message in results])

while True:
    receive_message('atomicity-messages', 'atomicity-message-processing')