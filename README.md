# qtrade_devops

qtrade 多仓安装、编排与运维入口。不包含业务代码。

各业务仓独立仓库、独立安装；本仓只约定工作区布局，并按依赖顺序把整条链装到目录隔离前缀。

## 工作区布局

将本仓与下列仓并列放置（目录名须一致）：

```text
<workspace>/
├── cpputils
├── qtrade_common
├── qtrade_engine
├── qtrade_service
├── qtrade_strategy
├── qtrade_client
└── qtrade_devops   ← 本仓
```

默认 `<workspace>` 为本仓的上一级目录。若目录不在这层，设置 `QTRADE_WORKSPACE`。

## 全链安装

```shell
./scripts/cmake-build.sh
```

顺序：cpputils → qtrade_common → qtrade_engine → qtrade_service → qtrade_strategy → qtrade_client。

安装前缀：

- cpputils：`/usr/local/cpputils`
- 其余 qtrade 仓：`/usr/local/qtrade`

覆盖方式：`QTRADE_PREFIX_CPPUTILS`、`QTRADE_PREFIX_QTRADE`。

默认 `cmake --build -j1`。受限主机必须保持单进程；其他机器可用 `QTRADE_BUILD_JOBS` 覆盖。

只编某一个仓时，到该仓按它自己的 README 执行 cmake，不要用本脚本传 build 目录。

## 单仓构建

本仓不替代各仓 README。下游仓 configure 时使用：

```text
-DCMAKE_PREFIX_PATH="/usr/local/cpputils;/usr/local/qtrade"
```
