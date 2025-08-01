.PHONY: build run clean test help docker-build docker-run docker-test

# 项目配置
PROJECT_NAME = png2icns
VERSION = $(shell grep '^version' Cargo.toml | sed 's/version = "\(.*\)"/\1/')

# 默认目标
all: docker-build

# 构建 Docker 镜像
build: docker-build

docker-build:
	@echo "🐳 Building Docker image..."
	./build.sh

# 运行容器（显示帮助）
run: docker-run

docker-run:
	@echo "🚀 Running container..."
	docker run --rm $(PROJECT_NAME):latest

# 测试转换功能
test: docker-test

docker-test:
	@echo "🧪 Testing conversion..."
	@echo "Creating test PNG..."
	@mkdir -p input output
	@docker run --rm -v $(PWD)/input:/tmp alpine/imagemagick \
		convert -size 512x512 xc:blue /tmp/test.png || \
		echo "⚠️  ImageMagick not available, please place a PNG file in input/ directory manually"
	@if [ -f input/test.png ]; then \
		echo "Converting test.png to test.icns..."; \
		docker run --rm \
			-v $(PWD)/input:/app/input \
			-v $(PWD)/output:/app/output \
			$(PROJECT_NAME):latest \
			-i /app/input/test.png \
			-o /app/output/test.icns \
			--verbose; \
		echo "✅ Test completed! Check output/test.icns"; \
	else \
		echo "❌ No test PNG file found. Please place a PNG file in input/ directory and run 'make test' again."; \
	fi

# 转换示例（需要用户提供 PNG 文件）
convert:
	@echo "🔄 Converting PNG to ICNS..."
	@if [ -z "$(INPUT)" ] || [ -z "$(OUTPUT)" ]; then \
		echo "Usage: make convert INPUT=input/your-file.png OUTPUT=output/your-file.icns"; \
		echo "Available PNG files in input/:"; \
		ls -la input/*.png 2>/dev/null || echo "No PNG files found in input/"; \
	else \
		docker run --rm \
			-v $(PWD)/input:/app/input \
			-v $(PWD)/output:/app/output \
			$(PROJECT_NAME):latest \
			-i /app/$(INPUT) \
			-o /app/$(OUTPUT) \
			--verbose; \
	fi

# 批量转换
batch-convert:
	@echo "📦 Batch converting all PNG files..."
	@for file in input/*.png; do \
		if [ -f "$$file" ]; then \
			filename=$$(basename "$$file" .png); \
			echo "Converting $$filename.png..."; \
			docker run --rm \
				-v $(PWD)/input:/app/input \
				-v $(PWD)/output:/app/output \
				$(PROJECT_NAME):latest \
				-i "/app/input/$$filename.png" \
				-o "/app/output/$$filename.icns" \
				--verbose; \
		fi; \
	done
	@echo "✅ Batch conversion completed!"

# 开发模式
dev:
	@echo "👨‍💻 Starting development mode..."
	docker-compose run --rm dev bash

# 运行 Rust 测试
rust-test:
	@echo "🧪 Running Rust tests..."
	docker-compose run --rm dev cargo test

# 代码格式化
fmt:
	@echo "📝 Formatting code..."
	docker-compose run --rm dev cargo fmt

# 代码检查
clippy:
	@echo "🔍 Running clippy..."
	docker-compose run --rm dev cargo clippy

# 清理
clean:
	@echo "🧹 Cleaning up..."
	docker-compose down --volumes --remove-orphans
	docker rmi $(PROJECT_NAME):latest $(PROJECT_NAME):dev 2>/dev/null || true
	rm -f input/test.png output/test.icns
	@echo "✅ Cleanup completed!"

# 显示项目信息
info:
	@echo "📋 Project Information:"
	@echo "Name: $(PROJECT_NAME)"
	@echo "Version: $(VERSION)"
	@echo "Docker images:"
	@docker images $(PROJECT_NAME) --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" 2>/dev/null || echo "No images found"
	@echo ""
	@echo "📁 Directory contents:"
	@echo "Input files:"
	@ls -la input/ 2>/dev/null || echo "No input directory"
	@echo "Output files:"
	@ls -la output/ 2>/dev/null || echo "No output directory"

# GitHub Actions 相关命令
gh-status:
	@echo "📊 GitHub Actions Status:"
	@gh run list --limit 10

gh-logs:
	@echo "📋 Latest workflow logs:"
	@gh run view --log

gh-release:
	@echo "🚀 Creating new release..."
	@read -p "Enter version (e.g., v1.0.0): " version; \
	git tag $$version && \
	git push origin $$version && \
	echo "✅ Tag $$version pushed. GitHub Actions will create the release automatically."

gh-pull-image:
	@echo "🐳 Pulling latest Docker image from GitHub Container Registry..."
	docker pull ghcr.io/$(shell git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\).*/\1/' | sed 's/\.git$$//' | tr '[:upper:]' '[:lower:]'):latest

# 显示帮助
help:
	@echo "🖼️  PNG to ICNS Converter - Available Commands:"
	@echo ""
	@echo "🏗️  Build & Setup:"
	@echo "  build, docker-build    - Build Docker image"
	@echo "  clean                  - Clean up containers and images"
	@echo ""
	@echo "🚀 Run & Test:"
	@echo "  run, docker-run        - Run container (show help)"
	@echo "  test, docker-test      - Test conversion with sample image"
	@echo "  convert INPUT=... OUTPUT=... - Convert specific file"
	@echo "  batch-convert          - Convert all PNG files in input/"
	@echo ""
	@echo "👨‍💻 Development:"
	@echo "  dev                    - Start development container"
	@echo "  rust-test              - Run Rust unit tests"
	@echo "  fmt                    - Format Rust code"
	@echo "  clippy                 - Run Rust linter"
	@echo ""
	@echo "🐙 GitHub Actions:"
	@echo "  gh-status              - Show GitHub Actions status"
	@echo "  gh-logs                - Show latest workflow logs"
	@echo "  gh-release             - Create new release tag"
	@echo "  gh-pull-image          - Pull latest image from GHCR"
	@echo ""
	@echo "📋 Information:"
	@echo "  info                   - Show project information"
	@echo "  help                   - Show this help message"
	@echo ""
	@echo "💡 Usage Examples:"
	@echo "  make build                                    # Build the Docker image"
	@echo "  make test                                     # Test with sample image"
	@echo "  make convert INPUT=input/icon.png OUTPUT=output/icon.icns"
	@echo "  make batch-convert                            # Convert all PNG files"
	@echo "  make gh-release                               # Create new release"
	@echo ""
	@echo "📁 File Management:"
	@echo "  - Place PNG files in the 'input/' directory"
	@echo "  - Converted ICNS files will appear in 'output/' directory"
	@echo ""
	@echo "🔗 Links:"
	@echo "  - GitHub Repository: https://github.com/your-username/png2icns"
	@echo "  - Container Registry: https://ghcr.io/your-username/png2icns"
	@echo "  - Latest Release: https://github.com/your-username/png2icns/releases/latest"