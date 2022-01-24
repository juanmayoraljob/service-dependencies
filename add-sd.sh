#!/bin/bash

HOST=$1
OS=$2
ALL=$3
PATH_BASE=$(dirname "$0")
PATH_BACKUP=$PATH_BASE/backup
FILE=$(find /srv/sensor/nagios/vol/etc/local -iname $1.cfg)
ID=$(docker ps |grep -i naemon |awk '{print $NF}')
#ALLSERVICES=$(grep -i service_description $FILE |grep -iv ping |grep -v "#" |awk '{print $2}' | paste -s -d, -)
ALLSERVICES=$(docker exec -i $ID /bin/bash -c "pynag list WHERE host_name=$HOST and object_type=service" |grep service |grep -v "PING" |awk '{print $2}' | cut -d '/' -f2 | paste -s -d,)
BASICSERVICES=$(docker exec -i $ID /bin/bash -c "pynag list WHERE host_name=$HOST and object_type=service" |grep service |egrep -i 'FILESYS*|LOAD|CPU|MEMORI*|SERVIC*|DISCO*|SWAP|' |grep -v "PING" |awk '{print $2}' | cut -d '/' -f2 | paste -s -d,)

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

cp $FILE $PATH_BACKUP/$HOST.bkp
check_status () {
    if [ $? -eq 0 ]; then echo "Error" exit; fi
}


LINUX (){
        echo "Copiando configuracion para $HOST a $FILE"
    if  [ "$OS" == "LINUX" ] && [ -z $ALL ]; then
        echo "OS: $OS. Copiando configuracion para $HOST a $FILE para los servicios basicos: $BASICSERVICES"
cat << EOF >> $FILE
define servicedependency {
    host_name                           $HOST
    service_description                 PING
    dependent_host_name                 $HOST
    dependent_service_description       $BASICSERVICES
    execution_failure_criteria          c
    notification_failure_criteria       c
}
EOF
    check_status
    echo "Config aplicada"
elif [ "$OS" == "LINUX" ] && [ ! -z $ALL ]; then
        echo "OS: $OS. Copiando configuracion para $HOST a $FILE para todos los servicios: $ALLSERVICES"
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
    check_status
echo "Config aplicada"
fi
}

WIN () {
            echo "Copiando configuracion para $HOST a $FILE"
    if  [ "$OS" == "WIN" ] && [ -z $ALL ]; then
        echo "OS: $OS. Copiando configuracion para $HOST a $FILE $FILE para los servicios basicos: $BASICSERVICES"
cat << EOF >> $FILE
define servicedependency {
    host_name                           $HOST
    service_description                 PING
    dependent_host_name                 $HOST
    dependent_service_description       $BASICSERVICES
    execution_failure_criteria          c
    notification_failure_criteria       c
}
EOF
    check_status
    echo "Config aplicada"
elif [ "$OS" == "WIN" ] && [ ! -z $ALL ]; then
        echo "OS: $OS. Copiando configuracion para $HOST a $FILE para todos los servicios: $ALLSERVICES"
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
    check_status
echo "Config aplicada"
fi
}

ALL () {
                echo "Copiando configuracion para $HOST a $FILE"
    if  [ "$OS" == "ALL" ]; then
        echo "OS: $OS. Copiando configuracion para $HOST a $FILE para todos los servicios: $ALLSERVICES"
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
    check_status
echo "Config aplicada"
fi
}

if [ -z "$ALL" ] && [ $OS != "ALL" ]
then
while true; do
    read -p "Aplicar configuracion:
             Hostname: $HOST
             File: $FILE
             OS: $OS
             Services: $BASICSERVICES
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
