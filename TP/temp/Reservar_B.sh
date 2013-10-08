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
        FECHA=$1
        DIA=`echo "$FECHA" | cut -d "/" -f 1`
        MES=`echo "$FECHA" | cut -d "/" -f 2`
        ANIO=`echo "$FECHA" | cut -d "/" -f 3`
                     
        VALIDO_ANIO=`echo $ANIO | grep "^20[0-3][0-9]" | wc -l`
        
        if [ $VALIDO_ANIO ==  0 ]
        then	
                echo 1
                return
        fi

        VALIDO_MES=`echo $MES | grep "^0[0-9]" | wc -l`
        if [ $VALIDO_MES == 0 ]
        then
                VALIDO_MES=`echo $MES | grep "^1[0-2]" | wc -l`
                if [ $VALIDO_MES == 0 ]
                then
                        echo 2
                        return
                fi
        fi
        
        VALIDO_DIA=`echo $DIA | grep "^0[1-9]" | wc -l`
        
        if [ $VALIDO_DIA == 0 ]
        then	
                VALIDO_DIA=`echo $DIA | grep "^1[0-9]" | wc -l`
                if [ $VALIDO_DIA == 0 ]
                then
                        VALIDO_DIA=`echo $DIA | grep "^2[0-8]" | wc -l`
                        if [ $VALIDO_DIA == 0 ]
						then
								if [ $MES != "02" ]
                                then
									VALIDO_DIA=`echo $DIA | grep "^29" | wc -l`
									if [ $VALIDO_DIA == 0 ]
									then
											if [ $MES == "01" -o $MES == "03" -o $MES == "05" -o $MES == "07" -o $MES == "08" -o $MES == "10" -o $MES == "12" ]
											then
												VALIDO_DIA=`echo $DIA | grep "^3[01]" | wc -l`
												if [ $VALIDO_DIA == 0 ]
												then
													echo 3
													return
												fi
											else
												VALIDO_DIA=`echo $DIA | grep "^30" | wc -l`
												if [ $VALIDO_DIA == 0 ]
												then
													echo 4
													return
												fi
											fi
                                    fi
                                else
									#Por ahora no acepto años biciestos
									echo 5
									return
                                fi
                        fi
                fi      
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

FECHITA="29/02/2005"

VALOR=$(fechaValida $FECHITA)
if [ $VALOR != 0 ] 
then
	echo "Fecha invalida"
	echo $VALOR
else
	echo "Fecha Valida"
fi
read hola
inicializarReservar
for archivo in `ls $ACEPDIR`
do
        procesarArchivo `echo "$ACEPDIR"$archivo`
done
