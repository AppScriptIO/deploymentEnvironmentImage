#!/usr/bin/env bash
##
 # USAGE: 
 # ./entrypoint.sh [build|run] entrypointConfigurationPath=./entrypoint/configuration.js entrypointOption=[install|build|...]
##

# : ${DEPLOYMENT:=containerManagement}; export DEPLOYMENT # set variable only if if is unset or empty string.

currentFilePath=$(dirname "$0")
dockerComposeFilePath="${currentFilePath}/container/containerDeployment.dockerCompose.yml"

### DOESN'T WORK ANYMORE - as the dockerfile used to build the image, relies on a specific directory structure, which in the "containerManagement" is reorganized.
### Now builds are made only through nodejs app, not directly through docker-compose build.
# # Initial build - used for building the container through calling docker-compose tool directly, rather than interacting with the docker nodejs management tool (docker API). As the manager nodejs container relies on this docker image to run.
# # USAGE: ./entrypoint.sh build entrypointConfigurationPath=./entrypoint/configuration.js entrypointOption=install
# build() {
#     # --no-cache can be used.
#     DEPLOYMENT=imageBuild; export DEPLOYMENT;    
#     docker-compose -f $dockerComposeFilePath build --no-cache dockerfile
# }

# For managing the the development, build, & testing of this project.
# USAGE: ./entrypoint.sh build entrypointConfigurationPath=./application/setup/entrypoint/configuration.js entrypointOption=build dockerImageTag=X
# USAGE for debugging: ./entrypoint.sh build entrypointConfigurationPath=./application/setup/entrypoint/configuration.js entrypointOption=run
build() {
    # docker-compose -f $dockerComposeFilePath pull containerDeploymentManagement
    DEPLOYMENT=containerManagement; 
    
    # Check if docker image exists
    dockerImage=myuserindocker/deployment-environment:latest;
    if [[ "$(docker images -q $dockerImage 2> /dev/null)" == "" ]]; then 
        dockerImage=node:latest
    fi
    echo "• dockerImage=$dockerImage"

    export dockerImage; export DEPLOYMENT;
    # run container manager
    docker-compose \
        -f ${dockerComposeFilePath} \
        --project-name appDeploymentEnvironment \
        up --force-recreate --no-build --abort-on-container-exit containerDeploymentManagement;

    # stop and remove containers related to project name.
    docker-compose \
        -f ${dockerComposeFilePath} \
        --project-name appDeploymentEnvironment \
        down; 
}

if [[ $# -eq 0 ]] ; then # if no arguments supplied, fallback to default
    echo 'Shell Script • No arguments passed.'
    run
else

    # Export arguments  
    for ARGUMENT in "${@:2}"; do # iterate over arguments, skipping the first.
        KEY=$(echo $ARGUMENT | cut -f1 -d=); VALUE=$(echo $ARGUMENT | cut -f2 -d=);
        case "$KEY" in
                entrypointConfigurationPath)     entrypointConfigurationPath=${VALUE}; export entrypointConfigurationPath ;;
                entrypointOption)         entrypointOption=${VALUE}; export entrypointOption ;;
                dockerImageTag)         dockerImageTag=${VALUE}; export dockerImageTag ;;
                *)
        esac
    done

    if [[ $1 != *"="* ]]; then # if first argument is a command, rather than a key-value pair.
        echo 'Shell Script • Command as argument passed.'
        # run first argument as function.
        $@ # Important: call arguments verbatim. i.e. allows first argument to call functions inside file. So that it could be called as "./setup/entrypoint.sh <functionName>".
    else
        echo 'Shell Script • Key-Value arguments passed.'
        run
    fi

fi




