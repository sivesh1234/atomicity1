#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)
inputconfigfile='configTemplate.js'
outputconfigfile='config.js'

projectPlaceholder=placeholderProjectID
topicPlaceholder=placeholderTopic
subscriptionPlaceholder=placeholderSubscription
processIdPlaceholder=placeholderProcessId
bucketPlaceholder=placeholderBucket
redisPlaceholder=placeholderRedis
passwordPlaceholder=placeholderPassword
windowPlaceholder="'placeholderWindow'"
backlogPlaceholder="'placeholderBacklog'"
writePlaceholder="'placeholderWrite'"
processPlaceholder="'placeholderProcess'"
repoPlaceholder=placeholderRepoName
domainPlaceholder=placeholderDomain
sshPlaceholder=placeholderSsh

function googleinit {
    copyconfigtemplate
    echo "First step what is your google cloud project id?"
    read -p "gcloud projectid: " gcpproject
    echo
    echo "Great I will remember that $gcpproject and I can use it later"
    echo "I will also add $gcpproject as your project in the config"
    editconfig $projectPlaceholder $gcpproject
    echo "Now lets initialise gcloud on that project,"
    gcloud init
    checkpubsubtopic
}

function copyconfigtemplate {
    cp "$inputconfigfile" "$outputconfigfile"
}

function checkpubsubtopic {
    while true; do
    echo "Now PubSub, do you have a topic set up already?"
    read -p "[${bold}Y${normal}es]/[${bold}N${normal}o]: " topicalready
    echo
    case "$topicalready" in 
        y|Y|yes|Yes ) 
        exisitingtopic
        break
        ;;
        n|N|no|No ) 
        createtopic
        break
        ;;
        * ) 
        echo "invalid"
        ;;
    esac
    done
    echo
}

function addextras {
    echo "Final stretch now!"
    echo "The next questions will fill the config,"
    echo "if you dont know any just put a placeholder they can easily be changed after"
    echo "What is your redis ip ?(if you dont know it just put 0.0.0.0)"
    read -p "redis host ip: " redis
    echo
    echo "Adding redis host ip $redis to config"
    editconfig $redisPlaceholder $redis
    echo "What is your redis password?"
    read -sp "redis password: " redispass
    echo
    echo "Adding redis password to config"
    editconfig $passwordPlaceholder $redispass
    echo "What is your window period ? (Live API time period)"
    read -p "window period: " windowperiod
    echo
    echo "Adding window period $windowperiod to config"
    editconfig $windowPlaceholder $windowperiod
    echo "What is your backlog period? (Data kept in redis before it is backed up)" 
    read -p "backlog period: " backlogperiod
    echo
    echo "Adding backlog period $backlogperiod to config"
    editconfig $backlogPlaceholder $backlogperiod
    echo "What is your write interval ? (Interval a which data is written to cloud storage, must be bigger than window period)"
    read -p "write interval: " writeinterval
    echo
    echo "Adding write interval $writeinterval to config"
    editconfig $writePlaceholder $writeinterval
    echo "What is your data process interval? (How often the redis data is processed)" 
    read -p "process interval: " processinterval
    echo
    echo "Adding process interval $processinterval to config"
    editconfig $processPlaceholder $processinterval
    echo "What is your repo name?" 
    read -p "repo: " reponame
    echo
    echo "Adding repo name $reponame to config"
    editconfig $repoPlaceholder $reponame
    echo "What is your ssh path of instance? (How often the redis data is processed)" 
    read -p "ssh path: " sshpath
    echo
    echo "Adding ssh path $sshpath to config"
    editconfig $sshPlaceholder $sshpath
    echo "What is your domain name?" 
    read -p "domain: " domainname
    echo
    echo "Adding domain name $domainname to config"
    editconfig $domainPlaceholder $domainname
    echo "All done! Your config is now configured"
    echo "Good Luck!"
    echo
    exit
}

