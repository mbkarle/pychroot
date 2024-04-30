#!/bin/bash

###
# Creates a chroot jail directory at $1
# Determines locations of dependencies of key binaries:
# - Python for py app
# - Bash, ls, for inspecting chroot jail manually in cli
# - (add more as desired)
# Copies entire *parent directories* of dependencies
# This is important because Python modules may add more dependencies
# from these locations, so we conservatively copy more than we need

set -e

# Check if a directory argument is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <path/to/jail>"
  exit 1
fi

# create jail directory with bin subdir
mkdir -p "$1/bin"

# all binaries to copy over, along with their dependencies
# add more as desired
binaries=("python" "bash" "ls")

# accumulate dependencies for all binaries
all_deps=""

for binary in "${binaries[@]}"; do
  all_deps+=$(ldd "$(which $binary)")
  cp -v "$(which $binary)" "$1/bin/$binary"
done

# determine directories for dependencies
dep_dirs=$(echo "$all_deps" | awk '{print $(NF-1)}' | xargs dirname)
# de-dup dependency directories
uniq_dep_dirs=$(echo "$dep_dirs" | sort | uniq)

# for each directory containing dependencies, copy whole directory into chroot jail
while IFS= read -r dep_dir; do
  # Check if the dep directory is valid library
  if [ -n "$dep_dir" ] && [ "${dep_dir:0:1}" = "/" ]; then
    # get parent dirname
    parent_dir="${dep_dir%/*}"

    echo "'$dep_dir' -> '$1$dep_dir'"
    
    # make hierarchy as needed
    mkdir -p "$1$parent_dir"

    # Copy all to the dependencies directory
    cp -r "$dep_dir/" "$1$parent_dir/"
  fi
done <<< "$uniq_dep_dirs"
