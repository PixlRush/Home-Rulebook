#!/bin/bash

BRANCH=$(git branch --show-current)
TAG=$(git describe --abbrev=0 HEAD)
STEPS=$(git rev-list $TAG..HEAD --count)

LWTAG=$(git describe --tags --abbrev=0 HEAD)
LWSTEPS=$(git rev-list $LWTAG..HEAD --count)

if [[ $TAG != $LWTAG ]]
then
        echo "$BRANCH: $TAG-$((STEPS + 1)) $LWTAG-$((LWSTEPS + 1))"
else
        echo "$BRANCH: $TAG-$((STEPS + 1))"
fi