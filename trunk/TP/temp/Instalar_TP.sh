#!/bin/bash  
#
# Instala el TP
#

#Finaliza el proceso de instalacion
#Elimina los archivos temporales ( extension ".auxINST" )
#Graba en el log el motivo de finalizacion (si hubo error, el motivo, o finalizo correctamente)
function finalizarInstalacion(){
	clear

	rm -f *.auxINST
	Grabar_L.sh "Instalar_TP" "$2" "$1"
	FAIL='\033[91m'
	ENDC='\033[0m'
	OKGREEN='\033[92m'
	echo ""

	if [ "$2" == "Informativo" ]; then
		echo -e $OKGREEN
		echo "La Instalacion ha concluido Satisfactoriamente."
		echo -e $ENDC
		echo ""
		exit 0
	else
		echo -e $FAIL
		echo "INSTALACION ABORTADA"
		echo -e $ENDC
		echo ""
		exit 1
	fi

}

#Crea un directorio si este no existe
function crearDirectorio(){
	# -d para preguntar por directorio SI existe
	if ! [ -d $1/ ]; then
		#mkdir crea el directorio
		mkdir -p $1
		Grabar_L.sh "Instalar_TP" "Informativo" "Se creo el directorio "$1
	fi
}

#Recibe Mensaje como parametro
#Almacena el resultado en variable RTA
function entradaSiNo(){
	RTA="NADA"
	#ciclo hasta que el usuario indique Si o No
	until [ "${RTA}" == "SI" ] || [ "${RTA}" == "NO" ]; do
		echo $1" SI - NO"
		read RTA
		RTA=${RTA^^}
	done
}

#Imprime mensaje de que no esta Perl o su version correcta
#y finaliza el proceso de instalacion
function abortarPorNoPerl(){
	echo "TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright © Grupo 02"
	echo "Para instalar el TP es necesario contar con Perl 5 o superior instalado."
	echo "Efectue su instalación e intentelo nuevamente."
	read
	finalizarInstalacion "Para instalar el TP es necesario contar con Perl 5 o superior instalado. Proceso de Instalacion Cancelado" "ERROR"
}

#Imprime mensaje de que no esta Bash o su version correcta
#y finaliza el proceso de instalacion
function abortarPorNoBash(){
	echo "TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright © Grupo 02"
	echo "Para instalar el TP es necesario contar con Bash 4 o superior instalado."
	echo "Efectue su instalación e intentelo nuevamente."
	read
	finalizarInstalacion "Para instalar el TP es necesario contar con Bash 4 o superior instalado. Proceso de Instalacion Cancelado" "ERROR"
}

#Realiza el chequeo de que Perl este instalado y sea la version correcta
#Crea un archivo auxiliar:
# perlversion.auxINST
function chequeoPerl(){
	if perl --version > perlversion.auxINST 2>&1; then

		#Guarda en "linea" la linea que contiene la frase "v." y la version
		version=`grep 'v[0-9]\.' perlversion.auxINST | sed s/'.*v\([0-9]\).*/\1/'`
		#El sed reemplaza toda la linea por el numero de version, contigua a "v."
				
		#Se pide que la version de Perl sea mayor o igual a la version 5
		if [ $version -lt 5 ]; then
			#La version no es la adecuada. Se aborta la instalacion
			abortarPorNoPerl
		else
			Grabar_L.sh "Instalar_TP" "Informativo" "TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright © Grupo 02"
			vers="Perl Version: "$version
			Grabar_L.sh "Instalar_TP" "Informativo" "$vers"
		fi

	else
		#Perl no esta instalado
		abortarPorNoPerl	
	fi
}

#Realiza el chequeo de que Bash este instalado y sea la version correcta
function chequeoBash(){
	bash_v=`echo "$BASH_VERSION" | sed -n "s/^\([0-9]\).*/\1/p"`
	if [ -z $bash_v ]; then
		#Bash no esta instalado
		abortarPorNoBash	
	else
		if [ $bash_v -lt 4 ]; then
			#La version no es la adecuada. Se aborta la instalacion
			abortarPorNoBash
		else
			vers="Bash Version: "$bash_v
			Grabar_L.sh "Instalar_TP" "Informativo" "$vers"
		fi
	fi
}

