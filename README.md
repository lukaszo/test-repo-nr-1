# test-repo-nr-1

Fixture repo for testing the MAIS internal build registry (zot) on cloud-runtime.

## Why this exists

`koyeb/example-nginx` is a single `FROM nginx` with no extra layers, so buildkit
skips cache export ("empty result") and the registry cache path can't be tested.
This repo's `Dockerfile` adds several deterministic, offline `RUN`/`COPY` layers so
buildkit exports real cache layers to the `<service>-cache` repo in zot. A rebuild
then imports them and reports `CACHED`, which lets us:

- verify cache push/pull against zot end to end, and
- reproduce / rule out the suspected cache-push race.

## Layout

- `Dockerfile` — layered image (3 `RUN` + 2 `COPY` layers), based on `nginx:1.27`,
  serves on port 80.
- `index.html`, `static/` — served content (also the `COPY` layers).

## Usage

Build a cloud-runtime service from `github.com/lukaszo/test-repo-nr-1` (branch
`main`, Dockerfile build). First build populates the cache; a rebuild with
unchanged sources should show `CACHED` steps. Change only `index.html` to test
partial cache reuse (layers 1-4 cached, layer 5 rebuilt).

Keep layers deterministic (no timestamps, no network) so digests are stable
across builds.
