# 多阶段构建 Dockerfile for PNG to ICNS converter

# 构建阶段
FROM rust:1.81-slim-bookworm AS builder

# 安装必要的系统依赖
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 复制 Cargo 文件以利用 Docker 缓存
COPY Cargo.toml Cargo.lock* ./

# 创建虚拟的 main.rs 来构建依赖
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release && rm -rf src

# 复制实际源代码
COPY src ./src

# 构建应用程序
RUN cargo build --release

# 运行阶段 - 使用最小化镜像
FROM debian:bookworm-slim

# 安装运行时依赖
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 创建非 root 用户
RUN useradd -m -u 1000 converter

# 设置工作目录
WORKDIR /app

# 从构建阶段复制二进制文件
COPY --from=builder /app/target/release/png2icns ./png2icns

# 创建输入输出目录
RUN mkdir -p /app/input /app/output

# 设置权限 - 让所有用户都能访问
RUN chmod +x ./png2icns && \
    chmod 755 /app/input && \
    chmod 777 /app/output

# 不切换用户，保持 root 权限以避免 CI 环境中的权限问题
# 在生产环境中可以通过 --user 参数指定用户

# 设置入口点
ENTRYPOINT ["./png2icns"]

# 默认显示帮助
CMD ["--help"]