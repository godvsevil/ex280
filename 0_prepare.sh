#!/bin/bash

#	1. PREPARE :
#	- Here prepare.sh script is invoked via Jenkins groovy script and it does
#		○ Create a directory for source download
#		○ Download the relevant git repository
#		○ Change to required build branch 

#$1 = projectName
#$2 = pr_baseName
#$3 = git URL
#$4 = build branch
#$5 = PR number

projectName=`echo $1`
baseBranch=`echo $2`
gitURL=`echo $3`
buildBranch=`echo $4`
prNumber=`echo $5`
repo_host=`echo $6`
key=`echo $7`
echo $7;
#projectName=`echo "nalx"`
#baseBranch=`echo "dev"`
#gitURL=`echo "git@github.com:srijanaravali/nalx.git"`
#buildBranch="dev"
#prNumber="55"




configure() {
  ssh-keyscan -H $repo_host >> ~/.ssh/known_hosts
}

clone() {

    eval `ssh-agent -s`
    ssh-add ~/.ssh/id_rsa_$projectName			
    echo "Creating sandboxed kubernetes pod image for BUILD"
#    BUILD_HOME_DIR=`echo "src_"$baseBranch`
    #Added as part of multi Repo build support on 27th July 2018
    BUILD_HOME_DIR=`echo "src_"$baseBranch"_"$projectName`

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

echo "copy the settings file"
cp docker-utils/config/settings-$projectName-$baseBranch.php $BUILD_HOME_DIR/docroot/sites/default/settings.php
#cp docker-utils/lm_env/database-$projectName-$baseBranch.conf $BUILD_HOME_DIR/docroot/lm/config/database_conf.php
if [ $? != 0 ]
then
        echo "base branch did not match the configuration , please check"
exit 1
fi



echo "copy the lm env file"
cp docker-utils/lm_env/.env-$projectName-$baseBranch $BUILD_HOME_DIR/docroot/lm/.env
if [ $? != 0 ]
then
        echo "base branch did not match the configuration , please check"
exit 1
fi



}
#---------- Use default function clone when the script is run
configure
clone





