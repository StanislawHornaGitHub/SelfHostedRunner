#!/bin/sh

export RUNNER_ALLOW_RUNASROOT="0"

./config.sh remove --token "$(cat ./token.txt)"