#!/bin/bash
#
# Comando para pasar las solicitudes de reservas a confirmadas o no confirmadas, dependiendo de la disponibilidad.
# Solo se tiene en cuenta la cantidad de butacas disponibles, no posiciones especificas
# Se dispara automaticamente

MAEDIR="MAESTROS"
ARRIDIR="ARRIBOS"
ACEPDIR="ACEPTADOS"
RECHDIR="RECHAZADOS"
REPODIR="INVITADOS"
LANG="_ES.UTF-8"
BINDIR="."
LOGSIZE=300
export LOGSIZE
LOGEXT=".log"
export LOGEXT
LOGDIR="LOGS"
export LOGDIR

PROCDIR="PROCESADOS"


function inicializarReservar(){
        "$BINDIR"/Grabar_L.sh "Reservar_B" "Informativo" "Inicio de operacion de Reservar_B"
        "$BINDIR"/Grabar_L.sh "Reservar_B" "Informativo" "Se procesan `ls $ACEPDIR | wc -l` archivos"
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
        CANT_LINEAS=`cat $1 | wc -l`
        CANT_LINEAS_FORMATO=`grep "^[^;]*;[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9];[0-9][0-9]:[0-9][0-9];[^;]*;[^;]*;[0-9]\+;" "$1" | wc -l`
		
        if [ $CANT_LINEAS -le $CANT_LINEAS_FORMATO ]
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
        
        
        if [ $RAZON -eq 1 ]
        then
            MOTIVO="Fecha Invalida"
        elif [ $RAZON -eq 2 ]
        then
                if [ $6 -eq 1 ]
                then
                        MOTIVO="Reserva Vencida"
                elif [ $6 -eq 2 ]
                then
                        MOTIVO="Reserva Tardia"
                else
                        MOTIVO="Reserva Anticipada"
                fi
        elif [ $RAZON -eq 3 ]
        then
                MOTIVO="Hora Invalida"
        elif [ $RAZON -eq 4 ]
        then
                MOTIVO="No existe el evento solicitado"
        elif [ $RAZON -eq 5 ]
        then
                MOTIVO="Falta de Disponibilidad"
        fi
        
        FECHA_GRABACION=`date`
        
        
        SALIDA=`echo $RECH_REGISTRO';'$MOTIVO';'$3';'$5';'$4';'$FECHA_GRABACION';'$USER`
        echo $SALIDA >> $PROCDIR/reservas.nok 
        registrosNOK=`expr $registrosNOK + 1`
}

