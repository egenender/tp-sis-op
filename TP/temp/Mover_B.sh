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
		echo "No existe el archivo origen!"
		exit 1
	fi
}

# Verifica si existe el destino a donde mover. En caso de no existir, 
# no se mueve nada y se devuelve 1.
# Trabaja con variables de entorno.
function existeDestino {
	if [ ! -d "$RUTA_DESTINO" ]; then
		# ruta destino no existe
		echo "No existe el destino!"
		exit 1
	fi
}

# Verifica si existe el destino es el mismo que el origen.
# En ese caso no se mueve nada y se devuelve 1.
# Trabaja con variables de entorno.
function destinoEsOrigen {
	if [ "$RUTA_DESTINO" == `dirname "$RUTA_ORIGEN"` ]; then
		# se quiere mover al mismo lugar
		echo "Mismo destino que origen!"
		exit 1
	fi
}

# Verifica si ya existe un archivo en el destino con el mismo nombre
# que el archivo de origen. En ese caso la variable de entorno DUPLICADO
# se setea en "TRUE", sino queda en "FALSE".
# Trabaja con variables de entorno.
function esDuplicado {
	DUPLICADO="FALSE"
	#TODO
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
esDuplicado
#if [ $DUPLICADO == "TRUE" ]; then
#	generarDuplicado  # va a modificar RUTA_DESTINO y el ARCHIVO_DESTINO
#	echo "El archivo estaba dupĺicado!"
#fi

# Movemos...
mv "$RUTA_ORIGEN" "$RUTA_DESTINO/$ARCHIVO_DESTINO"
echo "TODO BIEN!"
exit 0