#Se setean los parametros con los valores default
function setearParametrosDefault(){
	BINDIR="bin"
	MAEDIR="mae"
	ARRIDIR="arribos"
	ACEPDIR="aceptados"
	RECHDIR="rechazados"
	REPODIR="listados"
	PROCDIR="procesados"
	LOGDIR="log"
	DATASIZE=100
	LOGEXT="log"
	LOGSIZE=400
}

function setearVariablesFinal(){
	BINDIR="$PWD/"$BINDIR
	MAEDIR="$PWD/"$MAEDIR
	ARRIDIR="$PWD/"$ARRIDIR
	ACEPDIR="$PWD/"$ACEPDIR
	RECHDIR="$PWD/"$RECHDIR
	REPODIR="$PWD/"$REPODIR
	PROCDIR="$PWD/"$PROCDIR
	LOGDIR="$PWD/"$LOGDIR
}

#primer parametro: variable a tratar
#segundo parametro: valor default de la variable
#tercer parametro: mensaje
#primer parametro: variable a tratar
#segundo parametro: valor default de la variable
#tercer parametro: mensaje
function definirParametro(){
	echo $2 "("$1"):"
	read lectura
	RESULTADO=$1

	if [ ! "$lectura" == "" ]; then
		RESULTADO=$lectura
		Grabar_L.sh "Instalar_TP" "Informativo" "Usuario ha redefinido: "$3". Con el valor: "$RESULTADO
	fi
}

function definirParametroBINDIR(){
	valido="NO"
	RESULTADO=$1
	while [ $valido == "NO" ]; do
		echo $2 "("$1"):"
		read lectura
		valido=`echo $lectura | grep "\/"`
		if [ -z $valido ]; then
			valido="SI"
		else
			echo "El directorio de archivos binarios no puede estar definido como mas de una SubCarpeta."
			valido="NO"
		fi
	done
	if [ ! "$lectura" == "" ]; then
		RESULTADO=$lectura
		Grabar_L.sh "Instalar_TP" "Informativo" "Usuario ha redefinido: "$3". Con el valor: "$RESULTADO
	fi
}

function definirBINDIR(){
	definirParametroBINDIR "$BINDIR" "Defina el directorio de instalación de los ejecutables" "BINDIR"
	BINDIR=$RESULTADO
}

function definirMAEDIR(){
	definirParametro "$MAEDIR" "Defina el directorio de instalación de los archivos maestros" "MAEDIR"
	MAEDIR=$RESULTADO
}

function definirARRIDIR(){
	definirParametro "$ARRIDIR" "Defina el directorio de arribo de archivos externos" "ARRIDIR"
	ARRIDIR=$RESULTADO
}

function definirACEPDIR(){
	definirParametro "$ACEPDIR" "Defina el directorio de grabación de los archivos externos aceptados" "ACEPDIR"
	ACEPDIR=$RESULTADO
}

function definirRECHDIR(){
	definirParametro "$RECHDIR" "Defina el directorio de grabación de los archivos externos rechazados" "RECHDIR"
	RECHDIR=$RESULTADO
}

function definirREPODIR(){
	definirParametro "$REPODIR" "Defina el directorio de los listados de salida" "REPODIR"
	REPODIR=$RESULTADO
}

function definirPROCDIR(){
	definirParametro "$PROCDIR" "Defina el directorio de grabación de los archivos procesados" "PROCDIR"
	PROCDIR=$RESULTADO
}

function definirLOGDIR(){
	definirParametro "$LOGDIR" "Defina el directorio de logs" "LOGDIR"
	LOGDIR=$RESULTADO
}

#primer parametro: numero/cadena a verifica
#Verifica que lo ingresado por parametro sea un numero, y además, que sea positivo 
#Estan permitidos los numeros reales y la separacion de la parte entera de la fraccionaria es con "."
function esNumeroPositivo(){
	ES_POSITIVO="NO"
	ref='^[1-9][0-9]*\.?[0-9]*$'
	re='^0\.[0-9]*$'
	if [[ $1 =~ $re ]] || [[ $1 =~ $ref ]]; then
		comp=`echo "$1 > 0" | bc`
		if [ $comp -eq 1 ]; then
			ES_POSITIVO="SI"
		fi
	fi
	if [ "$ES_POSITIVO" == "NO" ]; then
		Grabar_L.sh "Instalar_TP" "Informativo" "El dato ingresado no es valido"
		echo "Debe ingresar un numero positivo."
	fi
}

