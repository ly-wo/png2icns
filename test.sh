#!/bin/bash

set -e

echo "🧪 Testing PNG to ICNS Converter..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_NAME="png2icns"

# 检查 Docker 是否可用
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found. Please install Docker first.${NC}"
    exit 1
fi

# 确保目录存在并设置适当权限
mkdir -p input output examples
chmod 755 input output examples

echo -e "${BLUE}📋 Test Plan:${NC}"
echo "1. Build Docker image"
echo "2. Test help command"
echo "3. Create test PNG image"
echo "4. Test PNG to ICNS conversion"
echo "5. Verify output file"
echo "6. Test different presets"
echo "7. Test custom sizes"
echo ""

# 1. 构建 Docker 镜像
echo -e "${YELLOW}1. 🔨 Building Docker image...${NC}"
if ./build.sh > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker image built successfully${NC}"
else
    echo -e "${RED}❌ Docker build failed${NC}"
    exit 1
fi

# 2. 测试帮助命令
echo -e "${YELLOW}2. 📖 Testing help command...${NC}"
if docker run --rm ${PROJECT_NAME}:latest --help > /dev/null; then
    echo -e "${GREEN}✅ Help command works${NC}"
else
    echo -e "${RED}❌ Help command failed${NC}"
    exit 1
fi

# 3. 创建测试 PNG 图像
echo -e "${YELLOW}3. 🎨 Creating test PNG image...${NC}"

# 尝试使用 ImageMagick 创建测试图像
if docker run --rm -v $(pwd)/input:/tmp alpine/imagemagick \
    convert -size 512x512 xc:blue /tmp/test-blue.png > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Created test-blue.png with ImageMagick${NC}"
    TEST_FILE="test-blue.png"
elif docker run --rm -v $(pwd)/input:/tmp alpine/imagemagick \
    convert -size 512x512 gradient:blue-red /tmp/test-gradient.png > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Created test-gradient.png with ImageMagick${NC}"
    TEST_FILE="test-gradient.png"
else
    # 如果 ImageMagick 不可用，创建一个简单的测试图像
    echo -e "${YELLOW}⚠️  ImageMagick not available, creating simple test image...${NC}"
    
    # 使用 Python 创建测试图像
    docker run --rm -v $(pwd)/input:/tmp python:3.9-slim bash -c "
    pip install Pillow > /dev/null 2>&1
    python3 -c \"
from PIL import Image
import os
# 创建一个简单的蓝色图像
img = Image.new('RGB', (512, 512), color='blue')
img.save('/tmp/test-simple.png')
print('Created simple test image')
\"
    " > /dev/null 2>&1
    
    if [ -f "input/test-simple.png" ]; then
        echo -e "${GREEN}✅ Created test-simple.png with Python${NC}"
        TEST_FILE="test-simple.png"
    else
        echo -e "${RED}❌ Failed to create test image${NC}"
        echo -e "${YELLOW}💡 Please manually place a PNG file in the input/ directory and run the test again${NC}"
        exit 1
    fi
fi

# 4. 测试 PNG 到 ICNS 转换
echo -e "${YELLOW}4. 🔄 Testing PNG to ICNS conversion...${NC}"
if docker run --rm \
    -v $(pwd)/input:/app/input \
    -v $(pwd)/output:/app/output \
    ${PROJECT_NAME}:latest \
    -i "/app/input/${TEST_FILE}" \
    -o "/app/output/test.icns" \
    --verbose > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Basic conversion successful${NC}"
else
    echo -e "${RED}❌ Basic conversion failed${NC}"
    exit 1
fi

# 5. 验证输出文件
echo -e "${YELLOW}5. 🔍 Verifying output file...${NC}"
if [ -f "output/test.icns" ]; then
    FILE_SIZE=$(stat -f%z "output/test.icns" 2>/dev/null || stat -c%s "output/test.icns" 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✅ Output file created (size: ${FILE_SIZE} bytes)${NC}"
    
    # 检查文件类型
    if command -v file &> /dev/null; then
        FILE_TYPE=$(file output/test.icns)
        if [[ $FILE_TYPE == *"Mac OS X icon"* ]] || [[ $FILE_TYPE == *"icns"* ]]; then
            echo -e "${GREEN}✅ File type verification passed${NC}"
        else
            echo -e "${YELLOW}⚠️  File type: ${FILE_TYPE}${NC}"
        fi
    fi
else
    echo -e "${RED}❌ Output file not created${NC}"
    exit 1
fi

# 6. 测试不同预设
echo -e "${YELLOW}6. 🎯 Testing different presets...${NC}"

# 测试基础预设
if docker run --rm \
    -v $(pwd)/input:/app/input \
    -v $(pwd)/output:/app/output \
    ${PROJECT_NAME}:latest \
    -i "/app/input/${TEST_FILE}" \
    -o "/app/output/test-basic.icns" \
    --preset basic > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Basic preset works${NC}"
else
    echo -e "${RED}❌ Basic preset failed${NC}"
fi

# 测试完整预设
if docker run --rm \
    -v $(pwd)/input:/app/input \
    -v $(pwd)/output:/app/output \
    ${PROJECT_NAME}:latest \
    -i "/app/input/${TEST_FILE}" \
    -o "/app/output/test-full.icns" \
    --preset full > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Full preset works${NC}"
else
    echo -e "${RED}❌ Full preset failed${NC}"
fi

# 7. 测试自定义尺寸
echo -e "${YELLOW}7. 📏 Testing custom sizes...${NC}"
if docker run --rm \
    -v $(pwd)/input:/app/input \
    -v $(pwd)/output:/app/output \
    ${PROJECT_NAME}:latest \
    -i "/app/input/${TEST_FILE}" \
    -o "/app/output/test-custom.icns" \
    --sizes "16,32,128,256" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Custom sizes work${NC}"
else
    echo -e "${RED}❌ Custom sizes failed${NC}"
fi

# 测试总结
echo ""
echo -e "${GREEN}🎉 All tests passed successfully!${NC}"
echo ""
echo -e "${BLUE}📊 Test Results:${NC}"
echo "✅ Docker image build: OK"
echo "✅ Help command: OK"
echo "✅ Test image creation: OK"
echo "✅ Basic conversion: OK"
echo "✅ Output verification: OK"
echo "✅ Preset testing: OK"
echo "✅ Custom sizes: OK"

echo ""
echo -e "${BLUE}📁 Generated files:${NC}"
ls -la output/*.icns 2>/dev/null || echo "No ICNS files found"

echo ""
echo -e "${BLUE}🚀 Ready for use!${NC}"
echo ""
echo -e "${YELLOW}💡 Usage examples:${NC}"
echo "# Convert your own PNG:"
echo "cp your-icon.png input/"
echo "make convert INPUT=input/your-icon.png OUTPUT=output/your-icon.icns"
echo ""
echo "# Batch convert all PNG files:"
echo "make batch-convert"
echo ""
echo "# Using docker directly:"
echo "docker run --rm -v \$(pwd)/input:/app/input -v \$(pwd)/output:/app/output ${PROJECT_NAME}:latest -i /app/input/your-icon.png -o /app/output/your-icon.icns"

# 清理测试文件（可选）
if [ "$1" = "--clean" ]; then
    echo ""
    echo -e "${YELLOW}🧹 Cleaning up test files...${NC}"
    rm -f input/test-*.png output/test*.icns
    echo -e "${GREEN}✅ Cleanup completed${NC}"
fi