#!/bin/bash

LOCKER=$1
if [ "$LOCKER" == "" ]; then
  echo "ERROR: Locker URL required (format: s3://bucket/prefix/)" >&2
  exit -1
fi
LOCKER=${LOCKER%/}

VERSION=$2
BASE_VERSION="zookeeper"
if [ "$VERSION" == "" ]; then
  VERSION=${BASE_VERSION}
fi

CONFIG=$3

find ./ -name "*.class" -exec rm {} \;
find ./ -name "*.pyc" -exec rm {} \;
find ./ -name "*~" -exec rm {} \;
find ./ -name "*.bak" -exec rm {} \;



if which pogo; then
    echo "Using pogo..."
    if [ "$CONFIG" != "" ]; then
        CONFIG="--config=${CONFIG}"
    fi
    S3_CP_CMD="pogo ${CONFIG} sync --delete-removed"
elif which aws; then
    echo "Using aws-cli..."
    if [ "$CONFIG" != "" ]; then
        CONFIG="--profile=${CONFIG}"
    fi
    S3_CP_CMD="aws ${CONFIG} s3 sync"
elif which aws; then
    echo "Using s3cmd..."
    if [ "$CONFIG" != "" ]; then
        CONFIG="-c ${CONFIG}"
    fi
    S3_CP_CMD="s3cmd ${CONFIG} sync --delete-removed"
else
    echo "No S3 transfer tool found!"
    exit -1
fi

# Copies the cookbooks and roles to S3. Note: this overwrites latest so you may be fighting with someone else running this at the same time!
pushd ./chef > /dev/null
for REPO in site-cookbooks roles data_bags; do
    if [ -e  $REPO ]; then
        tar -czf ${REPO}.tgz ${REPO}
        ${S3_CP_CMD} ${REPO}.tgz ${LOCKER}/chef/${VERSION}/${REPO}.tgz
        rm ${REPO}.tgz
    fi
done
popd > /dev/null

# Copyies cluster-init to S3
${S3_CP_CMD} ./cluster-init/${BASE_VERSION}/ ${LOCKER}/cluster-init/${VERSION}
