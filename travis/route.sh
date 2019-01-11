#!/bin/sh
__CURRENT__=`pwd`
__DIR__=$(cd "$(dirname "$0")";pwd)

check_docker_dependency(){
    if [ "`docker -v 2>&1 | grep "version"`"x = ""x ]; then
        echo "\n❌ Docker not found!"
        exit 255
    fi
}

install_docker_compose(){
    which "docker-compose" > /dev/null
    if [ $? -ne 0 ]; then
        echo "\n🤔 Can not found docker-compose, try to install it now...\n"
        curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > docker-compose && \
        chmod +x docker-compose && \
        sudo mv docker-compose /usr/local/bin && \
        docker -v && \
        docker-compose -v
    fi
}

prepare_data_files(){
    cd ${__DIR__} && \
    remove_data_files && \
    mkdir -p data && \
    mkdir -p data/run && \
    mkdir -p data/mysql && \
    mkdir -p data/redis && \
    chmod -R 777 data
}

remove_data_files(){
    cd ${__DIR__} && \
    rm -rf ../travis/data
}

start_docker_containers(){
    cd ${__DIR__} && \
    remove_docker_containers && \
    docker-compose up -d && \
    docker-compose ps
}

remove_docker_containers(){
    cd ${__DIR__} && \
    docker-compose kill > /dev/null 2>&1 && \
    docker-compose rm -f > /dev/null 2>&1
}

run_tests_in_docker(){
    docker exec swoole touch /.travisenv && \
    docker exec swoole /swoole-src/travis/docker-route.sh
}

remove_tests_resources(){
    remove_docker_containers
    remove_data_files
}

set -e

cd ${__DIR__}
source env.sh

install_docker_compose

echo "\n📖 Prepare for files...\n"
prepare_data_files

echo "📦 Start docker containers...\n"
start_docker_containers && trap "remove_tests_resources"

echo "\n⏳ Run tests in docker...\n"
run_tests_in_docker

echo "\n🚀🚀🚀Completed successfully🚀🚀🚀\n"
