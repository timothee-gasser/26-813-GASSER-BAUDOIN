#!/bin/bash

PAGE="/home/etudiant/web-monitoring/site/page1.html"
BACKUP="/home/etudiant/web-monitoring/site/page1.html.bak"

restore_page() {
    if [ -f "$BACKUP" ]; then
        mv "$BACKUP" "$PAGE"
        echo "[OK] page1.html a ete restauree"
    fi
}

trap restore_page EXIT

if [ -f "$PAGE" ]; then
    mv "$PAGE" "$BACKUP"
    echo "[INFO] page1.html indisponible pendant 30 secondes"
else
    echo "[ERREUR] page1.html introuvable"
    exit 1
fi

sleep 30
