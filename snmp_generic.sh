#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <fichier> <OID> <IP_agent> <community>"
    exit 1
fi

filename="$1"
oid="$2"
agent_ip="$3"
community="$4"

max_counter=18446744073709551616  # compteur 64 bits

value=$(snmpget -v2c -Oq -c "${community}" "${agent_ip}" "${oid}" | cut -d " " -f 2)
date=$(date +%s)

# Conversion compteur en kB
value_kb=$((value / 1024))

# Première exécution
if [ ! -f "${filename}" ] || [ ! -s "${filename}" ]; then
    echo "${date};${value_kb} kB;0 kbit/s" >> "${filename}"
    exit 0
fi

lastline=$(tail -n 1 "${filename}")
olddate=$(echo "${lastline}" | cut -d ";" -f 1)
oldvalue_kb=$(echo "${lastline}" | cut -d ";" -f 2 | cut -d " " -f 1)

# Reconvertir en octets pour le calcul
oldvalue=$((oldvalue_kb * 1024))

delta_temps=$((date - olddate))

if [ "${delta_temps}" -le 0 ]; then
    exit 1
fi

# Gestion rebouclage
if [ "${value}" -ge "${oldvalue}" ]; then
    delta_octets=$((value - oldvalue))
else
    delta_octets=$(((max_counter - oldvalue) + value))
fi

# Débit en kbit/s
debit_kbps=$((delta_octets * 8 / delta_temps / 1000))

echo "${date};${value_kb} kB;${debit_kbps} kbit/s" >> "${filename}"
