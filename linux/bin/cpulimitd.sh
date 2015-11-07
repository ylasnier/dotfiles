#!/bin/bash

# ln -s cpulimitd.service /etc/init.d/cpulimitd.service

[Unit]
Description=Limit Opera CPU usage

[Service]
Type=oneshot
ExecStart=cpulimit -e opera -l 90 -b
ExecStop=cpulimit -e opera -l 100 -b
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target

