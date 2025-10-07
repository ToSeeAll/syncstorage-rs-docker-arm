# 使用多阶段构建和官方Rust镜像的多架构支持
FROM --platform=${BUILDPLATFORM} rust:latest AS builder

ARG GIT_COMMIT=1dc421474df2a4ee973d529534cd0eb7189d58ce
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# 创建工作目录
WORKDIR /app

# 安装必要的依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-virtualenv \
    python3-pip \
    python3-dev \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# 克隆syncstorage-rs并构建
RUN git clone https://github.com/mozilla-services/syncstorage-rs ./syncstorage-rs \
    && cd /app/syncstorage-rs \
    && git checkout ${GIT_COMMIT}

# 构建应用
RUN cd /app/syncstorage-rs \
    && cargo install --path ./syncserver --no-default-features --features=syncstorage-db/mysql --locked \
    && cargo install diesel_cli --no-default-features --features 'mysql' --locked \
    && cargo clean

# 设置Python虚拟环境
RUN cd /app/syncstorage-rs \
    && virtualenv venv \
    && /app/syncstorage-rs/venv/bin/pip install -r requirements.txt \
    && /app/syncstorage-rs/venv/bin/pip install -r tools/tokenserver/requirements.txt \
    && /app/syncstorage-rs/venv/bin/pip install pyopenssl==22.1.0

# 创建最终镜像，使用更小的基础镜像
FROM --platform=${TARGETPLATFORM} debian:bullseye-slim

# 安装运行时依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-venv \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# 创建必要的目录
RUN mkdir -p /app /config /app/syncstorage-mysql/migrations /app/tokenserver-db/migrations
WORKDIR /app

# 从构建阶段复制必要的文件
COPY --from=builder /app/syncstorage-rs/venv /app/venv
COPY --from=builder /app/syncstorage-rs/syncstorage-mysql/migrations /app/syncstorage-mysql/migrations
COPY --from=builder /app/syncstorage-rs/tokenserver-db/migrations /app/tokenserver-db/migrations
COPY --from=builder /usr/local/cargo/bin/syncserver /usr/local/bin/
COPY --from=builder /usr/local/cargo/bin/diesel /usr/local/bin/

# 复制entrypoint脚本并设置权限
COPY --chmod=755 entrypoint.sh /
ENTRYPOINT /entrypoint.sh
