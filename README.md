# RedTilt Solutions Ltd — Public Images

Container images used across the organisation.

## Images

### GitHub Org Runner (`gh-runner`)

Self-hosted GitHub Actions runner for organisation-level workflows. Registers with a GitHub org and runs jobs with Docker-in-Docker support.

**Image:** `ghcr.io/<org>/github-org-runner`  
**Tags:** `latest`, git SHA, and tag refs (e.g. `v1.0.0` when a tag is pushed)

#### Required environment variables

| Variable       | Description                                                   |
| -------------- | ------------------------------------------------------------- |
| `GITHUB_OWNER` | GitHub organisation name                                      |
| `GITHUB_PAT`   | Personal access token with `admin:org` → `manage_runners:org` |

#### Optional environment variables

| Variable             | Default            | Description                         |
| -------------------- | ------------------ | ----------------------------------- |
| `RUNNER_NAME_PREFIX` | `portainer-org`    | Prefix for the runner name          |
| `RUNNER_LABELS`      | `portainer,docker` | Comma-separated runner labels       |
| `RUNNER_WORKDIR`     | `_work`            | Runner working directory            |
| `RUNNER_GROUP`       | —                  | Runner group name                   |
| `EPHEMERAL`          | `false`            | Set to `true` for ephemeral runners |

#### Example (Docker)

```bash
docker run -d \
  -e GITHUB_OWNER=your-org \
  -e GITHUB_PAT=ghp_xxx \
  -e RUNNER_LABELS=linux,docker \
  --name github-runner \
  ghcr.io/<org>/github-org-runner:latest
```

## Publishing

Images are built and pushed to GitHub Container Registry (GHCR) on every push to `main`. The workflow lives in [.github/release.yml](.github/release.yml).
