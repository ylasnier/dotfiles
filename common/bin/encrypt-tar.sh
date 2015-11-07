#!/bin/bash
tar cfz - $1 | openssl enc -aes-256-cbc -e > $1.tar.gz

