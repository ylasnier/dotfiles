#!/bin/bash
#LD_PRELOAD='/usr/lib/x86_64-linux-gnu/libstdc++.so.6'
#LD_PRELOAD='/usr/lib/x86_64-linux-gnu/dri/i965_dri.so /usr/lib/x86_64-linux-gnu/dri/swrast_dri.so' \
LD_LIBRARY_PATH="/usr/lib/mesa-diverted/x86_64-linux-gnu:/usr/lib/mesa-diverted/i386-linux-gnu/:/home/yl/.steam-lib/:$LD_LIBRARY_PATH" \
STEAM_RUNTIME=0 \
steam

