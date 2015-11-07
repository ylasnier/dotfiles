#!/bin/bash
# Fix all broken links after renaming a dir in symlinks path
# Here: find every links to /home/ylasnier/<relativepath> files in /home/yl dir
# and replace them by /home/yl/<relativepath>
find /home/yl -lname '/home/ylasnier/*' -exec sh -c 'L=$(readlink $0); ln -snf "/home/yl/${L##/home/ylasnier/}" "$0"' {} \;

