#!/bin/bash

# archivo de configuracion, es una ruta fija segun el enunciado
CONF="../conf/Instalar_TP.conf" # TODO: revisar este path.
#TODO: yo asumo que estoy en    foo/bin/Iniciar_B.sh y el la conf en   foo/conf/Instalar_TP.conf

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
#	if [ "$PATH" != "" ] ; then  # TODO: PATH siempre estaria inicializado en... algo (?)
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
		export LANG="_ES.UTF-8"
		#TODO: Ver si falta alguno mas
	else
		return 1
	fi
	
	#export PATH=$PATH:$GRUPO:$BINDIR"/":$REPODIR"/"   #TODO: no se muy bien como se pone el PATH
	return 0
}


# Otorga permisos de ejecucion a los archivos ejecutables
function otorgarPermisos {
	# TODO: asumo que Recibir_B.sh y Iniciar_B.sh estan en el mismo nivel:
	chmod +x Recibir_B.sh
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
./Grabar_L.sh "Iniciar_B" "Informativo" "Verificando la instalacion del paquete"
if [ $? -eq 1 ] ; then
	echo "No se puede iniciar debido a una instalación incompleta o inexistente."
	echo "Por favor instale el paquete mediante el comando Instalar_TP."
	./Grabar_L.sh "Iniciar_B" "SEVERAL ERROR" "La instalacion no se ha completado"
	./Grabar_L.sh "Iniciar_B" "SEVERAL ERROR" "Componentes faltantes: ..................." #TODO listar lo que falte
	./Grabar_L.sh "Iniciar_B" "Informativo" "Fin de Ejecución"
	exit 1
else
	./Grabar_L.sh "Iniciar_B" "Informativo" "Se encuentra todo instalado."
fi

# Veo si ya había sido inicializado el ambiente
verificarAmbiente
if [ $? -eq 1 ] ; then
	echo "Ambiente ya inicializado. Si desea reiniciar, termine su sesión e ingrese nuevamente."
	./Grabar_L.sh "Iniciar_B" "Error" "Intento de inicializar ambiente ya inicializado"
	./Grabar_L.sh "Iniciar_B" "Error" "Estado del ambiente: GRUPO=$GRUPO, ARRIDIR=$ARRIDIR, RECHDIR=$RECHDIR, BINDIR=$BINDIR, MAEDIR=$MAEDIR, REPODIR=$REPODIR, LOGDIR=$LOGDIR, LOGEXT=$LOGEXT, LOGSIZE=$LOGSIZE"
	./Grabar_L.sh "Iniciar_B" "Informativo" "Fin de Ejecución"
	exit 1 
else
	./Grabar_L.sh "Iniciar_B" "Informativo" "El ambiente se encuentra limpio"
fi

setearVariables
# TODO: grabar en log que se setearon las variables, y en que estado
./Grabar_L.sh "Iniciar_B" "Informativo" "Se setearon las variables de entorno."
./Grabar_L.sh "Iniciar_B" "Informativo" "Estado del ambiente: GRUPO=$GRUPO, ARRIDIR=$ARRIDIR, RECHDIR=$RECHDIR, BINDIR=$BINDIR, MAEDIR=$MAEDIR, REPODIR=$REPODIR, LOGDIR=$LOGDIR, LOGEXT=$LOGEXT, LOGSIZE=$LOGSIZE"

otorgarPermisos # A Recibir_B.sh
./Grabar_L.sh "Iniciar_B" "Informativo" "Se otorgaron permisos a Recibir_B.sh"

solicitarInicioRecibir
# Si solicito iniciar Recibir_B:
if [ $? -eq 0 ] ; then
	# Veo si ya habia uno ejecutando
	ejecutandoRecibirB
	# Si no se esta ejecutando...
	if [ $?  -eq 0 ] ; then
		# Lo iniciamos:
		./Grabar_L.sh "Iniciar_B" "Informativo" "El usuario dicidio ejecutar Recibir_B.sh"
		./Start_D.sh # comenzar el Recibir_B.sh como demonio
		PIDRECIBIRB=`ps | grep "Recibir_B.sh" | head -1 | awk '{print $1 }'`
		
		# Si por alguna razon no se pudo iniciar el demonio...
		if [ "$PIDRECIBIRB" == ""] ; then
			./Grabar_L.sh "Iniciar_B" "Error" "Por alguna razon no se pudo correr el demonio para Recibir_B.sh"
			echo "No se pudo ejecutar el demonio Recibir_B"
			
		# Si lo iniciamos exitosamente...
		else
			./Grabar_L.sh "Iniciar_B" "Informativo" "El proceso Recibir_B.sh se inicio. PID: $PIDRECIBIRB"
			echo "Se inicio el demonio Recibir_B"
		fi
		
	# Si el demonio ya existia...
	else
		echo "El proceso Recibir_B ya estaba siendo ejecutando anteriormente bajo el PID:$PIDRECIBIRB?"
		./Grabar_L.sh "Iniciar_B" "Warning" "El proceso Recibir_B.sh ya estaba siendo ejecutado. PID: $PIDRECIBIRB"
	fi
	
	# Si por alguna razon no se pudo iniciar el demonio...
	if [ "$PIDRECIBIRB" == ""] ; then
		explicarStart
		
	# Si lo pudimos iniciar o estaba iniciado... 
	else
		explicarStop
	fi
	
# Si decididio no iniciar el Recibir_B:
else
	explicarStart
	./Grabar_L.sh "Iniciar_B" "Informativo" "El usuario decidio no ejecutar Recibir_B.sh"
fi

imprimirInformacion

./Grabar_L.sh "Iniciar_B" "Informativo" "Fin de Ejecución"

exit 0
