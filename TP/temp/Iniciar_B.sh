#!/bin/bash

# archivo de configuracion, es una ruta fija segun el enunciado
CONF="../conf/.conf" # TODO: revisar este path

function verificarInstalacion {
	#TODO
	return 0
}

# Verifica que las variables de ambiente esten vacias.
# Si no lo estan, el ambiente ya habia sido inicializado.
# 
# Devuelve:
# 	0 : si el ambiente esta limpio
#	1 : si el ambiente ya habia sido inicializado
function verificarAmbiente {
#	if [ "$PATH" != "" ] ; then
#		return 1
#	fi
	if [ "$GRUPO" != "" ] ; then
		return 1
	fi
	if [ "$CONFDIR" != "" ] ; then
		return 1
	fi
	if [ "$ARRIDIR" != "" ] ; then
		return 1
	fi
	if [ "$RECHDIR" != "" ] ; then
		return 1
	fi
	if [ "$BINDIR" != "" ] ; then
		return 1
	fi
	if [ "$MAEDIR" != "" ] ; then
		return 1
	fi
	if [ "$REPODIR" != "" ] ; then
		return 1
	fi
	if [ "$LOGDIR" != "" ] ; then
		return 1
	fi
	if [ "$LOGEXT" != "" ] ; then
		return 1
	fi
	if [ "$LOGSIZE" != "" ] ; then
		return 1
	fi
	return 0
}


# Setea las variables de entorno segun el archivo de configuracion.
# Devuelve 1 en caso de error, 0 si todo salio bien.
function setearVariables {
	# Si existe el archivo de configuracion...
	if [ -f $CONF ] ; then
		# formato por linea: VARIABLE=VALOR=FECHA
		# TODO: CREO que por ejemplo CONFDIR vale $GRUPO/conf, o sea, incluye el path de grupo
		export GRUPO=`grep "^GRUPO=" $CONF | sed "s/^GRUPO=\([^=]*\)=.*$/\1/"`
		export CONFDIR=`grep "^CONFDIR=" $CONF | sed "s/^CONFDIR=\([^=]*\)=.*$/\1/"`
		export ARRIDIR=`grep "^ARRIDIR=" $CONF | sed "s/^ARRIDIR=\([^=]*\)=.*$/\1/"`
		export RECHDIR=`grep "^RECHDIR=" $CONF | sed "s/^RECHDIR=\([^=]*\)=.*$/\1/"`
		export BINDIR=`grep "^BINDIR=" $CONF | sed "s/^BINDIR=\([^=]*\)=.*$/\1/"`
		export MAEDIR=`grep "^MAEDIR=" $CONF | sed "s/^MAEDIR=\([^=]*\)=.*$/\1/"`
		export REPODIR=`grep "^REPODIR=" $CONF | sed "s/^REPODIR=\([^=]*\)=.*$/\1/"`
		export LOGDIR=`grep "^LOGDIR=" $CONF | sed "s/^LOGDIR=\([^=]*\)=.*$/\1/"`
		export LOGEXT=`grep "^LOGEXT=" $CONF | sed "s/^LOGEXT=\([^=]*\)=.*$/\1/"`
		export LOGSIZE=`grep "^LOGSIZE=" $CONF | sed "s/^LOGSIZE=\([^=]*\)=.*$/\1/"`	
		#Ver si falta alguno mas
	else
		return 1
	fi
	
	#export PATH=$PATH:$GRUPO:$BINDIR"/":$REPODIR"/"   #TODO: no se muy bien como se pone el PATH
	return 0
}


# Otorga permisos de ejecucion a los archivos ejecutables
function otorgarPermisos {
	# TODO: ver donde se encontraria Recibir_B.sh respecto de Iniciar_B.sh. Si estan en mismo directorio, es así:
	# chmod +x Recibir_B.sh
	return 0
}

# Verifica si ya se esta ejecutando Recibir_B.sh
# Devuelve 0 si no se esta ejecutado, el PID si se estaba ejecutando.
function ejecutandoRecibirB(){
	PIDRECIBIRB=`ps | grep "Recibir_B.sh" | head -1 | awk '{print $1 }'`   
	if [ "$PIDRECIBIRB" != "" ]; then
		return 1
	fi
	return 0
}

