# `make artifact-host` — Artefakt für den Host cross-kompiliert

## Vertrag

wie `artifact`, aber für den HOST cross-kompiliert (`TARGET_OS`/`TARGET_ARCH` aus `uname`, wie `host-bin`) statt den byte-identischen Default-Pfad zu nehmen ([`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix)/slice-048 unberührt) — für einen lokal lauffähigen Smoke auf einem Host, dessen Kernel/Architektur vom Docker-Build-Image abweicht (macOS, Windows, abweichendes CPU-Arch)



Eine Hilfe ohne Anspruch: Host der Läufer `make full-smoke` und `make mutate` ist Linux, macOS ist dafür nicht getragen (`AGENTS.md` §3.9); ein Lauf über dieses Ziel ist kein Beleg. Das Produkt-Binary ([`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix)) bleibt davon unberührt.
