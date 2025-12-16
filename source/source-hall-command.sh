#!/bin/bash

export XU_BIN_PATH=${HOME}"/.hall-command/command"
if [ -d "$XU_BIN_PATH" ] ; then
   export PATH="$XU_BIN_PATH:$PATH"
fi
