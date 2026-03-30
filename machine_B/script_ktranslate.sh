#!/bin/bash

URL="https://univ-smb.fr"
DUREE=30
END=$((SECONDS + DUREE))

echo "[INFO] Generation de trafic HTTP vers $URL pendant $DUREE secondes"

while [ $SECONDS -lt $END ]; do
    curl -s "$URL" > /dev/null
done

echo "[OK] Test termine"
