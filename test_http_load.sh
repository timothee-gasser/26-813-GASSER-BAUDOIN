#!/bin/bash

URL="http://10.100.4.2:8080/page1.html"

echo "[INFO] Envoi de nombreuses requetes HTTP sur $URL pendant 30 secondes"

END=$((SECONDS+30))

while [ $SECONDS -lt $END ]; do
    curl -s "$URL" > /dev/null
done

echo "[OK] Test termine"
