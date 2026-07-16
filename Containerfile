FROM scratch AS build-files
COPY build_files /

FROM scratch AS system-files
COPY system_files /

FROM scratch AS local-rpms
COPY local_rpms /

FROM ghcr.io/ublue-os/bluefin-dx:44

COPY --from=ghcr.io/ublue-os/akmods-nvidia-lts:main-44 /rpms /tmp/akmods-rpms
RUN find /tmp/akmods-rpms/ublue-os/nvidia-install.sh
RUN IMAGE_NAME="" ./tmp/akmods-rpms/ublue-os/nvidia-install.sh

RUN --mount=type=bind,from=build-files,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/00-cleanup.sh

RUN --mount=type=bind,from=build-files,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/10-packages.sh

RUN --mount=type=bind,from=build-files,source=/,target=/ctx \
    --mount=type=bind,from=local-rpms,source=/,target=/ctx/local_rpms \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/20-local-rpms.sh

RUN --mount=type=bind,from=build-files,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/30-copr.sh

RUN --mount=type=bind,from=build-files,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/40-gnome.sh

RUN --mount=type=bind,from=build-files,source=/,target=/ctx \
    --mount=type=bind,from=system-files,source=/,target=/ctx/system_files \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/50-system.sh

RUN bootc container lint
