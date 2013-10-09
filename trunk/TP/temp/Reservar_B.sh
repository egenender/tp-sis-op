#!/bin/bash
#
# Comando para pasar las solicitudes de reservas a confirmadas o no confirmadas, dependiendo de la disponibilidad.
# Solo se tiene en cuenta la cantidad de butacas disponibles, no posiciones especificas
# Se dispara automaticamente

function inicializarReservar(){
        "$BINDIR"Grabar_L.sh "Reservar_B" "Informativo" "Inicio de operacion de Reservar_B"
        "$BINDIR"Grabar_L.sh "Reservar_B" "Informativo" "Se procesan `ls | wc -l` archivos"
}

function cumpleFormato(){
    #Ambos tipos de archivo tienen el mismo tipo de formato, con los mismos
    #campos como opcionales. El formato es:
    # Referencia Interna (caracteres), opcional
    # Fecha de la funcion (dd/mm/aa), obligatorio
    # Hora de la funcion (hh:mm), obligatorio
    # nro de fila (caracteres), opcional
    # nro de butaca (caracteres), opcional
    # Cantida de butacas solicitadas (numerico), obligatorio
    # Seccion (caracteres), opcional
        
    #Me fijo que tenga todos los campos en todas las lineas, con el formato (mas o menos) adecuado:
        CANT_LINEAS=`wc -l < "$1"`
        CANT_LINEAS_FORMATO=`grep "^[^;]*;[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9];[0-9][0-9]:[0-9][0-9];[^;]*;[^;]*;[0-9]\+;[^;]*$" "$1" | wc -l`
        
        if [ $CANT_LINEAS == $CANT_LINEAS_FORMATO ]
        then
                return 0
        else
                return 1
        fi
}

function fechaValida(){
        FECHA_RESERVA=`echo $1 | sed 's+^\([^/]*\)/\([^/]*\)/\(.*\)$+\2/\1/\3+'`
        #SALIDA_DIA=$(date --date="$FECHA_RESERVA")
        date --date="$FECHA_RESERVA" 2> aux_date.txt > aux_date1.txt
        
        VALIDO=`grep "^date:" aux_date.txt | wc -l`
        
        rm aux_date.txt aux_date1.txt
        
        if [ $VALIDO == 0 ]
        then
                return 0
        else
                return 1
        fi
}

function distanciaAFechaValida(){
        FECHA_RESERVA=`echo $1 | sed 's+^\([^/]*\)/\([^/]*\)/\(.*\)$+\2/\1/\3+'`
        FECHA_ACTUAL=$(date +%m/%d/%y)
        
        DIF_SEG=`expr $(date --date=$FECHA_RESERVA +%s) - $(date --date=$FECHA_ACTUAL +%s)`
        #Divido por los segundos en un dia:
    DIAS=`expr $DIF_SEG / 86400`
    if [ $DIAS -le 0 ]
        then
                return 1
        fi
        
        if [ $DIAS -eq 1 ]
        then
                return 2
        fi
        
        if [ $DIAS -gt 30 ]
        then
                return 3
        fi
        
        return 0
}

function horaValida(){
        HORA_RESERVA=$1
        
        FORMAT=`echo $HORA_RESERVA | grep "^[0-9][0-9]:[0-9][0-9]$" | wc -l`
        if [ $FORMAT == 0 ]
        then
                return 1
        fi
        
        HH=`echo "$HORA_RESERVA" | cut -d ":" -f 1`
        MM=`echo "$HORA_RESERVA" | cut -d ":" -f 2`
        if [ $HH -lt 0 -o $HH -gt 23 ]
        then
                return 1
        fi
        if [ $MM -lt 0 -o $MM -gt 59 ]
        then
                return 1
        fi
        return 0
}

