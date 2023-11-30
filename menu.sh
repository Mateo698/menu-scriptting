#!/bin/bash

# Definir archivos para cada móduo
current="none"
USUARIOS_FILE="usuarios.txt"
DEPTOS_FILE="deptos.txt"
ASIGNACIONES_FILE="asignaciones.txt"
LOGS_FILE="logs.txt"
ACTIVIDADES_FILE="actividades.txt"
SISTEMA_FILE="sistema.txt"

nueva_actividad() {
    user=$1
    category=$2
    action=$3
    timestamp=$(date +"%Y-%m-%dT%H:%M:%SZ")

    archivo="actividades.txt"
    echo "$user;$category;$action;$timestamp" >> "$archivo"
}

validar_usuario() {
    local nombre=$1
    if id "$nombre" >/dev/null 2>&1; then
        echo "existe"
    else
        echo "no existe"
    fi
}

# Menu para modificar usuario
modificar_usuario() {
    while true; do
        echo ""
        echo "MODIFICAR USUARIO"
        echo "Seleccione una opción para modificar usuario:"
	    echo "1. Modificar nombre de usuario"
        echo "2. Modificar contraseña de usuario"      
        echo "3. Modificar grupo de usuario"        
        echo "4. Modificar fecha de expiración de usuario"
	echo ""
	echo "Escriba \"atras\" para volver, o \"salir\" para cerrar el programa"
        read -p "Ingrese su opción: " item
        nueva_actividad "$current" "procesos" "modificar usuario"
        case $item in

            1)
                read -p "Ingrese el nombre de usuario a modificar: " usuario_a_modificar
                existe=$(validar_usuario "$usuario_a_modificar")

                if [ "$existe" == "existe" ]; then
                    read -p "Ingrese el nuevo nombre de usuario: " nuevo_nombre
                    sudo usermod -l "$nuevo_nombre" "$usuario_a_modificar"
                    echo "Usuario $usuario_a_modificar modificado exitosamente."
                    # Actualizar el archivo de usuarios.txt
                    sed -i "s/$usuario_a_modificar;ACTIVO/$nuevo_nombre;ACTIVO/g" "$USUARIOS_FILE"
                    
                    nueva_actividad "$current" "memoria" "cambiar nombre de usuario de $usuario_a_modificar a $nuevo_nombre"
                fi                
                ;;
            2)      
                read -p "Ingrese el nombre de usuario a modificar: " usuario_a_modificar   
                existe=$(validar_usuario "$usuario_a_modificar")
                
                if ["$existe" = "existe"]; then                               
                    sudo passwd "$usuario_a_modificar"
                    echo "Usuario $usuario_a_modificar modificado exitosamente."    
                    nueva_actividad "$current" "memoria" "cambiar contraseña a $usuario_a_modificar"
                fi 
                ;;   
            3)
                read -p "Ingrese el nombre de usuario a modificar: " usuario_a_modificar
                existe=$(validar_usuario "$usuario_a_modificar")

                if [ "$existe" == "existe" ]; then
                    read -p "Ingrese el nuevo grupo de usuario: " nuevo_grupo
                    sudo usermod -g "$nuevo_grupo" "$usuario_a_modificar"
                    echo "Usuario $usuario_a_modificar modificado exitosamente."
                    nueva_actividad "$current" "memoria" "cambiar grupo de $usuario_a_modificar a grupo $nuevo_grupo"
                fi
                ;;
            4)
                read -p "Ingrese el nombre de usuario a modificar: " usuario_a_modificar
                existe=$(validar_usuario "$usuario_a_modificar")

                if [ "$existe" == "existe" ]; then
                    read -p "Ingrese la nueva fecha de expiración de usuario: " nueva_fecha
                    sudo usermod -e "$nueva_fecha" "$usuario_a_modificar"
                    echo "Usuario $usuario_a_modificar modificado exitosamente."
                    nueva_actividad "$current" "memoria" "cambiar fecha de expiración de $usuario_a_modificar a $nueva_fecha"
                fi
                ;;

            salir)
                exit 0
                ;;

            atras)
                gestionar_usuarios
                ;;

            *)
                echo "Opción no válida"
                ;;
        esac
        
    done
}





