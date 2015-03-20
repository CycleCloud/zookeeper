#!/bin/bash

LOCKER=${1%/}
if [ "$LOCKER" == "" ]; then
   echo "Please supply your locker url."
   echo "Usage: deploy.sh <locker_url> "
   exit -1
fi
echo "Using locker: $LOCKER"

EXAMPLE=zookeeper
VERSION=0.1

find . -name "*.sh" -exec chmod a+x {} \;
find . -name "*~" -exec rm {} \;
find . -name "*.bak" -exec rm {} \;

echo "Deploying custom cookbooks..."
pushd chef > /dev/null
if [ -d site-cookbooks ]; then
    tar czf site-cookbooks.tgz site-cookbooks
    pogo put site-cookbooks.tgz ${LOCKER}/chef/${EXAMPLE}/${VERSION}/
fi
if [ -d roles ]; then
    tar czf roles.tgz roles
    pogo put roles.tgz ${LOCKER}/chef/${EXAMPLE}/${VERSION}/
fi
if [ -d databags ]; then
    tar czf databags.tgz databags
    pogo put databags.tgz ${LOCKER}/chef/${EXAMPLE}/${VERSION}/
fi
popd > /dev/null

echo "Deploying changes to cluster-init..."
pogo sync ./cluster-init/ ${LOCKER}/cluster-init/

echo "Deployment Complete."

