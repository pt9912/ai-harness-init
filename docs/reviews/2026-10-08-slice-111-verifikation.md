# Verifikations-Bericht: slice-111 — 2026-10-08

**Rolle:** Verifier (Modul 11) · **Modell:** claude-opus-5-5 · **Datum:** 2026-10-08

**Gegenstand:** `8749d5b5`, `e2ce9549` gegen slice-111 §2 (DoD) und §3 (Plan). Der Review
`2026-10-08-slice-111-review.md` (LOW-1/2, behoben in `e2ce9549`) ist vollständig gelesen. Die
Verhaltens-Messungen sind deshalb Stichproben an einem eigenen, frisch gebootstrappten Ziel. Die
Rot-Belege stammen aus Mutationen in einem Klon im Scratchpad, nicht im Repo.

**Messaufbau:** `git clone` des HEAD in das Scratchpad, dort `make host-bin`, dann in einem leeren
Ordner `git init` und `ai-harness-init --lang go --name T .` (rc=0). Danach wurde der emittierte
Wrapper `.claude/hooks/span-emit.sh` **unter `umask 077`** mit zwei Payloads gefahren: Haupt-Kontext
`Read` und Subagent `verifier`/`Bash`.

## Verdikte je DoD-Punkt

| DoD | Verdikt | Beleg |
|---|---|---|
| (1) die acht Zeichenketten sind benannt oder einer Menge zugeordnet; `harness/mk/`-Kommentar <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) --> | **bestätigt** | Kommando aus §1 selbst gefahren: `span-report 10 · span-clean 7 · erfassung.mk 1 · erfassung-feldliste 3 · span-emit 2 · state/bin 4 · agent.role 1 · Rollen-Typ 3` — keine Zeile `0`. Die Namen stehen überwiegend in §4 *Was die Erfassung aufzeichnet*. §6 verweist darauf (Zeile 512). Das erfüllt das „oder" des DoD-Wortlauts *„§6 … oder README"* großzügig gelesen. Das Etikett `harness/mk/` lautet jetzt „make-Bausteine … — Prüfungen und Kommandos" (`grep -n 'Prüfungen und Kommandos' docs/user/benutzerhandbuch.md` → 535) und zählt die Klassen nicht mehr auf. <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) --> Kein Gate färbt den Punkt rot. Das steht so in der DoD. |
| (2) der Baum sagt, ob er aufzählt oder zusammenfasst | **bedingt — Abnahme-Frage an den Planner** | Der Baum **zählt auf** und sagt das an genau einer Stelle (`grep -n 'Der Baum nennt jede Datei'` → 504). Er wird seit slice-191 von `harness/tools/handbuch-baum.sh` in `make full-smoke` gegen den realen Bestand gehalten (`full-smoke.sh:446,458`). Den Satz, den die DoD verlangt — wie ein Adopter die Menge selbst erhebt (`make help`, Blick in `harness/mk/`) —, gibt es nicht: `make help` erscheint nur als Baum-Etikett in Zeile 519. <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) --> Der Punkt ist durch slice-191 überholt: Statt einer ausgesprochenen Zusammenfassung gibt es jetzt eine bewachte Aufzählung. Ob der Planner das als *erfüllt* oder als *gegenstandslos* bucht, entscheidet er. Der Implementer hat das in §3 als Übergabe benannt. |
| `make gates` grün | **bestätigt** | `.harness/state/gates-passed.head` = `e2ce9549…` = HEAD, darum kein erneuter Lauf. CI `37825843605` auf HEAD lief bei Abfassung noch (`in_progress`). |
| Doku-Update (hier der Gegenstand) | **bestätigt mit Befund V-1** | siehe unten |

## Die geänderten Aussagen am Ziel gemessen

- **Ablage ohne Dateinamen-Zusage:** Laut Handbuch liegen die Spans unter `.harness/state/spans/`,
  „getrennt nach Sitzung und Agent in eigene Dateien". Gemessen: `s1.jsonl` (Haupt-Kontext) und
  `s1-a1.jsonl` (Subagent), dazu `.seq`/`.lock`. `git check-ignore -v` → `.harness/.gitignore:6:state/`.
  Die Aussage stimmt; der Review-Befund LOW-1 ist erledigt.
- **0600, Verzeichnis auflistbar:** Gemessen unter `umask 077` wurden alle Span-Dateien als
  `-rw-------` angelegt, das Verzeichnis mit `755`. Der Träger setzt den Verzeichnis-Modus
  ausdrücklich (`internal/span/emit.go:255–263`, `os.Chmod(dir, 0o755)`), die Dateien mit `0o600`
  samt `f.Chmod` (Zeilen 312, 318). Beide Sätze — im Handbuch Zeile 433 und in der emittierten
  `harness/erfassung-feldliste.md` des Ziels — stimmen mit dem Verhalten überein.
- **`agent_role`:** `verifier` → `"verifier"`, Haupt-Kontext → `"nicht bekannt: agent_type"`. Unter
  `.claude/agents/` liegen die sechs Rollen-Typen. README-Satz und §4 stimmen.

## Rot-Belege (Bewusstes Brechen, im Klon)

