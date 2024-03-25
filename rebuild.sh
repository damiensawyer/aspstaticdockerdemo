#!/bin/bash
 docker ps -aq | xargs docker rm -f
 docker build -f Dockerfile -t statictest .
 docker run --rm -d  -p 7170:7170 statictest
 docker ps -a
 echo waiting for startup....
 sleep 5
 curl http://localhost:7170/hello.html