function explicarStop {
	#TODO: Aca iria la explicacion de como funciona el STOP_D
	echo "explicacion stop"
}

function explicarStart {
	#TODO: Aca iria la explicacion de como funciona el START_D
	echo "explicacion start"
}

function imprimirInformacion {
	echo "TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright © Grupo 02"
	echo "Librería del Sistema:                      $CONFDIR."
	#ls $CONFDIR/
	echo "Ejecutables:                               $BINDIR."
	#ls $BINDIR/
	echo "Archivos maestros:                         $MAEDIR"
	#ls $MAEDIR/
	echo "Directorio de arribo de archivos externos: $ARRIDIR"
	echo "Archivos externos aceptados:               $ACEPDIR"
	echo "Archivos externos rechazados:              $RECHDIR"
	echo "Reportes de salida:                        $REPODIR"
	echo "Archivos procesados:                       $PROCDIR"
	echo "Logs de auditoria del Sistema:             $LOGDIR/Iniciar_B.$LOGEXT"
	echo "Estado del Sistema:                        INICIALIZADO" # TODO: esto sería una variable?
	echo "Demonio corriendo bajo el no.:             $PIDRECIBIRB"
}

function solicitarInicioRecibir {
	echo -n "Desea efectuar la activación de Recibir_B?” Si – No "
	RESPUESTA=""
	while [ "$RESPUESTA" != "Si" -a "$RESPUESTA" != "No" ] ; do
		read RESPUESTA
	done
	
	if [ "$RESPUESTA" == "Si" ] ; then
		return 0
	fi
	if [ "$RESPUESTA" == "No" ] ; then
		return 1
	fi
	
	return 1
}


# MAIN


#Inicializamos el log del comando Iniciar_B
./Grabar_L.sh "Iniciar_B" "Informativo" "Inicio de Ejecución"

# Verificamos que la instalacion este completa
verificarInstalacion
if [ $? -eq 1 ] ; then
	echo "No se puede iniciar debido a una instalación incompleta o inexistente."
	echo "Por favor instale el paquete mediante el comando Instalar_TP."
	./Grabar_L.sh "Iniciar_B" "SEVERAL ERROR" "La instalacion no se ha completado"
	#./Grabar_L.sh "Iniciar_B" "Informativo" "Componentes faltantes: " #TODO listar lo que falte
	exit 1
else
	# TODO: grabar en log que la instalacion estaba bien
fi

# Veo si ya había sido inicializado el ambiente
verificarAmbiente
if [ $? -eq 1 ] ; then
	echo "Ambiente ya inicializado. Si desea reiniciar, termine su sesión e ingrese nuevamente."
	#./Grabar_L.sh "Iniciar_B" "Error" "Intento de iniciar entorno ya inicializado"
	#./Grabar_L.sh "Iniciar_B" "Informativo" "Estado de las variables de entorno: GRUPO=$GRUPO, ARRIDIR=$ARRIDIR, RECHDIR=$RECHDIR, BINDIR=$BINDIR, MAEDIR=$MAEDIR, REPODIR=$REPODIR, LOGDIR=$LOGDIR, LOGEXT=$LOGEXT, LOGSIZE=$LOGSIZE"
	exit 1 
else
	# TODO: grabar en log que el ambiente estaba bien
fi

setearVariables
# TODO: grabar en log que se setearon las variables, y en que estado

otorgarPermisos # A Recibir_B.sh
# TODO: grabar en log que se otorgaron permisos

solicitarInicioRecibir
if [ $? -eq 0 ] ; then
	ejecutandoRecibirB
	if [ $?  -eq 0 ] ; then
		# comenzar el RECIBIR_B!!!
		PIDRECIBIRB=`ps | grep "Recibir_B.sh" | head -1 | awk '{print $1 }'`
		# TODO: grabar en log que se inicio el recibir_b
	else
		echo "El proceso Recibir_B ya estaba siendo ejecutando anteriormente bajo el PID:$PIDRECIBIRB?"
		# TODO: grabar en log que el recibir_b ya estaba
	fi
	explicarStop
else
	explicarStart
	# TODO: grabar en log que el usuario no quiso iniciarlo
fi

imprimirInformacion

#TODO: cerrar archivo de log...

exit 0
