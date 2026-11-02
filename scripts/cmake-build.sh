#!/usr/bin/env bash
# 按依赖顺序构建并安装 qtrade 全链；默认单进程编译。
set -euo pipefail

readonly SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
readonly WORKSPACE="${QTRADE_WORKSPACE:-$(cd "${REPO_ROOT}/.." && pwd)}"
readonly PREFIX_CPPUTILS="${QTRADE_PREFIX_CPPUTILS:-/usr/local/cpputils}"
readonly PREFIX_QTRADE="${QTRADE_PREFIX_QTRADE:-/usr/local/qtrade}"
readonly JOBS="${QTRADE_BUILD_JOBS:-1}"

require_dir() {
  local dir=$1
  if [[ ! -d "${dir}" ]]; then
    echo "缺少并列目录: ${dir}" >&2
    echo "请将各仓与 qtrade_devops 放在同一工作区，或设置 QTRADE_WORKSPACE。" >&2
    exit 1
  fi
}

build_and_install() {
  local project_dir=$1
  local install_prefix=$2
  local cmake_prefix_path=$3

  require_dir "${project_dir}"
  cmake -S "${project_dir}" -B "${project_dir}/build" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${install_prefix}" \
    -DCMAKE_PREFIX_PATH="${cmake_prefix_path}"
  cmake --build "${project_dir}/build" -j"${JOBS}"
  sudo cmake --install "${project_dir}/build"
}

echo "工作区: ${WORKSPACE}"
echo "并行度: ${JOBS}"

# 1. 基础工具库
build_and_install "${WORKSPACE}/cpputils" "${PREFIX_CPPUTILS}" ""
echo "${PREFIX_CPPUTILS}/lib" | sudo tee /etc/ld.so.conf.d/cpputils.conf >/dev/null
sudo ldconfig

# 2. 跨仓基础库
build_and_install "${WORKSPACE}/qtrade_common" "${PREFIX_QTRADE}" "${PREFIX_CPPUTILS}"

# 3. 核心交易引擎
build_and_install "${WORKSPACE}/qtrade_engine" "${PREFIX_QTRADE}" "${PREFIX_CPPUTILS};${PREFIX_QTRADE}"

# 4. 支撑服务
build_and_install "${WORKSPACE}/qtrade_service" "${PREFIX_QTRADE}" "${PREFIX_CPPUTILS};${PREFIX_QTRADE}"

# 5. 策略插件
build_and_install "${WORKSPACE}/qtrade_strategy" "${PREFIX_QTRADE}" "${PREFIX_CPPUTILS};${PREFIX_QTRADE}"

# 6. 客户端进程
build_and_install "${WORKSPACE}/qtrade_client" "${PREFIX_QTRADE}" "${PREFIX_CPPUTILS};${PREFIX_QTRADE}"