function rechazarReserva(){
	RAZON=$2
	RECH_REGISTRO=$1
	#Armamos el registro de rechazado.
	#Los primeros 7 campos son directamente el registro original
	#Las razones están tabuladas
	
	
	if [ $RAZON == 1 ]
	then
	    MOTIVO="Fecha Invalida"
	elif [ $RAZON == 2 ]
	then
		if [ $3 == 1 ]
		then
			MOTIVO="Reserva Vencida"
		elif [ $3 == 2 ]
		then
			MOTIVO="Reserva Tardia"
		else
			MOTIVO="Reserva Anticipada"
		fi
	elif [ $RAZON == 3 ]
	then
		MOTIVO="Hora Invalida"
	fi
	#Luego agrego el resto de los motivos
	
	FECHA_GRABACION=`date`
	
}

function procesarArchivo(){
        ARCHIVO_ACTUAL= $1
        "$BINDIR"Grabar_L.sh "Rerservar_B" "Informativo" "Se procesa el archivo $ARCHIVO_ACTUAL"
        
        #Movemos el archivo a procesar a PROCDIR
        "$BINDIR"Mover_B $ARCHIVO_ACTUAL $PROCDIR
        MOVIMIENTO_CORRECTO=$?
        #Ver que devuelve el mover_B
        if [ $MOVIMIENTO_CORRECTO != 0 ] 
        then
                "$BINDIR"Grabar_L.sh "Reservar_B" "Error" "Se rechaza el archivo por estar DUPLICADO"
                Mover_B $ARCHIVO_ACTUAL $RECHDIR
                return 1
        fi

        #Verificamos si el archivo se encuentra vacio:
        if [ `cat $ARCHIVO_ACTUAL|wc -l` == 0 ]         
        then
                "$BINDIR"Grabar_L.sh "Reservar_B" "Error" "No se procesa el archivo, por estar vacio"
                "$BINDIR"Mover_B.sh $ARCHIVO_ACTUAL $RECHDIR            
                return 2
        fi

        RESPETAFORMATO= $(cumpleFormato $ARCHIVO_ACTUAL)
        if [ $RESPETAFORMATO != 0 ]
        then
                "$BINDIR"Grabar_L.sh "Reservar_B" "Several Error" "El archivo no respeta el formato, no se lo procesa"
                "$BINDIR"Mover_B.sh $ARCHIVO_ACTUAL $RECHDIR
                return
        fi

        for linea in `cat $ARCHIVO_ACTUAL`
        do      
				#Separo los campos del registro
				REF_INTERNA=`echo $linea | cut -d ";" -f 1`                
                FECHA_REGISTRO=`echo $linea | cut -d ";" -f 2`
                HORA_REGISTRO=`echo $linea | cut -d ";" -f 3`
				NUM_FILA=`echo $linea | cut -d ";" -f 4`
				NUM_BUTACA=`echo $linea | cut -d ";" -f 5`
				CANT_RESERVAS=`echo $linea | cut -d ";" -f 6`
				SECCION=`echo $linea | cut -d ";" -f 7`
				
				#validar fecha:
                        #Verificar Fecha Valida. Rechazar (motivo = fecha invalida)
				fechaValida FECHA_REGISTRO
				if [ $? != 0 ]
				then
					rechazarReserva linea 1
					continue
				fi
				
				#Comparar fecha actual con la de la funcion. Si la diferencia es menor o igual a 1, se rechaza. (motivo = reserva tardia)
                #Si la diferencia es mayor a 30, se rechaza (motivo = reserva anticipada)
				distanciaAFechaValida FECHA_REGISTRO
				if [ $? != 0 ]
				then
					rechazarReserva linea 2 $?
					continue
				fi		
                
                #Validar hora:  #Si el formato de hora no es valido, se rechaza (formato HH:MM)
                horaValida HORA_REGISTRO
                if [ $? != 0 ]
                then
					rechazarReserva linea 3
                fi
                        
                #Validar exitencia de evento
                #Validar la disponibilidad
                                
        done
        
}


inicializarReservar
for archivo in `ls $ACEPDIR`
do
        procesarArchivo `echo "$ACEPDIR"$archivo`
done
