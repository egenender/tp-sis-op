#!/bin/bash
#
# Comando para pasar las solicitudes de reservas a confirmadas o no confirmadas, dependiendo de la disponibilidad.
# Solo se tiene en cuenta la cantidad de butacas disponibles, no posiciones especificas
# Se dispara automaticamente

function inicializarReservar(){
	$BINDIR/Grabar_L.sh "Reservar_B" "Informativo" "Inicio de operacion de Reservar_B"
	$BINDIR/Grabar_L.sh "Reservar_B" "Informativo" "Se procesan `ls | wc -l` archivos"
}


function procesarArchivo(){
	ARCHIVO_ACTUAL= $1
	$BINDIR/Grabar_L.sh "Rerservar_B" "Informativo" "Se procesa el archivo $ARCHIVO_ACTUAL"
	#Movemos el archivo a procesar a PROCDIR
#	CORRECTO=`$BINDIR/Mover_B $ARCHIVO_ACTUAL $PROCDIR`
	CORRECTO=0
	#Ver que devuelve el mover_B
	if [ $CORRECTO != 0 ] 
	then
		$BINDIR/Grabar_L.sh "Reservar_B" "Error" "Se rechaza el archivo por estar DUPLICADO"		
#		Mover_B $ARCHIVO_ACTUAL $RECHDIR
		return
	fi

	#Verificamos si el archivo se encuentra vacio:
	if [ `cat $ARCHIVO_ACTUAL|wc -l` == 0 ]		
	then
		$BINDIR/Grabar_L.sh "Reservar_B" "Error" "No se procesa el archivo, por estar vacio"
#		$BINDIR/Mover_B.sh $ARCHIVO_ACTUAL $RECHDIR		
		return
	fi

	RESPETAFORMATO= $(esDeReservas $ARCHIVO_ACTUAL)
	if [ $RESPETAFORMATO == 0 ]
	then
		$BINDIR/Grabar_L.sh "Reservar_B" "Several Error" "El archivo no respeta el formato, no se lo procesa"
		$BINDIR/Mover_B.sh $ARCHIVO_ACTUAL $RECHDIR
		return
	fi

	#for linea in `cat $ARCHIVO_ACTUAL`
	#do	
		#validar fecha:
			#Verificar Fecha Valida. Rechazar (motivo = fecha invalida)
			#Comparar fecha actual con la de la funcion. Si la diferencia es menor o igual a 1, se rechaza. (motivo = reserva tardia)
			#Si la diferencia es mayor a 30, se rechaza (motivo = reserva anticipada)
		#Validar hora:	#Si el formato de hora no es valido, se rechaza (formato HH:MM)
		#Validar exitencia de evento
		#Validar la disponibilidad
				
	#done
	
}

ACEPDIR="TDA"
BINDIR="TDA"

#inicializarReservar
for archivo in `ls $ACEPDIR/`
do
	procesarArchivo `echo $ACEPDIR/$archivo`
done