# Función para gestionar usuarios
gestionar_usuarios() {
    
    while true; do
        
        echo ""
        echo "GESTIÓN DE USUARIOS"
        echo "Seleccione una opción para gestión de usuarios:"
        echo "1. Crear usuario"
        echo "2. Deshabilitar usuario"
        echo "3. Modificar usuario"
        echo "4. Habilitar usuario"
	echo "\nEscriba \"atras\" para volver, o \"salir\" para cerrar el programa"
        read -p "Ingrese su opción: " item
        nueva_actividad "$current" "procesos" "gestión de usuarios"
        case $item in
            1)
                read -p "Ingrese el nombre de usuario a crear: " nuevo_usuario
                # Verificar si el usuario ya existe
                if id "$nuevo_usuario" >/dev/null 2>&1; then
                    echo "El usuario $nuevo_usuario ya existe."
                else
                    # Crear el usuario y guardar la información en el archivo usuarios.txt
                    sudo adduser "$nuevo_usuario"
                    echo "$nuevo_usuario;ACTIVO">> "$USUARIOS_FILE"
                    echo "Usuario $nuevo_usuario creado exitosamente."
                    nueva_actividad "$current" "memoria" "crear usuario $nuevo_usuario"
                fi
                ;;
            2)
                read -p "Ingrese el nombre de usuario a deshabilitar: " usuario_a_deshabilitar
                if id "$usuario_a_deshabilitar" >/dev/null 2>&1; then
                    echo "Se eliminará el usuario $usuario_a_deshabilitar"
                    # Deshabilitar el usuario y guardar la información en el archivo usuarios.txt
                    sudo usermod --expiredate 1 "$usuario_a_deshabilitar"
                    sed -i "s/$usuario_a_deshabilitar;ACTIVO/$usuario_a_deshabilitar;INACTIVO/g" "$USUARIOS_FILE"
                    echo "Usuario $usuario_a_deshabilitar deshabilitado exitosamente."
                    nueva_actividad "$current" "memoria" "deshabilitar a $usuario_a_deshabilitar"

                else
                    echo "El usuario $usuario_a_deshabilitar no existe."
                fi
                ;;
            3)
                modificar_usuario
                ;;
            4)
                read -p "Ingrese el nombre de usuario a habilitar: " usuario_a_habilitar
                if id "$usuario_a_habilitar" >/dev/null 2>&1; then
                    echo "Se habilitará el usuario $usuario_a_habilitar"
                    # Habilitar el usuario y guardar la información en el archivo usuarios.txt
                    sudo usermod --expiredate "" "$usuario_a_habilitar"
                    sed -i "s/$usuario_a_habilitar;INACTIVO/$usuario_a_habilitar;ACTIVO/g" "$USUARIOS_FILE"
                    echo "Usuario $usuario_a_habilitar habilitado exitosamente."
                    nueva_actividad "$current" "memoria" "habilitar a $usuario_a_habilitar"
                else
                    echo "El usuario $usuario_a_habilitar no existe."
                fi
            ;;
            
            salir)
                exit 0
                ;;
            atras)
                menu
                ;;
            *)
                echo "Opción no válida"
                ;;
        esac
    done
}

validar_grupo() {
    local grupo=$1
    if grep -q "^$grupo:" /etc/group; then
        echo "existe"
    else
        echo "no existe"
    fi
}


modificar_grupo() {
    while true; do
        echo ""
        echo "MODIFICAR GRUPO"
        echo "Seleccione una opción para modificar grupo:"
        echo "1. Modificar nombre de grupo"
        echo "2. Modificar contraseña de grupo"         
	echo "\nEscriba \"atras\" para volver, o \"salir\" para cerrar el programa"
        read -p "Ingrese su opción: " item
        nueva_actividad "$current" "procesos" "modificar grupo"
        case $item in
            1)
                read -p "Ingrese el nombre de grupo a modificar: " grupo_a_modificar
                existe=$(validar_grupo "$grupo_a_modificar")

                if [ "$existe" == "existe" ]; then
                    read -p "Ingrese el nuevo nombre de grupo: " nuevo_nombre
                    sudo groupmod -n "$nuevo_nombre" "$grupo_a_modificar"
                    echo "Grupo $grupo_a_modificar modificado exitosamente."
                    nueva_actividad "$current" "memoria" "modificar nombre de $grupo_a_modificar a $nuevo_nombre"
                fi
                ;;
            2)
                read -p "Ingrese el nombre de grupo a modificar: " grupo_a_modificar
                existe=$(validar_grupo "$grupo_a_modificar")

                if [ "$existe" == "existe" ]; then
                    sudo gpasswd "$grupo_a_modificar"
                    echo "Grupo $grupo_a_modificar modificado exitosamente."
                    nueva_actividad "$current" "memoria" "modificar contraseña de $grupo_a_modificar"
                fi 
                ;;     
            salir)
                exit 0
                ;;
            atras)
                gestionar_deptos
                ;;
            *)
                echo "Opción no válida"
                ;;

        esac
    done
}

