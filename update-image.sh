#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
IMAGE_NAME="abaplans-frontend"

sudo docker image rm $IMAGE_NAME 

if [ $# -eq 0 ]
then
	sudo docker build -t $IMAGE_NAME $DIR
fi