#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

ENV_DIR="./dgcalc_venv"
# Detect OS platform to handle Windows/POSIX path differences gracefully
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    PYTHON_BIN="${ENV_DIR}/Scripts/python.exe"
else
    PYTHON_BIN="${ENV_DIR}/bin/python"
fi

"${PYTHON_BIN}" -m dgcalc "$@"
