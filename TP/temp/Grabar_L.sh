#!/bin/bash
# Funcion para escribir un mensaje en el log, con origen y un tipo de mensaje (parametro opcional).
# La funcion tiene la firma: Grabar_L comando_que_llama tipo_mensaje mensaje, donde tipo_mensaje es un
# parametro opcional.
# Escribe en el archivo 'comando'.$LOGEXT.


function verificarRecorte(){
	CANT_LINEAS=`cat $RUTA_LOG | wc -l`
	if [ "$CANT_LINEAS" -gt "$LOGSIZE" ]
	then
		#Me quedo con las ultimas 50 lineas del log y agrego que recorto
		TEMP_LOG=`echo "$RUTA_LOG".temp`
		echo "Log Excedido, se recorta el log" > $TEMP_LOG
		tail -n 50 $RUTA_LOG >> $TEMP_LOG
		rm $RUTA_LOG
		cat $TEMP_LOG > $RUTA_LOG
		rm $TEMP_LOG
	fi
}

function loggear_install(){
	
	echo $MSJ_COMPLETO >> "$CONFDIR"Instalar_TP.log
}

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
	MSJ_COMPLETO=`date`" - "`echo ${TIPO_MSJ^^} - $MENSAJE`
else	
	TIPO_MSJ=""
	MENSAJE=$2
	MSJ_COMPLETO=`date`" - "`echo $MENSAJE`
fi

if [ $CALL_COMANDO == "Instalar_TP" ]
then
	loggear_install
	exit 0
fi

RUTA_LOG=`echo $LOGDIR$CALL_COMANDO$LOGEXT`

echo $MSJ_COMPLETO >> $RUTA_LOG 
verificarRecorte
