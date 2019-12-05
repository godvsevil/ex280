#!/bin/bash

SONAR_BASE="../sonar/sonar_scanner"
SONAR_VER="3.0.3.778"

echo "Downloading generic sonar-scanner"


if [ -d $SONAR_BASE ]; then
  #rm -rf $SONAR_NAME
  #mkdir -p $SONAR_NAME
  echo "Hi"
else
  wget https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_VER.zip
  echo "Unzipping content"
  unzip *.zip -d $SONAR_BASE
fi


echo "Generating key for the user admin"
python -c 'import sonar_admin; print sonar_admin.kGenerate()'

echo "Creating Project for JMX"
python -c 'import sonar_admin; print sonar_admin.pCreate()'

line=$(head -n 1 .sonarsecret)
echo $line

echo "Calling sonar scanner for code repository"

#SONAR_PATH="../sonar/sonar_scanner/sonar-scanner-$SONAR_VER/bin"
SONAR_PATH="../docker-utils/sonar/sonar_scanner/sonar-scanner-$SONAR_VER/bin"
PROJ_PATH="../../docroot/"
USER_AUTH_KEY=$(head -n 1 .sonarsecret)
PROJECT_KEY="JMXLOCALPROJECTKEY"


#echo $PROJECT_KEY
#echo $USER_AUTH_KEY

echo $PROJ_PATH
echo $SONAR_PATH


cd $PROJ_PATH  && \
$SONAR_PATH/sonar-scanner \
      -Dsonar.projectKey=$PROJECT_KEY \
        -Dsonar.sources=./sites/all/themes/,./sites/all/modules/   \
          -Dsonar.host.url=http://localhost:9005 \
            -Dsonar.login=$USER_AUTH_KEY \
            -Dsonar.exclusions=src/java/test/**
