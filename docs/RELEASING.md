# Releasing

Tamer is released from a git tag. GitHub Actions runs the test harness, builds the zip, uploads it to CurseForge, and makes a GitHub release.

## First-time setup

First, create a public GitHub repository named `tamer` under the owner's account and push `main`. The CurseForge description loads the banner from it, so it has to be public.

These need the project owner's CurseForge account:

1. Create the project at [authors.curseforge.com](https://authors.curseforge.com/#/projects/create/choose-game), using [curseforge-listing.md](curseforge-listing.md) and [art/logo.png](../art/logo.png).
2. Copy the project ID from the project page.
3. Create an API token at [authors-old.curseforge.com/account/api-tokens](https://authors-old.curseforge.com/account/api-tokens).
4. In the GitHub repository's **Settings > Secrets and variables > Actions**, add:
   - A **secret** named `CF_API_TOKEN`, holding the token.
   - A **variable** named `CF_PROJECT_ID`, holding the project ID.
   - For Wago, a **secret** named `WAGO_API_TOKEN`, holding a key from [addons.wago.io/account/apikeys](https://addons.wago.io/account/apikeys). Without it, releases skip Wago. The project ID is in the workflow.

## Each release

1. Set `## Version` in `addon/Tamer/Tamer.toc`.
2. Add a `## <version>` section to the top of `CHANGELOG.md`, in its usual style: short, plain bullets that start with what changed, such as "Added ..." or "Fixed ...". Add "Restart the game after updating." when the release adds or removes files. This section and every one below it become the release notes, so CurseForge and GitHub always show the whole history.
3. Commit as `Release <version> with <the main change>`, such as `Release 1.1.0 with training point warnings`, push to `main`, and check that the Release workflow passes.
4. Tag and push:

   ```bash
   git tag v1.0.0
   ```

   ```bash
   git push origin v1.0.0
   ```

The tag has to match the TOC's version, and the changelog needs a section for it, or the release stops before uploading anything. CurseForge reviews a new project's first file before it goes live.

Versions before 1.0.0 are test versions. They upload to CurseForge as a Beta and to GitHub as a pre-release, and get a changelog section like any other.

## When the client updates

Change `## Interface` in the TOC and `GAME_VERSION` in `.github/workflows/release.yml`. `GAME_VERSION` is CurseForge's name for the client version, such as `1.60.1`.
