#!/bin/bash

oid="1.3.6.1.2.1.31.1.1.1.10.2"
agent_ip="10.100.4.253"
community="123test123"
filename="throughput_int3.txt"

# Taille max du compteur utilisé
# ici compteur 64 bits
max_counter=18446744073709551616

value=$(snmpget -v2c -Oq -c ${community} ${agent_ip} ${oid} | cut -d " " -f 2)
date=$(date +%s)

# Première exécution : fichier absent ou vide
if [ ! -f "${filename}" ] || [ ! -s "${filename}" ]; then
    echo "${date};${value};0" >> "${filename}"
    exit 0
fi

lastline=$(tail -n 1 "${filename}")
olddate=$(echo "${lastline}" | cut -d ";" -f 1)
oldvalue=$(echo "${lastline}" | cut -d ";" -f 2)

delta_temps=$((date - olddate))

# Sécurité
if [ "${delta_temps}" -le 0 ]; then
    exit 1
fi

# Cas normal
if [ "${value}" -ge "${oldvalue}" ]; then
    delta_octets=$((value - oldvalue))
else
    # Rebouclage du compteur
    delta_octets=$(((max_counter - oldvalue) + value))
fi

debit=$((delta_octets * 8 / delta_temps))

echo "${date};${value};${debit}" >> "${filename}"
