Deployment Guide — GitHub Pages

This repo is ready to deploy as a static site to GitHub Pages using the included GitHub Actions workflow. Follow these steps to publish it under your GitHub account or the F1jobs-io organization.

F1jobs-io quick start (org repo)
- Create a repo under the org (example: `Arjun`): https://github.com/F1jobs-io
- Set `origin` to `https://github.com/F1jobs-io/Arjun.git` and push `main`
- In Settings → Pages, set Source to “GitHub Actions”
- (Optional) Custom domain is read from `CNAME` (currently `arjunprasad.com`); configure DNS and enable HTTPS

What’s included
- .github/workflows/deploy-pages.yml — Deploys the static site on every push to the main branch.
- .nojekyll — Disables Jekyll processing so all files are served as-is.
- CNAME (optional) — If present, configures a custom domain for Pages (see below).

Choose your Pages type
1) User site (recommended for a primary portfolio)
   - Repository name: <your-username>.github.io
   - URL: https://<your-username>.github.io
   - Only one user site is allowed per account.

2) Project site
   - Repository name: any (e.g., portfolio)
   - URL: https://<your-username>.github.io/<repo-name>

Create the repository
Option A: GitHub Web UI
1. Create a new public repository (user site or project site).
2. Do NOT initialize with a README; you’ll push this codebase.

Option B: GitHub CLI (if installed)
1. gh auth login
2. gh repo create <your-username>.github.io --public --source . --remote origin --push

Push the code (if you didn’t use the CLI push)
```
git init
git add -A
git commit -m "Initial deploy"
git branch -M main
git remote add origin https://github.com/<your-username>/<repo-name>.git
git push -u origin main
```

Using a Personal Access Token (PAT)
- When prompted by Git for username/password, enter your GitHub username and paste your PAT as the password.
- Do NOT hardcode your PAT into commands or files.

Enable GitHub Pages
1. In your repository on GitHub: Settings → Pages.
2. Under “Build and deployment”, set Source to “GitHub Actions”.
3. The included workflow (`.github/workflows/deploy-pages.yml`) will publish automatically on push to `main` (both user and org repos).

Custom domain (optional)
- This repo contains a `CNAME` file. If present, GitHub Pages will publish with that domain.
  - Current value: `arjunprasad.com` (change if needed, or delete `CNAME` to skip).
- Configure DNS: create a CNAME record for your domain pointing to `<your-username>.github.io` (user) or `<org>.github.io` (org).
- In Settings → Pages, add the custom domain and enable “Enforce HTTPS” after the certificate is issued.

Verifying the deployment
1. Go to the Actions tab and open the “Deploy to GitHub Pages” workflow run.
2. Ensure all steps pass; the summary shows the deployed URL.
3. Visit the site URL:
   - User site: https://<your-username>.github.io
   - Project site: https://<your-username>.github.io/<repo-name>

Notes & Tips
- Static site (no build): the workflow uploads the repository root as the artifact.
- Paths use relative URLs (e.g., `assets/...`); they work for both user and project sites.
- If you change the default branch name, update the workflow trigger branches in `deploy-pages.yml`.
- For SEO polish, consider adding `robots.txt`, `sitemap.xml`, and meta tags.

Org repos with GitHub CLI
You can also use the helper script to push under an org:

```
bash scripts/deploy_github_pages.sh
# When prompted for owner, enter: F1jobs-io
# When prompted for repo, enter: Arjun (or your preferred repo name)
```

Rollback / disable Pages
- Settings → Pages → Set Source to “Disabled”.
- To fully remove a published site, delete the gh-pages environment in Settings → Environments.