#primer parametro: variable a tratar
#segundo parametro: valor default de la variable
#tercer parametro: mensaje
#cuarto parametro: unidad de medicion
function definirParametroNumerico(){
	echo $2 "("$1 $4"):"

	ES_POSITIVO="NO"
	
	while [ "${ES_POSITIVO}" == "NO" ]; do
		read lectura
		RESULTADO=$1
		if [ ! "$lectura" == "" ]; then
			RESULTADO=$lectura
			Grabar_L.sh "Instalar_TP" "Informativo" "Usuario ha redefinido: "$3". Con el valor: "$RESULTADO
			esNumeroPositivo $lectura
		else
			#El dato default es un dato valido
			ES_POSITIVO="SI"
		fi
	done
}

function definirDatasize(){
	definirParametroNumerico "$DATASIZE" "Indique el espacio mínimo libre para el arribo de archivos externos, en Mbytes" "DATASIZE" "Mb"
	DATASIZE=$RESULTADO
}

function definirLOGSIZE(){
	mensaje="Defina el tamaño máximo para los archivos "$LOG_EXT", en Kbytes"
	definirParametroNumerico "$LOGSIZE" "$mensaje" "LOGSIZE" "Kb"
	LOGSIZE=$RESULTADO
}

function definirExtensionArchivos(){
	echo "Ingrese la extensión para los archivos de log: (."$LOGEXT"):"
	read lectura
	if [ ! "$lectura" == "" ]; then
		LOGEXT=$lectura
	fi
}

#Chequea el espacio disponible en la direccion ARRIDIR
#Si es suficiente continua, sino consulta al usuario
function chequearEspacioARRIDIR(){
	TAM=`ObtenerEspacio.sh $ARRIDIR`
	#Si TAM es menor que DATASIZE comp es 1
	comp=`echo "$DATASIZE > $TAM" | bc`
	HAY_ESPACIO="SI"
	if [ $comp -eq 1 ];then
		Grabar_L.sh "Instalar_TP" "Informativo" "Insuficiente espacio en disco"
		Grabar_L.sh "Instalar_TP" "Informativo" "Espacio disponible: "$TAM" Mb"
		Grabar_L.sh "Instalar_TP" "Informativo" "Espacio requerido: "$DATASIZE" Mb"
		Grabar_L.sh "Instalar_TP" "Informativo" "Cancele la instalación e inténtelo mas tarde o vuelva a intentarlo con otro valor"
		echo "Espacio Insuficiente"
		echo "Cancele la instalación e inténtelo mas tarde o vuelva a intentarlo con otro valor"
		HAY_ESPACIO="NO"
	fi
}

#verifica el espacio en disco y de no ser suficiente pregunta al usuario
#si desea redefinirlo, hacer espacio en disco y volver a chequear, o abortar
#la instalacion
function consultarUsuarioEspacio(){
	chequearEspacioARRIDIR

	if [ "$HAY_ESPACIO" == "NO" ]; then
		entradaSiNo "Desea redefinir el valor de Espacio minimo?"
		if [ "${RTA}" == "SI" ]; then
			Grabar_L.sh "Instalar_TP" "Informativo" "Usuario ha decidido redefinir el valor de Espacio minimo."
			redefinirDatasize
		else
			Grabar_L.sh "Instalar_TP" "Informativo" "El Usuario ha decidido no redefinir el Espacio mínimo"
			entradaSiNo "Desea abortar la instalacion?"
			if [ "${RTA}" == "SI" ]; then
				finalizarInstalacion "El usuario ha abortado la instalacion." "ERROR"
			else
				msj="Se debe liberar espacio en el disco. Se solicita nueva verificacion de espacio."
				Grabar_L.sh "Instalar_TP" "Informativo" "$msj"
				continuaEspacio
			fi
		fi
	fi
}

#Indica al usuario que debe liberar espacio en el disco y espera su
#orden para volver a verificar el espacio
function continuaEspacio(){
	echo "Libere espacio en disco."
	echo "Presione Enter para continuar"
	read basura
	consultarUsuarioEspacio
}

function redefinirDatasize(){
	definirDatasize
	consultarUsuarioEspacio
}

function definirParametros(){
	#Definicion de los directorios
	definirBINDIR
	definirMAEDIR
	definirARRIDIR

	redefinirDatasize
	
	definirACEPDIR
	definirRECHDIR
	definirREPODIR
	definirPROCDIR
	definirLOGDIR
	
	definirExtensionArchivos
	
	definirLOGSIZE
}

