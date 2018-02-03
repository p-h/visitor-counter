# Visitor Counter

## Description

A simple website which counts it's visitors in a Redis Database.

Written in Haskell. Deployed using docker-compose

## Requirements

  - stack
  - docker-compose

## Running

    stack image container

    docker-compose up

See if it works😃:

    % for i in {1..5}; do curl -s localhost:8888; done
    <h1>Hi there
    You are visitor number: 1!</h1>
    <h1>Hi there
    You are visitor number: 2!</h1>
    <h1>Hi there
    You are visitor number: 3!</h1>
    <h1>Hi there
    You are visitor number: 4!</h1>
    <h1>Hi there
    You are visitor number: 5!</h1>
