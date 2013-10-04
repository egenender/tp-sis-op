#!/bin/bash            
#
# Nombre: Start_D
#
# Inicia un demonio
# 

# Precondicion: Deben estar seteadas las variables de entorno e instalado todo.

# TODO: en principio, solo el Recibir_B.sh
nohup $BINDIR/Recibir_B.sh > /dev/null 2>&1 &
exit 0