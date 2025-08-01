# How to Create a Release

The "Create Release" job is skipped during normal pushes because it only runs when version tags are pushed. This is the correct behavior.

## To Create a Release:

### 1. Create a Version Tag
```bash
# Create a new version tag (replace with your desired version)
git tag v1.0.0

# Push the tag to trigger the release
git push origin v1.0.0
```

### 2. What Happens When You Push a Tag:
- ✅ All build jobs run (test, build-binary, build-docker)
- ✅ Security scan runs
- ✅ **Release job runs** and creates a GitHub Release
- ✅ Binary artifacts are uploaded to the release
- ✅ Docker images are tagged with the version

### 3. Tag Naming Convention:
- Use semantic versioning: `v1.0.0`, `v1.2.3`, etc.
- Pre-releases: `v1.0.0-beta.1`, `v1.0.0-rc.1`
- The "v" prefix is required for the release job to trigger

### 4. Example Release Process:
```bash
# 1. Make sure your code is ready
git add .
git commit -m "feat: ready for v1.0.0 release"
git push origin main

# 2. Create and push the tag
git tag v1.0.0
git push origin v1.0.0

# 3. Check GitHub Actions to see the release being created
# 4. Check GitHub Releases page for the new release
```

## Current Workflow Status:
- ✅ **Build jobs**: Run on every push/PR
- ✅ **Docker builds**: Run on every push/PR  
- ⏭️ **Release job**: Only runs on version tags (this is correct!)

The workflow is working as intended. The release job should be skipped for regular commits.