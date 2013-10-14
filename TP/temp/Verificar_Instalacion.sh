#!/bin/bash            
#
# Verifica Instalación del TP
#
# 2: no está instalado
# 1: instalación incompleta
# 0: instalación completa

#Escribe la linea del registro actualizado en el archivo temporal
#Si el registro no cambio, escribe la linea original
#Parametro 1: nombre del registro 
#Parametro 2: variable
function actualizarRegistroExistente(){
	obtenerValorExistente $1 "$ARCHCONF"
	if ! [ $VALOR_EN_ARCH == $2 ]; then
		echo $1"="$2"="$(whoami)"="`date` >> $CONFTEMP
		mensaje="El valor de "$1" fue actualizado a: "$2
		./Grabar_L.sh "Instalar_TP" "Informativo" "$mensaje"
	else
		echo $linea_original >> $CONFTEMP
	fi
}

#Actualiza el archivo de configuraciones con los nuevos valores
#de los parametros. Si el valor del parametro no cambia, tampoco
#lo hace el registro
#Crea un archivo auxiliar
function actualizarConfiguracionExistente(){
	CONFTEMP=$ARCHCONF".auxINST"
	> $CONFTEMP #Crea el archivo vacio
	
	actualizarRegistroExistente "GRUPO" $GRUPO
	actualizarRegistroExistente "CONFDIR" $CONFDIR
	actualizarRegistroExistente "BINDIR" $BINDIR
	actualizarRegistroExistente "MAEDIR" $MAEDIR
	actualizarRegistroExistente "ARRIDIR" $ARRIDIR
	actualizarRegistroExistente "ACEPDIR" $ACEPDIR
	actualizarRegistroExistente "RECHDIR" $RECHDIR
	actualizarRegistroExistente "REPODIR" $REPODIR
	actualizarRegistroExistente "PROCDIR" $PROCDIR
	actualizarRegistroExistente "LOGDIR" $LOGDIR
	actualizarRegistroExistente "LOGEXT" $LOGEXT
	actualizarRegistroExistente "LOGSIZE" $LOGSIZE
	actualizarRegistroExistente "DATASIZE" $DATASIZE
}

function modificarVarsPorFallo(){
	if [ $FALLOBINDIR -eq 1 ]; then
		BINDIR="bin"
	fi
	if [ $FALLOMAEDIR -eq 1 ]; then
		MAEDIR="mae"
	fi
	if [ $FALLOARRIDIR -eq 1 ]; then
		ARRIDIR="arribos"
	fi
	if [ $FALLOACEPDIR -eq 1 ]; then
		ACEPDIR="aceptados"
	fi
	if [ $FALLORECHDIR -eq 1 ]; then
		RECHDIR="rechazados"
	fi
	if [ $FALLODATASIZE -eq 1 ]; then
		DATASIZE=100
	fi
	if [ $FALLOREPODIR -eq 1 ]; then
		REPODIR="listados"
	fi
	if [ $FALLOPROCDIR -eq 1 ]; then
		PROCDIR="procesados"
	fi
	if [ $FALLOLOGDIR -eq 1 ]; then
		LOGDIR="log"
	fi
}

#A partir del archivo de configuraciones, obtiene el valor del
#registro correspondiente
#parametro 1: registro buscado
function obtenerValorExistente(){
	re="^$1"
	linea_original=`grep "$re" < $2`
	VALOR_EN_ARCH=`echo "$linea_original" | cut -d "=" -f 2`
}

function obtenerValoresExistentes(){
	obtenerValorExistente "BINDIR" "$1"
	BINDIR=$VALOR_EN_ARCH
	obtenerValorExistente "MAEDIR" "$1"
	MAEDIR=$VALOR_EN_ARCH
	obtenerValorExistente "ARRIDIR" "$1"
	ARRIDIR=$VALOR_EN_ARCH
	obtenerValorExistente "ACEPDIR" "$1"
	ACEPDIR=$VALOR_EN_ARCH
	obtenerValorExistente "RECHDIR" "$1"
	RECHDIR=$VALOR_EN_ARCH
	obtenerValorExistente "REPODIR" "$1"
	REPODIR=$VALOR_EN_ARCH
	obtenerValorExistente "PROCDIR" "$1"
	PROCDIR=$VALOR_EN_ARCH
	obtenerValorExistente "LOGDIR" "$1"
	LOGDIR=$VALOR_EN_ARCH
	obtenerValorExistente "LOGEXT" "$1"
	LOGEXT=$VALOR_EN_ARCH
	obtenerValorExistente "LOGSIZE" "$1"
	LOGSIZE=$VALOR_EN_ARCH
	obtenerValorExistente "DATASIZE" "$1"
	DATASIZE=$VALOR_EN_ARCH
}

function verificarComponenteDATASIZE() {
	FALLODATASIZE=0
	TAM=`./ObtenerEspacio.sh $ARRIDIR`
	#Si TAM es menor que DATASIZE comp es 1
	comp=`echo "$DATASIZE > $TAM" | bc`
	if [ $comp -eq 1 ];then
		echo "Tamaño de datos definido muy elevado: "$DATASIZE  >> componentesFaltantes.auxINST
		FALLODATASIZE=1
	fi
}