- **Feldlisten-Satz:** In `internal/span/fieldlist.go` wurde „Seine Dateien entstehen **nur für den
  Eigentümer lesbar** (Modus 0600); das" ersetzt durch „und **nicht zugriffsbeschränkt**; das". Mit
  `make test-go` → `--- FAIL: TestFeldliste_GrenzeUeberDenBestand` und
  `fieldlist_test.go:191: … fuehrt die Grenze "keine Zusage über den Bestand" nicht vollstaendig —
  es fehlt: "**nur für den Eigentümer lesbar**"`. Das ist die richtige Ursache. **Grenze:** Der
  Test hält die Wendung, nicht „(Modus 0600)" und nicht den Satz über das auflistbare Verzeichnis.
  Diese beiden Teile kann man streichen, ohne dass ein Test rot wird. Die Zeile in `full-smoke.sh`
  (`"… ist wenig zugesagt"`) ist gelesen, aber nicht gefahren.
- **Verhalten hinter der Aussage:** In `emit.go` wurde der Modus in Zeile 312 und 318 auf `0o644`
  gesetzt. Mit `make test-go` → `--- FAIL: TestModeIsOwnerOnly` und
  `span_test.go:842: Modus = -rw-r--r--, erwartet 0600`. Das ist die richtige Ursache.
  `TestModeIsOwnerOnly` hat keinen Fall in `test/mutations/`
  (`grep -rln TestModeIsOwnerOnly test/mutations` → leer). Der Wächter, auf den sich die neue
  Doku-Aussage stützt, ist also nicht durch `make mutate` gegen Zahnverlust gesichert.

## Plan-vs-Code

- **V-1 (Zusage/Regel): Gebaut ohne Plan, und gegen eine Accepted-ADR.** §3 setzt die Ebene auf
  „die Nutzer-Doku dieses Repos, **nicht** die emittierte Doku eines Ziels" und `spec/`, `adr/` auf
  unverändert. `e2ce9549` ändert aber die **emittierte** Feldliste (`internal/span/fieldlist.go`
  `limitStore`), ihren Test und `full-smoke.sh`. Dadurch weicht der emittierte Satz von zwei
  höherrangigen Quellen ab:
  - `spec/lastenheft.md:356–357` (`LH-FA-14` §Redaktion): *„er ist gitignored, nicht verschlüsselt
    und nicht zugriffsbeschränkt"*;
  - `ADR-0022` (Accepted) Festlegung 6 Stück 3, Zeile 520: Der Satz *„… nicht zugriffsbeschränkt
    …"* ist im Ziel **geschrieben** zu führen.

  In der Sache hat der Code recht: 0600 gilt schon vor diesem Slice. Die Rangordnung (§2) verlangt
  aber, die niedrigere Quelle anzupassen und nicht die höhere still zu überholen. Außerdem wird aus
  der „ausgesprochenen Nicht-Zusage" jetzt eine teilweise **Zusage** („wenig zugesagt", 0600).
  **Offene Auftraggeber-Frage** (Planner → Auftraggeber/Architect): ein Change Request zu `LH-FA-14`
  nach `MR-015` und eine Folge-ADR zu `ADR-0022` Festlegung 6.3 — oder die Rücknahme des
  emittierten Satzes. Der Slice-Plan nennt keine der Optionen.
- **Nebenbefund:** Der Kopfkommentar von `test/mutations/169-feldliste-grenze-bestand-weg.sh`
  (Zeilen 6–7) beschreibt weiter „nichts zugesagt … nicht zugriffsbeschraenkt". Der Fall selbst
  greift weiterhin, denn er streicht `limitStore` ganz. Die Datei wurde nicht angefasst, nach
  §3.7-Cutoff also kein Pflichtnachzug. Sie gehört aber zur selben Klärung.
- Umgekehrte Richtung (geplant, nicht gebaut): `AGENTS.md` §4 und `harness/README.md` sind
  unverändert. §3 begründet das (zwei Ebenen). Ohne Befund.

## Negativbefunde

- **Handbuch-Setzung:** Die hinzugefügten Zeilen in `README.md` und `docs/user/benutzerhandbuch.md`
  enthalten keine `LH-`/`ADR-`/`MR-`/`slice-`-Kennung und keine Chronik-Wörter
  (`git diff 8749d5b5^ e2ce9549 -- README.md docs/user/benutzerhandbuch.md | grep '^+' | grep -cE 'LH-|ADR-|MR-|slice-|seit |früher|künftig'` → 0).
- **Rest-Vorkommen von „zugriffsbeschränkt":** Außer im Lastenheft, in `ADR-0022` und im
  Kommentar von Fall 169 kommt die Wendung nicht mehr vor, insbesondere nicht in `docs/user/` und
  nicht in `README.md`.

## Offene Punkte

1. **Planner:** DoD (2) als *erfüllt* oder *gegenstandslos* buchen — der Baum zählt seit slice-191
   auf und ist bewacht.
2. **Auftraggeber/Architect:** V-1 — `LH-FA-14` und `ADR-0022` Festlegung 6.3 widersprechen dem
   emittierten Satz und dem Handbuch. Zu entscheiden ist zwischen einem CR mit Folge-ADR und der
   Rücknahme.
3. **Planner (Register oder Folge):** Für `TestModeIsOwnerOnly` gibt es keinen Mutations-Fall.
   `TestFeldliste_GrenzeUeberDenBestand` hält „(Modus 0600)" und „Verzeichnis auflistbar" nicht.
