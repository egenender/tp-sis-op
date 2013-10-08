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
        
        echo 1
}

function fechaValida(){
	FECHA_RESERVA=`echo $1 | sed 's+^\([^/]*\)/\([^/]*\)/\(.*\)$+\2/\1/\3+'`
	#SALIDA_DIA=$(date --date="$FECHA_RESERVA")
	date --date="$FECHA_RESERVA" 2> aux_date.txt > aux_date1.txt
	
	VALIDO=`grep "^date:" aux_date.txt | wc -l`
	
	rm aux_date.txt aux_date1.txt
	
	if [ $VALIDO == 0 ]
	then
		echo 0
	else
		echo 1
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
    echo 1
    return
	fi
	
	if [ $DIAS -eq 1 ]
	then
		echo 2
		return
	fi
	
	if [ $DIAS -gt 30 ]
	then
		echo 3
		return
	fi
	
	echo 0
}


function procesarArchivo(){
        ARCHIVO_ACTUAL= $1
        "$BINDIR"Grabar_L.sh "Rerservar_B" "Informativo" "Se procesa el archivo $ARCHIVO_ACTUAL"
        
        #Movemos el archivo a procesar a PROCDIR
        CORRECTO=`"$BINDIR"Mover_B $ARCHIVO_ACTUAL $PROCDIR`
#       CORRECTO=0
        #Ver que devuelve el mover_B
        if [ $CORRECTO != 0 ] 
        then
                "$BINDIR"Grabar_L.sh "Reservar_B" "Error" "Se rechaza el archivo por estar DUPLICADO"           
                Mover_B $ARCHIVO_ACTUAL $RECHDIR
                return
        fi

        #Verificamos si el archivo se encuentra vacio:
        if [ `cat $ARCHIVO_ACTUAL|wc -l` == 0 ]         
        then
                "$BINDIR"Grabar_L.sh "Reservar_B" "Error" "No se procesa el archivo, por estar vacio"
                "$BINDIR"Mover_B.sh $ARCHIVO_ACTUAL $RECHDIR            
                return
        fi

        RESPETAFORMATO= $(cumpleFormato $ARCHIVO_ACTUAL)
        if [ $RESPETAFORMATO == 0 ]
        then
                "$BINDIR"Grabar_L.sh "Reservar_B" "Several Error" "El archivo no respeta el formato, no se lo procesa"
                "$BINDIR"Mover_B.sh $ARCHIVO_ACTUAL $RECHDIR
                return
        fi

        for linea in `cat $ARCHIVO_ACTUAL`
        do      
                echo "::"
                
                #validar fecha:
                        #Verificar Fecha Valida. Rechazar (motivo = fecha invalida)
                        #Comparar fecha actual con la de la funcion. Si la diferencia es menor o igual a 1, se rechaza. (motivo = reserva tardia)
                        #Si la diferencia es mayor a 30, se rechaza (motivo = reserva anticipada)
                #Validar hora:  #Si el formato de hora no es valido, se rechaza (formato HH:MM)
                #Validar exitencia de evento
                #Validar la disponibilidad
                                
        done
        
}

FECHITA="10/10/2013"
VALIDEZ=$(fechaValida $FECHITA)
if [ $VALIDEZ != 0 ]
then
	echo "Fecha Invalida"
else
	echo "Fecha Valida"
	DIF_VALIDO=$(distanciaAFechaValida $FECHITA)
	if [ $DIF_VALIDO -eq 0 ]
	then
		echo "Distancia Correcta"
	else
		echo "Mal dia"
	fi
fi

read hola
inicializarReservar
for archivo in `ls $ACEPDIR`
do
        procesarArchivo `echo "$ACEPDIR"$archivo`
done
