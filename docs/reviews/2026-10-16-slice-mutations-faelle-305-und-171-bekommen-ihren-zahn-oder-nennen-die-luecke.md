# Review: slice-mutations-faelle-305-und-171-bekommen-ihren-zahn-oder-nennen-die-luecke

**Range:** Implementer `726cdd93` (`test/mutations/305-rollenachse-ziel-verliert-rolle-fullsmoke.sh`) und `1607085d` (`test/mutations/171-feldliste-ausserhalb-des-geprueften-bereichs.sh`) · **Plan:** `slice-mutations-faelle-305-und-171-bekommen-ihren-zahn-oder-nennen-die-luecke` (§1 Architect-Verdikt, §3, §4) · **Bezug:** LH-QA-01, LH-FA-15, LH-FA-10, LH-FA-13, ADR-0022 Festlegung 7, MR-071, MR-090, AGENTS.md §3.3/§3.5/§3.6/§3.7/§3.8/§3.10 · Reviewer-Skill (Stand HEAD). Nicht geprüft: DoD (Verifier).

**Summary:** 0 HIGH · 0 MEDIUM · 2 LOW · 2 INFO — annahmefähig. Ergebnis zu (a): Fall 305 misst die Eigenschaft an der tragenden Quelle, fällt allein an `rollen_typen_im_ziel`. Ergebnis zu (b): Fall 171 misst die Zusage „Feldliste im GEPRÜFTEN Bereich", Zahn ist die Zeile „laesst das docs-check des Ziels GRUEN".

## Findings

### LOW-1 — Kopf von 305 sagt „der einzige Vergleich, der die Rolle dann noch sieht", die Go-Tests sehen sie ebenfalls

- `kategorie`: LOW
- `quelle`: AGENTS.md §3.6 (Zusage nur, was ein Zahn hält), §3.7
- `pfad`: `test/mutations/305-rollenachse-ziel-verliert-rolle-fullsmoke.sh:16-18`
- `befund`: Der Satz „der einzige Vergleich, der die Rolle dann noch sieht, ist rollen_typen_im_ziel" gilt für die Stufen von `full-smoke.sh`. Dieselbe Mutation färbt unter `make test` auch `internal/emit/agents_test.go:50-54` und `internal/emit/rollen_kopplung_test.go:27-29` (Sechs-Rollen-Prüfung gegen `CanonicalRoles()`); der Fall `303-rollenachse-quelle-kuerzt` bindet dieselbe Kürzung über einen Go-Test. Der Fall ist nur für `# verify: full-smoke` vollständig, der Satz nennt den Geltungsbereich nicht.
- `verifizierbar`: ja (`grep -rln CanonicalRoles . --include='*.go'`; Fall 303)
- `klasse`: Exklusivitäts-Aussage im Fall-Kopf ohne Geltungsbereich

### LOW-2 — Beide Köpfe führen die Begründung als Konjunktiv über die verworfene Alternative

