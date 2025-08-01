# Contributing to PNG to ICNS Converter

Thank you for your interest in contributing to this project! 🎉

## 🚀 Getting Started

### Prerequisites
- Docker (for containerized development)
- Rust (optional, for local development)
- Git

### Development Setup

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/your-username/png2icns.git
   cd png2icns
   ```

2. **Build the Docker image**
   ```bash
   ./build.sh
   ```

3. **Run tests**
   ```bash
   ./test.sh
   ```

## 🛠️ Development Workflow

### Using Docker (Recommended)
```bash
# Build the image
make build

# Run tests
make test

# Development with live reload
make dev

# Format code
make fmt

# Run linter
make clippy
```

### Local Development (Optional)
```bash
# Install Rust if not already installed
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Build and test
cargo build --release
cargo test
cargo fmt
cargo clippy
```

## 📝 Code Style

- Follow Rust standard formatting (`cargo fmt`)
- Address all Clippy warnings (`cargo clippy`)
- Write clear, self-documenting code
- Add comments for complex logic
- Include tests for new functionality

## 🧪 Testing

### Running Tests
```bash
# All tests
make test

# Unit tests only
cargo test

# Docker integration tests
make docker-test
```

### Adding Tests
- Add unit tests in the same file as the code being tested
- Add integration tests for end-to-end functionality
- Test edge cases and error conditions
- Ensure tests are deterministic and can run in parallel

## 📚 Documentation

- Update README.md for user-facing changes
- Add inline documentation for public APIs
- Update PROJECT_SUMMARY.md for significant changes
- Include examples for new features

## 🔄 Pull Request Process

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write code following the style guidelines
   - Add tests for new functionality
   - Update documentation as needed

3. **Test your changes**
   ```bash
   make test
   make docker-test
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

5. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Use the PR template
   - Provide clear description of changes
   - Link any related issues
   - Ensure CI passes

## 🏷️ Commit Message Format

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools

### Examples
```
feat: add support for custom icon sizes
fix: handle invalid PNG files gracefully
docs: update installation instructions
test: add integration tests for Docker image
```

## 🐛 Bug Reports

When reporting bugs, please include:
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, Docker version, etc.)
- Input files (if applicable)
- Command used
- Error messages or logs

## 💡 Feature Requests

For feature requests, please provide:
- Clear description of the feature
- Use case and motivation
- Proposed implementation (if any)
- Examples of how it would be used

## 🔒 Security

If you discover a security vulnerability, please:
- **Do not** create a public issue
- Email the maintainers directly
- Provide detailed information about the vulnerability
- Allow time for the issue to be addressed before public disclosure

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🤝 Code of Conduct

This project follows a standard code of conduct:
- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Respect different viewpoints and experiences

## 🆘 Getting Help

If you need help:
- Check existing issues and discussions
- Create a new issue with the "question" label
- Join our community discussions
- Read the documentation thoroughly

## 🎯 Areas for Contribution

We welcome contributions in these areas:
- **Bug fixes**: Fix existing issues
- **Performance**: Optimize conversion speed or memory usage
- **Features**: Add new functionality (see open issues)
- **Documentation**: Improve docs, examples, or tutorials
- **Testing**: Add more comprehensive tests
- **CI/CD**: Improve build and deployment processes

Thank you for contributing! 🙏