# GitHub Actions 工作流说明

本项目使用 GitHub Actions 实现完全自动化的 CI/CD 流程。以下是各个工作流的详细说明：

## 📋 工作流概览

| 工作流 | 触发条件 | 主要功能 | 状态 |
|--------|----------|----------|------|
| [CI](.github/workflows/ci.yml) | Push, PR | 代码质量检查、测试 | [![CI](https://github.com/your-username/png2icns/actions/workflows/ci.yml/badge.svg)](https://github.com/your-username/png2icns/actions/workflows/ci.yml) |
| [Build and Release](.github/workflows/build-and-release.yml) | Push, Tag | 构建二进制、创建发布 | [![Build and Release](https://github.com/your-username/png2icns/actions/workflows/build-and-release.yml/badge.svg)](https://github.com/your-username/png2icns/actions/workflows/build-and-release.yml) |
| [Docker Publish](.github/workflows/docker-publish.yml) | Push, Tag | 构建和发布 Docker 镜像 | [![Docker Publish](https://github.com/your-username/png2icns/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/your-username/png2icns/actions/workflows/docker-publish.yml) |
| [Cleanup](.github/workflows/cleanup.yml) | 定时任务 | 清理旧的制品和缓存 | - |

## 🔄 CI 工作流 (ci.yml)

### 触发条件
- Push 到 `main`, `master`, `develop` 分支
- Pull Request 到 `main`, `master` 分支
- 每日定时运行 (UTC 2:00 AM)

### 作业详情

#### 1. **Lint** 作业
- **目的**: 代码质量检查
- **步骤**:
  - 检查代码格式 (`cargo fmt`)
  - 运行 Clippy 静态分析
  - 检查文档生成

#### 2. **Test** 作业
- **目的**: 多平台测试
- **矩阵策略**:
  - 操作系统: Ubuntu, macOS
  - Rust 版本: stable, beta
- **步骤**:
  - 运行单元测试
  - 构建 release 版本
  - 测试二进制文件

#### 3. **Docker Test** 作业
- **目的**: Docker 功能测试
- **步骤**:
  - 构建 Docker 镜像
  - 测试基本功能
  - 运行综合测试（多种预设和尺寸）

#### 4. **Security Audit** 作业
- **目的**: 安全检查
- **步骤**:
  - 运行 `cargo audit`
  - 检查依赖漏洞

#### 5. **Coverage** 作业
- **目的**: 代码覆盖率
- **步骤**:
  - 生成覆盖率报告
  - 上传到 Codecov

#### 6. **Benchmark** 作业
- **目的**: 性能基准测试
- **触发条件**: 仅在 main 分支 push 时运行
- **步骤**:
  - 创建基准测试图像
  - 运行转换性能测试

## 🚀 构建和发布工作流 (build-and-release.yml)

### 触发条件
- Push 到主要分支
- 创建标签 (`v*`)
- Pull Request

### 作业详情

#### 1. **Test** 作业
- **目的**: 发布前测试
- **步骤**:
  - 构建 Docker 镜像
  - 创建测试图像
  - 验证转换功能

#### 2. **Build Binary** 作业
- **目的**: 多平台二进制构建
- **矩阵策略**:
  - Linux x86_64 (glibc)
  - Linux x86_64 (musl)
  - macOS x86_64
  - macOS ARM64
- **步骤**:
  - 交叉编译
  - 创建压缩包
  - 生成校验和
  - 上传制品

#### 3. **Build Docker** 作业
- **目的**: 多架构 Docker 镜像
- **步骤**:
  - 构建 `linux/amd64` 和 `linux/arm64`
  - 推送到 GitHub Container Registry
  - 生成元数据标签

#### 4. **Release** 作业
- **触发条件**: 仅在创建标签时运行
- **步骤**:
  - 下载所有制品
  - 创建 GitHub Release
  - 上传二进制文件和校验和
  - 生成发布说明

#### 5. **Security Scan** 作业
- **目的**: 安全扫描
- **步骤**:
  - 使用 Trivy 扫描 Docker 镜像
  - 上传结果到 GitHub Security

## 🐳 Docker 发布工作流 (docker-publish.yml)

### 触发条件
- Push 到 `main`, `master` 分支
- 创建标签
- 每周定时重建 (周日 UTC 3:00 AM)

### 作业详情

#### 1. **Build and Push** 作业
- **步骤**:
  - 多架构构建 (`linux/amd64`, `linux/arm64`)
  - 推送到 GitHub Container Registry
  - 生成 SBOM (软件物料清单)
  - 安全扫描
  - 测试发布的镜像

#### 2. **Update README** 作业
- **目的**: 自动更新文档
- **步骤**:
  - 更新 README 中的构建信息
  - 自动提交更改

## 🧹 清理工作流 (cleanup.yml)

### 触发条件
- 每周定时运行 (周六 UTC 1:00 AM)
- 手动触发

### 作业详情

#### 1. **Cleanup Packages** 作业
- **目的**: 清理旧的容器镜像
- **策略**: 保留最新 10 个版本，删除未标记版本

#### 2. **Cleanup Artifacts** 作业
- **目的**: 清理旧的构建制品
- **策略**: 删除 30 天前的制品，保留最近 5 个

#### 3. **Cleanup Caches** 作业
- **目的**: 清理旧的构建缓存
- **策略**: 删除 7 天前的缓存

## 🔧 配置和密钥

### 必需的 GitHub Secrets
- `GITHUB_TOKEN`: 自动提供，用于访问 GitHub API

### 可选的 Secrets
- `CODECOV_TOKEN`: 用于上传代码覆盖率报告

### 权限要求
- `contents: write`: 创建发布和提交
- `packages: write`: 推送 Docker 镜像
- `security-events: write`: 上传安全扫描结果
- `actions: write`: 管理制品和缓存

## 📊 制品和输出

### 构建制品
- **二进制文件**: 多平台可执行文件
- **Docker 镜像**: 多架构容器镜像
- **校验和**: SHA256 校验文件
- **SBOM**: 软件物料清单

### 发布位置
- **GitHub Releases**: 二进制文件和校验和
- **GitHub Container Registry**: Docker 镜像
- **GitHub Security**: 安全扫描报告

## 🚨 故障排除

### 常见问题

1. **构建失败**
   - 检查 Rust 代码编译错误
   - 验证依赖版本兼容性
   - 查看 CI 日志详细信息

2. **Docker 构建失败**
   - 检查 Dockerfile 语法
   - 验证基础镜像可用性
   - 检查多架构构建支持

3. **发布失败**
   - 确认标签格式正确 (`v*`)
   - 检查权限设置
   - 验证制品生成

4. **安全扫描失败**
   - 更新依赖版本
   - 检查已知漏洞
   - 查看 Trivy 报告

### 调试技巧

1. **本地测试**
   ```bash
   # 模拟 CI 环境
   act -j test
   
   # 测试 Docker 构建
   docker build -t test .
   ```

2. **查看日志**
   - 在 GitHub Actions 页面查看详细日志
   - 使用 `set -x` 启用 shell 调试
   - 添加调试输出

3. **手动触发**
   - 使用 `workflow_dispatch` 手动运行
   - 测试特定分支或提交

## 📈 监控和指标

### 可用指标
- **构建时间**: 各个作业的执行时间
- **成功率**: CI/CD 流程的成功率
- **制品大小**: 二进制文件和镜像大小
- **安全扫描**: 漏洞数量和严重程度

### 监控建议
- 设置 GitHub 通知
- 监控构建时间趋势
- 定期检查安全报告
- 跟踪发布频率

---

这个 CI/CD 流程确保了代码质量、安全性和可靠的自动化发布。如有问题，请查看具体的工作流文件或创建 Issue。