function checkbucket {
    while true; do
    echo "Do you have a bucket on gcp storage set up already?"
    read -p "[${bold}Y${normal}es]/[${bold}N${normal}o]: " bucketalready
    echo
    case "$bucketalready" in 
        y|Y|yes|Yes ) 
        exisitingbucket
        break
        ;;
        n|N|no|No ) 
        createbucket
        break
        ;;
        * ) 
        echo "invalid"
        ;;
    esac
    done
    echo
}

function createtopic {
    echo "What is the topic name"
    read -p "Topic: " topicname
    echo
    echo "Creating topic on gcloud..."
    gcloud beta pubsub topics create $topicname
    echo "Adding topic $topicname to config"
    editconfig $topicPlaceholder $topicname
    echo "Adding the processId as $topicname in config"
    echo "(This is good practise but can be changed)"
    editconfig $processIdPlaceholder $topicname
    createsubscription $topicname
}

function exisitingtopic {
    echo "What is the topic name"
    read -p "Topic: " topicname
    echo
    echo "Adding topic $topicname to config"
    editconfig $topicPlaceholder $topicname
    echo "Adding the processId as $topicname in config"
    echo "(This is good practise but can be changed)"
    editconfig $processIdPlaceholder $topicname
    while true; do
    echo "Do you have a subscription set up for that topic?"
    read -p "[${bold}Y${normal}es]/[${bold}N${normal}o]: " subscriptionalready
    echo
    case "$subscriptionalready" in 
        y|Y|yes|Yes ) 
        exisitingsubscription $topicname
        break
        ;;
        n|N|no|No ) 
        createsubscription $topicname
        break
        ;;
        * ) 
        echo "invalid"
        ;;
    esac
    done
    echo
}

function exisitingsubscription {
    echo "What is the subscription name"
    read -p "Subscription: " subscriptionname
    echo
    echo "Adding subscription $subscriptionname to config"
    editconfig $subscriptionPlaceholder $subscriptionname
    checkbucket
}


function createsubscription {
    echo "Now we need a subscrition for that topic"
    echo "What do you want the subscription name to be,"
    read -p "Subscription: " subscriptionname
    echo
    echo "Creating subscription on gcloud..."
    gcloud beta pubsub subscriptions create $subscriptionname --topic $1
    echo "Adding subscription $subscriptionname to config"
    editconfig $subscriptionPlaceholder $subscriptionname
    checkbucket
}

function createbucket {
    echo "What is the bucket name"
    read -p "Bucket: " bucketname
    echo
    echo "Creating bucket on gcloud..."
    gsutil mb -p $gcpproject -c regional -l europe-west2 gs://$bucketname/
    echo "Adding bucket $bucketname to config"
    editconfig $bucketPlaceholder $bucketname
    addextras
}

function exisitingbucket {
    echo "What is the bucket name"
    read -p "Bucket: " bucketname
    echo
    echo "Adding bucket $bucketname to config"
    editconfig $bucketPlaceholder $bucketname
    addextras
}


function editconfig {
    perl -pi -e 's/'"$1"'/'"$2"'/g' $outputconfigfile
}

echo -e "\nThis is the script for setting up a new elasticity app,\v"

echo -e "${bold}Please Note if gcloud or gsutil errors are throw because of already exsiting topics, sub or bucket"
echo -e "${bold}the script will continue the topic, sub or bucket will still be added to the config."
echo -e "${bold}You can continue or start again."
echo
echo "${normal}Requirments before running:"
echo -e "\v\t* gcloud (initallised with project pub/sub & storage permissions)"
echo -e "\v\t* gsutil"
echo -e "\v\t* A project on gcp"
echo -e "\v\t* Redis instance setup"
echo
while true; do
echo "Do you want to continue"
read -p "[${bold}Y${normal}es]/[${bold}N${normal}o]: " startchoice
echo
case "$startchoice" in 
  y|Y|yes|Yes ) 
  googleinit
  break
  ;;
  n|N|no|No ) 
  echo "OK, see you!" 
  break
  ;;
  * ) 
  echo "invalid"
  ;;
esac
done
echo