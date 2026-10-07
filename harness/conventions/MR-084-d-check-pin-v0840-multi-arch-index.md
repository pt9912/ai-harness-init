# MR-084 — d-check-Pin v0.84.0 (Multi-Arch-Index, Prüfverhalten unverändert)

- **Datum:** 2026-10-07
- **Wirksamkeits-Anlass:** slice-pin-d-check-v0840-und-a-check-v0230;
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar),
  `internal/emit/emit.go` (emittierter Default-Pin); setzt
  [`MR-082`](../conventions.md#mr-082--d-check-pin-v0830-targetsauthority-disjoint-verfügbar-aktiv-nur-im-emittierten-ziel)
  fort. **Nicht** der a-check-Pin desselben Slice — er ist allein emittiert und tritt an keine
  Stelle dieses Blocks — und **nicht** die Methode der Gegenmessung
  ([`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)).
- **Ersetzt-Baseline-Regel:** keine. Nach dem Wortlaut der Eintrags-Vorlage ist der Eintrag damit
  ein **Fork**, aus demselben Grund wie
  [`MR-082`](../conventions.md#mr-082--d-check-pin-v0830-targetsauthority-disjoint-verfügbar-aktiv-nur-im-emittierten-ziel):
  ein Pin-Sprung tritt an keine Baseline-Stelle.
- **Adaption.** Der Pin springt **v0.83.0 → v0.84.0**, Digest
  `sha256:e82ef2d21c45dcb6fd280f8d7071e9f757c6b0f070cfb3807a70fd5822811bba`
  (`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.84.0` → MediaType
  `application/vnd.oci.image.index.v1+json`, Manifests `linux/amd64` und `linux/arm64`). Der
  gepinnte Digest ist der des **Index**, nicht eines Plattform-Manifests; der Docker-Hub-Spiegel
  trägt laut CHANGELOG des Werkzeugs denselben Index-Digest. Der lebende Pin steht in `d-check.mk`
  ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)).
  `--print-mk` unterscheidet sich zwischen den Digests in einem Hunk (`DCHECK_IMAGE`); das
  Fragment weicht von `--print-mk` in sechs Hunks ab (Kommando im Kopfkommentar von `d-check.mk`),
  die fünf Handgriffe aus
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) und
  [`MR-062`](../conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff)
  sind unverändert. Neu verfügbar wird kein Modul und kein Schalter.
- **Strenge-Bilanz — keine Senkung, keine Verschärfung.** Gegenmessung nach
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
  Setzung 2, netzlos, je Digest ein Lauf über einer `git archive`-Kopie von `1efbab43` (Angabe
  nach
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  Setzung 1: kein Objektspeicher); Lauf und Auswertung wie in `MR-082`, Sonden wie dort neu
  geschnitten. Mess-Protokoll samt Sonden-Liste: Commit-Message von `cb808e89`.

  **Prüf-Bedingung vor dem Lauf**
  ([`MR-067`](../conventions.md#mr-067--eine-aufbau-anleitung-nennt-ihre-prüf-bedingung-vor-ihren-kommandos)
  Setzung 1): `git ls-tree 1efbab43 .claude/rules/ | grep -c '^120000'` → 10, in der Kopie
  `find .claude/rules -type l` → 10 und `-type f` leer; in Stufe 3 hat jedes aktive Modul eine
  Basis (`grep -m1 '^modules:' .d-check.yml` in Dogfood und Ziel).

  | Stufe | `v0.83.0` | `v0.84.0` | `diff` |
  |---|---|---|---|
  | Dogfood unverändert | 2392 Dateien, 0 Befunde | gleich | leer |
  | Marker entwertet | 83 Befunde (46 `codepath-missing`, 37 `id-unlinked`) | gleich | leer |
  | zusätzlich Sonden | 94 Befunde, 12 Grund-Codes, alle neun Module mit Basis | gleich | leer |
  | Ziel `--lang go` unverändert | 21 Dateien, 0 Befunde | gleich | leer |
  | Ziel mit Sonden | 23 Dateien, 11 Befunde, 10 Grund-Codes, alle sieben Module mit Basis | gleich | leer |

  **Keine Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2); gemessen an `1efbab43`, einem Stand ohne diesen Eintrag. Die Sonden-Skripte bleiben
  unversioniert — dasselbe akzeptierte Negativ wie in `MR-082`.
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5):** gleiche Befundmengen in allen fünf
  Stufen; das CHANGELOG des Werkzeugs nennt für `v0.84.0` keine Änderung des Prüfverhaltens.
- **Grenze.** Gemessen ist allein `linux/amd64`; das `arm64`-Manifest unter demselben Index lief
  nicht, seine Gleichheit ist eine Aussage des Werkzeugs, nicht dieses Eintrags — akzeptiertes
  Negativ, weil Host (`uname -m` → `x86_64`) und der Gate-Job in `.github/workflows/ci.yml`
  (`runs-on: ubuntu-24.04`) `amd64` fahren. Der Digest ist an seine Kopie in
  `d-check.mk` gekoppelt (`TestDefaultDigest_MatchesCanonical`), nicht an das Image: kein Sensor
  hält den Digest gegen den Tag (`BEO-ALL/pin-digest-ohne-waechter`). Die Gegenmessung fährt den
  VCS-Port nicht (`git archive`-Kopie). Die Adaptions-Liste in Zeile 2 von `d-check.mk` nennt
  diesen Eintrag nicht — dasselbe akzeptierte Negativ wie in `MR-082`. Datierte Momentaufnahme
  (`MR-053`).
- **Begründung.** Der Digest ist die Reproduzierbarkeits-Zusage
  ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); der Index-Digest macht
  sie auf beiden Plattformen und über beide Registries mit **einem** Wert lesbar. Keine Aussage
  eines früheren Eintrags wird abgelöst
  ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 4); `MR-082` trägt keine Kopf-Marke.
- **Auflösungs-Trigger:** permanent, wie `MR-082`.
