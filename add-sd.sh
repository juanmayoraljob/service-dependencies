#!/bin/bash

HOST=$1
OS=$2
FILE=$(find /srv/sensor/nagios/vol/etc/local -iname $1.cfg)

if [ $# -eq 0 ]
  then
    echo "Faltan argumentos."
    exit 1
fi

if [ -z "$FILE" ]
then
      echo "$FILE no encontre el cfg con ese nombre."
      exit
else
      echo "El cfg es: $FILE"

fi

aplicar_config () {
    echo "Copiando configuracion para $HOST a $FILE"
    if  [ "$OS" == "LINUX" ]; then
    echo "OS: $OS. Copiando configuracion para $HOST a $FILE"
cat << EOF >> $FILE
define servicedependency {
    host_name                           $HOST
    service_description                 PING
    dependent_host_name                 $HOST
    dependent_service_description       CPU,MEMORIA,FILESYSTEMS
    execution_failure_criteria          c
    notification_failure_criteria       c
}
EOF
        echo "Config aplicada"
elif [ "$OS" == "WIN" ]; then
    echo "OS: $OS. Copiando configuracion para $HOST a $FILE"
cat << EOF >> $FILE
define servicedependency {
    host_name                           $HOST
    service_description                 PING
    dependent_host_name                 $HOST
    dependent_service_description       CPU,MEMORIA,DISCOS
    execution_failure_criteria          c
    notification_failure_criteria       c
}
EOF
        echo "Config aplicada"
fi
}
    
while true; do
    read -p "Aplicar configuracion:
             Hostname: $HOST 
             File: $FILE
             OS: $OS
             -> Aplicar configuracion? (Yyes/Nno): "  yn
    case $yn in
        [Yy]* ) aplicar_config ; break;;
        [Nn]* ) echo "No se realizo ningun cambio"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done