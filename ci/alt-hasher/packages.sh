#!/usr/bin/env bash
set -euo pipefail
test "$(id -un)" = builder
grep -q '^0::/hasher.scope$' /proc/self/cgroup
workdir=/home/builder/hasher
packager=${ALT_HASHER_PACKAGER:?Set the package maintainer metadata}
mkdir -p /results/rpms
collect() {
    status=$?
    trap - EXIT
    if test -d "$workdir/repo"; then
        find "$workdir/repo" -type f -name '*.rpm' -exec cp -- {} /results/rpms/ \; || true
    fi
    exit "$status"
}
trap collect EXIT

printf '%s\n' '::notice title=ALT build stage::Fetching package repositories'
git clone --single-branch --branch sis_in --no-recurse-submodules \
    https://git.altlinux.org/people/majioa/packages/libimgui.git /home/builder/imgui
git clone --single-branch --branch packaging/alt --no-recurse-submodules \
    https://github.com/malbajun/ImGuiColorTextEdit.git /home/builder/editor
git -c safe.directory=/sources clone --no-hardlinks --no-recurse-submodules \
    /sources /home/builder/geogram
{
    git -C /home/builder/imgui log -1 --format='libimgui: %H %s'
    git -C /home/builder/editor log -1 --format='editor: %H %s'
    git -C /home/builder/geogram log -1 --format='geogram: %H %s'
} | tee /results/input-revisions.txt

# Each package is built in hasher; the same local RPM repository supplies the
# dependency chain. The maintainer ImGui source and spec are never modified.
for package in imgui editor geogram; do
    printf '::notice title=ALT build stage::gear-hsh: %s\n' "$package"
    (
        cd "/home/builder/$package"
        gear-hsh --workdir="$workdir" --nprocs=4 --mountpoints=/proc \
            --apt-config=/etc/apt/apt.conf.d/99-ci-repository-cache.conf \
            --packager="$packager" --verbose
    ) 2>&1 | tee "/results/$package-build.log"
    printf '::notice title=ALT build stage::Completed gear-hsh: %s\n' "$package"
done
printf '%s\n' 'All three projects built through gear-hsh.' > /results/rpm-builds.ok
