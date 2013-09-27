#/bin/bash
#~ Se dispara automáticamente o a través del Start_D
#~ Se detiene a través del Stop_D

function esDeSala(){

	#~ ID de la SALA-CORREO-xxx
	#~ El id de la SALA siempre es un número par
	#~ Luego del guión viene el correo electrónico del teatro. La combinación Id de la Sala-correo debe existir en el archivo de SALAS
	#~ Y finalmente xxx que representa una cadena caracteres sin guiones ni espacios. 
	
	filename=$(basename "$1")
	
	#~ CUMPLEFORMATO=`echo $filename | grep ".*[^\-]\-.*[^\-]@.*[^\-]-.*[^\- ]$" | wc -l`
	
	if [$filename =~ "^[0-9]\+\-.*[^\-]@.*[^\-]-.*[^\- ]$"]
	then
		
		#~ sed s/"\(.*[^\-]\)\-.*[^\-]@.*[^\-]-.*[^\- ]$"/"\1"
		SALA=`echo "$filename"|cut -d- -f 1`

		if [`expr $SALA % 2` == 0]
		then 
			
			CORREO=`echo "$filename"|cut -d- -f 2`
			if [`grep "$SALA;.*[^;];.*[^;];.*[^;];.*[^;];$CORREO\$" $MAEDIR/salas.mae | wc -l` >= 1]
			then
				echo "1"
			fi
		fi
	fi
	echo "0"
}

function esDeProduccion(){

	#~ ID de la OBRA-CORREO-xxx
	#~ El id de la OBRA siempre es un número impar
	#~ Luego del guión viene el correo electrónico de la producción general o de la producción ejecutiva. 
	#~ La combinación Id de la OBRA-correo debe existir en el archivo de OBRAS
	#~ Y finalmente xxx que es cualquier combinación de caracteres sin guiones ni espacios. 

		
	filename=$(basename "$1")
	
	#~ CUMPLEFORMATO=`echo $filename | grep ".*[^\-]\-.*[^\-]@.*[^\-]-.*[^\- ]$" | wc -l`
	
	if [$filename =~ "^[0-9]\+\-.*[^\-]@.*[^\-]-.*[^\- ]$"]
	then
		
		#~ sed s/"\(.*[^\-]\)\-.*[^\-]@.*[^\-]-.*[^\- ]$"/"\1"
		OBRA=`echo "$filename"|cut -d- -f 1`

		if [`expr $OBRA % 2` != 0]
		then 
			
			CORREO=`echo "$filename"|cut -d- -f 2`
			if [(`grep "$OBRA;.*[^;];$CORREO;.*[^;]$" $MAEDIR/obras.mae | wc -l` >= 1) -o (`grep "$OBRA;.*[^;];.*[^;];$CORREO\$" $MAEDIR/obras.mae | wc -l` >= 1)]
			then
				echo "1"
			fi
		fi
	fi
	echo "0"
	
	
}

function esDeReservas(){
	
	ESDEPRODUCCION= $(esDeProduccion $1)
	ESDESALA= $(esDeSala $1)
	
	if [$ESDEPRODUCCION != 1 -a $ESDESALA != 1]
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
	if [$filename =~ ".*[^\- ].inv$"]
	then
		echo "1"
	fi
	echo "0"
	
}

#~ 1. Grabar en el Log el nro de ciclo: Ej: “Ciclo Nro 1”. Indicar en las hipótesis como realizan la contabilidad del ciclo.
#~ idea: variable de entorno


