#!/bin/bash
BASE_DIR=$(cd `dirname $0`; pwd)
EXECUTABLE_NAME=pencake

cp -i $BASE_DIR/bin/$EXECUTABLE_NAME /usr/local/bin/$EXECUTABLE_NAME
