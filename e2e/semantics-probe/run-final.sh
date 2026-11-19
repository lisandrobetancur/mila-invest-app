#!/bin/sh
# Tanda final, con la máquina libre: repite los casos sensibles al tiempo
# (A1, A3, A4, A5, B9, B10, F6) y completa D2b. Resultados aparte, en results/final/.
cd "$(dirname "$0")"
mkdir -p results/final
export PROBE_RESULTS=results/final
G='A1 login|A3 búsqueda|A4 depósito|A5 ticket|B9 |B10'
for m in on off; do
  PW_JSON=results/final/run-$m.json npx playwright test a-campos b-scroll -g "$G" --project=$m --output=test-results/final-$m > results/final/run-$m.log 2>&1
  echo "$m exit=$?" >> results/final/run-$m.log
  PW_JSON=results/final/run-pend-$m.json npx playwright test --config playwright.pendientes.config.ts -g "F6|D2b" --project=$m --output=test-results/final-pend-$m > results/final/run-pend-$m.log 2>&1
  echo "$m exit=$?" >> results/final/run-pend-$m.log
done
