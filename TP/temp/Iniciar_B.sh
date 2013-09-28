#!/bin/bash

function setearVariables(){
	PATH=""
	GRUPO=""
	ARRIDIR=""
	RECHDIR=""
	BINDIR=""
	MAEDIR=""
	REPODIR=""
	LOGDIR=""
	LOGEXT=""
	LOGSIZE=""
	#Ver si falta alguno mas
	
	export PATH
	export GRUPO
	export ARRIDIR
	export RECHDIR
	export BINDIR
	export MAEDIR
	export REPODIR
	export LOGDIR
	export LOGEXT
	export LOGSIZE
}

function verificarInstalacion(){
	#TODO
	echo 0
}

function explicarStop(){
	#Aca iria la explicacion de como funciona el STOP_D
}

function explicarStart(){
	#Aca iria la explicacion de como funciona el START_D
}

function impresionesTP(){
	echo "TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright © Grupo $GRUPO"
	echo "Librería del Sistema: $CONFDIR. Archivos:"
	ls $CONFDIR/
	echo "Ejecutables: $BINDIR. Archivos:"
	ls $BINDIR/
	echo "Archivos maestros: $MAEDIR"
	ls $MAEDIR/
	echo "Directorio de arribo de archivos externos: $ARRIDIR"
	echo "Archivos externos aceptados: $ACEPDIR"
	echo "Archivos externos rechazados: $RECHDIR"
	echo "Reportes de salida: $REPODIR"
	echo "Archivos procesados: $PROCDIR"
	echo "Logs de auditoria del Sistema: $LOGDIR/<comando>.$LOGEXT"
	echo "Estado del Sistema: INICIALIZADO"
	echo "Demonio corriendo bajo el no.: <Process Id de Recibir_B>"
}

function solicitarInicioRecibir(){
	echo "Desea efectuar la activación de Recibir_B?” Si – No"
	#leer stdin
	#CONTINUAR=1
	#while [ $CONTINUAR -eq 1 ]
	#do
	# 	if [ lectura == "Si"]
	#	then
	#		RTA=0
	#		CONTINUAR=0
	#	fi
	# 	if [ lectura == "No"]
	#	then
	#		RTA=1
	#		CONTINUAR=0
	#	fi
	#done
	#echo $RTA
	echo 0
}


#Me fijo si hay otra sesion en ejecucion (igual no me gusta esta forma)
if [[ ! -z "$REEJECUCION" ]]
then
	echo "El ambiente ya fue inicializado. Si desea reiniciar, termine su sesion e ingrese nuevamente"
	exit 1
fi
REEJECUCION=1
export REEJECUCION

#Inicializamos el log del comando Iniciar_B
./Grabar_L.sh "Iniciar_B" "Informativo" "Inicio de Ejecución"

ESTADO_INST=$(verificarInstalacion)
if [ $ESTADO_INST -eq 1 ]
then
	./Grabar_L.sh "Iniciar_B" "SEVERAL ERROR" "La instalacion no se ha completado"
	exit 1
fi

setearVariables
RECIB=$(solicitarInicioRecibir)
if [ RECIB -eq 0 ]
then
	explicarStop
	if [ otroRecibirB -eq 0 ]
	then
		# comenzar el RECIBIR_B!!!
		impresionesTP
	else
		echo "Hay otro Recibir_B en ejecucion"
	fi
else
	explicacionStart
fi
