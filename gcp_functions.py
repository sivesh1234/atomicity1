import argparse
import os
from google.cloud import pubsub

os.environ["GOOGLE_CLOUD_PROJECT"] = 'Small-Vivacity-Projects'
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = './backend/secrets/Small-Vivacity-Projects-f502d9066757.json'
pubsub_client = pubsub.Client().from_service_account_json('./backend/secrets/Small-Vivacity-Projects-f502d9066757.json')
#topic = pubsub_client.topic(topic)



def list_subscriptions(topic_name):
    """Lists all subscriptions for a given topic."""
    pubsub_client = pubsub.Client()
    topic = pubsub_client.topic(topic_name)

    for subscription in topic.list_subscriptions():
        print(subscription.name)

def list_topics():
    """Lists all Pub/Sub topics in the current project."""
    pubsub_client = pubsub.Client()

    for topic in pubsub_client.list_topics():
        print(topic.name)
def list_subscriptions(topic_name):
    """Lists all subscriptions for a given topic."""
    pubsub_client = pubsub.Client()
    topic = pubsub_client.topic(topic_name)

    for subscription in topic.list_subscriptions():
        print(subscription.name)

def receive_message(topic_name, subscription_name):
    """Receives a message from a pull subscription."""
    pubsub_client = pubsub.Client()
    topic = pubsub_client.topic(topic_name)
    subscription = topic.subscription(subscription_name)

    # Change return_immediately=False to block until messages are
    # received.
    results = subscription.pull(return_immediately=True)

    print('Received {} messages.'.format(len(results)))

    for ack_id, message in results:
        print('* {}: {}, {}'.format(
            message.message_id, message.data, message.attributes))

    # Acknowledge received messages. If you do not acknowledge, Pub/Sub will
    # redeliver the message.
    if results:
        subscription.acknowledge([ack_id for ack_id, message in results])


def create_subscription(topic_name, subscription_name):
    """Create a new pull subscription on the given topic."""
    pubsub_client = pubsub.Client()
    topic = pubsub_client.topic(topic_name)

    subscription = topic.subscription(subscription_name)
    subscription.create()

    print('Subscription {} created on topic {}.'.format(
        subscription.name, topic.name))



def publish_message(topic_name, data):
    """Publishes a message to a Pub/Sub topic with the given data."""
    pubsub_client = pubsub.Client()
    topic = pubsub_client.topic(topic_name)

    # Data must be a bytestring
    data = data.encode('utf-8')

    message_id = topic.publish(data)

    print('Message {} published.'.format(message_id))

def receive_message(topic_name, subscription_name):
    """Receives a message from a pull subscription."""
    pubsub_client = pubsub.Client()
    topic = pubsub_client.topic(topic_name)
    subscription = topic.subscription(subscription_name)

    # Change return_immediately=False to block until messages are
    # received.
    results = subscription.pull(return_immediately=True,max_messages=100)

    print('Received {} messages.'.format(len(results)))

    #for ack_id, message in results:
     #   print('* {}: {}, {}'.format(
      #     message.message_id, message.data, message.attributes))
    for ack_id, message in results:
        print('* {}: {}'.format(
            message.message_id, message.data))

    # Acknowledge received messages. If you do not acknowledge, Pub/Sub will
    # redeliver the message.
    if results:
        subscription.acknowledge([ack_id for ack_id, message in results])




#list_topics()
#publish_message('atomicity-messages', 'test')


