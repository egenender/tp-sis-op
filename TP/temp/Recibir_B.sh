#!/bin/bash

#~ Se dispara automáticamente o a través del Start_D
#~ Se detiene a través del Stop_D

# VARIABLES DE ENTORNO QUE DEBEN ESTAR SETEADAS POR Iniciar_B (Sacar cuando esto ya este)
MAEDIR="MAESTROS"
ARRIDIR="ARRIBOS"
ACEPDIR="ACEPTADOS"
RECHDIR="RECHAZADOS"
REPODIR="INVITADOS"
BINDIR='.'
LANG="_ES.UTF-8"



function esDeSala(){

	#~ ID de la SALA-CORREO-xxx
	#~ El id de la SALA siempre es un número par
	#~ Luego del guión viene el correo electrónico del teatro. La combinación Id de la Sala-correo debe existir en el archivo de SALAS
	#~ Y finalmente xxx que representa una cadena caracteres sin guiones ni espacios. 
	
	filename=$(basename "$1")
	
	if [ `echo "$filename" | grep "[0-9]\+\-[^-]+@[^-]+\-[^- ]*$" | wc -l` == 1 ]
	then

		SALA=`echo "$filename"|cut -d- -f 1`

		if [ `expr $SALA % 2` == 0 ]
		then 
			
			CORREO=`echo "$filename"|cut -d- -f 2`
			
			if [ `grep "^$SALA;[^;]*;[^;]*;[^;]*;[^;]*;$CORREO" $MAEDIR/salas.mae | wc -l` -ge 1 ]
			then
				echo "1"
			else
				
				$BINDIR/Grabar_L.sh "Recibir_B" "$f: no existe combinacion $SALA $CORREO en salas.mae"
			
				echo "0"
			fi
		else
			echo "0"	
		fi
	else
		echo "0"
	fi

}

function esDeProduccion(){

	#~ ID de la OBRA-CORREO-xxx
	#~ El id de la OBRA siempre es un número impar
	#~ Luego del guión viene el correo electrónico de la producción general o de la producción ejecutiva. 
	#~ La combinación Id de la OBRA-correo debe existir en el archivo de OBRAS
	#~ Y finalmente xxx que es cualquier combinación de caracteres sin guiones ni espacios. 

		
	filename=$(basename "$1")
	
	if [ `echo "$filename" | grep "[0-9]\+\-[^-]+@[^-]+\-[^- ]*$" | wc -l` == 1 ]
	then

		OBRA=`echo "$filename"|cut -d- -f 1`

		if [ `expr $OBRA % 2` != 0 ]
		then 
			
			CORREO=`echo "$filename"|cut -d- -f 2`
			if [ `grep "^$OBRA;[^;]*;$CORREO;[^;]*" $MAEDIR/obras.mae | wc -l` -ge 1 ] || [ `grep "^$OBRA;[^;]*;[^;]*;$CORREO" $MAEDIR/obras.mae | wc -l` -ge 1 ]
			then
				echo "1"
			else
				
				$BINDIR/Grabar_L.sh "Recibir_B" "$f: no existe combinacion $OBRA $CORREO en obras.mae"
				
				echo "0"
			fi
		else
			echo "0"
		fi
	else
		echo "0"
	fi

	
	
}

function esDeReservas(){
	
	ESDEPRODUCCION=$(esDeProduccion $1)
	ESDESALA=$(esDeSala $1)
	
	if [ $ESDEPRODUCCION != 1 -a $ESDESALA != 1 ]
	then
		echo "0"
	else
		echo "1"
	fi
	
}

function esDeInvitados(){
	
	#~ Validación del nombre de los archivos de invitados:
	#~ El nombre de los archivos de invitados tienen el siguiente formato: Referencia Interna del Solicitante.inv
	#~ La referencia Interna del solicitante es cualquier combinación de caracteres sin guiones ni espacios
	#~ Luego de la referencia debe seguir obligatoriamente “.inv” de lo contrario el archivo no será identificado como archivo de invitados

	filename=$(basename "$1")
	
	if [ `echo "$filename" | grep "[^- ]*\.inv$" | wc -l` != 1 ]
	then
		echo "0"
	else
		echo "1"
	fi

	
}


