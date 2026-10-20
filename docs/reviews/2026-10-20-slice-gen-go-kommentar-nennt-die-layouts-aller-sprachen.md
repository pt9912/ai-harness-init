# Review slice-gen-go-kommentar-nennt-die-layouts-aller-sprachen

Diff: Commit 7cc9f961 (`internal/gen/gen.go`, 11+/15-), Basis d71e8cdd. Reviewer, frischer Kontext.
Gegen: Slice-Plan, ADR-0088/0094/0095/0096, AGENTS.md §3.6/§3.7, MR-071, MR-089, Reviewer-Skill.

## Findings

Keine HIGH, keine MEDIUM.

- kategorie: LOW
  quelle: Maintainability / Slice-Plan §6
  pfad: docs/plan/planning/in-progress/slice-gen-go-kommentar-nennt-die-layouts-aller-sprachen.md:94
  befund: Der Risiko-Satz „macht die sechs Pins zu einem Stand, der nicht mehr aus dem Baum reproduzierbar ist" ist am Branch-HEAD schon vor diesem Commit nicht mehr pruefbar: `git log --oneline v0.10.0..HEAD -- internal cmd | wc -l` -> 4 Commits mit Code nach dem Tag. Reproduzierbar ist der Tag-Stand, nicht der HEAD; der Ausgang bei Closure sollte das benennen statt „eingetreten mit Folge-Slice" zu erzwingen.
  verifizierbar: ja (Kommando oben)
  klasse: Risiko-Formulierung nennt den falschen Bezugsstand

- kategorie: INFO
  quelle: Slice-Plan §1/§4/§6, LH-QA-02
  pfad: Plan §4 Rueckfuehrung 1; §6
  befund: L2 (Implementer-Meldung: Kommentar -4 Zeilen aendert alle sechs SHA256SUMS; dritter Bau am Originalstand byte-gleich zum ersten) wird vom Plan getragen: §1 „oder der Slice nennt, warum", §2 L2 fragt genau das, §6 nennt die Byte-Aenderung als Risiko. Eine Zusage „Kommentar aendert nichts am Binary" existiert nicht (`git grep -nE 'Kommentar.{0,60}(Binar|Digest|Bytes)'` ausserhalb des Slice: kein Treffer; Dockerfile:101 nennt nur `-trimpath`/`-ldflags`; MR-050 betrifft den Cache-Schluessel). Der Plan-Satz „commit-unabhaengig" meint nur `-buildvcs=false`, nicht Quelltext-Unabhaengigkeit. Fuer die Closure zu benennen: (a) Rueckfuehrungs-Bedingung §4.1 ist eingetreten und durch Nutzerentscheidung (Kommentar behalten, Pin v0.10.0 bleibt) entschieden; (b) Ausgang des §6-Risikos; (c) die Ursache (Zeilentabelle/pclntab) ist NICHT isoliert, nur die Wirkung gemessen — nicht als Ursache zusagen; (d) der Makefile-Pin (`TRAEGER_TAG ?= v0.10.0`, Makefile:45) zeigt auf das veroeffentlichte Asset und bleibt unveraendert, kein Gate beruehrt.
  verifizierbar: nein (Messung nicht wiederholt, Auftrag)
  klasse: Messung ohne isolierte Ursache

- kategorie: INFO
  quelle: AGENTS.md §3.7 (Cutoff: Bestand kein Arbeitsauftrag)
  pfad: internal/gen/hexagonal_test.go:252; cmd/ai-harness-init/main_test.go:902-906; harness/tools/full-smoke.sh:3523-3530
  befund: Weitere Kommentare tragen slice-045a/053/058 als Erzaehlung (u. a. der Doc-Kommentar von TestGenerateArch_LangSpecificArchRejected: „unerreichbar zwischen slice-053 und slice-058"). Sie verweisen nicht auf den geaenderten Kommentar und widersprechen ihm nicht; Plan §1 schliesst sie ausdruecklich aus. `.d-check.yml:125` nennt nur den Pfad eines done-Slice.
  verifizierbar: ja (git grep)
  klasse: Slice-Nummer als Erzaehlung im Bestand

## Geprueft, ohne Befund

- Kommentar gegen Tabelle (Schwerpunkt 1): `sed -n 137,175p internal/gen/gen.go` — go flat+hexslice+hexagonal; cpp, kotlin, java, python, csharp flat+hexslice; stimmt Zeile fuer Zeile mit `langArchs()`. ADR-Verweise: Festlegung 4 in ADR-0094 und Festlegung 5 in ADR-0095/0096 sind Layout-Festlegungen (Fundstellen 0094:73, 0095:99, 0096:101); ADR-0088 ist ohne Nummer zitiert, nennt kotlin-Layouts (Z. 61).
- `TestGenerateArch_LangSpecificArchRejected` prueft cpp+hexagonal und `Available == flat,hexslice` (hexagonal_test.go:257ff): Aussage stimmt. full-smoke: `add-lang java apps/javahex --arch hexagonal` mit rc==2 (full-smoke.sh:2932-2934). Der Kommentar sagt „Exit-2-Fall" fuer den Binary-Aufruf, nicht fuer `make`; AGENTS.md §3.6 (make-Exit-2) ist nicht beruehrt, da der Aufruf (Binary, direkt gemessen) genannt ist. Der Satz „fail-fast Exit 2" ist unveraenderter Bestand derselben Art.
- Grenze „kein Sensor haelt diesen Kommentar gegen die Tabelle": `git grep -n langArchs -- '*_test.go'` -> nur ein Kommentar-Treffer (hexslice_test.go:127); stimmt. Die Mutations-Faelle 678/690/705/729/744/748 binden die Tabelle, nicht den Kommentar.
- §3.7: Indikativ, keine Verworfene-Alternative, keine Chronik, keine Slice-Nummern im neuen Block; Herkunft als ADR-Felder. Entfernte Chronik (slice-045a/053/058, „Review INFO-1") ist korrekt entfallen.
- Mutations-Anker (Schwerpunkt 2): alle 13 Faelle (17, 47, 54, 63, 444, 445, 678, 690, 705, 709, 729, 744, 748) verankern auf Codezeilen/Muster (gelesen); drei gegen den neuen Stand gezaehlt (`grep -cF`: UnknownLangError-Zeile 1, `"python": {archFlat, archHexslice},` 1, `Available: archsForLang(lang)}` 1). `make mutate-greift` -> `759 Fall/Faelle, 759 greifen, 0 Befund(e)`. Ob jeder Wächter rot wird, sagt es nicht; die CI-Probe auf `mutate/slice-gen-go-kommentar-nennt-die-layouts-aller-sprachen-7cc9f961` liegt beim Auftraggeber und ist hier nicht bewertet.
- Diff-Umfang: nur Kommentar, kein Code; MR-089 nicht beruehrt (keine Laufzeit-Aussage).
