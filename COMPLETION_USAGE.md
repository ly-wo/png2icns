# Shell Completion 使用指南

PNG to ICNS 转换器现在支持内置的shell补全功能！

## 🚀 快速开始

### 生成补全脚本

```bash
# 生成 Bash 补全脚本
png2icns completion bash > /etc/bash_completion.d/png2icns

# 生成 Zsh 补全脚本
png2icns completion zsh > ~/.zsh/completions/_png2icns

# 生成 Fish 补全脚本
png2icns completion fish > ~/.config/fish/completions/png2icns.fish

# 生成 PowerShell 补全脚本
png2icns completion powershell > $PROFILE
```

### Docker 环境中使用

```bash
# 生成 Bash 补全脚本
docker run --rm png2icns:latest completion bash > completions/png2icns.bash

# 生成 Zsh 补全脚本
docker run --rm png2icns:latest completion zsh > completions/_png2icns

# 生成 Fish 补全脚本
docker run --rm png2icns:latest completion fish > completions/png2icns.fish

# 生成 PowerShell 补全脚本
docker run --rm png2icns:latest completion powershell > completions/png2icns.ps1
```

## 📋 新的命令结构

### 主要用法

```bash
# 方式1: 直接使用全局参数（向后兼容）
png2icns -i input.png -o output.icns

# 方式2: 使用 convert 子命令
png2icns convert -i input.png -o output.icns

# 方式3: 生成补全脚本
png2icns completion bash
png2icns completion zsh
png2icns completion fish
png2icns completion powershell
```

### 支持的子命令

1. **convert** - 转换PNG到ICNS（默认行为）
2. **completion** - 生成shell补全脚本

## 🔧 安装补全脚本

### Bash

```bash
# 系统级安装
sudo png2icns completion bash > /etc/bash_completion.d/png2icns

# 用户级安装
mkdir -p ~/.bash_completion.d
png2icns completion bash > ~/.bash_completion.d/png2icns
echo "source ~/.bash_completion.d/png2icns" >> ~/.bashrc
```

### Zsh

```bash
# 添加到 fpath
mkdir -p ~/.zsh/completions
png2icns completion zsh > ~/.zsh/completions/_png2icns

# 在 ~/.zshrc 中添加
echo 'fpath=(~/.zsh/completions $fpath)' >> ~/.zshrc
echo 'autoload -U compinit && compinit' >> ~/.zshrc
```

### Fish

```bash
# Fish 会自动加载
mkdir -p ~/.config/fish/completions
png2icns completion fish > ~/.config/fish/completions/png2icns.fish
```

### PowerShell

```powershell
# 添加到 PowerShell 配置文件
png2icns completion powershell >> $PROFILE
```

## ✨ 补全功能

补全脚本提供以下智能补全：

### 文件补全
- `-i, --input`: 自动补全 `.png` 文件
- `-o, --output`: 自动补全 `.icns` 文件

### 参数补全
- `-p, --preset`: 补全预设值 (`basic`, `standard`, `full`)
- `-s, --sizes`: 提供常用尺寸建议 (`16,32,64,128,256,512`)

### 子命令补全
- `convert`: 转换命令
- `completion`: 补全脚本生成命令

### Shell类型补全
- `completion` 子命令会补全支持的shell类型：
  - `bash`
  - `zsh` 
  - `fish`
  - `powershell`

## 🎯 使用示例

安装补全后，您可以使用 Tab 键进行智能补全：

```bash
# 输入命令并按 Tab
png2icns <Tab>
# 显示: convert completion -i --input -o --output -p --preset -s --sizes -v --verbose -h --help -V --version

# 输入参数并按 Tab
png2icns -i <Tab>
# 显示当前目录中的 .png 文件

# 输入预设参数并按 Tab
png2icns -p <Tab>
# 显示: basic standard full

# 输入子命令并按 Tab
png2icns completion <Tab>
# 显示: bash zsh fish powershell
```

## 🔄 向后兼容性

新的命令结构完全向后兼容：

```bash
# 这些命令都能正常工作
png2icns -i input.png -o output.icns                    # ✅ 原有方式
png2icns convert -i input.png -o output.icns            # ✅ 新的子命令方式
png2icns -i input.png -o output.icns --preset basic     # ✅ 带参数的原有方式
```

## 🐳 Docker 使用

在Docker环境中，您可以先生成补全脚本，然后在宿主机上安装：

```bash
# 生成所有补全脚本
mkdir -p completions
docker run --rm png2icns:latest completion bash > completions/png2icns.bash
docker run --rm png2icns:latest completion zsh > completions/_png2icns
docker run --rm png2icns:latest completion fish > completions/png2icns.fish
docker run --rm png2icns:latest completion powershell > completions/png2icns.ps1

# 然后根据您的shell类型安装相应的脚本
```

现在您可以享受智能补全带来的便利了！🎉