#Pregunta al usuario si acepta las condiciones de instalacion
#Si no las acepta Aborta la instalacion
function preguntarCondicionesDeInstalacion(){
	Grabar_L.sh "Instalar_TP" "Informativo" "Inicio de Instalación completa"
	echo "TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright © Grupo 02"
	echo "A T E N C I O N: Al instalar TP SO7508 Segundo Cuatrimestre 2013 Ud. expresa aceptar los términos y Condiciones del 'ACUERDO DE LICENCIA DESOFTWARE' incluido en este paquete."	
	entradaSiNo "Acepta las condiciones?"
	
	if [ "${RTA}" == "NO" ]; then
		finalizarInstalacion "El Usuario NO Aceptó los terminos y Condiciones de Instalacion. INSTALACION ABORTADA" "ERROR"
	fi
}

#Pregunta al usuario si esta seguro de querer instalar el programa
function confirmarInstalacion(){
	Grabar_L.sh "Instalar_TP" "Informativo" "Iniciando instalacion. Se pide confirmacion al usuario."
	entradaSiNo "Iniciando Instalacion. Esta ud. seguro que desea continuar?"

	if [ "${RTA}" == "NO" ]; then
		finalizarInstalacion "Instalacion rechazada por el usuario" "ERROR"
	fi	
}

#Permite al usuario definir los parametros, luego los muestra
#y pregunta si son correctos. Si el usuario indica que no, vuelve a
#redefinirlos
function definirParametrosPorUsuario(){
	RTA="NO"
	while [ "${RTA}" == "NO" ]; do
		definirParametros
		exportarVariables
		imprimirSusRespuestas.sh 0 "LISTA" "Instalar_TP"
		entradaSiNo "Es correcta la configuracion?"
		if [ "${RTA}" == "NO" ]; then
			Grabar_L.sh "Instalar_TP" "Informativo" "Configuracion rechazada por el usuario"
			clear
		fi
	done
}

#Se crean todos los directorios necesarios (en caso de no existir)
function crearDirectorios(){
	echo "Creando Estructuras de Directorio..."
	
	crearDirectorio $BINDIR
	crearDirectorio $MAEDIR
	crearDirectorio $ARRIDIR
	crearDirectorio $RECHDIR
	crearDirectorio $ACEPDIR
	crearDirectorio $REPODIR
	crearDirectorio $PROCDIR
	crearDirectorio $LOGDIR

	echo "Creacion de Directorios Finalizada!"
}

