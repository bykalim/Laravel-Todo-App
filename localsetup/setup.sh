#!/bin/bash
# A Shell Script To Get The Projeect Ready
# By Kalim - 19/Aug/19
chars="/-\|"

loading(){
    while :; do
        for (( i=0; i<${#chars}; i++ )); do
            sleep 0.5
            echo -en "${chars:$i:1}" "\r"
        done
    done
}

echo "* Check for the Application Environment for execution"
appEnv = $( grep APP_ENV .env | xargs )
if [ appEnv == "Production" ];then
    echo "==> "
    exit -1
else
    echo "$appEnv"
fi

echo "* Run Composer install dependencies"
composer install -vvv || exit -1

echo ""
echo "* Install laraDock"
if [[ ! -d "laradock" ]]; then
    rm -rf laradock
    git clone https://github.com/Laradock/laradock.git
fi 

echo "* Override Configuration with Laradock"
cd laradock
cp ./../env-example .env
docker-compose build --no-cache mysql

echo "* Up Docker"
docker-compose kill
docker-compose up -d nginx mysql redis workspace phpmyadmin mailhog

echo "* Compile resources"
cd ..
yarn install
yarn run dev

echo "** DONE **"
