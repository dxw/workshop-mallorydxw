#!/bin/sh
set -xe

BASE=/workbench/local
SRC=${BASE}/src
SHARE=${BASE}/share
BIN=${BASE}/bin
LIB=${BASE}/lib

rm -rf ${BASE}
mkdir -p ${SRC} ${SHARE} ${BIN} ${LIB}

# pluginscan
git -C ${SRC} clone --quiet git@git.govpress.com:dxw/pluginscan.git && \
  cd ${SRC}/pluginscan && \
  gem build pluginscan.gemspec && \
  GEM_HOME=/workbench/local/ruby gem install pluginscan-*.gem && \
  cd -

# log-tail
git -C ${SRC} clone --quiet git@git.govpress.com:dxw/log-tail && \
  git -C ${SRC} clone --quiet git@git.govpress.com:dxw/log-tail-settings-generator && \
  composer --working-dir=${SRC}/log-tail install && \
  ln -s ../log-tail-settings-generator/settings.php ${SRC}/log-tail/ && \
  ln -s ${SRC}/log-tail/bin/log-tail ${BIN}/

# dalmatian-tools
git -C ${SRC} clone --quiet git@github.com:dxw/dalmatian-tools.git && \
  ln -s ${SRC}/dalmatian-tools/bin/* ${BIN}/
