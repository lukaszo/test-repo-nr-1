# Cache-test fixture for the MAIS internal build registry (zot).
#
# Unlike koyeb/example-nginx (a single `FROM nginx` with no extra layers, which
# makes buildkit skip cache export with "empty result"), this image adds several
# deterministic, offline RUN/COPY layers. buildkit therefore exports real cache
# layers to the <service>-cache repo in zot, so a rebuild can import them and
# report CACHED steps. That is what lets us exercise cache push/pull and surface
# the suspected cache-push race.
#
# Everything here is deterministic (no timestamps, no network) so repeated builds
# of unchanged sources produce identical layer digests and hit the cache.

FROM nginx:1.27-bookworm

# --- Layer 1: a batch of small files (deterministic, offline) ---
RUN set -eux; \
    mkdir -p /opt/testdata/set1; \
    for i in $(seq 1 100); do echo "set1 entry $i" > "/opt/testdata/set1/file_$i.txt"; done

# --- Layer 2: a sizable deterministic blob so cache layers are non-trivial ---
RUN set -eux; \
    mkdir -p /opt/testdata/set2; \
    dd if=/dev/zero of=/opt/testdata/set2/blob.bin bs=1M count=16; \
    echo "layer2 built" > /opt/testdata/set2/marker.txt

# --- Layer 3: a third RUN layer (deterministic) ---
RUN set -eux; \
    mkdir -p /opt/testdata/set3; \
    seq 1 10000 > /opt/testdata/set3/numbers.txt

# --- Layer 4: static assets (COPY layer) ---
COPY static/ /usr/share/nginx/html/static/

# --- Layer 5: landing page (COPY layer) ---
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
