#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
name="kfxgen-test-$$"
trap 'docker logs "$name" 2>/dev/null || true; docker rm -fv "$name" >/dev/null 2>&1 || true; docker image rm "$name" "$name-mod" >/dev/null 2>&1 || true' EXIT

docker build -t "$name-mod" .
test "$(docker image inspect "$name-mod" --format '{{len .RootFS.Layers}}')" = 1
docker build -t "$name" -f - . <<EOF
FROM ${name}-mod AS mod
FROM lscr.io/linuxserver/calibre:latest
COPY --from=mod / /
EOF
docker run -d --name "$name" --shm-size=1g -e PUID=1234 -e PGID=1234 "$name"
wait_ready() {
    for _ in {1..120}; do
        if [[ $(docker logs "$name" 2>&1 | grep -c 'kfxgen ready' || true) -ge $1 ]]; then return; fi
        sleep 2
    done
    return 1
}
wait_ready 1
docker exec "$name" bash -ec '
    test "$(stat -c %u:%g /config/.config/calibre/plugins/kfxgen.zip)" = 1234:1234
    echo "<h1>KFX smoke test</h1><p>A small test book.</p>" > /tmp/book.html
    export CALIBRE_CONFIG_DIRECTORY=/config/.config/calibre
    s6-setuidgid abc ebook-convert /tmp/book.html /tmp/book.kfx
    test -s /tmp/book.kfx
    s6-setuidgid abc calibre-customize --disable-plugin kfxgen
'
docker restart "$name" >/dev/null
wait_ready 2
docker exec "$name" s6-setuidgid abc env CALIBRE_CONFIG_DIRECTORY=/config/.config/calibre \
    calibre-debug -c 'from calibre.customize.ui import is_disabled; assert is_disabled("kfxgen")'