# Función para gestionar departamentos
gestionar_deptos() {
    
    while true; do
        echo ""
        echo "GESTIÓN DE DEPARTAMENTOS"
        echo "Seleccione una opción para gestión de departamentos:"
        echo "1. Crear departamento"
        echo "2. Deshabilitar departamento"
        echo "3. Modificar departamento"
	echo "\nEscriba \"atras\" para volver, o \"salir\" para cerrar el programa"
        read -p "Ingrese su opción: " item
        nueva_actividad "$current" "procesos" "gestión de departamentos"
        case $item in
            1)
                read -p "Ingrese el nombre del departamento a crear: " nuevo_depto
                # Verificar si el departamento ya existe
                if grep -q "^$nuevo_depto:" /etc/group; then
                    echo "El departamento $nuevo_depto ya existe."
                else
                    # Crear el grupo y guardar la información en el archivo deptos.txt
                    sudo addgroup "$nuevo_depto"
                    echo "$nuevo_depto;ACTIVO" >> "$DEPTOS_FILE"
                    echo "Departamento $nuevo_depto creado exitosamente."
                    nueva_actividad "$current" "memoria" "crear $nuevo_depto"
                fi
                ;;
            2)
                read -p "Ingrese el nombre del departamento a deshabilitar: " depto_a_deshabilitar
                if grep -q "^$depto_a_deshabilitar:" /etc/group; then
                    # Deshabilitar el grupo y guardar la información en el archivo deptos.txt
                    sudo groupdel "$depto_a_deshabilitar"
                    sed -i "s/$depto_a_deshabilitar;ACTIVO/$depto_a_deshabilitar;INACTIVO/g" "$DEPTOS_FILE"
                    echo "Departamento $depto_a_deshabilitar deshabilitado exitosamente."
                    nueva_actividad "$current" "memoria" "deshabilitar $dept_a_deshabilitar"
                else
                    echo "El departamento $depto_a_deshabilitar no existe."
                fi
                ;;
            3)
                modificar_grupo
                ;;
            
            salir)
                exit 0
                ;;
            atras)
                menu
                ;;
            *)
                echo "Opción no válida"
            ;;
        esac
    done
}

# Función para gestionar asignaciones de usuarios a departamentos
gestionar_asignaciones() {
    while true; do
        
        echo ""
        echo "GESTIÓN DE USUARIOS A DEPARTAMENTOS"
        echo "Seleccione una opción para gestión de asignaciones:"
        echo "1. Asignar usuario a departamento"
        echo "2. Desasignar usuario de departamento"
	echo "\nEscriba \"atras\" para volver, o \"salir\" para cerrar el programa"
        read -p "Ingrese su opción: " item
        nueva_actividad "$current" "procesos" "gestión de usuarios a departamentos"
        case $item in
            1)
                read -p "Ingrese el nombre de usuario a asignar: " usuario_asignar
                read -p "Ingrese el nombre del departamento: " depto_asignar
                
                if [id "$nuevo_usuario" >/dev/null 2>&1] && [grep -q "^$depto_a_deshabilitar:" /etc/group]; then
                    # Asignar usuario a departamento y guardar la información en el archivo asignaciones.txt
                    sudo usermod -a -G "$depto_asignar" "$usuario_asignar"
                    echo "$usuario_asignar;$depto_asignar;ASIGNADO" >> "$ASIGNACIONES_FILE"
                    echo "Usuario $usuario_asignar asignado exitosamente al departamento $depto_asignar."
                    nueva_actividad "$current" "memoria" "asignar $usuario_asignar a $dept_asignar"
                else
                    echo "El usuario $usuario_asignar o el departamento $depto_asignar no existen."
                fi
                ;;
            2)
                read -p "Ingrese el nombre de usuario a desasignar: " usuario_desasignar
                read -p "Ingrese el nombre del departamento: " depto_desasignar
                # Eliminar asignación de usuario a departamento y eliminar registro correspondiente en asignaciones.txt
                if [id "$nuevo_usuario" >/dev/null 2>&1] && [grep -q "^$depto_a_deshabilitar:" /etc/group]; then
                    sudo gpasswd -d "$usuario_desasignar" "$depto_desasignar"
                    sed -i "s/$usuario_desasignar;$depto_desasignar;ASIGNADO/$usuario_desasignar;$depto_desasignar;DESASIGNADO/g" "$ASIGNACIONES_FILE"
                    echo "Usuario $usuario_desasignar desasignado exitosamente del departamento $depto_desasignar."
                    nueva_actividad "$current" "memoria" "desasignar a $usuario_desasignar de $dept_desasignar"
                else
                    echo "El usuario $usuario_desasignar o el departamento $depto_desasignar no existen."
                fi
                ;;
            salir)
                exit 0
                ;;
            atras)
                menu
                ;;
            *)
                echo "Opción no válida"
            ;;
        esac
    done
}

