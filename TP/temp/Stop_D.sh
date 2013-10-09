#!/bin/bash            
#
# Nombre: Stop_D
#
# Detiene un demonio
# 

# TODO: en principio, solo el Recibir_B.sh

# Obtengo su PID:
PID=`ps | grep "Recibir_B.sh" | head -1 | awk '{print $1 }'`
if [ -z "$PID" ]
then
	exit 1 # No habia proceso a detener
else
	kill -KILL $PID # Matamos el proceso
	killall sleep 2> /dev/null
	exit 0
fi