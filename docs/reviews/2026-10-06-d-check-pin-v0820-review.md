# Review-Report: slice-d-check-pin-nimmt-die-authority-liste — 2026-10-06

Rolle Reviewer (Modul 10, `.harness/skills/reviewer.md`). Gegenstand: Implementer-Commit `6fb5058f`
(`d-check.mk`, `internal/emit/emit.go`, `harness/sensors/history-range-guard.md`) und
Architect-Commit `2d1d2a73` (`MR-080` samt Index-Zeile), gegen Plan §1–§4, `MR-079`/`MR-080`,
`MR-025`/`MR-058`/`MR-063`/`MR-065`/`MR-067`, `MR-032` Setzung 4 und `AGENTS.md` §3.5–§3.8.
Alle Läufe in Kopien unter dem Scratchpad; der Baum ist unverändert.

## Findings

### F-1 — MEDIUM — Re-Evaluierungs-Trigger einer Accepted-ADR feuert, `MR-080` nennt ihn nicht

- `quelle`: `ADR-0045` §Re-Evaluierungs-Trigger; `MR-080` §Kein ADR nötig, §Begründung
- `pfad`: `docs/plan/adr/0045-authority-wechsel-senkt-eine-richtung.md:386`;
  `harness/conventions/MR-080-d-check-pin-v0820-authority-nimmt-eine-liste.md` (Absätze *Kein ADR
  nötig* und *Begründung*)
- `befund`: `ADR-0045` führt den Trigger *„Wenn `authority` mehr als eine Datei nimmt … ist die Wahl
  der Autoritäts-Datei neu zu halten“*. Genau das macht `v0.82.0` verfügbar (CHANGELOG, Plan §1).
  `MR-080` sagt „Kein ADR nötig“ und „keine Aussage eines früheren Eintrags wird abgelöst“, nennt
  `ADR-0045` aber nicht. Wird der Trigger nicht geroutet, steht eine Accepted-Entscheidung weiter,
  deren Grund (*„alternativlos“*) weggefallen ist. Eine Senkung ist das nicht. Es fehlt der
  Übergang Planner → Architect → Planner beim Trigger-Audit der Slice-Closure (Modul 6, Tabelle
  *Träger im Repo ohne Wellen*).
- `verifizierbar`: nein — kein Gate liest Re-Evaluierungs-Trigger
- `klasse`: Pin-Sprung feuert Trigger einer Accepted-ADR ohne Nennung

### F-2 — MEDIUM — Konfigurations-Kommentar zur Schema-Grenze ist durch den Sprung falsch

- `quelle`: `AGENTS.md` §3.7 (Kommentar beschreibt, was da ist); Kontext-Eskalation Gate-Konfiguration
- `pfad`: `.d-check.yml:157-161`
- `befund`: Der Kommentar sagt *„`authority` nimmt genau eine Datei (Schema-Grenze des Moduls); die
  zweite doc-tables-Datei … trägt darum nur Richtung 2“*. Unter dem neuen Pin stimmt das nicht mehr:
  Die L3-Probe unten fährt `authority: [harness/README.md]` mit Exit 0 bzw. 2 wie bei der
  String-Form. Der Satz begründet die Gate-Konfiguration mit einer Grenze, die das gepinnte Werkzeug
  nicht mehr hat. Diff und `MR-080` lassen ihn stehen; `MR-080` schließt den `targets`-Block aus
  seinem Geltungsbereich aus, nicht seinen Kommentar. Ein Leser, der die Datei ändert, liest den
  Satz als Werkzeug-Grenze und richtet seine Entscheidung danach aus (vgl. F-1).
- `verifizierbar`: nein — `comment-claims` hält keine Werkzeug-Aussagen
- `klasse`: Werkzeug-Aussage im Bestand vom Pin-Sprung falsifiziert (passt zu
  `BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`)

### F-3 — INFO — die verwiesene Aufbau-Anleitung fährt nicht wörtlich nach

- `quelle`: `MR-067` Setzung 1; `MR-080` §Strenge-Bilanz („Kommandos wie in `MR-079`“)
- `pfad`: `harness/conventions/MR-079-d-check-pin-v0810-vcs-bricht-ueber-leerer-range-ab.md`
  (Kommandos, Ziel)
- `befund`: Wörtlich gefahren bricht `ai-harness-init --lang go` ohne Zielordner mit Exit 2 ab. Die
  Ziel-Sonden *„Kennung der ersten ADR“* (das Ziel hat keine ADR) und *„eine Zelle in
  `harness/README.md`“* (nur die Spalten `Vertrag`/`Tut was` in §Sensors sind begrenzt) geben
  keinen Befund. Die Prüf-Bedingung *jedes Modul hat eine Basis* fängt das. Mit `ADR-0001`
  als Text und einer Zelle in §Sensors ergibt sich die Zahl aus `MR-080`. Das ist Bestand in
  `MR-079` und geerbt, keine falsche Zahl.
- `verifizierbar`: ja — Nachfahrt unten
- `klasse`: Aufbau-Anleitung per Verweis nicht wörtlich nachfahrbar

## Gefahrene Belege

