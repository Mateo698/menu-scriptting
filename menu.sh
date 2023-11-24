#!/bin/bash

# Definir archivos para cada módulo
USUARIOS_FILE="usuarios.txt"
DEPTOS_FILE="deptos.txt"
ASIGNACIONES_FILE="asignaciones.txt"
LOGS_FILE="logs.txt"
ACTIVIDADES_FILE="actividades.txt"
SISTEMA_FILE="sistema.txt"

# Menu para modificar usuario
modificar_usuario(){
    while true; do
        echo ""
        echo "MODIFICAR USUARIO"
        echo "Seleccione una opción para modificar usuario:"
        echo "1. Modificar nombre de usuario"
        echo "2. Modificar contraseña de usuario"
        echo "3. Modificar directorio de usuario"        
        echo "4. Modificar grupo de usuario"        
        echo "5. Modificar fecha de expiración de usuario"

        read -p "Ingrese el nombre de usuario a modificar: " usuario_a_modificar
        read -p "Ingrese su opción: " item

        if id "$usuario_a_modificar" >/dev/null 2>&1; then
            case $item in
                1)
                    read -p "Ingrese el nuevo nombre de usuario: " nuevo_nombre                   
                    sudo usermod -l "$nuevo_nombre" "$usuario_a_modificar"
                    echo "Usuario $usuario_a_modificar modificado exitosamente."
                    ;;
                2)                    
                    sudo passwd "$usuario_a_modificar"
                    echo "Usuario $usuario_a_modificar modificado exitosamente."     
                    ;;    
                3)
                    read -p "Ingrese el nuevo directorio de usuario: " nuevo_directorio
                    sudo usermod -d "$nuevo_directorio" "$usuario_a_modificar"
                    echo "Usuario $usuario_a_modificar modificado exitosamente."
                    ;;    
                4)
                    read -p "Ingrese el nuevo grupo de usuario: " nuevo_grupo
                    sudo usermod -g "$nuevo_grupo" "$usuario_a_modificar"
                    echo "Usuario $usuario_a_modificar modificado exitosamente."
                    ;;
                5)
                    read -p "Ingrese la nueva fecha de expiración de usuario: " nueva_fecha
                    sudo usermod -e "$nueva_fecha" "$usuario_a_modificar"
                    echo "Usuario $usuario_a_modificar modificado exitosamente."
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

        else
            echo "El usuario $usuario_a_modificar no existe."
        fi

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

        read -p "Ingrese su opción: " item

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
                fi
                ;;
            2)
                read -p "Ingrese el nombre de usuario a deshabilitar: " usuario_a_deshabilitar
                if id "$usuario_a_deshabilitar" >/dev/null 2>&1; then
                    echo "Se eliminará el usuario $usuario_a_deshabilitar"
                    # Deshabilitar el usuario y guardar la información en el archivo usuarios.txt
                    sudo userdel -r "$usuario_a_deshabilitar"
                    sed -i "s/$usuario_a_deshabilitar;ACTIVO/$usuario_a_deshabilitar;INACTIVO/g" "$USUARIOS_FILE"
                    echo "Usuario $usuario_a_deshabilitar deshabilitado exitosamente."

                else
                    echo "El usuario $usuario_a_deshabilitar no existe."
                fi
                ;;
            3)
                modificar_usuario              
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


