#!/bin/bash            
#
# Devuelve el tamaño disponible
#

function obtenerEspacio(){		
	#obtengo la linea donde se encuentran los datos (ultima linea del archivo)
	linea=`tail -1 espacio.auxESPACIO`
	
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
}

DIRECCION=$1
if ! [ -d $DIRECCION/ ]; then
	DIRECCION=grupo02/conf 
fi

#obtener espacio que le queda en Kb
df $DIRECCION > espacio.auxESPACIO

obtenerEspacio

rm *.auxESPACIO 
echo $TAM
