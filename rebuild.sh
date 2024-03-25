#!/bin/bash
 docker ps -aq | xargs docker rm -f
 docker build -f Dockerfile -t statictest .
 docker run -d statictest
 docker ps -a