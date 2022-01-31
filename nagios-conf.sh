#!/bin/bash
ID=$(docker ps |grep -i naemon |awk '{print $NF}')

echo "Chequeando conf:"
docker exec -t $ID su - naemon -c "/usr/bin/naemon -v /etc/nagios/conf/naemon.cfg"

reiniciar (){
    docker exec -t $ID supervisorctl restart nagios
}

while true; do
    read -p "CONTAINER ID=$ID
             Reiniciar naemon? (Yyes/Nno): "  yn
    case $yn in
        [Yy]* ) reiniciar ; break;;
        [Nn]* ) echo "No se realiza el restart" ; exit;;
        * ) echo "Please answer yes or no.";;
    esac