# Función para buscar líneas que contengan una cadena específica en un archivo de logs
buscar_cadena() {
    grep "$1" "$LOG_FILE"
    nueva_actividad "$current" "archivos" "busqueda de cadena"
}


mostrar_estadisticas_kernel() {
    echo "Generando estadísticas del kernel..."
    

    # Número total de líneas en el registro del kernel
    total_lineas_kernel=$(wc -l /var/log/kern.log | cut -d ' ' -f1)
    echo "Total de líneas en el registro del kernel: $total_lineas_kernel"
    
    # Imprimir líneas de error en el registro del kernel
    echo "Líneas de error en el registro del kernel:"
    grep -i "error" /var/log/kern.log
    
    # Número de mensajes de error en el registro del kernel
    errores_kernel=$(grep -ic "error" /var/log/kern.log)
    echo "Número de mensajes de error en el registro del kernel: $errores_kernel"
    
    # Imprimir líneas de advertencia en el registro del kernel
    echo "Líneas de advertencia en el registro del kernel:"
    grep -i "warning" /var/log/kern.log
    
    # Número de mensajes de advertencia en el registro del kernel
    advertencias_kernel=$(grep -ic "warning" /var/log/kern.log)
    echo "Número de mensajes de advertencia en el registro del kernel: $advertencias_kernel"
    
    nueva_actividad "$current" "archivos" "generación de estadisticas del kernel"

}



mostrar_estadisticas_syslog() {
    echo "Generando estadísticas del syslog..."
    # Número total de líneas en el registro del syslog
    total_lineas_syslog=$(wc -l /var/log/syslog | cut -d ' ' -f1)
    echo "Total de líneas en el registro del syslog: $total_lineas_syslog"
    
    # Número de eventos de inicio en el registro del syslog
    inicio_syslog=$(grep -ic "started" /var/log/syslog)
    echo "Número de eventos de inicio en el registro del syslog: $inicio_syslog"
    
    # Número de eventos de apagado en el registro del syslog
    apagado_syslog=$(grep -ic "shutdown" /var/log/syslog)
    echo "Número de eventos de apagado en el registro del syslog: $apagado_syslog"
    
    nueva_actividad "$current" "archivos" "generación de estadisticas del syslog"
    
}



mostrar_estadisticas_boot() {
    echo "Generando estadísticas de /var/log/boot.log..."
    
    # Número total de líneas en el registro de arranque
    total_lineas_boot=$(wc -l /var/log/boot.log | cut -d ' ' -f1)
    echo "Total de líneas en /var/log/boot.log: $total_lineas_boot"
    
    # Secuencia de eventos durante el arranque
    echo "Secuencia de eventos durante el arranque:"
    grep "Starting" /var/log/boot.log
    
    # Mensajes de error durante el arranque
    echo "Mensajes de error durante el arranque:"
    grep -i "error" /var/log/boot.log

}


