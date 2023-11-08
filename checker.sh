#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Uso: $0 archivo_de_ips"
    exit 1
fi

ips_file="$1"

if [ ! -f "$ips_file" ]; then
    echo "El archivo $ips_file no existe."
    exit 1
fi

while IFS= read -r ip; do
    result="IP: $ip -"
    
    # Verifica el puerto 80
    if timeout 2 bash -c "echo >/dev/tcp/$ip/80" &>/dev/null; then
        result="$result TCP/80 open -"
    elif [ $? -eq 124 ]; then
        result="$result TCP/80 timeout -"
    else
        result="$result TCP/80 closed -"
    fi
    
    # Verifica el puerto 443
    if timeout 2 bash -c "echo >/dev/tcp/$ip/443" &>/dev/null; then
        result="$result TCP/443 open"
    elif [ $? -eq 124 ]; then
        result="$result TCP/443 timeout"
    else
        result="$result TCP/443 closed"
    fi
    
    echo "$result"
done < "$ips_file"

