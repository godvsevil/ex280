#!/bin/bash

#	5. PRE_DEPLOY:
#		a. Copy the code to light weight docker base image DockerProdBase and tag it
#		b. Destroy the previous test container. Docker kill <project>_<build_base>_<PR>>
#		c. Push the new image to ACR


projectName=`echo $1`
baseBranch=`echo $2`
prNumber=`echo $3`
acr_url=`echo $4`
docker_repository=`echo $5`
#sourceDir=`echo "src_"$baseBranch`
containerName=`echo $projectName"_"$baseBranch"_"$prNumber` 
build_tag=`echo $baseBranch"-"$prNumber`



#projectName=`echo "nalx"`
#baseBranch=`echo "dev"`
#gitURL=`echo "git@github.com:srijanaravali/nalx.git"`
#buildBranch="dev"
#prNumber="55"
#build_tag=`echo $baseBranch"-"$prNumber`
#acr_url=`echo "https://vacje23jww6vy.azurecr.io"`
#docker_repository=`echo "azure-devops/spin-kub-demo"`
#baseImage="elcd8:1.0.0"
#containerRoot="/var/www/html"




imageTag () {

#----------- Tag the built SandBox image with ACR repository ------------------------------------------------



sandboxName=`echo $projectName"_sandbox:"$baseBranch"_"$prNumber`

build_tag=`echo $baseBranch"-"$BUILD_NUMBER`
docker_repo=`echo $acr_url | sed -e 's/^http:\/\///g' -e 's/^https:\/\///g'`
echo $docker_repo > $WORKSPACE/commandreply
echo $docker_repo > commandreply

docker tag  $sandboxName  $docker_repo/${docker_repository}:${build_tag}


echo "Docker image built succesfully"



}

#----------- Clean the running container to complete the build ------------------------------------------------
echo "Hi"
clean_container() {
        containerName=`echo $projectName"_"$baseBranch"_"$prNumber` 
        echo $containerName
        if [  "$(docker ps -a -q -f name="$containerName")" ]; then
        # cleanup
        echo "container already present, removing the container..."
        docker rm --force $containerName
            if [ $? -eq 0 ]
            then
            echo "Container removed successfully."
            exit 0
            else
            echo "Container removal failed."
            exit 1
            fi
        fi
}



imageTag
clean_container


