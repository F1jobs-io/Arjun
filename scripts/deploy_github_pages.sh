#!/usr/bin/env bash
set -euo pipefail

# Deploy this static site to GitHub Pages using GitHub CLI (gh).
# Prerequisites:
# - Git installed
# - GitHub CLI installed: https://cli.github.com/
# - Run: gh auth login   (or export GH_TOKEN and run: echo "$GH_TOKEN" | gh auth login --with-token)

REPO_NAME_DEFAULT="Arjun"

echo ":: GitHub Pages deployment script ::"

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: GitHub CLI (gh) is not installed." >&2
  echo "Install from https://cli.github.com/ and run 'gh auth login' first." >&2
  exit 1
fi

# Detect default owner (your user) and allow overriding with an org (e.g., F1jobs-io)
USER_LOGIN=$(gh api user -q '.login' 2>/dev/null || echo "")

read -r -p "GitHub owner (user or org) [${USER_LOGIN:-enter-owner}]: " GH_OWNER_INPUT || true
GH_OWNER=${GH_OWNER_INPUT:-$USER_LOGIN}
if [[ -z "$GH_OWNER" ]]; then
  echo "Error: GitHub owner is required (your user or org name)." >&2
  exit 1
fi

read -r -p "Repository name [${REPO_NAME_DEFAULT}]: " REPO_INPUT || true
REPO_NAME=${REPO_INPUT:-$REPO_NAME_DEFAULT}

echo "Using repo: $GH_OWNER/$REPO_NAME"

# Initialize git repo if needed
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Initializing new git repository..."
  git init
fi

# Ensure main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
if [[ "$CURRENT_BRANCH" != "main" ]]; then
  git checkout -B main
fi

# Initial commit if none
if ! git log -1 >/dev/null 2>&1; then
  echo "Creating initial commit..."
  git add -A
  git commit -m "Initial deploy"
fi

# Try to create repo and push
if git remote get-url origin >/dev/null 2>&1; then
  echo "Remote 'origin' already set. Pushing to origin..."
  git push -u origin main
else
  echo "Creating repo on GitHub and pushing..."
  # Attempt to create repo; if it exists, just add remote and push
  if gh repo view "$GH_OWNER/$REPO_NAME" >/dev/null 2>&1; then
    echo "Repository already exists. Adding remote..."
    git remote add origin "https://github.com/$GH_OWNER/$REPO_NAME.git"
    git push -u origin main
  else
    # Create under a user or org owner
    gh repo create "$REPO_NAME" --public --source . --remote origin --push --owner "$GH_OWNER"
  fi
fi

echo
echo "Push complete. GitHub Actions will deploy to Pages automatically."
echo "Next steps:"
echo "  1) Open: https://github.com/$GH_OWNER/$REPO_NAME/actions and watch 'Deploy to GitHub Pages' run."
DOMAIN=""
if [[ -f CNAME ]]; then
  DOMAIN=$(cat CNAME | tr -d '\n' || true)
fi
if [[ -n "$DOMAIN" ]]; then
  echo "  2) Set custom domain (optional): Repo → Settings → Pages → Custom domain: $DOMAIN"
else
  echo "  2) (Optional) Add a CNAME file with your custom domain if you have one."
fi
echo "  3) Enable 'Enforce HTTPS' once the certificate is issued."
echo
if [[ -n "$DOMAIN" ]]; then
  echo "If you haven't already, configure DNS for $DOMAIN to point to GitHub Pages."
fi
echo "See README_DEPLOY.md for the exact DNS records and org setup."
