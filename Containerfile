FROM scratch AS cleanup-script
COPY build_files/00-cleanup.sh /

FROM scratch AS packages-script
COPY build_files/10-packages.sh /

FROM scratch AS local-rpms-script
COPY build_files/20-local-rpms.sh /

FROM scratch AS copr-script
COPY build_files/30-copr.sh /

FROM scratch AS gnome-script
COPY build_files/40-gnome.sh /

FROM scratch AS system-script
COPY build_files/50-system.sh /

FROM scratch AS system-files
COPY system_files /

FROM scratch AS local-rpms
COPY local_rpms /

FROM ghcr.io/ublue-os/bluefin-dx:44

COPY --from=ghcr.io/ublue-os/akmods-nvidia-lts:main-44 /rpms /tmp/akmods-rpms
RUN find /tmp/akmods-rpms/ublue-os/nvidia-install.sh
RUN IMAGE_NAME="" ./tmp/akmods-rpms/ublue-os/nvidia-install.sh


RUN --mount=type=bind,from=cleanup-script,source=/00-cleanup.sh,target=/ctx/00-cleanup.sh \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/00-cleanup.sh

RUN --mount=type=bind,from=packages-script,source=/10-packages.sh,target=/ctx/10-packages.sh \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/10-packages.sh

RUN --mount=type=bind,from=local-rpms-script,source=/20-local-rpms.sh,target=/ctx/20-local-rpms.sh \
    --mount=type=bind,from=local-rpms,source=/,target=/ctx/local_rpms \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/20-local-rpms.sh

RUN --mount=type=bind,from=copr-script,source=/30-copr.sh,target=/ctx/30-copr.sh \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/30-copr.sh

RUN --mount=type=bind,from=gnome-script,source=/40-gnome.sh,target=/ctx/40-gnome.sh \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/40-gnome.sh

RUN --mount=type=bind,from=system-script,source=/50-system.sh,target=/ctx/50-system.sh \
    --mount=type=bind,from=system-files,source=/,target=/ctx/system_files \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/50-system.sh

RUN bootc container lint
