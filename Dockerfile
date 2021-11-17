FROM --platform=$TARGETPLATFORM alpine:latest

ARG TARGETPLATFORM
ARG TARGETARCH
ARG OVERLAY_VERSION="v2.2.0.3"
ARG OVERLAY_KEY="6101B2783B2FD161"

ENV DEBUG="false" \
    AccessFolder="/mnt" \
    RemotePath="mediaefs:" \
    MountPoint="/mnt/mediaefs" \
    ConfigDir="/config" \
    ConfigName="rclone.conf" \
    MountCommands="--allow-other --allow-non-empty" \
    UnmountCommands="-u -z" \
    Proxy="false" \
    ProxyTarget="host.docker.internal" \
    ProxyPort="1087"

RUN apk --no-cache upgrade \
    && apk add --no-cache --update ca-certificates fuse fuse-dev curl gnupg bash unzip \
    && echo "TargetPlatform is ${TARGETPLATFORM}" \
    && echo "TargetArch is ${TARGETARCH}" \
    && echo "OverlayArch is ${TARGETARCH/arm64/aarch64}" \
    && echo "Installing S6 Overlay" \
    && curl -o /tmp/s6-overlay.tar.gz -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${TARGETARCH/arm64/aarch64}.tar.gz" \
    && curl -o /tmp/s6-overlay.tar.gz.sig -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${TARGETARCH/arm64/aarch64}.tar.gz.sig" \
    && gpg --keyserver pgp.surfnet.nl --recv-keys ${OVERLAY_KEY} \
    && gpg --verify /tmp/s6-overlay.tar.gz.sig /tmp/s6-overlay.tar.gz \
    && tar xzf /tmp/s6-overlay.tar.gz -C / \
    && echo "install rclone" \
    && curl https://rclone.org/install.sh | bash \
    && mkdir -p /usr/local/sbin/ \
    && cp /usr/bin/rclone /usr/local/sbin/ \
    && apk del curl gnupg \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

COPY rootfs/ /

VOLUME ["/mnt"]

ENTRYPOINT ["/init"]

# Use this docker Options in run
# --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined
# -v /path/to/config/.rclone.conf:/config/.rclone.conf
# -v /mnt/mediaefs:/mnt/mediaefs:shared
