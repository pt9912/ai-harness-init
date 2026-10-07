# Review — Cache-Status trägt *nicht bekannt* (slice-span-pflichtfeld-traegt-nicht-bekannt)

**Gegenstand:** Commits `91af2b67`, `9b05aba7` gegen den Plan `slice-span-pflichtfeld-traegt-nicht-bekannt`
(Schnitt `5b134ea5`, nur die Cache-Status-Hälfte). **Rolle:** Reviewer (Modul 10), frischer Kontext.
**Maßstab:** Plan · `modul-15-observability.md` am Tag `v6.16.0` (Welle 154) · `LH-FA-13`, `LH-FA-15` ·
`spec/spezifikation.md` §5 · `MR-075`, `MR-076` · `ADR-0011`, `ADR-0078` · `AGENTS.md` §3.6/§3.7.

**Summary:** 0 HIGH · 1 MEDIUM · 3 LOW · 1 INFO.

## Findings

### M-1 — `null` im Zähler wird zu `0`, beim Schreiben und beim Lesen

- `kategorie`: MEDIUM
- `quelle`: `SPEC-087` („nie `0`"), `AGENTS.md` §3.6
- `pfad`: `internal/span/response.go:188-194` (`count`), `internal/span/notknown.go:36-41`
- `befund`: `count` gibt für das JSON-Literal `null` einen Zeiger auf `0` zurück (`json.Unmarshal` in einen
  `int64` ist bei `null` ein fehlerfreies No-op). Eine Payload mit `"usage":{"cache_read_input_tokens":null}`
  ergibt einen Span mit `"cache_read_input_tokens":0` — eine Messung, die nie stattfand; und
  `CacheCount.UnmarshalJSON` liest `null` als Wert `0`, obwohl sein Kommentar *ohne Wert* zusagt. Der
  `count`-Kommentar („wird nie zu 0") hält damit ebenso nicht. Kein Test und kein Mutations-Fall deckt die
  `null`-Form.
- Beleg (Sonde in Kopie unter dem Scratchpad, `make test-go`):
  `PROBE-NULL-READ: null liest sich als Wert 0` ·
  `PROBE-NULL-EMIT: {… "input_tokens":0,"cache_creation_input_tokens":0,"cache_read_input_tokens":0}`
- `verifizierbar`: ja (Go-Test mit `null`-Payload)
- `klasse`: Toleranter Zahl-Parser liest JSON-null als Null

### L-1 — Fall 538 nennt einen Test, den ein anderer allein trägt

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.6, Reviewer-Skill (Mutations-Fall nennt einen Test, die Mutation färbt mehrere)
- `pfad`: `test/mutations/538-span-cache-status-fehlt.sh:3`, `spec/spezifikation.md` Zeile `SPEC-077`
- `befund`: Gegenprobe — `t.Skip` allein in `TestFailedAgentCallCapturesNothing`, Mutation 538 angewandt —
  bleibt rot über `TestCacheStatusIsMarkedNotKnown` (Teilfälle `Bash`, `Agent ohne usage`),
  `TestMandatoryFieldsAlwaysPresent` und `TestSchemaFields_PflichtIstDieDrahtform`. Das Weglassen
  läuft im Fehlschlag- wie im Erfolgsfall durch dieselbe Marshal-Stelle; der benannte Test bindet nichts,
  was die mitgefärbten nicht schon allein binden. `SPEC-077` führt 538 als Binder dieses Wächters.
- `verifizierbar`: ja (Gegenprobe wie beschrieben)
- `klasse`: Mutations-Fall zeigt auf redundanten Wächter

### L-2 — Die Meldung zu Fall 536 nennt die falsche Ursache

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.6 (Rot trägt die behauptete Ursache)
- `pfad`: `internal/span/notknown_test.go:139-140`, `internal/span/response_test.go:64-71`
- `befund`: Unter 536 (`0` statt Kennzeichnung) bricht `mustContain` zuerst ab mit
  „… fehlt in der Span-Zeile — ohne diese Gegenprobe waere der Waechter auch bei einer Erfassung von nichts
  gruen"; erfasst wurde aber `0`, nicht nichts. Die Prüfung, die genau diese Ursache meldet
  (`mustNotContain … ":0"`), ist unter 536 unerreichbar. Die Meldung nennt das Feld, die Begründung schickt
  in die Irre.
- `verifizierbar`: ja (`make test-go` mit angewandtem 536, Ausgabe gelesen)
- `klasse`: Generische Fehlermeldung trägt fremde Ursache

### L-3 — `SPEC-012` nennt `[]` einen Wert, die Ableitung liefert `[]` auch bei Lesefehler

- `kategorie`: LOW
- `quelle`: `SPEC-012`, `LH-FA-13` (Kriterium *Leer heißt unbekannt*)
- `pfad`: `spec/spezifikation.md` Zeile `SPEC-012`; `internal/span/emit.go:421-424`
- `befund`: `references` gibt bei einem Lesefehler der Slice-Datei `nil` zurück; der Span trägt dann
  `"slice":["slice-…"]` mit `"requirement":[]`, das `SPEC-012` neu als Wert *kein Bezug* (nicht
  *nicht bekannt*) festschreibt — der Wert ist dort aber unbekannt. `LH-FA-13` (Rang 1) liest einen leeren
  Pflichtwert allgemein als *unbekannt*; die Einordnung deckt sich mit der Erfassung nur, wenn das Lesen
  gelingt.
- `verifizierbar`: ja (Slice-Datei unlesbar, Span lesen)
- `klasse`: Leerwert-Einordnung ohne Fehlerpfad der Ableitung

### I-1 — Feldliste und gepinnter Träger auseinander bis zum Release

- `kategorie`: INFO (zuständig: Release-Schnitt)
- `quelle`: Plan §6, Risiko 3
- `pfad`: `Makefile:45` (`TRAEGER_TAG ?= v0.2.8`), `internal/span/fieldlist.go` (`SchemaFields`)
- `befund`: Bestätigt wie im Plan: die Feldliste wird per Reflexion aus dem Span-Typ gelesen und führt beide
  Cache-Zähler jetzt als Pflicht; der per `make traeger-fetch` geholte Träger `v0.2.8` lässt sie weg. Kein
  Sensor im Ziel hält Zeilen gegen die Feldliste.
- `verifizierbar`: nein (kein Gate)
- `klasse`: Emittierte Deklaration vor dem Träger-Release

## Gefahren

```sh
make mutate MUTATE_CASES="536-span-cache-status-null-statt-kennzeichnung 537-span-cache-status-leer-statt-kennzeichnung 538-span-cache-status-fehlt"
# 536 -> TestCacheStatusIsMarkedNotKnown rot · 537 -> dito · 538 -> TestFailedAgentCallCapturesNothing rot; 3 ok, 0 Befund(e)
# Kopie (git archive HEAD), Sonden-Test + make test-go: PROBE-NULL-READ / PROBE-NULL-EMIT rot, PROBE-OLD grün
# Kopie, Mutation 538 + t.Skip in TestFailedAgentCallCapturesNothing + make test-go: 4 Tests rot (L-1)
# Kopie, Mutation 536 + make test-go: Meldung gelesen (L-2)
make gates
```

## Geprüft, ohne Befund

- **(a) Konsumenten der Draht-Form:** `internal/report` dekodiert `span.Span` (`report.go:120`), liest keinen
  Cache-Zähler; `CacheCount.UnmarshalJSON` gibt nie einen Fehler zurück, keine Zeile fällt aus der Bilanz.
  Kein Shell-, bats- oder emittierter Leser nennt die Felder (`git grep cache_read_input_tokens`).
  Alt-Bestand gefahren: Zahl `7` liest sich als `7`, fehlendes Feld als *ohne Wert*.
- **(b) `SPEC-087` gegen `LH-FA-13`/`LH-FA-15`:** kein Widerspruch — die Kennzeichnung ist keine Zahl
  (*Haupt-Kontext trägt keine Zahl*) und keine Ableitung oder Schätzung; `agent_role` ist unberührt.
- **(c) Tests:** `TestCacheStatusIsMarkedNotKnown` prüft die wörtliche Spec-Zeichenkette, gemessene `0`
  bleibt Wert; `TestMandatoryFieldsAlwaysPresent` färbt unter `omitzero` (Gegenprobe). 536/537/538 färben
  ihren Wächter.
- **(d) Emittierte Feldliste:** aus dem Typ gelesen, Pflicht genau ohne `omitempty`;
  `TestSchemaFields_PflichtIstDieDrahtform` färbt unter `omitzero`.
- **Regeln:** `MR-076` steht noch (Aufhebung ist Architect-Arbeit, Plan §1); `MR-075`-Bindungsspalte an
  `SPEC-087` gesetzt; Kommentare im Diff tragen Zusage/Abgrenzung — Ausnahme die widerlegte Zusage in M-1.
