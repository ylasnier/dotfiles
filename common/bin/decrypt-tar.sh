#!/bin/bash
openssl enc -in $1 -aes-256-cbc -d | tar -zxvf -

