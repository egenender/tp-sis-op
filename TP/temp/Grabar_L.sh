#!/bin/bash
# Funcion para escribir un mensaje en el log, con origen y un tipo de mensaje (parametro opcional).
# La funcion tiene la firma: Grabar_L comando_que_llama tipo_mensaje mensaje, donde tipo_mensaje es un
# parametro opcional.
# Escribe en el archivo 'comando'.$LOGEXT.


#Verifico que no me hayan pasado una mala cantidad de parametros
if [ $# -lt 1  -o $# -gt 3 ]
then	
	# Ver de poner un mensaje mas amigable
	echo "La funcion no se utiliza de esta manera"	
	exit 1
fi

#Seteo las variables de impresion al log, dependiendo de los parametros recibidos
CALL_COMANDO=$1

if [ $# == 3 ]
then
	TIPO_MSJ=$2
	MENSAJE=$3
	MSJ_COMPLETO=`echo ${TIPO_MSJ^^} - $MENSAJE`
else	
	TIPO_MSJ=""
	MENSAJE=$2
	MSJ_COMPLETO=`echo $MENSAJE`
fi
RUTA_LOG=`echo $CALL_COMANDO.$LOGEXT`

echo $MSJ_COMPLETO >> $RUTA_LOG
