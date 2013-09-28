#!/bin/bash            
#
# Nombre: Mover_B
#
# Funcion para mover de archivos
# 

# TODO: se podria hacer que devuelva distintos codigos de error para
# identificarlos. Por ahora devuelve siempre 1 en caso de algun error.

# Verifica si existe el archivo a mover. En caso de no existir, 
# no se mueve nada y se devuelve 1.
# Trabaja con variables de entorno.
function existeOrigen {
	if [ ! -f "$RUTA_ORIGEN" ] && [ ! -d "$RUTA_ORIGEN" ]; then
		# archivo origen no existe / directorio no existe
		echo "No existe el archivo origen!" #DEBUG
		exit 1
	fi
}

# Verifica si existe el destino a donde mover. En caso de no existir, 
# no se mueve nada y se devuelve 1.
# Trabaja con variables de entorno.
function existeDestino {
	if [ ! -d "$RUTA_DESTINO" ]; then
		# ruta destino no existe
		echo "No existe el destino!" #DEBUG
		exit 1
	fi
}

# Verifica si existe el destino es el mismo que el origen.
# En ese caso no se mueve nada y se devuelve 1.
# Trabaja con variables de entorno.
function destinoEsOrigen {
	if [ "$RUTA_DESTINO" == `dirname "$RUTA_ORIGEN"` ]; then
		# se quiere mover al mismo lugar
		echo "Mismo destino que origen!" #DEBUG
		exit 1
	fi
}

# Verifica si ya existe un archivo en el destino con el mismo nombre
# que el archivo de origen. En ese caso crea una carpeta dup (si no existe)
# y mueve el archivo a esa ruta, cambiandole el nombre agregando un
# numero de referencia.
# Trabaja con variables de entorno.
function verificarDuplicado {
	# Reviso si el archivo ya se encontraba en el destino (duplicado):
	DUPLICADO="FALSE"
	for ARCHIVO in `find "$RUTA_DESTINO" -maxdepth 1` ; do
		if [ $ARCHIVO == "$RUTA_DESTINO/$ARCHIVO_ORIGEN" ] ; then
			DUPLICADO="TRUE"
			echo "Archivo duplicado!" #DEBUG
			break
		fi
	done
	
	# Si no estaba duplicado salimos y dejamos todo como estaba:
	if [ $DUPLICADO == "FALSE" ] ; then
		return 0
	fi
	
	# Como estaba duplicado, vemos si existe el directorio "/dup" en el destino:
	DIRECTORIO=`find "$RUTA_DESTINO" -maxdepth 1 -type d -name 'dup'`
	DUP="FALSE"
	NUM=1
	if [ "$DIRECTORIO" == "$RUTA_DESTINO/dup" ] ; then
		DUP="TRUE"
		echo "/dup encontrado!" #DEBUG
		# Aumentamos el contador:
		for DUPLICADO in `find "$RUTA_DESTINO/dup" -maxdepth 1 -name "$ARCHIVO_ORIGEN.*"` ; do
			let NUM=$NUM+1
		done
		ARCHIVO_DESTINO="$ARCHIVO_ORIGEN.$NUM" # Renombramos el archivo
	fi
	
	# Si la carpeta dup no existe, es el primer duplicado:
	if [ $DUP == "FALSE" ] ; then
		mkdir "$RUTA_DESTINO/dup"
		ARCHIVO_DESTINO="$ARCHIVO_ORIGEN.1"
	fi
	RUTA_DESTINO="$RUTA_DESTINO/dup"
	echo "Se va a mover el archivo a $RUTA_DESTINO como $ARCHIVO_DESTINO" #DEBUG
}

# Funcion principal del script.
#
# Parametros:
# 	1 : origen				(ej: /origen/archivo.txt)
#	2 : destino				(ej: /destino)
#	3 : comando que invoca	(optativo)
#
# Devuelve:
#	0 : si movio el archivo
#	1 : en caso de error

RUTA_ORIGEN=$1
RUTA_DESTINO=$2
COMANDO=$3

ARCHIVO_ORIGEN=`basename $RUTA_ORIGEN`	# Obtengo nombre del archivo
ARCHIVO_DESTINO=$ARCHIVO_ORIGEN			# El nombre en el destino (puede llegar a cambiar)

# DEBUG:
echo "Voy a mover el archivo $RUTA_ORIGEN a $RUTA_DESTINO"
	
# Validaciones...
# TODO: Validar que se hayan pasado los parametros!
existeOrigen
existeDestino
destinoEsOrigen
verificarDuplicado # va a modificar RUTA_DESTINO y el ARCHIVO_DESTINO (en caso de ser necesario)

# Movemos...
mv "$RUTA_ORIGEN" "$RUTA_DESTINO/$ARCHIVO_DESTINO"
echo "TODO BIEN!" #DEBUG
exit 0
