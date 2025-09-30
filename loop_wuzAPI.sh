#!/bin/bash

cd ~/wuzapi || exit 1

MAX_RETRIES=5
FAILED_ATTEMPTS=0

# Verificar se está executando wuzAPI
if pgrep -f "./wuzapi" > /dev/null; then
  exit 0
fi

while true; do
  ./wuzapi -skipmedia -logtype json
  EXIT_CODE=$?

  if [ $EXIT_CODE -ne 0 ]; then
    ((FAILED_ATTEMPTS++))

    if [ $FAILED_ATTEMPTS -ge $MAX_RETRIES ]; then
      exit 1
    fi

    sleep 10
  else
    FAILED_ATTEMPTS=0
    sleep 600
  fi
done
