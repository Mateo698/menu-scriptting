#!/bin/bash

# Definir archivos para cada módulo
USUARIOS_FILE="usuarios.txt"
DEPTOS_FILE="deptos.txt"
ASIGNACIONES_FILE="asignaciones.txt"
LOGS_FILE="logs.txt"
ACTIVIDADES_FILE="actividades.txt"
SISTEMA_FILE="sistema.txt"

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
                read -p "Ingrese el nombre de usuario a modificar: " usuario_a_modificar
                # Agregar lógica para modificar usuario
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
                read -p "Ingrese el nombre del departamento a modificar: " depto_a_modificar
                # Agregar lógica para modificar departamento
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
    echo ""
    echo "GESTIÓN DE USUARIOS A DEPARTAMENTOS"
    echo "Seleccione una opción para gestión de asignaciones:"
    echo "1. Asignar usuario a departamento"
    echo "2. Desasignar usuario de departamento"
    read -p "Ingrese su opción: " opcion

    case $opcion in
        1)
            read -p "Ingrese el nombre de usuario a asignar: " usuario_asignar
            read -p "Ingrese el nombre del departamento: " depto_asignar
            # Agregar lógica para asignar usuario a departamento
            echo "Asignación: $usuario_asignar -> $depto_asignar" >> $ASIGNACIONES_FILE
            ;;
        2)
            read -p "Ingrese el nombre de usuario a desasignar: " usuario_desasignar
            read -p "Ingrese el nombre del departamento: " depto_desasignar
            # Agregar lógica para desasignar usuario de departamento
            ;;
        *)
            echo "Opción no válida"
            ;;
    esac
}

# Función para gestionar logs
gestionar_logs() {
    echo ""
    echo "GESTIÓN DE LOGS"
    echo "Seleccione una opción para gestión de logs:"
    echo "1. Buscar en logs"
    echo "2. Generar estadísticas de logs"
    read -p "Ingrese su opción: " opcion

    case $opcion in
        1)
            read -p "Ingrese el patrón de búsqueda: " patron_busqueda
            # Agregar lógica para buscar en logs con awk, sed, grep
            ;;
        2)
            # Agregar lógica para generar estadísticas de logs con patrones específicos
            ;;
        *)
            echo "Opción no válida"
            ;;
    esac
}

# Función para gestionar actividades en el sistema
gestionar_actividades() {
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
        *)
            echo "Opción no válida"
            ;;
    esac
}

# Función para gestionar el sistema
gestionar_sistema() {
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
        *)
            echo "Opción no válida"
            ;;
    esac
}

menu(){
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
        
}

menu