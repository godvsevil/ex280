echo "Cleanig up any orphan containers"

tagImage="mejkrqmc3hlyc.azurecr.io/elc/elx3-cms-dev"
sandImage="elx-d8_sandbox"

containers=`docker ps -a -q`


if [[ ! -z $containers ]]
then 
    docker rm --force $(docker ps -a -q)
    echo "Hi"
else    
    echo "No containers are running"
fi    
sleep 1

echo "Deleting ACR tagged docker images.."  
images=`docker images | grep -i $tagImage | awk '{print $3}'`
if [[ ! -z $images ]]
then 
    docker images | grep -i $tagImage | awk '{print $3}' > images_files
    while read image
	do
   		echo $image
        docker rmi --force $image
	done < images_files
else    
    echo "No Images with tag  : $tagImage"
fi    
sleep 1

echo "Deleting docker images that are untagged , if any..."
images=`docker images | grep -i "<none>" | awk '{print $3}'`
if [[ ! -z $images ]]
then 
    docker images | grep -i "<none>" | awk '{print $3}' > images_files
    while read image
	do
   		echo $image
        docker rmi --force $image
	done < images_files
else    
    echo "No untagged images found"
fi    
sleep 1

echo "Deleting docker sandbox images .."
images=`docker images | grep -i $sandImage | awk '{print $3}'`
if [[ ! -z $images ]]
then 
    docker images | grep -i $sandImage | awk '{print $3}' > images_files
    while read image
	do
   		echo $image
        docker rmi --force $image
	done < images_files
else    
    echo "No ACR images found"
fi    
sleep 1

echo "Searching for untagged images, if any..."
images=`docker images | grep -i "<none>" | awk '{print $3}'`
if [[ ! -z $images ]]
then 
    docker images | grep -i "<none>" | awk '{print $3}' > images_files
    while read image
	do
   		echo $image
        docker rmi --force $image
	done < images_files
else    
    echo "No untagged images found"
fi    
sleep 1
