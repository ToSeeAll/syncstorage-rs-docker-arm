#!/bin/bash
# 简单的构建测试脚本

# 检查是否存在.env文件
if [ ! -f .env ]; then
  echo "警告: .env 文件不存在，请从 example.env 创建并配置"
  echo "cp example.env .env"
  exit 1
fi

# 检查必要的环境变量是否设置
if grep -q "^SYNC_URL=$" .env; then
  echo "警告: SYNC_URL 未设置，请在 .env 文件中配置"
  exit 1
fi

if grep -q "^MYSQL_PASSWORD=$" .env; then
  echo "警告: MYSQL_PASSWORD 未设置，请在 .env 文件中配置"
  exit 1
fi

if grep -q "^SYNC_MASTER_SECRET=$" .env; then
  echo "警告: SYNC_MASTER_SECRET 未设置，请在 .env 文件中配置"
  echo "提示: 可以使用 `cat /dev/urandom | base32 | head -c64` 生成随机值"
  exit 1
fi

echo "环境检查通过，您可以使用以下命令构建和运行应用:"
echo "1. docker-compose build  # 构建镜像"
echo "2. docker-compose up -d  # 启动服务"
echo "3. docker-compose logs -f  # 查看日志"