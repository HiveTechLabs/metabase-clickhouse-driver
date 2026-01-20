#!/bin/bash
set -e

METABASE_VERSION="${1:-v0.53.18}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Building ClickHouse driver against Metabase ${METABASE_VERSION}..."

docker run --rm \
  -v "${SCRIPT_DIR}:/driver:ro" \
  -v "${SCRIPT_DIR}/target:/output" \
  eclipse-temurin:21-jdk \
  bash -c "
    set -e

    echo '==> Installing dependencies...'
    apt-get update -qq && apt-get install -y -qq curl git > /dev/null

    echo '==> Installing Clojure CLI...'
    curl -sO https://download.clojure.org/install/linux-install-1.11.1.1182.sh
    bash linux-install-1.11.1.1182.sh > /dev/null

    echo '==> Cloning Metabase ${METABASE_VERSION}...'
    git clone --depth 1 --branch ${METABASE_VERSION} https://github.com/metabase/metabase.git /build
    cd /build

    echo '==> Copying driver source...'
    cp -r /driver modules/drivers/clickhouse
    echo '{:deps {metabase/clickhouse {:local/root \"clickhouse\" }}}' > modules/drivers/deps.edn

    echo '==> Building driver JAR...'
    bin/build-driver.sh clickhouse

    echo '==> Copying JAR to output...'
    mkdir -p /output
    cp resources/modules/clickhouse.metabase-driver.jar /output/

    echo '==> Done!'
  "

echo ""
echo "Driver JAR built successfully:"
ls -lah "${SCRIPT_DIR}/target/clickhouse.metabase-driver.jar"