- `kategorie`: LOW (nach Skill-HIGH-Liste „Kommentar trägt keine der Kommentar-Klassen" erwogen; die Sätze tragen die Klasse Kopplung — warum zwei Dateien bzw. warum der Pfad stehen bleibt —, daher nicht HIGH)
- `quelle`: AGENTS.md §3.7
- `pfad`: `test/mutations/305-…sh:11-13` („Kuerzte nur CanonicalRoles, fiele der Lauf dort … und erreichte … nie"); `test/mutations/171-…sh:11-15` („verschoeben wir die Datei …, faellt die Stufe … und der Lauf erreicht die Zusage nie")
- `befund`: Beide Absätze beschreiben, was bei der nicht gewählten Mutation geschähe, im Konjunktiv bzw. als Bedingungssatz; der Zustand der gewählten Mutation (Handbuch-Baum bleibt grün; Pfad unverrückt) steht im jeweils zweiten Satz im Indikativ. Beschreibt die Stelle nach §3.7 der Indikativ-Zustand, bleibt der erste Satz die verworfene Alternative.
- `verifizierbar`: nein (kein Gate; `make comment-claims` liest keine Alternativen)
- `klasse`: Kopplungs-Begründung als Konjunktiv über verworfene Alternative

### INFO-1 — Lokale Fahrbarkeit hängt an `SMOKE_ARTIFACT_TARGET=artifact-host`, nirgends dokumentiert; Köpfe berührt es nicht

- `kategorie`: INFO
- `quelle`: AGENTS.md §3.6; `harness/sensors/mutate.md`
- `pfad`: `harness/sensors/mutate.md`, `harness/tools/mutate.sh` (kein Treffer für `SMOKE_ARTIFACT_TARGET`)
- `befund`: Auf macOS fährt `full-smoke.sh` ohne diese Variable `artifact` (Linux-Binary), `make full-smoke-host` setzt sie im Makefile (`Makefile:236`); `make mutate` reicht sie nur durch, wenn der Aufrufer sie setzt. Keine Zusage der beiden Köpfe nennt Host oder Plattform; keine Zusage wird berührt. Zuständig: Planner (Dokumentation des Treibers).
- `verifizierbar`: ja (`grep -rn SMOKE_ARTIFACT_TARGET harness/ Makefile`)
- `klasse`: Fahrbarkeits-Voraussetzung eines Falls undokumentiert

### INFO-2 — Erster Einzellauf von 305 fiel an Docker/colima, nicht am Fall

- `kategorie`: INFO
- `quelle`: `harness/sensors/mutate.md`; Slice §6 (Docker-Last, Ausgang weiter offen)
- `pfad`: Einzellauf Fall 305, erster Versuch
- `befund`: BEFUND „falscher Grund" (1.09 s) mit `ERROR: failed to build: … rpc error: code = Unavailable … EOF` in `make artifact-host` (colima, Einzelfall, ein Worker beansprucht). Der Wiederholungslauf desselben Falls war OK (8.66 s). Das Rot ist vom Fall unabhängig; der Treiber ordnet es als „falscher Grund" richtig ein, die Ursache liegt im Docker-Backend, nicht im Fall.
- `verifizierbar`: nein (nicht reproduzierbar)
- `klasse`: Docker-Backend-Aussetzer im Einzellauf

## Ergebnisse zu den Schwerpunkten

**(a) Fall 305.** `CanonicalRoles` steht wirklich in `internal/span/emit.go:174`; das `sed` greift auf die exakte `return`-Zeile, das Handbuch-`sed` löscht genau die Zeile `│       └── validator.md` (`docs/user/benutzerhandbuch.md:602`; Diffstat der angewandten Mutation: `benutzerhandbuch.md | 1 -`, `emit.go | 2 +-`). Die Handbuch-Kürzung ist nicht künstlich: Der Baum in §6 ist die Quelle, die die Stufe Handbuch-Baum gegen den Bestand frischer Ziele hält; er führt jede Rollen-Datei einzeln, ein gleichzeitig kürzender Mensch ändert beide. `# files:` mit zwei Dateien ist redlich: beide Anker greifen im Quellbestand (`make mutate-greift`: 653 Fälle, 653 greifen, 0 Befunde). Gegenprobe im Worktree mit angewandter Mutation und vollem `full-smoke.sh`: die drei Handbuch-Baum-Zeilen bleiben grün („94/13/15 Pfade … decken den Bestand"), danach exakt `FEHLER — Rollen-Typ fehlt (--lang go): .claude/agents/validator.md`, Exit 1. Es fällt nur `rollen_typen_im_ziel`.

**(b) Fall 171.** Die Mutation hängt `"harness/erfassung-feldliste.md"` an die exakte `scan.ignore`-Zeile (`internal/emit/templates/d-check.yml:16`); das Muster greift nur dort (`mutate-greift` grün). Der Pfad der Feldliste bleibt, der Handbuch-Baum bleibt grün (95/13/15 Pfade); Rot kommt aus `full-smoke.sh:996` („ein toter Verweis in harness/erfassung-feldliste.md laesst das docs-check des Ziels GRUEN: das Dokument liegt ausserhalb des geprueften Bereichs"), also genau der Zahn, der die Zusage aus ADR-0022 Festlegung 7 (GEPRÜFTER Bereich) misst — Datei-Anwesenheit (`feldliste_im_ziel`) bleibt grün. Der Wegfall der alten Pfad-Verschiebungs-Mutation ist im Kopf benannt („WARUM DER PFAD STEHEN BLEIBT"); die Pfad-Verschiebung bleibt an der Stufe Handbuch-Baum (Fälle 614/615) sichtbar und wird nicht mehr an der Feldlisten-Stufe gemessen; der Kopf sagt „wir sehen die Zusage nicht", nicht dass andere Fälle sie nicht sehen. Das ist die Grenze, und sie ist benannt.

Reproduzierte Einzelläufe (je allein, `SMOKE_ARTIFACT_TARGET=artifact-host`, `PATH=…gnubin`):

```text
mutate: [w1] 305-rollenachse-ziel-verliert-rolle-fullsmoke OK (8.66 s)
mutate: ok      305-rollenachse-ziel-verliert-rolle-fullsmoke -> FEHLER — Rollen-Typ fehlt rot
mutate: [w1] 171-feldliste-ausserhalb-des-geprueften-bereichs OK (8.92 s)
mutate: ok      171-feldliste-ausserhalb-des-geprueften-bereichs -> laesst das docs-check des Ziels GRUEN rot
mutate: TEILLAUF 1 von 653 — kein Beleg (der Beleg-Slot bleibt unberuehrt).
```

(Zwischen Wiederholung: erster 305-Versuch INFO-2.)

## Geprüft, ohne Befund

- **Zusage-Deckung beider Köpfe (§3.6):** jede Zusage (Handbuch bleibt grün; Quelle trägt sechste Datei; Feldliste im Ziel, Pfad unverrückt) steht als Gegenprobe am vollen `full-smoke.sh`-Lauf gesehen, siehe (a)/(b).
- **Anker-Redlichkeit (MR-071/MR-090):** beide `sed`-Muster greifen im Quellbestand; `make mutate-greift` 653/653.
- **Commit-Zuschnitt (§3.3/§3.8/§3.10):** zwei Commits, je ausschließlich eine Datei unter `test/mutations/`; kein Norm-Text, keine Closure-Artefakte, Slice-Datei unverändert; `harness/tools/full-smoke.sh` nicht berührt (Plan §3 sieht es nur für Variante (i) vor, gewählt ist (ii)).
- **Planabweichung:** Der Plan nennt für 305 „Datei-Anlage" als einzig herstellbares (ii); der Implementer wählt eine Handbuch-Kürzung im Gleichschritt. Das ist keine Norm-Änderung; es misst die vom Architect verworfene Herstellbarkeit neu (Handbuch-Baum führt jede Rolle einzeln) und widerlegt sie am Handbuch statt am Emissions-Code. Verdikt-Grenze (kein Carveout, keine Schwelle) bleibt gewahrt (§3.5).
- **Baum nach dem Lauf:** Worktree entfernt, `git status` sauber, kein Rest.
