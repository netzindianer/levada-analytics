#!/usr/bin/env bash
set -ex

# 1. Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "Uncommitted changes found. Commit or stash before deploying."
    exit 1
fi

# 2. Clean .deploy-dist
rm -rf .deploy-dist

# 3. Build
npm run build

# 4. Copy build output to .deploy-dist
cp -r docs/.vitepress/dist .deploy-dist

# 5. Switch to gh-pages branch
if git show-ref --verify --quiet refs/heads/gh-pages; then
    git checkout gh-pages
else
    git checkout --orphan gh-pages
fi

# 6. Remove all files/folders except dotfiles (.git, .deploy-dist stay)
rm -rf ./*

# 7. Copy from .deploy-dist to root
cp -r .deploy-dist/* .

# 8. Remove .deploy-dist
rm -rf .deploy-dist

# 9. Commit with current date
git add -A
git commit -m "deploy $(date '+%Y-%m-%d %H:%M:%S')"

# 10. Push and go back to main
git push -f origin gh-pages
git checkout main
