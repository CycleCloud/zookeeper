#!/bin/bash

LOCKER=${1%/}
if [ "$LOCKER" == "" ]; then
   echo "Please supply your locker url."
   echo "Usage: deploy.sh <locker_url> "
   exit -1
fi
echo "Using locker: $LOCKER"

find . -name "*.sh" -exec chmod a+x {} \;
find . -name "*~" -exec rm {} \;
find . -name "*.bak" -exec rm {} \;

echo "Deploying custom cookbooks..."
pushd chef > /dev/null
tar czf site-cookbooks.tgz site-cookbooks
pogo put site-cookbooks.tgz ${LOCKER}/chef/zookeeper/0.1/
popd > /dev/null

echo "Deploying changes to cluster-init..."
pogo sync ./cluster-init/ ${LOCKER}/cluster-init/

echo "Deployment Complete."

