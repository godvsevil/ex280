#!/bin/bash

#Maintainer : girish.kumar@srijan.net
#This script will delete the extra images in the ACR.
#Image limit is to be mentioned in the config file retention_numbe=10
#Script will enter the loop, scan every repository in the ACR and restrict the number of images under every
#repository to the mentioned number - No customization available in this version
#This should be a job - just like the docker image clear in Jenkins.

source 11_acr_cleaner.conf

az_login() {


az login --service-principal -u $application_id -p $application_password --tenant $tenant_id
file_repo_name=`echo $repo_name |sed 's#/#_#g'`
az acr repository list --name $registry_name -u $registry_admin -p $registry_pwd  --output table > $registry_name".repository_lst"
sed '1,2d' $registry_name".repository_lst" > $registry_name".repository_lst_refined"
echo "Repository list Succesfully refined"
rm $registry_name".repository_lst"

}

az_repo_delete() {
echo "Start"
#repo_name="elc/elx3-cms-dev"
while read repo_name;
do echo "Hello $repo_name"
    file_repo_name=`echo $repo_name |sed 's#/#_#g'`
    #az acr repository delete --name $registry_name -u $registry_admin -p $registry_pwd --repository $repo_name --tag $im_tag --yes
    #az acr repository show-manifests --name $registry_name -u $registry_admin -p $registry_pwd  --repository $repo_name
    echo  "Fetching list of images in the repository : $repo_name and registry : $registry_name"
    az acr repository show-tags --name $registry_name -u $registry_admin -p $registry_pwd  --repository $repo_name --output table > $registry_name"_"$file_repo_name".lst"  

    echo "Remove the result part of the output"

    unref_lst=`echo $registry_name"_"$file_repo_name".ref_lst"`
    if [ -f $unref_lst ]; then
        echo "Fresh list present deleting..."
        rm  $unref_lst
    else
        echo "Fresh list not present"
    fi

    sed '1,2d' $registry_name"_"$file_repo_name".lst" > $registry_name"_"$file_repo_name".ref_lst"
    echo "Succesfully refined"
    rm $registry_name"_"$file_repo_name".lst"

    #python 11_acr_cleaner.py $registry_name"_"$file_repo_name".ref_lst" > $registry_name"_"$file_repo_name".sorted_lst"

    del_lst=`echo $registry_name"_"$file_repo_name".del_lst"`


    #Cleanup the alredy existing list which might casue conflicts
    if [ -f $del_lst ]; then
        echo "Delete list present deleting..."
        rm  $del_lst
    else
        echo "Delete list not present"
    fi

    #End point of python execution is a file "mejkrqmc3hlyc_elc_elx3-cms-dev.del_lst"
    python 11_acr_cleaner.py $registry_name $file_repo_name  $retention_number 

    if [ -f $del_lst ]; then
        echo "Delete list present created proceeding with deletion..."

    else
        echo "Delete list not present, dGenetation failed.. check for errors..."
        exit
    fi

    rm $registry_name"_"$file_repo_name".ref_lst"


    #Now read the sript line by line "mejkrqmc3hlyc_elc_elx3-cms-dev.del_lst" and delete these images


    while read im_tag;
    do echo "Hello $repo_name":"$im_tag"
    echo "az acr repository delete --name $registry_name -u $registry_admin -p $registry_pwd --repository $repo_name --tag $im_tag --yes"
    #az acr repository delete --name $registry_name -u $registry_admin -p $registry_pwd --repository $repo_name --tag $im_tag --yes    
    sleep 1
    done < $registry_name"_"$file_repo_name".del_lst"

done < $registry_name".repository_lst_refined"

#@rm $registry_name".repository_lst_refined"
}

az_login
az_repo_delete