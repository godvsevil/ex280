#!/bin/bash

#	2. PRE-BUILD :
#	- Here docker run -f DockerEnvBase -d --name <project>_<build_base>_<PR> -v <mount the code directory> -I -t <project>_<build_base>_<PR>:latest 
#		○ Inflate.sh is invoked to get the following
#		○ docker exec <project>_<build_base>_<PR> sh /mnt/inflate.sh
#			§ Npm modules
#			§ Php modules - composer install 
#			§ Node modules


projectName=`echo $1`
baseBranch=`echo $2`
gitURL=`echo $3`
buildBranch=`echo $4`
prNumber=`echo $5`
baseImage=`echo $6`
containerRoot=`echo $7`
jenkinsHome=`echo $8`
JENKINS_HOME=`echo $jenkinsHome`
codeRoot=$9
lmCodeRoot=${10}

#projectName=`echo "nalx"`
#baseBranch=`echo "dev"`
#gitURL=`echo "git@github.com:srijanaravali/nalx.git"`
#buildBranch="dev"
#prNumber="55"
#baseImage="elcd8:1.0.0"
#containerRoot="/var/www/html"

#Added as part of multi Repo build support on 27th July 2018
sourceDir=`echo "src_"$baseBranch"_"$projectName`
#sourceDir=`echo "src_"$baseBranch`
#mountDir=`echo $JENKINS_HOME"/build-home/build-utils_multi/"$sourceDir"/"`
mountDir=`echo $JENKINS_HOME"/build-home/build-utils_adf/"$sourceDir"/"`
#mountDir="/Users/crawler/Desktop/src_dev/docroot"
containerName=`echo $projectName"_"$baseBranch"_"$prNumber` 


clean_container() {
        #if [ ! "$(docker ps -aq -f name="$containerName")" ]; then
        if [  "$(docker ps -aq -f name="$containerName")" ]; then
        # cleanup
        echo "container already present, removing the container..."
        docker rm --force $containerName
            if [ $? -eq 0 ]
            then
            echo "Container removed successfully."
            else
            echo "Container removal failed."
            exit 1
            fi
        fi

}


run_container()
{

    echo "Running the Env Base image as container"
    echo  $mountDir":"$containerRoot
    #docker run --init -d  v  -i -t 
    
    docker run -v $mountDir:$containerRoot  --init -d  --name $containerName -i -t $baseImage tail -f /dev/null
    if [ $? -eq 0 ]
    then
    echo "Container created successfully."
    else
    echo "Container creation failed."
    exit 1
    fi

}



preBuild() {
# Here we install all composer related depandacies in the image which is uploaded in the pre-flight stage

#fromImage=`echo $projectName"_preflight:"$baseBranch"_"$prNumber`
#echo $fromImage
#docker build -f Dockerfiletest --build-arg preflight_tag=$1_$2_$5 -t prebuild:$1_$2_$5 ..
#docker build -f ../Dockerfile_prebuild --build-arg preflight_tag=$fromImage -t "$projectName"_prebuild:$baseBranch"_"$prNumber ..
    codePath=`echo $containerRoot"/"$codeRoot`
    docker exec $containerName bash $containerRoot/inflate.sh $codePath
    if [ $? -eq 0 ]
    then
    echo "Container created successfully."
    else
    echo "Container creation failed."
    exit 1
    fi

}


preBuild_lm() {
# Here we install all composer related depandacies in the image which is uploaded in the pre-flight stage    
#fromImage=`echo $projectName"_preflight:"$baseBranch"_"$prNumber`
#echo $fromImage
#docker build -f Dockerfiletest --build-arg preflight_tag=$1_$2_$5 -t prebuild:$1_$2_$5 ..
#docker build -f ../Dockerfile_prebuild --build-arg preflight_tag=$fromImage -t "$projectName"_prebuild:$baseBranch"_"$prNumber ..
    codePath=`echo $containerRoot"/"$codeRoot"/"$lmCodeRoot`
    docker exec $containerName bash $containerRoot/inflate.sh $codePath
    
if [ $? -eq 0 ]
    then
    echo "Container created successfully."
    else
    echo "Container creation failed."
    exit 1
    fi

}


clean_container
run_container
preBuild
preBuild_lm

