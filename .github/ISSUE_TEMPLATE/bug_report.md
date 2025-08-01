---
name: Bug report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Run command '...'
2. With input file '...'
3. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots/Output**
If applicable, add screenshots or command output to help explain your problem.

**Environment (please complete the following information):**
- OS: [e.g. Ubuntu 20.04, macOS 12.0, Windows 11]
- Docker version: [e.g. 20.10.17]
- Image version: [e.g. latest, v1.0.0]
- Input file format: [e.g. PNG]
- Input file size: [e.g. 1024x1024, 2MB]

**Command used**
```bash
# Paste the exact command you used
docker run --rm -v $(pwd)/input:/app/input -v $(pwd)/output:/app/output png2icns:latest -i /app/input/test.png -o /app/output/test.icns
```

**Additional context**
Add any other context about the problem here.