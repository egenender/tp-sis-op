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
	./Grabar_L.sh "Instalar_TP" "Informativo" "$1"
	
	if [ "$2" == "OK" ]; then
		echo ""
		echo "La Instalacion ha concluido Satisfactoriamente."
		echo ""
	else
		echo ""
		echo "INSTALACION ABORTADA"
		echo ""
	fi

	exit 0
}

#Crea un directorio si este no existe
function crearDirectorio(){
	# -d para preguntar por directorio SI existe
	if ! [ -d $1/ ]; then
		#mkdir crea el directorio
		mkdir -p $1
		./Grabar_L.sh "Instalar_TP" "Informativo" "Se creo el directorio "$1
	fi
}

#Recibe Mensaje como parametro
#Almacena el resultado en variable RTA
function entradaSiNo(){
	RTA="NADA"
	#ciclo hasta que el usuario indique Si o No
	until [ "${RTA^^}" == "SI" ] || [ "${RTA^^}" == "NO" ]; do
		echo $1" Si - No"
		read RTA
	done
}

#Imprime mensaje de que no esta Perl o su version correcta
#y finaliza el proceso de instalacion
function abortarPorNoPerl(){
	echo "TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright © Grupo 02"
	echo "Para instalar el TP es necesario contar con Perl 5 o superior instalado."
	echo "Efectue su instalación e intentelo nuevamente."
	finalizarInstalacion "Para instalar el TP es necesario contar con Perl 5 o superior instalado. Proceso de Instalacion Cancelado" "ERROR"
}

