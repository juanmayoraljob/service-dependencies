#!/bin/bash

HOST=$1
OS=$2
ALL=$3
FILE=$(find /srv/sensor/nagios/vol/etc/local -iname $1.cfg)
ID=$(docker ps |grep -i naemon |awk '{print $NF}')
ALLSERVICES=$(grep -i service_description $FILE |grep -iv ping |awk '{print $2}' | paste -s -d, -)

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


LINUX (){
        echo "Copiando configuracion para $HOST a $FILE"
    if  [ "$OS" == "LINUX" ] && [ -z $ALL ]; then
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
elif [ "$OS" == "LINUX" ] && [ ! -z $ALL ]; then
        echo "OS: $OS. Copiando configuracion para $HOST a $FILE for services: $ALLSERVICES"
cat << EOF >> $FILE
define servicedependency {
    host_name                           $HOST
    service_description                 PING
    dependent_host_name                 $HOST
    dependent_service_description       $ALLSERVICES
    execution_failure_criteria          c
    notification_failure_criteria       c
}
EOF
echo "Config aplicada"
fi
}

WIN () {
            echo "Copiando configuracion para $HOST a $FILE"
    if  [ "$OS" == "WIN" ] && [ -z $ALL ]; then
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
elif [ "$OS" == "WIN" ] && [ ! -z $ALL ]; then
        echo "OS: $OS. Copiando configuracion para $HOST a $FILE for services: $ALLSERVICES"
cat << EOF >> $FILE
define servicedependency {
    host_name                           $HOST
    service_description                 PING
    dependent_host_name                 $HOST
    dependent_service_description       $ALLSERVICES
    execution_failure_criteria          c
    notification_failure_criteria       c
}
EOF
echo "Config aplicada"
fi
}

VMWARE () {
                echo "Copiando configuracion para $HOST a $FILE"
    if  [ "$OS" == "VMWARE" ]; then
        echo "OS: $OS. Copiando configuracion para $HOST a $FILE for services: $ALLSERVICES"
cat << EOF >> $FILE
define servicedependency {
    host_name                           $HOST
    service_description                 PING
    dependent_host_name                 $HOST
    dependent_service_description       $ALLSERVICES
    execution_failure_criteria          c
    notification_failure_criteria       c
}
EOF
echo "Config aplicada"
fi
}

if [ -z "$ALL" ]
then
while true; do
    read -p "Aplicar configuracion:
             Hostname: $HOST 
             File: $FILE
             OS: $OS
             Services: BASICOS 
             -> Aplicar configuracion? (Yyes/Nno): "  yn
    case $yn in
        [Yy]* ) $OS ; break;;
        [Nn]* ) echo "No se realizo ningun cambio"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

else

while true; do
    read -p "Aplicar configuracion:
             Hostname: $HOST 
             File: $FILE
             OS: $OS
             Services: $ALLSERVICES
             -> Aplicar configuracion? (Yyes/Nno): "  yn
    case $yn in
        [Yy]* ) $OS ; break;;
        [Nn]* ) echo "No se realizo ningun cambio"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

fi