- **Pin:** `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.82.0` →
  `sha256:d28e9437…532e0c8`, gleich `d-check.mk:79` und `internal/emit/emit.go:33`; Tags an beiden
  Stellen `v0.82.0`. `diff` der zwei `--print-mk` (`OLD` `c6e61342…`, `NEW`) → ein Hunk
  (`DCHECK_IMAGE`). `diff <(--print-mk NEW) d-check.mk | grep -c '^[0-9]'` → 6.
- **Dogfood, Kopien aus `git archive 6fb5058f`, alte mit `d-check.mk` aus `6fb5058f~1`:**
  Symlinks 10 = `git ls-tree` 10, `find -type f` leer. Stufe 1: beide `2278 Datei(en) geprüft,
  0 Befund(e)`, `diff` leer. Stufe 2 (Marker entwertet, `-type f`): beide 39 `codepath-missing`,
  37 `id-unlinked`, `diff` leer.
- **Ziel `--lang go`** (`ai-harness-init --lang go --name rv <dir>` nach `git init`, alte Kopie per
  `sed` auf `v0.81.0`): unverändert beide `20 Datei(en)`, 0 Befunde. Mit Sonden beide `22 Datei(en)`,
  10 Befunde, alle sechs Module mit Basis (`target-missing`/`repo-escape`, `anchor-missing`,
  `id-unlinked`, `matrix-forbidden`, `span-unclosed`/`fence-unclosed`, `section-cell-oversized`),
  `diff` leer. Angabe nach `MR-065`: frisch emittiert, kein Objektspeicher.
- **L3 / `--doctor`:** zwei Kopien von `6fb5058f`, `authority: harness/README.md` gegen
  `[harness/README.md]`. Grün: `make doc-doctor` dreimal, getrennt und mit `2>&1` jeweils
  byte-gleich. Rot (ein `.PHONY`-Rezept `sonde-undok` ohne README-Zeile): `doc-targets` beide Exit 2,
  byte-gleich, `gate-undocumented`. `doc-doctor` fünfmal: getrennte Ströme 5/5 byte-gleich. Mit
  `2>&1` erscheinen zwei Reihenfolgen, **in beiden Konfigurationen** (String: 2×/3×, Liste: 1×/4×).
  Die zeilensortierten Ausgaben haben über alle zehn Läufe einen Hash. Die Begründung *„Verzahnung,
  nicht Inhalt“* trägt.
- **`history-range-guard.md`:** Z. 99 datiert die Tabelle jetzt auf `v0.81.0`, das stimmt. Die
  Präsens-Aussage Z. 108–109 (*„Am Modul `vcs` deckt der gepinnte Stand ihn selbst“*) gilt unter
  `v0.82.0`: `make -f d-check.mk doc-immutable RANGE=HEAD..HEAD` → `Range-Leerfall …`, Exit 2;
  `doc-commits` → `0 Befund(e)`, Exit 0 (vollständiger Klon, Arbeitsbaum).

## Negativbefunde

- Pin an beiden Stellen und Fragment-Abstand (Schwerpunkt a): ohne Befund, gemessen.
- `MR-080`, Zahlen und Kommandos (b): Jede Zahl der Tabelle hat ihr Kommando über `MR-079` mit den
  genannten Abweichungen. Stufen 1, 2, 4 und 5 nachgefahren, gleiche Zahlen. 2278 ist an `6fb5058f`
  genommen; am Kopf `2d1d2a73` sind es 2279, weil der Eintrag eine Datei hinzufügt. Der Eintrag
  bewegt also keine seiner Zahlen (`MR-058`). Die Grenzen nennen VCS-Port, Digest ohne Wächter,
  `authority` > 1 Datei und Kopfzeile 2; ohne Befund außer F-3.
- L3-Einschränkung auf getrennte Ströme (c): ohne Befund, nachgefahren.
- Satzänderung in `history-range-guard.md` (d): ohne Befund.
- Senkung/ADR-Pflicht (e): Die Befundmengen sind über alle gefahrenen Stufen gleich; keine Senkung,
  keine ADR-Pflicht nach §3.5. Davon getrennt ist der Trigger in F-1.
- `MR-032` Setzung 4 (keine Kopf-Marke an `MR-079`): Der Sprung löst keine Aussage von `MR-079` ab.
  Dessen Werkzeug-Aussagen nennen `v0.81.0` als Operand. Ohne Befund.
- §3.8 Commit-Zuschnitt: `2d1d2a73` berührt nur `harness/conventions.md` und den MR-Eintrag, die
  Rolle steht in der Message; `6fb5058f` berührt kein Architect-Artefakt. Ohne Befund.
- Kommentar-Regel §3.7 an den angefassten Zeilen von `d-check.mk` und `emit.go`: ohne Befund.

## Summary

Wiederkehrende Finding-Klassen: *Werkzeug-Aussage im Bestand vom Pin-Sprung falsifiziert* (F-2) ·
*Pin-Sprung feuert Trigger einer Accepted-ADR ohne Nennung* (F-1).

## Verdikt

Kein HIGH. Zwei MEDIUM (F-1, F-2) sind vor der Closure zu klären: F-1 ist ein Trigger-Audit-Posten
für Planner → Architect, F-2 ein Kommentar in der Gate-Konfiguration. Pin, Strenge-Bilanz und
L3-Aussage sind ohne Befund nachgemessen.
