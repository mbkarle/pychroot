#!/bin/bash

# Check if 'which python' returns a path
python_path=$(which python)
if [ -z "$python_path" ]; then
  echo "Error: Python interpreter not found in PATH. Consider using a virtual environment."
  exit 1
else
  echo "Python interpreter found at: $python_path"
fi
