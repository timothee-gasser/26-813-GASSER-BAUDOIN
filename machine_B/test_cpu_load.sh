#!/bin/bash

echo "[INFO] Generation d'une charge CPU pendant 30 secondes"

yes > /dev/null &
PID1=$!
yes > /dev/null &
PID2=$!

sleep 30

kill $PID1 $PID2

echo "[OK] Charge CPU arretee"
