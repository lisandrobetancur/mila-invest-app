#!/bin/sh
# Sondas E (X, tabs, atrás) y F (issues de Flutter): 5 repeticiones, ON y después OFF.
cd "$(dirname "$0")"
PW_JSON=results/run-ef-on.json  npx playwright test --config playwright.pendientes.config.ts --project=on  --output=test-results/ef-on  > results/run-ef-on.log 2>&1
echo "on exit=$?" >> results/run-ef-on.log
PW_JSON=results/run-ef-off.json npx playwright test --config playwright.pendientes.config.ts --project=off --output=test-results/ef-off > results/run-ef-off.log 2>&1
echo "off exit=$?" >> results/run-ef-off.log
