# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files

# Base Image
FROM ghcr.io/ublue-os/bluefin-dx:44

COPY --from=ghcr.io/ublue-os/akmods-nvidia-lts:main-44 /rpms /tmp/akmods-rpms
RUN find /tmp/akmods-rpms/ublue-os/nvidia-install.sh
RUN IMAGE_NAME="" ./tmp/akmods-rpms/ublue-os/nvidia-install.sh

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
