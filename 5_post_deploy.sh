#!/bin/bash


projectName=`echo $1`
baseBranch=`echo $2`
gitURL=`echo $3`
buildBranch=`echo $4`
prNumber=`echo $5`
baseImage=`echo $6`
containerRoot=`echo $7`
jenkinsHome=`echo $8`

echo "***********" $jenkinsHome

#projectName=`echo "nalxdemo"`
#baseBranch=`echo "dev"`
#gitURL=`echo "git@github.com:srijanaravali/nalxdemo.git"`
#buildBranch="dev"
#prNumber="55"
##mountDir="/Users/crawler/Desktop/src_dev/docroot"
#baseImage="elcd8:1.0.0"
#containerRoot="/var/www/html"
#jenkinsHome=`echo "/var/lib/jenkins"`


JENKINS_HOME=`echo $jenkinsHome`
#Added as part of multi Repo build support on 27th July 2018
sourceDir=`echo "src_pb_"$baseBranch"_"$projectName`
#sourceDir=`echo "src_pb_"$baseBranch`
mountDir=`echo $JENKINS_HOME"/build-home/build-utils/"$sourceDir"/"`
#mountDir=`echo $JENKINS_HOME"/var/lib/jenkins/build-home/test/build-utils_multi/"$sourceDir"/"`
containerName=`echo $projectName"_"$baseBranch"_pb_"$prNumber` 





configure() {
  ssh-keyscan -H $repo_host >> ~/.ssh/known_hosts
}

clone() {
    echo "Creating sandboxed kubernetes pod image for BUILD"
    #Added as part of multi Repo build support on 27th July 2018
    BUILD_HOME_DIR=`echo "src_pb_"$baseBranch"_"$projectName`
#    BUILD_HOME_DIR=`echo "src_pb_"$baseBranch`
    echo "Deleting the previosly loaded source code"

    if [ -d $BUILD_HOME_DIR ]; then
    rm -rf $BUILD_HOME_DIR
    mkdir -p $BUILD_HOME_DIR
    else
    mkdir -p $BUILD_HOME_DIR
    fi
#----------- Pull latest version of BUILD code from git repo----------------------
    echo "Cloning the latest code from BUILD repository"

    git clone $gitURL $BUILD_HOME_DIR
    if [ $? != 0 ]
    then
        echo "Unable to clone the repository. Ensure that the CI machine user is authorized with read access to the upstream repo."
    exit 1
    fi

    sleep 2
    echo "chaning the branch to $buildBranch"
    sleep 1

    git -C $BUILD_HOME_DIR fetch && git -C $BUILD_HOME_DIR checkout $buildBranch



#----------- Delete all the git references from the directory-------------------

echo "Removing git references"

rm -rf $BUILD_HOME_DIR.git

}




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

#----------- Clean the running container to complete the build ------------------------------------------------

clean_container() {

        if [  "$(docker ps -aq -f name="$containerName")" ]; then
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



postDeploy() {

    codePath=`echo $containerRoot"/automation_suite/postman_suite"`
    docker exec $containerName bash $containerRoot/api_runner.sh $codePath
    if [ $? -eq 0 ]
    then
    echo "Container created successfully."
    clean_container
    else
    echo "Post build test failed, clean the container"
    clean_container
    exit 1
    fi

}





clone
clean_container
run_container
postDeploy

