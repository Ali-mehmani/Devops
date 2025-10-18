#!/bin/bash

#**The Color Section**

BLACK="\033[48;5;16m         "
WHITE="\033[48;5;15m         "
RESET="\033[0m"

LINES=4

#**Colem And Row Section**

for row in {1..8}; do
        for i in $(seq 1 $LINES);do
        for col in {1..8}; do
                if (( (row + col) % 2 == 0 )); then
        echo -n -e "${WHITE}" #if th sum of row even,its white
else
        echo -n -e "${BLACK}"
                fi
        done
        echo -e "${RESET}"
done
done
