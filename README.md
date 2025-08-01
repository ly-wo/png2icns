# 基于Kiro Claude Sonnet 4.0 自动生成

需求：<b>*使用rust或者golang编写一个实现png转icns的程序。要求：基于docker容器编译。*</b>

# PNG to ICNS Converter 🖼️
[![GitHub stars](https://img.shields.io/github/stars/ly-wo/png2icns)](https://img.shields.io/github/stars/ly-wo/png2icns)
[![GitHub forks](https://img.shields.io/github/forks/ly-wo/png2icns)](https://img.shields.io/github/forks/ly-wo/png2icns)

[![Last Commit](https://img.shields.io/github/last-commit/ly-wo/png2icns)](https://img.shields.io/github/last-commit/ly-wo/png2icns)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)


[![CI](https://github.com/ly-wo/png2icns/actions/workflows/ci.yml/badge.svg)](https://github.com/ly-wo/png2icns/actions/workflows/ci.yml)
[![Build and Release](https://github.com/ly-wo/png2icns/actions/workflows/build-and-release.yml/badge.svg)](https://github.com/ly-wo/png2icns/actions/workflows/build-and-release.yml)
[![Docker Publish](https://github.com/ly-wo/png2icns/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/ly-wo/png2icns/actions/workflows/docker-publish.yml)

一个基于 Docker 容器编译的高性能 PNG 转 ICNS 工具，使用 Rust 编写。

## ✨ 功能特性

- 🎯 **PNG 转 ICNS**: 将 PNG 图像转换为 macOS ICNS 图标格式
- 📏 **多尺寸支持**: 自动生成多个尺寸的图标 (16x16 到 512x512)
- 🎨 **质量预设**: 内置基础、标准、完整三种质量预设
- 🔧 **自定义尺寸**: 支持用户自定义图标尺寸
- 🐳 **Docker 化**: 完全基于 Docker 容器编译和运行
- 🚀 **高性能**: 使用 Rust 编写，性能优异
- 📦 **零依赖**: 容器化部署，无需本地安装 Rust

## 🚀 快速开始

### 方式一：使用预构建的 Docker 镜像 (推荐)

```bash
# 拉取最新镜像
docker pull ghcr.io/ly-wo/png2icns:latest

# 直接使用
docker run --rm \
  -v $(pwd)/input:/app/input \
  -v $(pwd)/output:/app/output \
  ghcr.io/ly-wo/png2icns:latest \
  -i /app/input/your-icon.png \
  -o /app/output/your-icon.icns
```

### 方式二：下载预编译二进制文件

从 [Releases](https://github.com/ly-wo/png2icns/releases) 页面下载适合你平台的二进制文件：

```bash
# Linux x86_64
wget https://github.com/ly-wo/png2icns/releases/latest/download/png2icns-linux-x86_64.tar.gz
tar -xzf png2icns-linux-x86_64.tar.gz
chmod +x png2icns-linux-x86_64
sudo mv png2icns-linux-x86_64 /usr/local/bin/png2icns

# macOS (Intel)
wget https://github.com/ly-wo/png2icns/releases/latest/download/png2icns-macos-x86_64.tar.gz
tar -xzf png2icns-macos-x86_64.tar.gz
chmod +x png2icns-macos-x86_64
sudo mv png2icns-macos-x86_64 /usr/local/bin/png2icns

# macOS (Apple Silicon)
wget https://github.com/ly-wo/png2icns/releases/latest/download/png2icns-macos-aarch64.tar.gz
tar -xzf png2icns-macos-aarch64.tar.gz
chmod +x png2icns-macos-aarch64
sudo mv png2icns-macos-aarch64 /usr/local/bin/png2icns

# 验证安装
png2icns --version
```

### 方式三：从源码构建

#### 1. 构建 Docker 镜像

```bash
# 使用构建脚本（推荐）
./build.sh

# 或手动构建
docker build -t png2icns:latest .
```

#### 2. 准备文件

```bash
# 创建输入输出目录
mkdir -p input output

# 将 PNG 文件放入 input 目录
cp your-icon.png input/
```

#### 3. 转换图像

```bash
# 基础用法
docker run --rm \
  -v $(pwd)/input:/app/input \
  -v $(pwd)/output:/app/output \
  png2icns:latest \
  -i /app/input/your-icon.png \
  -o /app/output/your-icon.icns

# 使用 docker-compose（推荐）
docker-compose run --rm png2icns \
  -i /app/input/your-icon.png \
  -o /app/output/your-icon.icns
```

## 📖 使用指南

### 命令行选项

```bash
png2icns [OPTIONS] --input <INPUT> --output <OUTPUT>

选项:
  -i, --input <INPUT>      输入 PNG 文件路径
  -o, --output <OUTPUT>    输出 ICNS 文件路径
  -p, --preset <PRESET>    质量预设 [默认: standard] [可选: basic, standard, full]
  -s, --sizes <SIZES>      自定义尺寸 (逗号分隔，如: 16,32,64,128,256,512)
  -v, --verbose            详细输出
  -h, --help               显示帮助信息
  -V, --version            显示版本信息
```

### 质量预设

| 预设       | 包含尺寸                  | 说明                   |
| ---------- | ------------------------- | ---------------------- |
| `basic`    | 16, 32, 128, 256, 512     | 基础尺寸，适合简单图标 |
| `standard` | 16, 32, 64, 128, 256, 512 | 标准尺寸，推荐使用     |
| `full`     | 16, 32, 64, 128, 256, 512 | 完整尺寸，最高质量     |

### 使用示例

#### 1. 标准转换
```bash
docker-compose run --rm png2icns \
  -i /app/input/app-icon.png \
  -o /app/output/app-icon.icns
```

#### 2. 使用基础预设
```bash
docker-compose run --rm png2icns \
  -i /app/input/app-icon.png \
  -o /app/output/app-icon.icns \
  --preset basic
```

#### 3. 自定义尺寸
```bash
docker-compose run --rm png2icns \
  -i /app/input/app-icon.png \
  -o /app/output/app-icon.icns \
  --sizes 16,32,128,256,512
```

#### 4. 详细输出
```bash
docker-compose run --rm png2icns \
  -i /app/input/app-icon.png \
  -o /app/output/app-icon.icns \
  --verbose
```

#### 5. 批量转换
```bash
# 转换 input 目录下的所有 PNG 文件
for file in input/*.png; do
  filename=$(basename "$file" .png)
  docker-compose run --rm png2icns \
    -i "/app/input/$filename.png" \
    -o "/app/output/$filename.icns"
done
```

## 🛠️ 开发

### 本地开发环境

```bash
# 使用开发容器
docker-compose run --rm dev cargo run -- --help

# 运行测试
docker-compose run --rm dev cargo test

# 代码格式化
docker-compose run --rm dev cargo fmt

# 代码检查
docker-compose run --rm dev cargo clippy
```

### 项目结构

```
png2icns/
├── src/
│   └── main.rs              # 主程序
├── input/                   # 输入文件目录
├── output/                  # 输出文件目录
├── examples/                # 示例文件
├── Cargo.toml              # Rust 项目配置
├── Dockerfile              # Docker 构建文件
├── docker-compose.yml      # Docker Compose 配置
├── build.sh                # 构建脚本
└── README.md               # 项目文档
```

## 🧪 测试

### 创建测试图像

```bash
# 使用 ImageMagick 创建测试 PNG
docker run --rm -v $(pwd)/input:/tmp alpine/imagemagick \
  convert -size 1024x1024 xc:blue /tmp/test-blue.png

# 或使用在线工具创建 PNG 文件并放入 input 目录
```

### 验证转换结果

```bash
# 转换测试图像
docker-compose run --rm png2icns \
  -i /app/input/test-blue.png \
  -o /app/output/test-blue.icns \
  --verbose

# 检查输出文件
ls -la output/
file output/test-blue.icns
```

## 🔄 CI/CD 和自动化

### GitHub Actions 工作流

本项目使用 GitHub Actions 实现完全自动化的 CI/CD 流程：

#### 1. **持续集成 (CI)**
- **代码质量检查**: 自动运行 `rustfmt` 和 `clippy`
- **多平台测试**: 在 Ubuntu 和 macOS 上测试
- **Docker 测试**: 验证 Docker 镜像构建和功能
- **安全审计**: 使用 `cargo audit` 检查依赖安全性
- **代码覆盖率**: 生成并上传到 Codecov

#### 2. **自动构建和发布**
- **多架构 Docker 镜像**: 自动构建 `linux/amd64` 和 `linux/arm64`
- **多平台二进制文件**: 自动编译 Linux 和 macOS 版本
- **自动发布**: 推送 tag 时自动创建 GitHub Release
- **制品上传**: 二进制文件和 Docker 镜像自动上传

#### 3. **Docker 镜像发布**
- **GitHub Container Registry**: 自动推送到 `ghcr.io`
- **多标签支持**: `latest`, 版本号, 分支名
- **安全扫描**: 使用 Trivy 扫描漏洞
- **SBOM 生成**: 自动生成软件物料清单

### 可用的 Docker 镜像

```bash
# 最新版本
docker pull ghcr.io/ly-wo/png2icns:latest

# 特定版本
docker pull ghcr.io/ly-wo/png2icns:v1.0.0

# 开发版本
docker pull ghcr.io/ly-wo/png2icns:main
```

### 发布流程

1. **开发**: 在功能分支上开发
2. **测试**: CI 自动运行所有测试
3. **合并**: 合并到主分支
4. **标签**: 创建版本标签 (如 `v1.0.0`)
5. **发布**: 自动构建并发布到 GitHub Releases 和 Container Registry

```bash
# 创建新版本
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions 将自动：
# - 构建多平台二进制文件
# - 构建多架构 Docker 镜像
# - 创建 GitHub Release
# - 上传所有制品
```

## 📦 部署

### 生产环境部署

```bash
# 使用预构建镜像（推荐）
docker pull ghcr.io/ly-wo/png2icns:latest

# 运行转换服务（推荐使用非 root 用户）
docker run -d \
  --name png2icns-service \
  --restart unless-stopped \
  --user 1000:1000 \
  -v /path/to/input:/app/input:ro \
  -v /path/to/output:/app/output:rw \
  ghcr.io/ly-wo/png2icns:latest
```

### Kubernetes 部署

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: png2icns
spec:
  replicas: 3
  selector:
    matchLabels:
      app: png2icns
  template:
    metadata:
      labels:
        app: png2icns
    spec:
      containers:
      - name: png2icns
        image: ghcr.io/ly-wo/png2icns:latest
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        volumeMounts:
        - name: input-volume
          mountPath: /app/input
        - name: output-volume
          mountPath: /app/output
      volumes:
      - name: input-volume
        persistentVolumeClaim:
          claimName: png2icns-input-pvc
      - name: output-volume
        persistentVolumeClaim:
          claimName: png2icns-output-pvc
```

### Docker Compose 生产配置

```yaml
version: '3.8'
services:
  png2icns:
    image: ghcr.io/ly-wo/png2icns:latest
    restart: unless-stopped
    volumes:
      - ./input:/app/input:ro
      - ./output:/app/output:rw
    environment:
      - RUST_LOG=info
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 128M
```

## 🔒 安全说明

### 容器安全
- **生产环境**: 推荐使用 `--user` 参数以非 root 用户运行容器
- **CI/CD 环境**: 容器默认以 root 用户运行以避免权限问题
- **文件权限**: 输出目录设置为 777 权限以确保跨环境兼容性

```bash
# 生产环境安全运行
docker run --rm --user $(id -u):$(id -g) \
  -v $(pwd)/input:/app/input:ro \
  -v $(pwd)/output:/app/output:rw \
  png2icns:latest -i /app/input/icon.png -o /app/output/icon.icns
```

## 🔧 故障排除

### 常见问题

1. **权限问题**
   ```bash
   # 确保输出目录有写权限
   chmod 755 output/
   ```

2. **文件不存在**
   ```bash
   # 检查输入文件是否存在
   ls -la input/
   ```

3. **镜像构建失败**
   ```bash
   # 清理 Docker 缓存重新构建
   docker system prune -f
   ./build.sh
   ```

4. **内存不足**
   ```bash
   # 对于大图像，增加 Docker 内存限制
   docker run --memory=2g --rm ...
   ```

### 调试模式

```bash
# 进入容器调试
docker run -it --rm \
  -v $(pwd)/input:/app/input \
  -v $(pwd)/output:/app/output \
  png2icns:latest bash

# 查看详细日志
docker-compose run --rm png2icns \
  -i /app/input/icon.png \
  -o /app/output/icon.icns \
  --verbose
```

## 📋 系统要求

- Docker 20.10+
- Docker Compose 2.0+
- 至少 1GB 可用磁盘空间
- 至少 512MB 可用内存

## 🤝 贡献

欢迎贡献代码！请查看 [CONTRIBUTING.md](.github/CONTRIBUTING.md) 了解详细的贡献指南。

### 快速开始贡献

1. **Fork 项目**
2. **创建功能分支**: `git checkout -b feature/amazing-feature`
3. **开发和测试**: 使用 `make test` 确保所有测试通过
4. **提交更改**: `git commit -m 'feat: add amazing feature'`
5. **推送分支**: `git push origin feature/amazing-feature`
6. **创建 Pull Request**: 使用我们的 PR 模板

### 开发环境

```bash
# 克隆项目
git clone https://github.com/ly-wo/png2icns.git
cd png2icns

# 构建和测试
make build
make test

# 开发模式
make dev
```

所有 Pull Request 都会自动运行 CI 测试，包括：
- 代码格式检查
- 静态分析 (Clippy)
- 单元测试和集成测试
- Docker 镜像构建测试
- 安全审计

## 📄 许可证

MIT License - 详见 LICENSE 文件

## 🙏 致谢

- [image](https://crates.io/crates/image) - Rust 图像处理库
- [icns](https://crates.io/crates/icns) - ICNS 格式支持
- [clap](https://crates.io/crates/clap) - 命令行参数解析

---

**PNG to ICNS Converter** - 让图标转换变得简单！ 🚀