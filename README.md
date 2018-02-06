# Visitor Counter

## Description

A simple website which counts it's visitors in a Redis Database.

Written in Haskell. Deployed on docker swarm behind HAProxy

## Requirements

  - stack
  - docker

## Running

### Setup or start your Docker Swarm

    docker-machine create node-1

    docker-machine create node-2

    docker-machine create node-3

... or however many you want

Create the swarm

    eval $(docker-machine env node-1)

    docker swarm init --advertise-addr $(docker-machine ip node-1) --listen-addr $(docker-machine ip node-1):2377

    TOKEN=$(docker swarm join-token -q worker)

Join the swarm on each worker node

    eval $(docker-machine env node-2)

    docker swarm join --token $TOKEN $(docker-machine ip node-1):2377


    eval $(docker-machine env node-3)

    docker swarm join --token $TOKEN $(docker-machine ip node-1):2377

    ...

    eval $(docker-machine env node-1)

We need a private registry so that our worker nodes are able to see the
image.

    docker service create --name registry --publish published=5000,target=5000 registry:2


Build the image, tag it and push it to the private registry so that the
workener nodes are able to see it

    stack image container

    docker tag visitor-counter-visitor-counter:latest localhost:5000/visitor-counter-visitor-counter

    docker push localhost:5000/visitor-counter-visitor-counter

    docker-compose up

See if it works😃:

    % for i in {1..5}; do curl -s $(docker-machine ip node-1); done

    <!DOCTYPE HTML>

    <html><head><title>Hello Visitor #1!</title></head><body><h1>Hi there</h1><p>My name is: b0336d29bc54</p><p>You are total visitor number: 1!</p><p>You are b0336d29bc54&#39;s visitor number: 1!</p></body></html>

    <!DOCTYPE HTML>

    <html><head><title>Hello Visitor #2!</title></head><body><h1>Hi there</h1><p>My name is: d1f451a11401</p><p>You are total visitor number: 2!</p><p>You are d1f451a11401&#39;s visitor number: 1!</p></body></html>

    <!DOCTYPE HTML>

    <html><head><title>Hello Visitor #3!</title></head><body><h1>Hi there</h1><p>My name is: d2a1c6b1e941</p><p>You are total visitor number: 3!</p><p>You are d2a1c6b1e941&#39;s visitor number: 1!</p></body></html>

    <!DOCTYPE HTML>

    <html><head><title>Hello Visitor #4!</title></head><body><h1>Hi there</h1><p>My name is: b0336d29bc54</p><p>You are total visitor number: 4!</p><p>You are b0336d29bc54&#39;s visitor number: 2!</p></body></html>

    <!DOCTYPE HTML>

    <html><head><title>Hello Visitor #5!</title></head><body><h1>Hi there</h1><p>My name is: d1f451a11401</p><p>You are total visitor number: 5!</p><p>You are d1f451a11401&#39;s visitor number: 2!</p></body></html>
