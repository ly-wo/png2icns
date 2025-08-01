#!/bin/bash

set -e

echo "🐳 Building PNG to ICNS Converter Docker Image..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 项目信息
PROJECT_NAME="png2icns"
VERSION=$(grep '^version' Cargo.toml | sed 's/version = "\(.*\)"/\1/')

echo -e "${BLUE}📦 Project: ${PROJECT_NAME}${NC}"
echo -e "${BLUE}🏷️  Version: ${VERSION}${NC}"
echo ""

# 创建必要的目录
echo -e "${YELLOW}📁 Creating directories...${NC}"
mkdir -p input output examples

# 构建 Docker 镜像
echo -e "${YELLOW}🔨 Building Docker image...${NC}"
docker build -t "${PROJECT_NAME}:${VERSION}" -t "${PROJECT_NAME}:latest" .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Docker image built successfully!${NC}"
else
    echo -e "${RED}❌ Docker build failed!${NC}"
    exit 1
fi

# 显示镜像信息
echo -e "${BLUE}📊 Image information:${NC}"
docker images "${PROJECT_NAME}:latest" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

echo ""
echo -e "${GREEN}🎉 Build completed!${NC}"
echo ""
echo -e "${BLUE}🚀 Usage examples:${NC}"
echo "# Show help:"
echo "docker run --rm ${PROJECT_NAME}:latest"
echo ""
echo "# Convert PNG to ICNS:"
echo "docker run --rm -v \$(pwd)/input:/app/input -v \$(pwd)/output:/app/output ${PROJECT_NAME}:latest -i /app/input/icon.png -o /app/output/icon.icns"
echo ""
echo "# Using docker-compose:"
echo "docker-compose run --rm png2icns -i /app/input/icon.png -o /app/output/icon.icns"
echo ""
echo -e "${YELLOW}💡 Tips:${NC}"
echo "- Place your PNG files in the 'input' directory"
echo "- Converted ICNS files will appear in the 'output' directory"
echo "- Use different presets: --preset basic|standard|full"
echo "- Custom sizes: --sizes 16,32,64,128,256,512,1024"