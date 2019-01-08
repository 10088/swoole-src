#!/bin/sh -e
__CURRENT__=`pwd`
__DIR__=$(cd "$(dirname "$0")";pwd)

# enter the dir
cd ${__DIR__}

# show system info
date && echo ""
uname -a && echo ""

# show php info
php -v && echo ""

# compile in docker
./docker-compile.sh

# swoole info
php --ri swoole

# alpine
if [ "`apk 2>&1 | grep apk-tools`"x != ""x ]; then
  echo -e "\n😪 skip alpine\n"
  exit 0
fi

# run unit tests
./run-tests.sh
