#!/bin/bash

oid="1.3.6.1.2.1.31.1.1.1.10.2"
agent_ip="10.100.4.253"
community="123test123"
filename="throughput_int3.txt"

value=$(snmpget -v2c -Oq -c ${community} ${agent_ip} ${oid} | cut -d " " -f 2)
date=$(date +%s)

if [ ! -f "${filename}" ] || [ ! -s "${filename}" ]; then
    echo "${date};${value};0" >> "${filename}"
    exit 0
fi

lastline=$(tail -n 1 "${filename}")
olddate=$(echo "${lastline}" | cut -d ";" -f 1)
oldvalue=$(echo "${lastline}" | cut -d ";" -f 2)

delta_octets=$((value - oldvalue))
delta_temps=$((date - olddate))
debit=$((delta_octets * 8 / delta_temps))

echo "${date};${value};${debit}" >> "${filename}"