mostrar_estadisticas_auth() {
    echo "Generando estadísticas del auth..."
    
    # Número total de líneas en el registro del auth
    total_lineas_auth=$(wc -l /var/log/auth.log | cut -d ' ' -f1)
    echo "Total de líneas en el registro del auth: $total_lineas_auth"
    
    # Número de intentos de inicio de sesión fallidos en el registro del auth
    intentos_fallidos_auth=$(grep -ic "authentication failure" /var/log/auth.log)
    echo "Número de intentos de inicio de sesión fallidos en el registro del auth: $intentos_fallidos_auth"
    
    # Número de intentos de inicio de sesión exitosos en el registro del auth
    intentos_exitosos_auth=$(grep -ic "session opened" /var/log/auth.log)
    echo "Número de intentos de inicio de sesión exitosos en el registro del auth: $intentos_exitosos_auth"
    
}

mostrar_estadisticas_dpkg() {
    echo "Generando estadísticas de /var/log/dpkg.log..."
    
    # Número total de líneas en el registro de dpkg
    total_lineas_dpkg=$(wc -l /var/log/dpkg.log | cut -d ' ' -f1)
    echo "Total de líneas en /var/log/dpkg.log: $total_lineas_dpkg"
    
    # Número de instalaciones de paquetes
    instalaciones=$(grep -c "install " /var/log/dpkg.log)
    echo "Número de instalaciones de paquetes: $instalaciones"
    
    # Número de desinstalaciones de paquetes
    desinstalaciones=$(grep -c "remove " /var/log/dpkg.log)
    echo "Número de desinstalaciones de paquetes: $desinstalaciones"
    
}



# Función para gestionar logs
gestionar_logs() {
    nueva_actividad "$current" "procesos" "gestión de logs"
    while true; do
        echo ""
        echo "GESTIÓN DE LOGS"
        echo "Seleccione una opción para gestión de logs:"
        echo "1. Buscar en log especifico"
        echo "2. Generar estadísticas de logs"
	echo "\nEscriba \"atras\" para volver, o \"salir\" para cerrar el programa"
        read -p "Ingrese su opción: " opcion
        nueva_actividad "$current" "archivos" "lectura de archivo de logs $LOG_FILE"
        case $opcion in
            1)  read -p "Ingrese la ruta del archivo de logs: " LOG_FILE
                
                if [ ! -f "$LOG_FILE" ]; then
                    echo "El archivo de logs no existe. Verifique la ruta y vuelva a intentar."
                    return
                fi
                read -p "Ingrese el patrón de búsqueda: " patron_busqueda
                # Lógica para buscar en logs con awk, sed, grep
                echo "Resultados de la búsqueda para el patrón '$patron_busqueda':"
                buscar_cadena "$patron_busqueda"
                nueva_actividad "$current" "archivos" "busqueda por patrón: $patron_busqueda"
                ;;
            2)
                echo "\n1. Estadísticas del Kernel"
                echo "2. Estadísticas del Syslog"
                echo "3. Estadísticas del Boot"
                echo "4. Estadísticas del Auth"
                echo "5. Estadisticas del Dpkg"
                echo "6. Salir"
                
                read -p "Seleccione una opción (1-5): " opcion
                
                case $opcion in
                    1) mostrar_estadisticas_kernel ;;
                    2) mostrar_estadisticas_syslog ;;
                    3) mostrar_estadisticas_boot ;;
                    4) mostrar_estadisticas_auth ;;
                    5) mostrar_estadisticas_dpkg ;;
                    6) echo "Saliendo..."; exit ;;
                    *) echo "Opción no válida. Por favor, seleccione una opción válida." ;;
                esac
                ;;
            salir)
                exit 0
                ;;
            atras)
                menu
                ;;
            *)
                echo "Opción no válida"
                ;;
        esac
    done
}