modificar_grupo(){
    while true; do
        echo ""
        echo "MODIFICAR GRUPO"
        echo "Seleccione una opción para modificar grupo:"
        echo "1. Modificar nombre de grupo"
        echo "2. Modificar contraseña de grupo"         

        read -p "Ingrese el nombre de grupo a modificar: " grupo_a_modificar
        read -p "Ingrese su opción: " item

        if grep -q "^$grupo_a_modificar:" /etc/group; then
            case $item in
                1)
                    read -p "Ingrese el nuevo nombre de grupo: " nuevo_nombre                   
                    sudo groupmod -n "$nuevo_nombre" "$grupo_a_modificar"
                    echo "Grupo $grupo_a_modificar modificado exitosamente."
                    ;;
                2)                    
                    sudo gpasswd "$grupo_a_modificar"
                    echo "Grupo $grupo_a_modificar modificado exitosamente."     
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

        else
            echo "El grupo $grupo_a_modificar no existe."
        fi

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
        read -p "Ingrese su opción: " item

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
                fi
                ;;
            2)
                read -p "Ingrese el nombre del departamento a deshabilitar: " depto_a_deshabilitar
                if grep -q "^$depto_a_deshabilitar:" /etc/group; then
                    # Deshabilitar el grupo y guardar la información en el archivo deptos.txt
                    sudo groupdel "$depto_a_deshabilitar"
                    sed -i "s/$depto_a_deshabilitar;ACTIVO/$depto_a_deshabilitar;INACTIVO/g" "$DEPTOS_FILE"
                    echo "Departamento $depto_a_deshabilitar deshabilitado exitosamente."
                    
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
        read -p "Ingrese su opción: " item

        case $item in
            1)
                read -p "Ingrese el nombre de usuario a asignar: " usuario_asignar
                read -p "Ingrese el nombre del departamento: " depto_asignar

                if [id "$nuevo_usuario" >/dev/null 2>&1] && [grep -q "^$depto_a_deshabilitar:" /etc/group]; then
                    # Asignar usuario a departamento y guardar la información en el archivo asignaciones.txt
                    sudo usermod -a -G "$depto_asignar" "$usuario_asignar"
                    echo "$usuario_asignar;$depto_asignar;ASIGNADO" >> "$ASIGNACIONES_FILE"
                    echo "Usuario $usuario_asignar asignado exitosamente al departamento $depto_asignar."
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
}

# Función para generar estadísticas específicas en un archivo de logs
generar_estadisticas() {
    # Ejemplo: Contar la cantidad de mensajes de error en el log
    errores=$(grep "error" "$LOG_FILE" | wc -l)
    echo "Cantidad de errores: $errores"
    
    # Puedes agregar más estadísticas según tus necesidades
}

# Función para gestionar logs
gestionar_logs() {
    read -p "Ingrese la ruta del archivo de logs: " LOG_FILE

    if [ ! -f "$LOG_FILE" ]; then
        echo "El archivo de logs no existe. Verifique la ruta y vuelva a intentar."
        return
    fi

    while true; do
        echo ""
        echo "GESTIÓN DE LOGS"
        echo "Seleccione una opción para gestión de logs:"
        echo "1. Buscar en logs"
        echo "2. Generar estadísticas de logs"
        read -p "Ingrese su opción: " opcion

        case $opcion in
            1)
                read -p "Ingrese el patrón de búsqueda: " patron_busqueda
                # Lógica para buscar en logs con awk, sed, grep
                echo "Resultados de la búsqueda para el patrón '$patron_busqueda':"
                buscar_cadena "$patron_busqueda"
                ;;
            2)
                # Lógica para generar estadísticas de logs con patrones específicos
                generar_estadisticas
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
        read -p "Ingrese su opción: " opcion

        case $opcion in
            1)
                # Agregar lógica para rastrear actividades de memoria
                ;;
            2)
                # Agregar lógica para rastrear actividades de procesos
                ;;
            3)
                # Agregar lógica para rastrear actividades de archivos
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
        read -p "Ingrese su opción: " opcion

        case $opcion in
            1)
                # Agregar lógica para monitorizar estado del sistema
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

menu(){
    while true; do
        echo ""
        echo "Bienvenido al sistema de gestión de empresa"    
        echo "Seleccione una opción para continuar:"
        echo "1. Gestión de usuarios"
        echo "2. Gestión de departamentos"
        echo "3. Usuarios x departamentos"
        echo "4. Gestión de logs"
        echo "5. Gestión de actividades en el sistema"
        echo "6. Gestión del sistema"
        
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

menu