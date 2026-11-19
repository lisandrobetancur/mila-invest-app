#!/bin/sh
# Corre todas las sondas: primero ON (deja coordenadas y capturas), después OFF.
# 5 repeticiones por caso (repeatEach del config). No reintenta nada.
cd "$(dirname "$0")"
mkdir -p results
PW_JSON=results/run-on.json  npx playwright test --project=on  --output=test-results/on  > results/run-on.log 2>&1
echo "on exit=$?" >> results/run-on.log
PW_JSON=results/run-off.json npx playwright test --project=off --output=test-results/off > results/run-off.log 2>&1
echo "off exit=$?" >> results/run-off.log
