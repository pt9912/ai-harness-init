# `make dcheck-fetch` — legt das d-check-Binary per OCI-Pull aus dem gepinnten Digest ab

## Vertrag

legt das d-check-Binary (`.harness/state/bin/d-check`) per **anonymem OCI-Pull nach Digest** aus dem gepinnten Image ab — Pin ist der gesetzte `DCHECK_DIGEST` aus `d-check.mk` (`grep -n '^DCHECK_DIGEST' d-check.mk`), dieselbe Summe, die der opt-in Image-Weg mit `docker run …@sha256:` referenziert; kein Prerequisite; braucht Netz an genau diesem Aufruf · seit slice-binraire-ziehen-ohne-docker

## Weg — die Messung, die die Wahl trägt

Der Kandidat „GitHub-Release der Quelle github.com/pt9912/d-check" trägt keine pinierbaren Binaries (`curl -s https://api.github.com/repos/pt9912/d-check/releases/latest` → `"assets": []`); der Klon+Build-Fallback hängt an einer zweiten Pin-Stelle (Source-Tarball ohne Prüfsummen-Asset) und an Host-go. Gewählt ist der Registry-Zug, weil er den bestehenden Digest-Pin **als denselben Pin** weiterführt — kein zweiter Pin-Bestand, die pinsync-Paarung `d-check.mk` ↔ `internal/emit/emit.go` bleibt unberührt.

## Die Zuordnung Digest ↔ Binary (an dieser Stelle, nicht an einer zweiten)

Die Byte-Kette: (1) die Index-Bytes hashen auf `DCHECK_DIGEST` — die Summe, die `docker run` referenziert (OCI-Index, Mehrplattform); (2) der Index nennt je Plattform deren Manifest-Digest, die Manifest-Bytes hashen auf ihren Eintrag; (3) das Manifest nennt je Layer ihren Blob-Digest, die Blob-Bytes hashen darauf — geprüft je Blob vor der nächsten Stufe; (4) das Binary wird aus einem geprüften Layer extrahiert (`tar`). **Was die Kette nicht eigen pint:** das tar-Member selbst — sein Name trägt die Zuordnung als Formular-Match (`d-check`), seine Bytes hängen an der Layer-Kette ([ADR-0059](../../docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)-Form Tag + Prüfsumme, fail-closed ohne eigenes Prüfsummen-Asset am Release).

Fail-closed: fehlt der Digest-Pin, haftet die Prüfform `sha256:<64-hex>` nicht, weichen Index/Manifest/Blob von ihrer Summe ab, fehlt das linux-Manifest der Host-Architektur, fehlt das Member — der Lauf bricht, ohne den Ablagepfad anzulegen.

## Anschluss an die Umgebungs-Zusage

Die `d-check`-Zeile des Inventars (`harness/tools/environment-inventory.txt`) trägt eine **ausdrücklich benannte** Erweiterung der Anwesenheit: außer dem `PATH` sieht die Prüfform die fetched Ablage (`probe_dcheck_ablage` in `harness/tools/environment-check.sh`, `DCHECK_CARRIER` überschreibt) — ohne Ablage bleibt der Umgebungs-Befund „Ist: fehlt". Die Probe misst Anwesenheit und Ausführbar-Form, nicht, dass es die gepinnte Fassung ist; die trägt dieser Fetch mit seiner Digest-Kette.

## Wächter

`test/dcheck-fetch.bats` hält die Kette hermetisch (Stubs für den Registry-Zug): Happy (Member gelegt, lauffähig, Kette je Aufruf), Negative für Index-, Blob- und Member-Abweichung je fail-closed ohne Ablage, Vorab-Fälle für fehlende Prüfsumme und falsche Prüfform.
