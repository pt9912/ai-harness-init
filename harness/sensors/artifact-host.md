# `make artifact-host` — Artefakt für den Host cross-kompiliert

## Vertrag

wie `artifact`, aber für den HOST cross-kompiliert (`TARGET_OS`/`TARGET_ARCH` aus `uname`, wie `host-bin`) statt den byte-identischen Default-Pfad zu nehmen ([`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix)/slice-048 unberührt) — für einen lokal lauffähigen Smoke auf einem Host, dessen Kernel/Architektur vom Docker-Build-Image abweicht (macOS, Windows, abweichendes CPU-Arch)

