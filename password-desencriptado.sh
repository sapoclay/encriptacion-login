#!/bin/bash

# Crear un menú bash de usuario que permita añadir un usuario y su contraseña encriptada en un archivo .txt. 
# Debe permitir loguearse utilizando los usuarios y las contraseñas que se guarden en el archivo .txt
# En el menú de usuario debe permitir ver solo los usuarios guardados en el archivo .txt
# También debe aparecer en el menú la opción de mostrar la contraseña de un usuario indicado por teclado, 
# además se debe poder mostrar la contraseña del usuario guardado en el archivo txt desencriptada utilizando una contraseña maestra que será 12345

# Archivo donde se guardarán los usuarios y las contraseñas encriptadas
archivo_usuarios="usuarios.txt"

# Crear el archivo en el que guardar los usuarios si no existe
if [ ! -f "$archivo_usuarios" ]; then
    touch "$archivo_usuarios"
fi

# Contraseña maestra para desencriptar las contraseñas
contrasena_maestra="12345"

# Función para encriptar una contraseña
encriptar_contrasena() {
    contrasena="$1"
    contrasena_encriptada=$(echo "$contrasena" | openssl enc -aes-256-cbc -a -salt -pbkdf2 -pass pass:"$contrasena_maestra")
    echo "$contrasena_encriptada"
}

# Función para desencriptar una contraseña
desencriptar_contrasena() {
    contrasena_encriptada="$1"
    contrasena=$(echo "$contrasena_encriptada" | openssl enc -d -aes-256-cbc -a -salt -pbkdf2 -pass pass:"$contrasena_maestra" 2>/dev/null)
    echo "$contrasena"
}

# Función para añadir un usuario y contraseña encriptada al archivo
agregar_usuario() {
    clear
    echo "----------------------------"
    echo "Añadir el nombre de usuario:"
    read usuario
    echo "Añadir la contraseña:"
    read -s contrasena
    contrasena_encriptada=$(encriptar_contrasena "$contrasena")
    echo "$usuario:$contrasena_encriptada" >> "$archivo_usuarios"
    echo "-----------------------------------"
    echo "Usuario $usuario añadido con éxito."
    read -p "Pulsa Intro para continuar..."
}

# Función para iniciar sesión
iniciar_sesion() {
    clear
    echo "-----------------------------"
    echo "Escribe el nombre de usuario:"
    read usuario
    echo "Escribe la contraseña:"
    read -s contrasena
    usuario_encontrado=$(grep "^$usuario:" "$archivo_usuarios")
    if [ -n "$usuario_encontrado" ]; then
        contrasena_encriptada=$(echo "$usuario_encontrado" | cut -d ":" -f 2)
        contrasena_desencriptada=$(desencriptar_contrasena "$contrasena_encriptada")
        if [ "$contrasena" = "$contrasena_desencriptada" ]; then
            clear
            fecha=$(date +"%d-%m-%Y %H:%M:%S") # Fecha y hora del sistema
            echo ""
            echo "==========================================="
            echo "¡Bienvenid@, te has logueado como $usuario!"
            echo "Fecha y hora: $fecha"
            echo "==========================================="
            echo ""
            read -p "Pulsa Intro para continuar..."
            exit 0
        else
            echo "Contraseña incorrecta."
            read -p "Pulsa Intro para continuar..."
        fi
    else
        echo "Usuario no encontrado."
        read -p "Pulsa Intro para continuar..."
    fi
}

# Función para mostrar la lista de usuarios
mostrar_usuarios() {
    clear
    echo "Lista de usuarios disponibles:"
    cut -d ":" -f 1 "$archivo_usuarios"
    read -p "Pulsa Intro para continuar..."
}

# Función para mostrar la contraseña de un usuario
mostrar_contrasena() {
    clear 
    echo "------------------------------"
    echo "Escribe el nombre de usuario: "
    read usuario
    echo "Escribe la contraseña maestra: "
    read -s contrasena
    if [ "$contrasena" = "$contrasena_maestra" ]; then
	    usuario_encontrado=$(grep "^$usuario:" "$archivo_usuarios")
	    if [ -n "$usuario_encontrado" ]; then
		contrasena_encriptada=$(echo "$usuario_encontrado" | cut -d ":" -f 2)
		contrasena_desencriptada=$(desencriptar_contrasena "$contrasena_encriptada")
		echo "La contraseña $contrasena_encriptada de $usuario desencriptada es: $contrasena_desencriptada"
		read -p "Pulsa Intro para continuar..."
	    else
		echo "Usuario no encontrado."
		read -p "Pulsa Intro para continuar..."
	    fi
    else
    	echo "La contraseña maestra es incorrecta"
    	read -p "Pulsa Intro para continuar..."
    fi
}

# Menú principal a mostrar
while true; do
    clear
    echo "Menú de Usuario"
    echo "---------------"
    echo "1. Añadir Usuario"
    echo "2. Iniciar Sesión"
    echo "3. Mostrar Usuarios"
    echo "4. Mostrar Contraseña de Usuario maestra"
    echo "5. Salir"
    echo "----------------------------------------"
    echo "Escribe una opción"
    read opcion
    echo ""
    case $opcion in
        1) agregar_usuario ;;
        2) iniciar_sesion ;;
        3) mostrar_usuarios ;;
        4) mostrar_contrasena ;;
        5) echo "Saliendo..."; exit 0 ;;
        *) echo "Opción inválida." ;;
    esac
done