function procesarArchivo(){
        ARCHIVO_ACTUAL=$1
        "$BINDIR"/Grabar_L.sh "Reservar_B" "Informativo" "Se procesa el archivo $ARCHIVO_ACTUAL"
                
                #Verifico no haber procesado ya este archivo:
        if [ `ls $PROCDIR | grep "^$ARCHIVO_ACTUAL$" | wc -l` != 0 ] 
        then
                "$BINDIR"/Grabar_L.sh "Reservar_B" "Error" "Se rechaza el archivo por estar DUPLICADO"
                "$BINDIR"/Mover_B.sh $ARCHIVO_ACTUAL $RECHDIR
                return 1
        fi

        #Verificamos si el archivo se encuentra vacio:
        if [ `cat $ARCHIVO_ACTUAL|wc -l` == 0 ]         
        then
                "$BINDIR"/Grabar_L.sh "Reservar_B" "Error" "No se procesa el archivo, por estar vacio"
                "$BINDIR"/Mover_B.sh $ARCHIVO_ACTUAL $RECHDIR            
                return 2
        fi

                cumpleFormato $ARCHIVO_ACTUAL
        RESPETAFORMATO=$?
        
        if [ $RESPETAFORMATO != 0 ]
        then
                "$BINDIR"/Grabar_L.sh "Reservar_B" "Several Error" "El archivo no respeta el formato, no se lo procesa"
                "$BINDIR"/Mover_B.sh $ARCHIVO_ACTUAL $RECHDIR
                return 3
        fi
        
        #Necesito saber el correo del solicitante:
        CORREO=`echo $ARCHIVO_ACTUAL | cut -d "-" -f 2`
		ID=`echo "$ARCHIVO_ACTUAL"|cut -d/ -f 2 | cut -d- -f 1`
		
		#Validar exitencia de evento
        ARCH_COMBOS="$PROCDIR"/combos.dis
        if [ `expr $ID % 2` != 0 ]
        then
			ID_OBRA=$ID
			ID_SALA="[^;]*"
        else
			ID_OBRA="[^;]*"
			ID_SALA=$ID
		fi

		#Proceso el archivo, linea a linea (registro a registro):
        for linea in `cat $ARCHIVO_ACTUAL`
        do      
                registrosTOT=`expr $registrosTOT + 1`
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
                fechaValida $FECHA_REGISTRO
                VALIDEZ=$?
                if [ $VALIDEZ != 0 ]
                then
					rechazarReserva $linea 1 "Falta Obra" "Falta Sala" $CORREO
                    continue
                fi
                                                                
                #Comparar fecha actual con la de la funcion. Si la diferencia es menor o igual a 1, se rechaza. (motivo = reserva tardia)
                #Si la diferencia es mayor a 30, se rechaza (motivo = reserva anticipada)
                distanciaAFechaValida $FECHA_REGISTRO
                VALIDEZ=$?
                if [ $VALIDEZ != 0 ]
                then
					rechazarReserva $linea 2 "Falta Obra" "Falta Sala" $CORREO $VALIDEZ
                    continue
                fi              
                
                #Validar hora:  #Si el formato de hora no es valido, se rechaza (formato HH:MM)
                horaValida $HORA_REGISTRO
                VALIDEZ=$?
                if [ $VALIDEZ != 0 ]
                then
					rechazarReserva $linea 3 "Falta Obra" "Falta Sala" $CORREO
                    continue
                fi
                                               
                EXISTE=`grep "^[^;]*;$ID_OBRA;$FECHA_REGISTRO;$HORA_REGISTRO;$ID_SALA;" $ARCH_COMBOS | wc -l `      
                if [ $EXISTE == 0 ]
                then
					if [ "$ID_OBRA" == "[^;]*" ]
                    then
						ID_OBRA="Falta Obra"
                    else
						ID_SALA="Falta Sala"
                    fi
                    rechazarReserva $linea 4 $ID_OBRA $ID_SALA $CORREO
                    continue
                fi
                ID_COMBO=`grep "^[^;]*;$ID_OBRA;$FECHA_REGISTRO;$HORA_REGISTRO;$ID_SALA;" $ARCH_COMBOS | cut -d ";" -f 1`
                                                                                
                #Validar la disponibilidad
                #Si es la primera vez que veo este combo en este ciclo:
          
                if [ "${Disponibilidades[$ID_COMBO]}" == "" ]
                then
					DISP=`grep "^$ID_COMBO;" $ARCH_COMBOS | cut -d ";" -f 7`
                    Disponibilidades[$ID_COMBO]=$DISP
                fi
                DISPONIBILIDAD=${Disponibilidades[$ID_COMBO]}
        
                ID_OBRA=`grep "^$ID_COMBO;" $ARCH_COMBOS | cut -d ";" -f 2`
                ID_SALA=`grep "^$ID_COMBO;" $ARCH_COMBOS | cut -d ";" -f 5`
                
                if [ $DISPONIBILIDAD -lt $CANT_RESERVAS ]
                then
                    rechazarReserva $linea 5 $ID_OBRA $ID_SALA $CORREO
                    continue
                fi
                
                NUEVA_DISP=`expr $DISPONIBILIDAD - $CANT_RESERVAS`
                Disponibilidades[$ID_COMBO]=$NUEVA_DISP
                                
                #A partir de aca el registro ya es valido:
                #Obtengo el nombre de la obra:
                NOMBRE_OBRA=`grep "^$ID_OBRA;" $MAEDIR/obras.mae | cut -d ";" -f 2`
                #Obtengo el nombre de la sala:
                NOMBRE_SALA=`grep "^$ID_SALA;" $MAEDIR/salas.mae | cut -d ";" -f 2`
                              
                FECHA=`date`
                SALIDA=`echo "$ID_OBRA"';'"$NOMBRE_OBRA"';'"$FECHA_REGISTRO"';'"$HORA_REGISTRO"';'"$ID_SALA"';'"$NOMBRE_SALA"';'"$CANT_RESERVAS"';'"$ID_COMBO"';'"$REF_INTERNA"';'"$CANT_RESERVAS"';'"$CORREO"';'"$FECHA"';'"$USER"`
                echo $SALIDA >> $PROCDIR/reservas.ok 
                registrosOK=`expr $registrosOK + 1`
        done
        #Muevo el archivo procesado:
        "$BINDIR"/Mover_B.sh $ARCHIVO_ACTUAL $PROCDIR
}

declare -A Disponibilidades
registrosTOT=0
registrosOK=0
registrosNOK=0

inicializarReservar
for archivo in `ls $ACEPDIR`
do
        procesarArchivo `echo "$ACEPDIR"/$archivo`
done

#Verificacion:
VERIF=`expr $registrosOK + $registrosNOK`
if [ "$VERIF" != "$registrosTOT" ]
then
        exit 1
fi

#Actualizo las disponibilidades:
for ID_COMBO in "${!Disponibilidades[@]}"
do
        #Busco la linea que estoy actualizando:
        REG_INICIO=`grep "^$ID_COMBO;" "$PROCDIR"/combos.dis | sed 's/\(.*\);[^;]*;[^;]*$/\1/'`
        REG_FIN=`grep "^$ID_COMBO;" "$PROCDIR"/combos.dis | sed 's/.*;[^;]*;\([^;]*\)$/\1/'`
                
        TEMPORAL="$PROCDIR"/combosTEMP.dis
        #Me quedo con todas las lineas excepto con la que estoy actualizando
        sed "/^$ID_COMBO/d" "$PROCDIR"/combos.dis > $TEMPORAL
        NUEVO_REG=`echo "$REG_INICIO"';'"${Disponibilidades[$ID_COMBO]}"';'$REG_FIN`
        
        echo $NUEVO_REG >> "$PROCDIR"/combosTEMP.dis
        cat "$PROCDIR"/combosTEMP.dis > "$PROCDIR"/combos.dis
        rm "$PROCDIR"/combosTEMP.dis
        "$BINDIR"/Grabar_L.sh "Reservar_B" "Informativo" "Actualizacion de Disponibilidad"
done

"$BINDIR"/Grabar_L.sh "Reservar_B" "Informativo" "Fin de Reservar_B"

exit 0
