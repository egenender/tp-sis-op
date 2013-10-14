 listarArchivos(){
	if [ -d "$1" ]; then
		msj=`ls $1`
		if [ "$msj" == "" ]; then
			echo "Directorio Vacio"
			./Grabar_L.sh "$SCRIPT_PADRE" "Informativo" "Directorio "$2" vacio."
		else
			echo "Archivos:"
			./Grabar_L.sh "$SCRIPT_PADRE" "Informativo" "Archivos:"
			echo $msj
			./Grabar_L.sh "$SCRIPT_PADRE" "Informativo" "$msj"
		fi
	else
		echo "No existe el directorio."
		./Grabar_L.sh "$SCRIPT_PADRE" "Informativo" "Directorio "$2" no existe"
	fi
}

#si se desea ademas que liste el contenido de las carpetas, pasar parametro = 1
function imprimirSusRespuestas(){
	clear #Limpio la pantalla
	
	version="TP SO7508 Segundo Cuatrimestre 2013. Tema B Copyright © Grupo 02"
	echo $version
	./Grabar_L.sh "$SCRIPT_PADRE" "Informativo" "$version"
	
	libreria="Librería del Sistema: "$CONFDIR
	echo $libreria
	./Grabar_L.sh "$SCRIPT_PADRE" "Informativo" "$libreria"
	if [ $1 -eq 1 ]; then
		listarArchivos $CONFDIR
	fi
	
	ejec="Ejecutables: "$BINDIR
	echo $ejec
	./Grabar_L.sh "$SCRIPT_PADRE" "Informativo" "$ejec"
	if [ $1 -eq 1 ]; then
		listarArchivos $BINDIR
	fi
	
	maestr="Archivos maestros: "$MAEDIR
	echo $maestr
	./Grabar_L.sh "$SCRIPT_PADRE" "Informativo" "$maestr"
	if [ $1 -eq 1 ]; then
		listarArchivos $MAEDIR
	fi
	
	extern="Directorio de arribo de archivos externos: "$ARRIDIR
	echo $extern
	./Grabar_L.sh "$SCRIPT_PADRE" "Informativo" "$extern"
	
	tam="Espacio mínimo libre para arribos: "$DATASIZE" Mb"
	echo $tam
	./Grabar_L.sh "$SCRIPT_PADRE" "Informativo" "$tam"
	
	aceptado="Archivos externos aceptados: "$ACEPDIR
	echo $aceptado
	./Grabar_L.sh "$SCRIPT_PADRE" "Informativo" "$aceptado"
	
	rechazado="Archivos externos rechazados: "$RECHDIR
	echo $rechazado
	./Grabar_L.sh "$SCRIPT_PADRE" "Informativo" "$rechazado"
	
	reporte="Reportes de salida: "$REPODIR
	echo $reporte
	
	proc="Archivos procesados: "$PROCDIR
	echo $proc
	./Grabar_L.sh "$SCRIPT_PADRE" "Informativo" "$proc"
	
	logs="Logs de auditoria del Sistema: "$LOGDIR"/<comando>."$LOGEXT
	echo $logs
	./Grabar_L.sh "$SCRIPT_PADRE" "Informativo" "$logs"
	
	tamMax="Tamaño máximo para los archivos de log del sistema: "$LOGSIZE" Kb"
	echo $tamMax
	./Grabar_L.sh "$SCRIPT_PADRE" "Informativo" "$tamMax"
	
	if [ $SCRIPT_PADRE == "Instalar_TP" ]; then
		estado="Estado de la instalacion: "$2
	else
		estado="Estado del sistema: "$2
	fi
	
	echo $estado
	./Grabar_L.sh "$SCRIPT_PADRE" "Informativo" "$estado"
	
	exit 0
}

SCRIPT_PADRE=$3
imprimirSusRespuestas $1 $2
