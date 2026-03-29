# DevPod compose image stain repro

Public reproduction for [skevetter/devpod#654](https://github.com/skevetter/devpod/issues/654).

This repro shows that when two Compose-based devcontainers reuse the same `image:` tag and each project applies different devcontainer Features, DevPod mutates that shared local image tag in place instead of isolating the feature layer to a workspace-specific derived image.

## Repro shape

- `project-a` uses `devpod-repro-shared-base:latest` and adds the GitHub CLI feature
- `project-b` uses the same `devpod-repro-shared-base:latest` and adds the Node feature
- both use a Compose override file that injects an environment variable

Expected:

- Project A should not modify the base image used by Project B
- Project B should not inherit Project A's feature layer

Observed:

- after Project A, the shared tag itself already contains `gh`
- after Project B, the same shared tag contains both `node` and `gh`

## Files

- `project-a/.devcontainer/devcontainer.json`
- `project-a/.devcontainer/compose.yaml`
- `project-a/.devcontainer/compose.override.yaml`
- `project-b/.devcontainer/devcontainer.json`
- `project-b/.devcontainer/compose.yaml`
- `project-b/.devcontainer/compose.override.yaml`
- `reset-shared-base.sh`

## Usage

```bash
./reset-shared-base.sh

devpod up ./project-a --provider docker --ide none --open-ide=false
docker image inspect devpod-repro-shared-base:latest --format '{{.Id}}'
docker run --rm devpod-repro-shared-base:latest gh --version

devpod up ./project-b --provider docker --ide none --open-ide=false
docker image inspect devpod-repro-shared-base:latest --format '{{.Id}}'
docker run --rm devpod-repro-shared-base:latest sh -lc 'node --version && gh --version'
```

If the bug reproduces, the shared tag changes after each project and Project B sees `gh` even though only Project A requested it.