function moverArchivos(){
	chmod a+x ARCHS/BINARIOS/*.sh
	cp ARCHS/BINARIOS/*.sh $BINDIR
	cp ARCHS/BINARIOS/*.pl $BINDIR
	cp ARCHS/MAESTROS/*.mae $MAEDIR
	cp ARCHS/MAESTROS/*.dis $PROCDIR
}

#A partir del archivo de configuraciones, obtiene el valor del
#registro correspondiente
#parametro 1: registro buscado
function obtenerValorExistente(){
	re="^$1"
	linea_original=`grep "$re" < $2`
	VALOR_EN_ARCH=`echo "$linea_original" | cut -d "=" -f 2`
}

#Escribe un registro en ARCHCONF
function escribirRegistro(){
	echo $1"="$2"="$(whoami)"="`date` >> $ARCHCONF
}

#Crea el archivo de configuracion y guarda todos los registros
#Separacion de registros "="
function actualizarConfiguracionCompleto(){
	
	echo "Actualizando la configuración del sistema"
	Grabar_L.sh "Instalar_TP" "Informativo" "Se almacenan todos los registros en el archivo de configuración."
	
	> $ARCHCONF #Crea el archivo vacio

	escribirRegistro "GRUPO" "$GRUPO"
	escribirRegistro "CONFDIR" $CONFDIR
	escribirRegistro "BINDIR" $BINDIR
	escribirRegistro "MAEDIR" $MAEDIR
	escribirRegistro "ARRIDIR" $ARRIDIR
	escribirRegistro "ACEPDIR" $ACEPDIR
	escribirRegistro "RECHDIR" $RECHDIR
	escribirRegistro "REPODIR" $REPODIR
	escribirRegistro "PROCDIR" $PROCDIR
	escribirRegistro "LOGDIR" $LOGDIR
	escribirRegistro "LOGEXT" $LOGEXT
	escribirRegistro "LOGSIZE" $LOGSIZE
	escribirRegistro "DATASIZE" $DATASIZE	
}

#Proceso de instalacion
function instalar(){
	
	preguntarCondicionesDeInstalacion
	
	chequeoPerl
	chequeoBash
	
	setearParametrosDefault
	
	definirParametrosPorUsuario

	confirmarInstalacion
	
	setearVariablesFinal
	
	crearDirectorios
	
	moverArchivos
	
	actualizarConfiguracionCompleto
	
	finalizarInstalacion "Instalacion: CONCLUIDA" "Informativo"
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

function verificarEspacioEnDisco() {
	TAM=`ObtenerEspacio.sh $ARRIDIR`
	comp=`echo "$DATASIZE > $TAM" | bc`
	if [ $comp -eq 1 ];then
		Grabar_L.sh "Instalar_TP" "Informativo" "Insuficiente espacio en disco"
		Grabar_L.sh "Instalar_TP" "Informativo" "Espacio disponible: "$TAM" Mb"
		Grabar_L.sh "Instalar_TP" "Informativo" "Espacio requisitado: "$DATASIZE" Mb"
		echo "Espacio Insuficiente"
		msj="Espacio insuficiente para datos. Instalacion Abortada"
		finalizarInstalacion "$msj" "ERROR"
	fi
}

function exportarVariables(){
	export GRUPO
	export CONFDIR
	export ARRIDIR
	export ACEPDIR
	export RECHDIR
	export PROCDIR
	export BINDIR
	export MAEDIR
	export REPODIR
	export LOGDIR
	export LOGEXT
	export LOGSIZE
	export DATASIZE
}

function imprimirFaltantes(){
	echo "Componentes Faltantes:"
	cat componentesFaltantes.auxINST
}

function completarInstalacion(){
	entradaSiNo "Desea Completar la Instalación?"
	
	if [ "${RTA}" == "NO" ]; then
		rm $CONFTEMP
		finalizarInstalacion "El Usuario decidió no completar la instalación" "ERROR"
	fi
	
	chequeoPerl
	chequeoBash
	
	exportarVariables
	imprimirSusRespuestas.sh 0 "LISTA" "Instalar_TP"	
	confirmarInstalacion
	
	crearDirectorios
	
	moverArchivos
	
	#elimina la configuracion anterior
	mv $CONFTEMP $ARCHCONF
	
	finalizarInstalacion "Instalacion: CONCLUIDA" "Informativo"
}

function informaryCompletarInstalacion(){
	exportarVariables
	imprimirSusRespuestas.sh 1 "INCOMPLETA" "Instalar_TP"
	
	CONFTEMP=$ARCHCONF".auxINST"
	obtenerValoresExistentes "$CONFTEMP"
	
	verificarEspacioEnDisco
	
	imprimirFaltantes

	completarInstalacion
}

#otorga permisos de ejecucion  de los scripts que utiliza
chmod a+x $PWD"/ARCHS/BINARIOS/"*.sh

#setea la variable de configuracion
export CONFDIR="$PWD"/conf

DIR_ACTUAL=$PWD
GRUPO=grupo02

export PATH=$PATH:$PWD"/ARCHS/BINARIOS/"

crearDirectorio "$CONFDIR"

Grabar_L.sh "Instalar_TP" "Informativo" "Inicio de Instalación"
Grabar_L.sh "Instalar_TP" "Informativo" "Log del Comando Instalar_TP: "$CONFDIR"Instalar_TP.log"
Grabar_L.sh "Instalar_TP" "Informativo" "Directorio de Configuración: "$CONFDIR

ARCHCONF=$CONFDIR"/Instalar_TP.conf"
export ARCHCONF

if [ -f $ARCHCONF ]; then
	obtenerValoresExistentes "$ARCHCONF"
fi

exportarVariables
Verificar_Instalacion.sh "Instalar_TP"

estado=$?
# no esta instalado
if [ $estado -eq 2 ]; then
	instalar
fi

# instalacion incompleta
if [ $estado -eq 1 ]; then
	informaryCompletarInstalacion
fi

#instalacion completa
exportarVariables
imprimirSusRespuestas.sh 1 "COMPLETA" "Instalar_TP"
read basura
finalizarInstalacion "Proceso de Instalación Cancelado" "Informativo"