CICLOS_RECIBIR_B=0
#~ demonio
while [ 1 ]
do
	#~ 1. Grabar en el Log el nro de ciclo: Ej: “Ciclo Nro 1”. Indicar en las hipótesis como realizan la contabilidad del ciclo.
	CICLOS_RECIBIR_B=`expr $CICLOS_RECIBIR_B + 1`
	
	#~ Probar cuando este implementado
	$BINDIR/Grabar_L.sh "Recibir_B" "Ciclo Nro $CICLOS_RECIBIR_B"

	#~ echo "Recibir_B Ciclo Nro $CICLOS_RECIBIR_B"
	
	#~ 2. Chequear si hay archivos en el directorio $ARRIDIR. 
	NUMARCHIVOS=`ls $ARRIDIR | wc -l`
	
	if [ $NUMARCHIVOS != 0 ]
	then
	
		#~ Si existen archivos, por cada archivo que se detecta
		for f in $ARRIDIR/*
		do
			#~ 2.1. Verificar que el archivo sea un archivo común, de texto. Los archivos de cualquier otro tipo, se rechazan. 
			ISTEXTFILE=`file $f | grep "text"| wc -l`
			if [ $ISTEXTFILE != 0 ]
			then
				#~ 2.2. Verificar que el formato del nombre del archivo sea correcto, los archivos con nombres que no se correspondan con el formato esperado, se rechazan.
				#~ 2.3. Si es de reservas mover el archivo aceptado a $ACEPDIR empleando la función  Mover_B y grabar en el log el mensaje de éxito
				ESDERESERVAS=`esDeReservas $f`
				if [ "$ESDERESERVAS" == 1 ]
				then

					$BINDIR/Mover_B.sh $f $ACEPDIR "Recibir_B"

					$BINDIR/Grabar_L.sh "Recibir_B" "Exito al procesar el archivo  de reservas $f"

				fi
				ESDEINVITADOS=`esDeInvitados $f`
				#~ 2.4. Si es de invitados mover el archivo aceptado a $REPODIR empleando la función  Mover_B y grabar en el log el mensaje de éxito
				if [ "$ESDEINVITADOS" == 1 ]
				then
					
					$BINDIR/Mover_B.sh $f $REPODIR "Recibir_B"
					
					$BINDIR/Grabar_L.sh "Recibir_B" "Exito al procesar el archivo  de invitados $f"
				
				fi
				
				#~ 2.5. Si el nombre del archivo no es válido mover el archivo rechazado a $RECHDIR empleando la función Mover_B, grabar en el log el mensaje de rechazo aclarando cual es el motivo:
				if [ "$ESDERESERVAS" != 1 -a "$ESDEINVITADOS" != 1 ]
				then
				
					$BINDIR/Mover_B.sh $f $RECHDIR "Recibir_B"
					
					$BINDIR/Grabar_L.sh "Recibir_B" "$f: archivo no es ni de reservas ni de invitados"

				fi
				
			else

				$BINDIR/Mover_B.sh $f $RECHDIR "Recibir_B"
					
				$BINDIR/Grabar_L.sh "Recibir_B" "$f: tipo de archivo invalido "
			
			fi
	
		
		done
		
		#~ 3. Una vez que se hayan procesado todos los archivos que existen en $ARRIDIR se debe chequear la existencia de archivos en el directorio $ACEPDIR (ya sean del ciclo actual o de ciclos anteriores). 
		#~ 4. Si existen archivos en $ACEPDIR
		NUMARCHIVOS=`ls $ACEPDIR | wc -l`
		
		if [ $NUMARCHIVOS != 0 ]
		then
			#~ 4.1. Invocar al Comando Reservar_B siempre que éste no se esté ejecutando.
			
			PIDRESERVAR=`ps | grep "Reservar_B.sh" | head -1 | awk '{print $1 }'`
			
			if [ -z "$PIDRESERVAR" ]
			then
			#~ No se esta ejecutando, lo ejecuto
				#~ Si arranca correctamente se debe mostrar por pantalla el process id de Reservar_B
				#~ Si da algún tipo de error se debe mostrar por pantalla el mensaje explicativo
				
				$BINDIR/Reservar_B.sh &
				
				if [ $? -ne 0 ]; then
					echo "Error al ejecutar Reservar_B.sh "
				else
					
					echo "Reservar_B.sh se ejecuto exitosamente con pid $!"

				fi


				
			fi
			

		fi
		
	fi
	
	#~ 5. Dormir x minutos y Volver al punto 1
	sleep 1m
	

done