# Función para gestionar actividades en el sistema
gestionar_actividades() {
    while true; do
        echo ""
        echo "GESTIÓN DE ACTIVIDADES"
        echo "Seleccione una opción para gestión de actividades en el sistema:"
        echo "1. Rastrear actividades de memoria"
        echo "2. Rastrear actividades de procesos"
        echo "3. Rastrear actividades de archivos"
	echo "\nEscriba \"atras\" para volver, o \"salir\" para cerrar el programa"
        read -p "Ingrese su opción: " opcion
        nueva_actividad "$current" "procesos" "gestión de actividades"
        case $opcion in
            1)
                # Agregar lógica para rastrear actividades de memoria
                memoria=$(grep -E "memoria" "$ACTIVIDADES_FILE")
                echo "$memoria"
                nueva_actividad "$current" "archivos" "rastreo actividades de memoria"
                ;;
            2)
                # Agregar lógica para rastrear actividades de procesos
                procesos=$(grep -E "procesos" "$ACTIVIDADES_FILE")
                echo "$procesos"
                nueva_actividad "$current" "archivos" "rastreo actividades de procesos"
                ;;
            3)
                # Agregar lógica para rastrear actividades de archivos
                archivos=$(grep -E "archivos" "$ACTIVIDADES_FILE")
                echo "$archivos"
                nueva_actividad "$current" "archivos" "rastreo actividades de archivos"
                ;;
            salir)
                exit 0
            ;;
            atras)
                menu
            ;;
            *)
                echo "Opción no válida"
            ;;
        esac
    done
}

# Función para gestionar el sistema
gestionar_sistema() {
    while true; do
        echo ""
        echo "GESTIÓN DEL SISTEMA"
        echo "Seleccione una opción para gestión del sistema:"
        echo "1. Monitorizar estado del sistema"
        echo "2. Crear reporte de alerta"
	echo "Escriba \"atras\" para volver, o \"salir\" para cerrar el programa"
        read -p "Ingrese su opción: " opcion
        
        case $opcion in
            1)
                last_login=$(grep "$current;procesos;inicio de sesión" actividades.txt | tail -n 1)
                last_activities=$(grep -F "$last_login" -B 10000 actividades.txt | tail -n +2)
                echo "$last_activities"

                echo "ESTADO DEL SISTEMA"
                echo "----------------------------------------"
                echo "Usuario actual: $current"
                echo "Último inicio de sesión: $last_login"
                echo "Memoria utilizada: $(free -m | grep Mem | awk '{print $3}') MB"
                echo "Memoria disponible: $(free -m | grep Mem | awk '{print $4}') MB"
                echo "Memoria total: $(free -m | grep Mem | awk '{print $2}') MB"
                echo "Tamaño del log de actividades: $(wc -l actividades.txt | cut -d ' ' -f1) líneas"
                echo "Tamaño del log de usuarios: $(wc -l usuarios.txt | cut -d ' ' -f1) líneas"
                echo "----------------------------------------"

                
                nueva_actividad "$current" "procesos" "monitorización del sistema"
                ;;
            2)
                # Agregar lógica para crear reporte de alerta
            ;;
            salir)
                exit 0
            ;;
            atras)
                menu
            ;;
            *)
                echo "Opción no válida"
            ;;
        esac
    done
}

menu() {
    while true; do
        echo ""
        echo "Bienvenido al sistema de gestión de empresa"
        echo "Seleccione una opción para continuar:"
        echo "1. Gestión de usuarios"
        echo "2. Gestión de departamentos"
        echo "3. Usuarios x departamentos"
        echo "4. Gestión de logs"
        echo "5. Gestión de actividades en el sistema"
        echo "6. Gestión del sistem"

        echo "O escriba \"salir\" para cerrar el programa"

        read -p "Ingrese su opción: " item
        
        case $item in
            1)
                gestionar_usuarios
            ;;
            2)
                gestionar_deptos
            ;;
            3)
                gestionar_asignaciones
            ;;
            4)
                gestionar_logs
            ;;
            5)
                gestionar_actividades
            ;;
            6)
                gestionar_sistema
            ;;
            
            salir)
                exit 0
            ;;
            
            *)
                echo "Opción no válida"
            ;;
        esac
    done
}

login() {
	
	while true; do
		echo "Bienvenido al sistema de gestión de empres"
		echo "Debe iniciar sesión para poder usar el sistea"
		read -p "Escriba su nombre de usuario: " user_attempt
		if grep -q "$user_attempt" "$USUARIOS_FILE" && grep -q "ACTIVO" "$USUARIOS_FILE"; then
            if [ $user_attempt != "admin" ]; then
                read -s -p "Escriba su contraseña: " kennwort
                echo -e "$kennwort" | su - "$user_attempt"
            else echo "Bienvenido $user_attempt"
            fi
            current=$user_attempt
			nueva_actividad "$current" "procesos" "inicio de sesión"
			menu
		else 
            echo "Usuario no encontrado, intente otra vez"
		fi
        
	done
}

login

