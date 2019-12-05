#!/bin/bash


#$1 = pr_baseName
#$2 = sonarProject
#$3 = sonarHost
#$4 = sonarLogin
#$5 = sonarScanHome
#$6 =sonarPaths



run_sonarscan(){

#Added as part of multi Repo build support on 27th July 2018
BUILD_HOME_DIR=`echo "src_"$baseBranch"_"$projectName`

#BUILD_HOME_DIR=`echo "src_"$baseBranch`

#-----------  Run the code scanning test if the job is of type integration -------------------


  echo "Integration build , running the sonarqube scan on the latest feature code"

  cd  ../$BUILD_HOME_DIR/docroot/sites/all/themes/custom/elx_front && sonar-scanner \
  -Dsonar.projectKey=THISISFIRSTPROJECT \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://52.173.78.153:9000 \
  -Dsonar.login=9f0c24057777a677e651a80314cd65d5d9beaec2

   cd ../../../modules/custom/  && sonar-scanner \
  -Dsonar.projectKey=THISISFIRSTPROJECT \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://52.173.78.153:9000 \
  -Dsonar.login=9f0c24057777a677e651a80314cd65d5d9beaec2


echo "Cheking the status of the sonar analysis"

cd /home/jenkins/KUBERNETES_PROD/K8S_IMAGE/scripts/ 

python -c 'import sonar_admin; print sonar_admin.pStatus()'

line=$(head -n 1 .sonarstatus)
echo $line

echo "Updating the status in to git,slack and Jenkins"

if [ $line == "ERROR" ]
then
  echo "Project analysis failed, please check sonar server project logs"
  exit 1
#  exit 1
elif [ $line == "OK" ]
then
  echo "Project analysis passed"
else
  echo "Some unknow error could not read the status"
  exit 1
fi



}


