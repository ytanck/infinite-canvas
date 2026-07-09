#!/usr/bin/env bash
# 本机构建前端 + 打包 docker 镜像。
# 绕开容器内 bun install——适用于 Docker 容器无法访问 npm 源的网络受限环境
# （本机用已装好的 web/node_modules 跑 npm run build，再用 Dockerfile.prebuilt 把 dist 打进 nginx）。
#
# 用法:
#   ./build-image.sh                     # 默认 tag: infinite-canvas:dev-<VERSION>
#   ./build-image.sh my-image:tag        # 自定义 tag
#
# 前置: 本机已装 node，且 web/node_modules 存在（首次需先 cd web && npm install）。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VERSION="$(cat VERSION 2>/dev/null || echo local)"
TAG="${1:-infinite-canvas:dev-$VERSION}"

echo "==> [1/2] 构建前端 (web: npm run build)"
cd "$SCRIPT_DIR/web"
npm run build

echo "==> [2/2] 打包 docker 镜像: $TAG"
cd "$SCRIPT_DIR"
docker build -t "$TAG" -f Dockerfile.prebuilt .

echo "==> 完成"
docker images "$TAG" --format "  {{.Repository}}:{{.Tag}}  {{.Size}}  {{.CreatedAt}}"
