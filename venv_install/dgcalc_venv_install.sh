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

# Create a virtual environment using system Python
echo "Creating virtual environment in ${ENV_DIR}..."
python3 -m venv "${ENV_DIR}"

# Install module `dgcalc` inside the environment
echo "==> Installing 'dgcalc' into the environment..."
"${PYTHON_BIN}" -m pip install --upgrade pip
"${PYTHON_BIN}" -m pip install dgcalc