CICLOS_RECIBIR_B=0
#~ demonio
while [ 1 ]
do
	CICLOS_RECIBIR_B=`expr $CICLOS_RECIBIR_B + 1`
	
	#~ Probar cuando este implementado
	#~ Grabar_L "Recibir_B" "Ciclo Nro $CICLOS_RECIBIR_B"

	echo "Recibir_B Ciclo Nro $CICLOS_RECIBIR_B"
	
	#~ 2. Chequear si hay archivos en el directorio $ARRIDIR. 
	NUMARCHIVOS=`ls $ARRIDIR | wc -l`
	
	if [$NUMARCHIVOS != 0]
	then
	
		#~ Si existen archivos, por cada archivo que se detecta
		for f in $ARRIDIR/*
		do
			#~ 2.1. Verificar que el archivo sea un archivo común, de texto. Los archivos de cualquier otro tipo, se rechazan. 
			ISTEXTFILE=`file $f | grep "text"| wc -l`
			if [$ISTEXTFILE != 0]
			then
				#~ 2.2. Verificar que el formato del nombre del archivo sea correcto, los archivos con nombres que no se correspondan con el formato esperado, se rechazan.
				#~ 2.3. Si es de reservas mover el archivo aceptado a $ACEPDIR empleando la función  Mover_B y grabar en el log el mensaje de éxito
				ESDERESERVAS=$(esDeReservas $f)
				if [$ESDERESERVAS == 1]
				then
					Mover_B $ARRIDIR $ACEPDIR "Recibir_B"
					
					#~ Probar cuando este implementado
					#~ Grabar_L "Recibir_B" "Exito al procesar el archivo  de reservas $f"
					
					echo "Exito al procesar el archivo de reservas $f"
				fi
				ESDEINVITADOS=$(esDeInvitados $f)
				#~ 2.4. Si es de invitados mover el archivo aceptado a $REPODIR empleando la función  Mover_B y grabar en el log el mensaje de éxito
				if [$ESDEINVITADOS == 1]
				then
					Mover_B $ARRIDIR $REPODIR "Recibir_B"
					
					#~ Probar cuando este implementado
					#~ Grabar_L "Recibir_B" "Exito al procesar el archivo  de invitados $f"
				
					echo "Exito al procesar el archivo de invitados $f"
				fi
				
				#~ 2.5. Si el nombre del archivo no es válido mover el archivo rechazado a $RECHDIR empleando la función Mover_B, grabar en el log el mensaje de rechazo aclarando cual es el motivo:
				if [$ESDERESERVAS != 1 -a $ESDEINVITADOS != 1]
				then
					Mover_B $ACEPDIR $RECHDIR "Recibir_B"
					
					#~ Probar cuando este implementado
					#~ Grabar_L "Recibir_B" "El archivo $f no es valido"
					
					echo "El archivo $f no es valido"
				
				fi
				
				else
					#Rechazar por formato invalido
				
					Mover_B $ACEPDIR $RECHDIR "Recibir_B"
					
					#~ Probar cuando este implementado
					#~ Grabar_L "Recibir_B" "El archivo $f no es valido"
					
					echo "El archivo $f no es valido"
				fi
				
			else
				#Rechazar por Tipo de archivo invalido
				Mover_B $ACEPDIR $RECHDIR "Recibir_B"
					
				#~ Probar cuando este implementado
				#~ Grabar_L "Recibir_B" "El archivo $f no es valido"
				
				echo "El archivo $f no es valido"
			
			fi
	
		
		done
		
		#~ 3. Una vez que se hayan procesado todos los archivos que existen en $ARRIDIR se debe chequear la existencia de archivos en el directorio $ACEPDIR (ya sean del ciclo actual o de ciclos anteriores). 
		#~ 4. Si existen archivos en $ACEPDIR
		NUMARCHIVOS=`ls $ACEPDIR | wc -l`
		
		if [$NUMARCHIVOS != 0]
		then
			#~ 4.1. Invocar al Comando Reservar_B siempre que éste no se esté ejecutando.
			#~ Si arranca correctamente se debe mostrar por pantalla el process id de Reservar_B
			#~ Si da algún tipo de error se debe mostrar por pantalla el mensaje explicativo
			#~  esto me dice si se esta ejecutando, podria ponerlo en un while ps cax | grep command o esperar a la proxima y chau (hipotesis)
			#~ Para cuando este: correr reservar. pid da el process id y wait espera a que cambie el algo...
			#~ Reservar_B
			#~ pid=$!
			#~ wait $! 
		
			echo "Se corre Reservar_B y toda la gilada"
		fi
		#~ 5. Dormir x minutos y Volver al punto 1
		sleep 1m
	fi
	

done


