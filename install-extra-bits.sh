#!/bin/sh
set -xe

rm -rf /workbench/local

SRC=/workbench/local/src
SHARE=/workbench/local/share
BIN=/workbench/local/bin
LIB=/workbench/local/lib
mkdir -p ${SRC} ${SHARE} ${BIN} ${LIB}

# pluginscan
gem sources -a https://gems.dxw.net/ && \
  GEM_HOME=/workbench/local/ruby gem install rake pluginscan

# log-tail
git -C ${SRC} clone --quiet git@git.govpress.com:dxw/log-tail && \
  git -C ${SRC} clone --quiet git@git.govpress.com:dxw/log-tail-settings-generator && \
  composer --working-dir=${SRC}/log-tail install && \
  ln -s ../log-tail-settings-generator/settings.php ${SRC}/log-tail/ && \
  ln -s ${SRC}/log-tail/bin/log-tail ${BIN}/
