#!/bin/sh

export RUNNER_ALLOW_RUNASROOT="0"

RUNNER_LABELS="container,$LABELS"

if [ "$GITHUB_OBJECT" = "xxx" ]; then
    echo "Missing GitHub object name"
    exit 1
fi;

if [ "$ACCESS_TOKEN" = "xxx" ]; then
    echo "Missing access token"
    exit 1
fi;

if [ -z "$LABELS" ]; then
    RUNNER_LABELS="container"
else
    RUNNER_LABELS="container,$LABELS"
fi;

if echo "$GITHUB_OBJECT" | grep -q "/" ; then
    REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" "https://api.github.com/repos/${GITHUB_OBJECT}/actions/runners/registration-token" | jq .token --raw-output)
else
    REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" "https://api.github.com/orgs/${GITHUB_OBJECT}/actions/runners/registration-token" | jq .token --raw-output)
fi;

cd /usr/bin/actions-runner || exit 3

echo "$REG_TOKEN" > token.txt

./config.sh --url "https://github.com/${GITHUB_OBJECT}" --token "$REG_TOKEN"  --labels "$RUNNER_LABELS"

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token "$(cat ./token.txt)"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!