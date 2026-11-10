# ALT Geogram 1.10.1 verification

The trusted push job builds three projects through `gear-hsh`, in dependency
order: the unchanged maintainer `libimgui` branch `sis_in`, the published editor
`packaging/alt` branch, and this Geogram checkout. The local hasher RPM repository
supplies dependencies between builds. Source revisions and all resulting RPMs
are retained in the Actions artifact for 14 days.

Geogram uses its system dependency mode, the standalone editor built with
`ENABLE_GEOGRAM=ON`, and system ImGui backends. Lua stays disabled as in the
original ALT packaging. The small ImGui string adapter is compiled as Geogram
application support; it does not duplicate or modify ImGui core.

Success requires ten runtime/devel/application RPMs, actual clean-chroot builds,
normal APT installation and an independent CMake consumer. Consumer tests cover
editor load/clear, OpenNL context creation and TetGen/Triangle triangulations.
Missing outputs or failed geometry checks fail the job.

This uses the proven disposable rootful GitHub runner/container setup. The
managed workspace's rootless Docker cannot start hasher; it can still be used
for ordinary native configuration/build diagnostics. No GitHub token is passed
into the container. Only trusted branch pushes/manual runs trigger the workflow.

Keep `.gear` updates in their own final commit at the branch tip. Source, CMake
and CI changes precede that packaging commit.