function verificarComponenteMAEDIR(){
	FALLOMAEDIR=0
	if ! [ -d $MAEDIR ]; then
		./Grabar_L.sh "Instalar_TP" "Informativo" "No existe el directorio de archivos maestros: "$MAEDIR
		echo "No existe el directorio de archivos maestros:" $MAEDIR >> componentesFaltantes.auxINST
		FALLOMAEDIR=1
		return 1
	fi
	if ! [ -f $MAEDIR"/salas.mae" ]; then
		./Grabar_L.sh "Instalar_TP" "Informativo" "No existe el archivo maestro de salas en: "$MAEDIR
		echo "Archivo maestro de salas:" salas.mae >> componentesFaltantes.auxINST
		FALLOMAEDIR=1
	fi
	if ! [ -f $MAEDIR"/obras.mae" ]; then
		./Grabar_L.sh "Instalar_TP" "Informativo" "No existe el archivo maestro de obras en: "$MAEDIR
		echo "Archivo maestro de obras:" obras.mae >> componentesFaltantes.auxINST
		FALLOMAEDIR=1
	fi
}

function verificarEjecutable(){
	if ! [ -f "$1"/"$2" ]; then
		msj="No existe el archivo "$2" en: "$1
		./Grabar_L.sh "Instalar_TP" "Informativo" "$msj"
		echo "Archivo ejecutable: ""$2" >> componentesFaltantes.auxINST
		FALLOBINDIR=1
	fi
}

function verificarComponenteBINDIR(){
	FALLOBINDIR=0
	if ! [ -d $BINDIR ]; then
		./Grabar_L.sh "Instalar_TP" "Informativo" "No existe el directorio de ejecutables: "$BINDIR
		echo "No existe el directorio de archivos ejecutables:" $BINDIR >> componentesFaltantes.auxINST
		FALLOBINDIR=1
		return 1
	fi
	verificarEjecutable $BINDIR Iniciar_B.sh
	verificarEjecutable $BINDIR Recibir_B.sh
	verificarEjecutable $BINDIR Reservar_B.sh
	verificarEjecutable $BINDIR Grabar_L.sh
	verificarEjecutable $BINDIR Mover_B.sh
	verificarEjecutable $BINDIR Start_D.sh
	verificarEjecutable $BINDIR Stop_D.sh
}

function verificarComponenteARRIDIR(){
	FALLOARRIDIR=0
	if ! [ -d $ARRIDIR ]; then
		./Grabar_L.sh "Instalar_TP" "Informativo" "No existe el directorio de arribos: "$ARRIDIR
		echo "No existe el directorio de arribos: "$ARRIDIR >> componentesFaltantes.auxINST
		FALLOARRIDIR=1
	fi
}

function verificarComponenteACEPDIR(){
	FALLOACEPDIR=0
	if ! [ -d $ACEPDIR ]; then
		./Grabar_L.sh "Instalar_TP" "Informativo" "No existe el directorio de archivos aceptados: "$ACEPDIR
		echo "No existe el directorio de archivos aceptados: "$ACEPDIR >> componentesFaltantes.auxINST
		FALLOACEPDIR=1
	fi
}

function verificarComponenteRECHDIR(){
	FALLORECHDIR=0
	if ! [ -d $RECHDIR ]; then
		./Grabar_L.sh "Instalar_TP" "Informativo" "No existe el directorio de archivos rechazados: "$RECHDIR
		echo "No existe el directorio de archivos rechazados: "$RECHDIR >> componentesFaltantes.auxINST
		FALLORECHDIR=1
	fi
}

function verificarComponenteREPODIR(){
	FALLOREPODIR=0
	if ! [ -d $REPODIR ]; then
		./Grabar_L.sh "Instalar_TP" "Informativo" "No existe el directorio de reportes de salida: "$REPODIR
		echo "No existe el directorio de reportes de salida: "$REPODIR >> componentesFaltantes.auxINST
		FALLOREPODIR=1
	fi
}

function verificarComponentePROCDIR(){
	FALLOPROCDIR=0
	if ! [ -d $PROCDIR ]; then
		./Grabar_L.sh "Instalar_TP" "Informativo" "No existe el directorio de archivos procesados: "$PROCDIR
		echo "No existe el directorio de archivos procesados: "$PROCDIR >> componentesFaltantes.auxINST
		FALLOPROCDIR=1
	fi
}

function verificarComponenteLOGDIR(){
	FALLOLOGDIR=0
	if ! [ -d $LOGDIR ]; then
		./Grabar_L.sh "Instalar_TP" "Informativo" "No existe el directorio de archivos de log: "$LOGDIR
		 echo "No existe el directorio de archivos de log: "$LOGDIR >> componentesFaltantes.auxINST
		FALLOLOGDIR=1
	fi
}

function verificarComponentes(){
	verificarComponenteBINDIR
	verificarComponenteMAEDIR
	verificarComponenteARRIDIR
	verificarComponenteACEPDIR
	verificarComponenteRECHDIR
	verificarComponenteREPODIR
	verificarComponentePROCDIR
	verificarComponenteDATASIZE
	verificarComponenteLOGDIR
}

ARCHCONF=$CONFDIR"Instalar_TP.conf"
export ARCHCONF

if [ ! -f $ARCHCONF ]; then
	./Grabar_L.sh "Instalar_TP" "Informativo" "El TP no está instalado"
	exit 2
fi

verificarComponentes

sumaFallos=`expr $FALLOBINDIR + $FALLOMAEDIR + $FALLOARRIDIR + $FALLODATASIZE + $FALLOACEPDIR + $FALLORECHDIR + $FALLOREPODIR + $FALLOPROCDIR + $FALLOLOGDIR`
if [ $sumaFallos -eq 0 ]; then
	./Grabar_L.sh "Instalar_TP" "Informativo" "La instalación está completa"
	exit 0
fi

./Grabar_L.sh "Instalar_TP" "Informativo" "La instalación está incompleta"
GRUPO=grupo02
obtenerValoresExistentes $ARCHCONF
modificarVarsPorFallo
actualizarConfiguracionExistente
exit 1
