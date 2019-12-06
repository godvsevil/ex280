#!/bin/bash


API_HOME_DIR=`echo $1`

#----------- Run the API test suit ----------------------

echo "Running API test suite"

cd $API_HOME_DIR &&  newman run NALXcollection.json -e NALXenviornment.json