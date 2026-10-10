# MR-092 — d-check-Pin v0.86.1 (Go-Sicherheitsfix, Prüfverhalten unverändert)

- **Datum:** 2026-10-10
- **Wirksamkeits-Anlass:** slice-d-check-pin-bringt-den-go-sicherheitsfix;
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar),
  `internal/emit/emit.go` (emittierter Default-Pin), die Pin-Fassung der Kommentar-Blöcke
  `reviews` und `codepaths` in `internal/emit/templates/d-check.yml`; setzt
  [`MR-084`](../conventions.md#mr-084--d-check-pin-v0840-multi-arch-index-prüfverhalten-unverändert)
  fort. **Nicht** die Methode der Gegenmessung
  ([`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen))
  und **nicht** die Positions-Aussage von
  [`MR-086`](../conventions.md#mr-086--das-modul-reviews-bleibt-als-dritte-position-aus-dem-emittierten-doc-gate).
- **Ersetzt-Baseline-Regel:** keine. Nach dem Wortlaut der Eintrags-Vorlage ist der Eintrag damit
  ein **Fork**, aus demselben Grund wie `MR-084`: ein Pin-Sprung tritt an keine Baseline-Stelle.
- **Adaption.** Der Pin springt **v0.84.0 → v0.86.1** über die Zwischenstände `v0.85.0` und
  `v0.86.0`, Digest des **Index**
  `sha256:3e0b9779a71e2fa942960e8b961428fba036455c535513d34a75bfb799ffce0e`
  (`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.86.1` → MediaType
  `application/vnd.oci.image.index.v1+json`, Manifests `linux/amd64` und `linux/arm64`). Der
  lebende Pin steht in `d-check.mk`
  ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)).
  `--print-mk` unterscheidet sich zwischen den Digests in einem Hunk (`DCHECK_IMAGE`), das
  Fragment von `--print-mk` in sechs; die fünf Handgriffe aus
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) und
  [`MR-062`](../conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff)
  sind unverändert. Neu verfügbar wird kein Modul; geändert sind Vorgaben und Matching des Moduls
  `reviews`, das weder Dogfood noch Ziel fährt.

  **Der Grund des Sprungs ist die Go-Fassung**, gemessen am Binär beider Plattform-Manifeste
  (`docker cp /d-check` aus dem Plattform-Digest, dann `go version -m` im Go-Image der
  Dockerfile-`deps`-Stage): `linux/amd64` und `linux/arm64` je `go1.27.2`,
  `golang.org/x/net v0.60.0` (`v0.84.0`: `go1.27.1`). Welche Befunde die Fassung behebt, sagt das
  CHANGELOG des Werkzeugs, nicht dieser Eintrag.
- **Strenge-Bilanz — keine Senkung, keine Verschärfung.** Gegenmessung nach `MR-063` Setzung 2,
  netzlos, je Digest ein Lauf über einer `git archive`-Kopie von `43091527` (Angabe nach
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  Setzung 1: kein Objektspeicher), Digest per Override. Prüf-Bedingung
  ([`MR-067`](../conventions.md#mr-067--eine-aufbau-anleitung-nennt-ihre-prüf-bedingung-vor-ihren-kommandos)
  Setzung 1): `git ls-tree 43091527 .claude/rules/ | grep -c '^120000'` → 10, in der Kopie
  `find -type l` → 10 und `-type f` leer; Dogfood und Ziel fahren je neun Module
  (`grep -m1 '^modules:' .d-check.yml`), jedes hat in Stufe 3 bzw. 5 eine Basis. Mess-Protokoll,
  Sonden und Grund-Codes: Commit-Message von `4abafc4f`; die Zwischenstände in `144a2ad5` und
  `53107f53` ergeben dieselben Mengen.

  | Stufe | `v0.84.0` | `v0.86.1` | `diff` |
  |---|---|---|---|
  | Dogfood unverändert | 2659 Dateien, 0 Befunde | gleich | leer |
  | Marker entwertet | 97 Befunde (60 `codepath-missing`, 37 `id-unlinked`) | gleich | leer |
  | zusätzlich Sonden | 108 Befunde, 12 Grund-Codes, alle neun Module mit Basis | gleich | leer |
  | Ziel `--lang go` unverändert | 21 Dateien, 0 Befunde | gleich | leer |
  | Ziel mit Sonden | 23 Dateien, 9 Befunde, 9 Grund-Codes, alle neun Module mit Basis | gleich | leer |

  **Keine Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2); gemessen an `43091527`, einem Stand ohne diesen Eintrag. Die Sonden-Skripte bleiben
  unversioniert — dasselbe akzeptierte Negativ wie in `MR-084`.
- **`MR-086` gilt unverändert, ohne Kopf-Marke und ohne Vermerk.** Sein Auflösungs-Trigger tritt
  an `v0.86.1` nicht ein, und zwar in beiden Hälften (Sonden mit aktivem `reviews` im emittierten
  Ziel, Commit-Messages `724b63ff`, `53107f53`, `4abafc4f`; nachgeprüft in `a79d72a9`): ein frisches
  Ziel ohne Slice-Plan startet fail-closed rot (`review-missing`), auch mit `skip-pattern` und
  `skip-allows-empty`; und `match: name` deckt nur den längsten passenden Basisnamen — teilen zwei
  Namen ein Präfix, bleibt der kürzere ohne Report. Keine Aussage von `MR-086` wird damit abgelöst
  ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 4): seine Messung ist am Pin `v0.84.0` datiert und bleibt dort wahr.
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5):** gleiche Befundmengen in allen fünf
  Stufen.
- **Grenze.** Die Gegenmessung lief allein auf `linux/amd64`; für `arm64` ist nur die Go-Fassung
  gemessen — akzeptiertes Negativ wie in `MR-084`, weil Host und Gate-Job `amd64` fahren. Der
  Digest ist an seine Kopie gekoppelt (`TestDefaultDigest_MatchesCanonical`), nicht an das Image:
  kein Sensor hält ihn gegen den Tag (`BEO-ALL/pin-digest-ohne-waechter`). Die Pin-Fassung der
  `reviews`-Prosa hält `TestDCheckConfig_ReviewsBleibtKommentarBlock` an `emit.DefaultImage`, die
  der `codepaths`-Prosa hält kein Test — akzeptiertes Negativ, weil der nächste Pin-Sprung sie
  ohnehin nachmisst. Die Gegenmessung fährt den VCS-Port nicht. Die Adaptions-Liste in Zeile 2 von
  `d-check.mk` nennt diesen Eintrag nicht, wie bei `MR-084`. Datierte Momentaufnahme (`MR-053`).
- **Begründung.** Der Digest ist die Reproduzierbarkeits-Zusage
  ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); der Sprung tauscht die
  Go-Fassung des Werkzeugs, ohne sein Prüfverhalten zu bewegen. `MR-084` trägt keine Kopf-Marke.
- **Auflösungs-Trigger:** permanent, wie `MR-084`.