#Realiza el chequeo de que Perl este instalado y sea la version correcta
#Crea un archivo auxiliar:
# perlversion.auxINST
function chequeoPerl(){
	if perl --version > perlversion.auxINST 2>&1; then

		#Guarda en "linea" la linea que contiene la frase "This is perl"
		linea=`grep '^This is perl .,' < perlversion.auxINST`
		#Borro la parte que dice "This is perl " xq luego de eso viene escrita la version
		linea=${linea##"This is perl "}
		#En version queda el numero de version ya que este es el primer caracter de la linea
		version=${linea:0:1}

		#Se pide que la version de Perl sea mayor o igual a la version 5
		if [ $version -lt 5 ]; then
			#La version no es la adecuada. Se aborta la instalacion
			abortarPorNoPerl
		else
			./Grabar_L.sh "Instalar_TP" "Informativo" "TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright © Grupo 02"
			vers="Perl Version: "$version
			./Grabar_L.sh "Instalar_TP" "Informativo" "$vers"
		fi

	else
		#Perl no esta instalado
		abortarPorNoPerl	
	fi

}

#Se setean los parametros con los valores default
function setearParametrosDefault(){
	BINDIR="bin"
	export BINDIR
	MAEDIR="mae"
	export MAEDIR
	ARRIDIR="arribos"
	export ARRIDIR
	ACEPDIR="aceptados"
	export ACEPDIR
	RECHDIR="rechazados"
	export RECHDIR
	REPODIR="listados"
	export REPODIR
	PROCDIR="procesados"
	export PROCDIR
	LOGDIR="log"
	export LOGDIR
	DATASIZE=100
	export DATASIZE
	LOGEXT="log"
	export LOGEXT
	LOGSIZE=400
	export LOGSIZE
}

function definirBINDIR(){
	definirParametro "$BINDIR" "Defina el directorio de instalación de los ejecutables" "BINDIR"
	BINDIR=$RESULTADO
	export BINDIR
}

function definirMAEDIR(){
	definirParametro "$MAEDIR" "Defina el directorio de instalación de los archivos maestros" "MAEDIR"
	MAEDIR=$RESULTADO
	export MAEDIR
}

function definirARRIDIR(){
	definirParametro "$ARRIDIR" "Defina el directorio de arribo de archivos externos" "ARRIDIR"
	ARRIDIR=$RESULTADO
	export ARRIDIR
}

function definirACEPDIR(){
	definirParametro "$ACEPDIR" "Defina el directorio de grabación de los archivos externos aceptados" "ACEPDIR"
	ACEPDIR=$RESULTADO
	export ACEPDIR
}

function definirRECHDIR(){
	definirParametro "$RECHDIR" "Defina el directorio de grabación de los archivos externos rechazados" "RECHDIR"
	RECHDIR=$RESULTADO
	export RECHDIR
}

function definirREPODIR(){
	definirParametro "$REPODIR" "Defina el directorio de los listados de salida" "REPODIR"
	REPODIR=$RESULTADO
	export REPODIR
}

function definirPROCDIR(){
	definirParametro "$PROCDIR" "Defina el directorio de grabación de los archivos procesados" "PROCDIR"
	PROCDIR=$RESULTADO
	export PROCDIR
}

function definirLOGDIR(){
	definirParametro "$LOGDIR" "Defina el directorio de logs" "LOGDIR"
	LOGDIR=$RESULTADO
	export LOGDIR
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
		./Grabar_L.sh "Instalar_TP" "Informativo" "El dato ingresado no es valido"
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
	
	while [ "${ES_POSITIVO^^}" == "NO" ]; do
		read lectura
		RESULTADO=$1
		if [ ! "$lectura" == "" ]; then
			RESULTADO=$lectura
			./Grabar_L.sh "Instalar_TP" "Informativo" "Usuario ha redefinido: "$3". Con el valor: "$RESULTADO
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
	export DATASIZE
}

function definirLOGSIZE(){
	mensaje="Defina el tamaño máximo para los archivos "$LOGEXT", en Kbytes"
	definirParametroNumerico "$LOGSIZE" "$mensaje" "LOGSIZE" "Kb"
	LOGSIZE=$RESULTADO
	export LOGSIZE
}

function definirExtensionArchivos(){
	echo "Ingrese la extensión para los archivos de log: (."$LOGEXT"):"
	read lectura
	if [ ! "$lectura" == "" ]; then
		LOGEXT=$lectura
		export LOGEXT
	fi
}

#Chequea el espacio disponible en la direccion ARRIDIR
#Si es suficiente continua, sino consulta al usuario
function chequearEspacioARRIDIR(){
	#obtener espacio que le queda en Kb
	#df $ARRIDIR > espacio.auxINST
	df $CONFDIR > espacio.auxINST
	
	#obtengo la linea donde se encuentran los datos (ultima linea del archivo)
	linea=`tail -1 espacio.auxINST`
	
	i=0
	for c in $linea; do
		i=`expr 1 + $i`
		#El cuarto valor corresponde al tamaño disponible
		if [ $i -eq 4 ]; then
			TAM=$c
		fi
	done
	
	#Como el valor esta en Kb divido para tenerlo en Mb
	TAM=$(echo "$TAM / 1024" |bc -l)
	
	#Si TAM es menor que DATASIZE comp es 1
	comp=`echo "$DATASIZE > $TAM" | bc`
	HAY_ESPACIO="SI"
	if [ $comp -eq 1 ];then
		./Grabar_L.sh "Instalar_TP" "Informativo" "Insuficiente espacio en disco"
		./Grabar_L.sh "Instalar_TP" "Informativo" "Espacio disponible: "$TAM" Mb"
		./Grabar_L.sh "Instalar_TP" "Informativo" "Espacio requerido: "$DATASIZE" Mb"
		./Grabar_L.sh "Instalar_TP" "Informativo" "Cancele la instalación e inténtelo mas tarde o vuelva a intentarlo con otro valor"
		echo "Espacio Insuficiente"
		echo "Cancele la instalación e inténtelo mas tarde o vuelva a intentarlo con otro valor"
		HAY_ESPACIO="NO"
	fi
}

#primer parametro: variable a tratar
#segundo parametro: valor default de la variable
#tercer parametro: mensaje
function definirParametro(){
	echo $2 "("$GRUPO"/"$1"):"
	read lectura
	RESULTADO=$1
	if [ ! "$lectura" == "" ]; then
		RESULTADO=$lectura
		./Grabar_L.sh "Instalar_TP" "Informativo" "Usuario ha redefinido: "$3". Con el valor: "$RESULTADO
	fi
}

#verifica el espacio en disco y de no ser suficiente pregunta al usuario
#si desea redefinirlo, hacer espacio en disco y volver a chequear, o abortar
#la instalacion
function verificarEspacio(){
	chequearEspacioARRIDIR

	if [ "$HAY_ESPACIO" == "NO" ]; then
		entradaSiNo "Desea redefinir el valor de Espacio minimo?"
		if [ "${RTA^^}" == "SI" ]; then
			./Grabar_L.sh "Instalar_TP" "Informativo" "Usuario ha decidido redefinir el valor de Espacio minimo."
			datasize
		else
			./Grabar_L.sh "Instalar_TP" "Informativo" "El Usuario ha decidido no redefinir el Espacio mínimo"
			entradaSiNo "Desea abortar la instalacion?"
			if [ "${RTA^^}" == "SI" ]; then
				finalizarInstalacion "El usuario ha abortado la instalacion." "ERROR"
			else
				msj="Se debe liberar espacio en el disco. Se solicita nueva verificacion de espacio."
				./Grabar_L.sh "Instalar_TP" "Informativo" "$msj"
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
	verificarEspacio
}

function datasize(){
	definirDatasize
	verificarEspacio
}

function definirParametros(){
	#Definicion de los directorios
	definirBINDIR
	definirMAEDIR
	definirARRIDIR

	datasize
	
	definirACEPDIR
	definirRECHDIR
	definirREPODIR
	definirPROCDIR
	definirLOGDIR
	
	definirExtensionArchivos
	
	definirLOGSIZE
}

function listarArchivos(){
	echo "Archivos:"
	./Grabar_L.sh "Instalar_TP" "Informativo" "Archivos:"
	if [ $1 -eq 1 ]; then
		msj=`ls $2`
		echo $msj
		./Grabar_L.sh "Instalar_TP" "Informativo" "$msj"
	fi
}

function imprimirSusRespuestas(){
	clear #Limpio la pantalla
	
	version="TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright © Grupo 02"
	echo $version
	./Grabar_L.sh "Instalar_TP" "Informativo" "$version"
	
	libreria="Librería del Sistema: "$CONFDIR
	echo $libreria
	./Grabar_L.sh "Instalar_TP" "Informativo" "$libreria"
	listarArchivos $1 $CONFDIR
	
	ejec="Ejecutables: "$BINDIR
	echo $ejec
	./Grabar_L.sh "Instalar_TP" "Informativo" "$ejec"
	listarArchivos $1 $BINDIR
	
	maestr="Archivos maestros: "$MAEDIR
	echo $maestr
	./Grabar_L.sh "Instalar_TP" "Informativo" "$maestr"
	listarArchivos $1 $MAEDIR
	
	extern="Directorio de arribo de archivos externos: "$ARRIDIR
	echo $extern
	./Grabar_L.sh "Instalar_TP" "Informativo" "$extern"
	
	tam="Espacio mínimo libre para arribos: "$DATASIZE" Mb"
	echo $tam
	./Grabar_L.sh "Instalar_TP" "Informativo" "$tam"
	
	aceptado="Archivos externos aceptados: "$ACEPDIR
	echo $aceptado
	./Grabar_L.sh "Instalar_TP" "Informativo" "$aceptado"
	
	rechazado="Archivos externos rechazados: "$RECHDIR
	echo $rechazado
	./Grabar_L.sh "Instalar_TP" "Informativo" "$rechazado"
	
	reporte="Reportes de salida: "$REPODIR
	echo $reporte
	
	proc="Archivos procesados: "$PROCDIR
	echo $proc
	./Grabar_L.sh "Instalar_TP" "Informativo" "$proc"
	
	logs="Logs de auditoria del Sistema: "$LOGDIR"/<comando>."$LOGEXT
	echo $logs
	./Grabar_L.sh "Instalar_TP" "Informativo" "$logs"
	
	tamMax="Tamaño máximo para los archivos de log del sistema: "$LOGSIZE" Kb"
	echo $tamMax
	./Grabar_L.sh "Instalar_TP" "Informativo" "$tamMax"
	
	#??? Lista es un estado o hay que mantenerlo ???
	estado="Estado de la instalacion: LISTA"
	echo $estado
	./Grabar_L.sh "Instalar_TP" "Informativo" "$estado"
	
}

#Pregunta al usuario si acepta las condiciones de instalacion
#Si no las acepta Aborta la instalacion
function verificarCondicionesDeInstalacion(){
	./Grabar_L.sh "Instalar_TP" "Informativo" "Inicio de Instalación completa"
	echo "TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright © Grupo 02"
	echo "A T E N C I O N: Al instalar TP SO7508 Segundo Cuatrimestre 2013 Ud. expresa aceptar los términos y Condiciones del 'ACUERDO DE LICENCIA DESOFTWARE' incluido en este paquete."	
	entradaSiNo "Acepta las condiciones?"
	
	if [ "${RTA^^}" == "NO" ]; then
		finalizarInstalacion "El Usuario NO Aceptó los terminos y Condiciones de Instalacion. INSTALACION ABORTADA" "ERROR"
	fi	
}

#Pregunta al usuario si esta seguro de querer instalar el programa
function confirmarInstalacion(){
	./Grabar_L.sh "Instalar_TP" "Informativo" "Iniciando instalacion. Se pide confirmacion al usuario."
	entradaSiNo "Iniciando Instalacion. Esta ud. seguro que desea continuar?"

	if [ "${RTA^^}" == "NO" ]; then
		finalizarInstalacion "Instalacion rechazada por el usuario" "ERROR"
	fi	
}

#Permite al usuario definir los parametros, luego los muestra
#y pregunta si son correctos. Si el usuario indica que no, vuelve a
#redefinirlos
function definirParametrosPorUsuario(){
	RTA="NO"
	while [ "${RTA^^}" == "NO" ]; do
		definirParametros
		imprimirSusRespuestas 0
		entradaSiNo "Es correcta la configuracion?"
		if [ "${RTA^^}" == "NO" ]; then
			./Grabar_L.sh "Instalar_TP" "Informativo" "Configuracion rechazada por el usuario"
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

#???
function moverArchivos(){
# 	1 : origen				(ej: /origen/archivo.txt)
#	2 : destino				(ej: /destino)
#	3 : comando que invoca	(optativo)
	#./Mover_B.sh 
	echo "Falta Implementar moverArchivos"
}

#A partir del archivo de configuraciones, obtiene el valor del
#registro correspondiente
#parametro 1: registro buscado
function obtenerValorExistente(){
	re="^$1"
	linea_original=`grep "$re" < $ARCHCONF`
	ind=`expr index "$linea_original" '='`
	linea_aux=${linea_original:$ind}
	ind2=`expr index "$linea_aux" '='`
	VALOR_EN_ARCH=${linea_aux:0:$ind2-1}
}

#Escribe la linea del registro actualizado en el archivo temporal
#Si el registro no cambio, escribe la linea original
#Parametro 1: nombre del registro 
#Parametro 2: variable
function actualizarRegistroExistente(){
	obtenerValorExistente $1
	if ! [ $VALOR_EN_ARCH == $2 ]; then
		echo $1"="$2"="$(whoami)"="`date` >> $CONFTEMP
		mensaje="El valor de "$1" fue actualizado a: "$2
		./Grabar_L.sh "Instalar_TP" "Informativo" "$mensaje"
		if [ $3 -eq 1 ]; then
			crearDirectorio $2
		fi
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
	
	actualizarRegistroExistente "GRUPO" $GRUPO 1
	actualizarRegistroExistente "CONFDIR" $CONFDIR 1
	actualizarRegistroExistente "BINDIR" $BINDIR 1
	actualizarRegistroExistente "MAEDIR" $MAEDIR 1
	actualizarRegistroExistente "ARRIDIR" $ARRIDIR 1
	actualizarRegistroExistente "ACEPDIR" $ACEPDIR 1
	actualizarRegistroExistente "RECHDIR" $RECHDIR 1
	actualizarRegistroExistente "REPODIR" $REPODIR 1
	actualizarRegistroExistente "PROCDIR" $PROCDIR 1
	actualizarRegistroExistente "LOGDIR" $LOGDIR 1
	actualizarRegistroExistente "LOGEXT" $LOGEXT 0
	actualizarRegistroExistente "LOGSIZE" $LOGSIZE 0
	actualizarRegistroExistente "DATASIZE" $DATASIZE 0
	
	#elimina la configuracion anterior
	mv $CONFTEMP $ARCHCONF
}

#Escribe un registro en ARCHCONF
function escribirRegistro(){
	echo $1"="$2"="$(whoami)"="`date` >> $ARCHCONF
}

#Crea el archivo de configuracion y guarda todos los registros
#Separacion de registros "="
function actualizarConfiguracionCompleto(){
	
	echo "Actualizando la configuración del sistema"
	./Grabar_L.sh "Instalar_TP" "Informativo" "Se almacenan todos los registros en el archivo de configuración."
	
	> $ARCHCONF #Crea el archivo vacio

	escribirRegistro "GRUPO" $GRUPO
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
	
	verificarCondicionesDeInstalacion
	
	chequeoPerl
	
	setearParametrosDefault
	
	definirParametrosPorUsuario

	confirmarInstalacion
	
	crearDirectorios
	
	moverArchivos
	
	actualizarConfiguracionCompleto
	
	finalizarInstalacion "Instalacion: CONCLUIDA" "OK"
}

#???
function verificarInstalacion(){
	setearParametrosDefault
	actualizarConfiguracionExistente
	echo "Falta Implementar verificarInstalacion"
}


#setea la variable de configuracion
CONFDIR=grupo02/conf/
export CONFDIR
GRUPO=grupo02
DIR_ACTUAL=$PWD

crearDirectorio $GRUPO"/conf/"

./Grabar_L.sh "Instalar_TP" "Informativo" "Inicio de Instalación"
./Grabar_L.sh "Instalar_TP" "Informativo" "Log del Comando Instalar_TP: "$CONFDIR"Instalar_TP.log"
./Grabar_L.sh "Instalar_TP" "Informativo" "Directorio de Configuración: "$CONFDIR

ARCHCONF=$CONFDIR"Instalar_TP.conf"
export ARCHCONF

if [ -f $ARCHCONF ]; then
	verificarInstalacion
else
	instalar
fi
