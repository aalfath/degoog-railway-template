# degoog 1.2.0, the official multi-arch image, pinned by tag and digest.
# Update: bump the tag and digest together and add a CHANGELOG.md entry.
FROM ghcr.io/degoog-org/degoog:1.2.0@sha256:c3a975a2c512300aae942b2d8713be643e457dabf2475adf187536a4a6c6b3dd

COPY railway-start.sh /railway-start.sh
RUN chmod 0755 /railway-start.sh

# All state (settings, installed extensions, themes, indexer, blocklist) lives in
# /app/data, which the template mounts as a Railway volume.
EXPOSE 4444

ENTRYPOINT ["/railway-start.sh"]
