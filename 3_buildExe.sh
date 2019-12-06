#!/bin/bash

#This script will run the drush commands to update the database and clear the cache
#This is done on Docker container environment , after the folder gets copied.

projectName=`echo $1`
baseBranch=`echo $2`
prNumber=`echo $3`
baseImage=`echo $4`
prodImage=`echo $5`
containerRoot=`echo $6`
jenkinsHome=`echo $7`
JENKINS_HOME=`echo $jenkinsHome`
codeRoot=$8
oauth_repo=$10
codePath=`echo $containerRoot"/"$codeRoot`
#Added as part of multi Repo build support on 27th July 2018
sourceDir=`echo "src_"$baseBranch"_"$projectName`
#sourceDir=`echo "src_"$baseBranch`
containerName=`echo $projectName"_"$baseBranch"_"$prNumber` 
build_tag=`echo $baseBranch"-"$prNumber`

echo $oauth_repo

#projectName=`echo "nalx"`
#baseBranch=`echo "dev"`
#gitURL=`echo "git@github.com:srijanaravali/nalx.git"`
#buildBranch="dev"
#prNumber="55"
#baseImage="elcd8:1.0.0"
#containerRoot="/var/www/html"
#prodImage="d8prod:1.0.0"

cleanCode() {
        echo $containerName
# Here we install all composer related depandacies in the image which is uploaded in the pre-flight stage
        if [  "$(docker ps -q -f name="$containerName")" ]; then
        # cleanup
        echo "container running, executing build commands..."
        docker exec $containerName rm -rf $containerRoot
            if [ $? -eq 0 ]
            then
                echo "build executed successfully."
            else
                echo "build error occurs when contents of a mounted directory is cleaned from outside the container."
                exit 0
            fi
        fi


    }



buildExe() {
        echo $containerName
# Here we install all composer related depandacies in the image which is uploaded in the pre-flight stage
        if [  "$(docker ps -q -f name="$containerName")" ]; then
        # cleanup
        echo "container running, executing build commands..."
        docker exec $containerName bash $containerRoot/build.sh $codePath
            if [ $? -eq 0 ]
            then
                echo "build executed successfully."
            else
                echo "build execution failed."
                cleanCode
                exit 1
            fi
        fi


    }



packageCode()
{
    prodimage_tag=$prodImage
    echo $oauth_repo
#Added as part of multi Repo build support on 27th July 2018
    source_path=`echo "src_"$baseBranch"_"$projectName`
    #source_path=`echo "src_"$baseBranch`   
    #Copy the code from local to the lightweight php container image and create the local image
    #docker build --build-arg prodimage_tag=$prodimage_tag --build-arg source_path=$source_path  -t "$projectName"_sandbox:$baseBranch"_"$prNumber .
    docker build --build-arg prodimage_tag=$prodimage_tag --build-arg source_path=$source_path --build-arg oauth_path_repo=$oauth_repo --build-arg projectName=$projectName --build-arg baseBranch=$baseBranch  -t "$projectName"_sandbox:$baseBranch"_"$prNumber .

}









buildExe
packageCode
cleanCode



