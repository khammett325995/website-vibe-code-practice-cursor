# website-vibe-code-practice-cursor

Practice project for a redesigned portfolio site (static HTML/CSS/JS).

## GitHub Pages (free public URL)

After you push this repository to GitHub:

1. Open the repo on GitHub → **Settings** → **Pages** (under “Code and automation”).
2. Under **Build and deployment**, set **Source** to **GitHub Actions** (not “Deploy from a branch”).
3. Push to `main` or `master`, or open the **Actions** tab and run **Deploy GitHub Pages** manually (**Run workflow**).

The workflow copies only root-level `*.html`, `*.css`, and `*.js` into the published site (so `_orig/`, `tools/`, etc. are not exposed on the live URL).

Your site will be available at:

**`https://<your-username>.github.io/<repository-name>/`**

Use that full URL when sharing; all asset links in this project are relative and work under that path.

### One-time note

If Pages says the workflow needs approval, complete the **Configure GitHub Pages** / environment step GitHub shows on first deploy.

### Regenerating subpages

The `tools/build-subpages.ps1` script expects a local `_orig/` folder (same HTML as the [original portfolio repo](https://github.com/khammett325995/Portfolio-Website-Kylie-Hammett)). `_orig/` is gitignored. After you change sources, run the script, commit the updated root `*.html` files, and push to redeploy.
