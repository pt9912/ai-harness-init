# Review-Report: slice-traeger-tag-nachzug-untergrenze-v1 — 2026-11-28

**Review-Art:** Code — geprüft gegen Slice-Plan + ADRs.

**Gegenstand:** Tag-Schnitt `v0.11.0` auf `79eebb75` (Quell-Baum byte-identisch mit
`b06bf941` + Plan-Kopf — `git diff b06bf941 79eebb75` über `:!docs/plan` leer) und
die Pin-Commits auf `main`: `cbad2888` (Plan-Kopf), `c7cdbae5` (Pin-Kette),
`a5de6365` (releasing.md + je-Check-Keys).

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 ·
**Modell:** claude/glm-5.3-flash · **Datum:** 2026-11-28

**Eingangs-Kontext:**

- `slice-traeger-tag-nachzug-untergrenze-v1` (Plan, in-progress)
- ADR-0058 (Festlegung 2, 3), ADR-0059, ADR-0064, ADR-0063, ADR-0041, ADR-0115, ADR-0116
- `LH-QA-02`
- `AGENTS.md` §3 (Hard Rules) · MR-014 · ADR-0111

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | LOW | Die gebaute Fassung der Naht ist der Zwei-Züge-Fluss (Tag aus dem Quell-Stand, Pin-Commit nach der Publikation); ADR-0058 Festlegung 2 sagt, der Release-Schnitt „koppelt Pin und Werkzeug-Fassung im selben Commit" und sichert zu, ein Ziel führe danach einen Pin „zur jüngsten Release-Fassung". Die Neufassung in releasing.md beschreibt die zwei Züge und **zitiert** dabei die Festlegung, deren Wortlaut sie verlässt — ohne dass ein Folge-ADR die Naht auf die gebaute Form schiebt. Kein Implementer-Widerspruch: die prozedurale Richtung (Pin gegen die Publikation, gemessen) bleibt und ist hier sogar reproduziert — darum LOW mit Adressierung (Folge-ADR, gekoppelt an ADR-0115), keine blockierende Stufe. | ADR-0058 Festlegung 2 | `docs/user/releasing.md` · Schritt 2: „Der Pin-Commit folgt dem Tag-Commit" | nein — kein Gate liest ADR-Prosa gegen eine Prozedur; Träger ist Folge-ADR + dieser Review | „Pin-Naht vom ADR-Wortlaut gelöst, ohne Folge-ADR" |
| F-2 | LOW | Die Neufassung benennt den einen Schnitt zurückliegenden Fragment-Default („zeigt einen Schnitt zurück, und der nächste Schnitt hebt ihn"), aber nicht dessen Konsum-Folge: ein Ziel, das der v0.11.0-Träger emittiert, fetcht den v0.10.0-Träger — mit `[untergrenze]`-Konsum-Bruch, genau die Fassung, die der Pin-Nachzug trägt. Strukturell bestätigt: `git show 79eebb75:internal/emit/templates/enforce/traeger.mk` Zeile 25 = `v0.10.0`, und die Enforce-Vorlagen reisen per `//go:embed all:templates/enforce` (`internal/emit/enforce.go:28`) im Binary. | ADR-0058 Festlegung 2 (Fassungs-Fit-Zusage) | `docs/user/releasing.md` · Schritt 2, letzter Satz | nein — Doku-Grenze; der strukturelle Teil ist per Kommando reproduzierbar | „Grenze benannt ohne ihre Konsum-Folge" |
| F-3 | INFO | Der Anker `· seit slice-traeger-tag-nachzug-untergrenze-v1` hängt am `--version`-Satz (Inhalt ADR-0063, Injektions-Kanal), während der Satz, den dieser Schnitt einführt — der zurückliegende Fragment-Default — ohne Anker bleibt. | [`AGENTS.md`](../../AGENTS.md) §3.7 (Herkunft als ein auflösbares Feld) | `docs/user/releasing.md` · Schritt 2, letzter Satz | nein — kein Sensor liest Anker-Platzierung | „Herkunfts-Anker am Nachbar-Satz" |

**Zur Kategorie-Frage der Naht (Auftrag):** Festlegung 2 sagt „im selben Commit"; die
gebaute Fassung ist der Zwei-Züge-Fluss. Ich stufe **nicht** auf HIGH, weil (a) der
Implementer dem ADR nicht widerspricht — die Prozedur zitiert Festlegung 2 und misst
den Pin gegen die Publikation (`make traeger-pins-check TAG=v0.11.0`, hier
reproduziert, EXIT 0) —, (b) die Buchstaben-Form unter der Vertriebs-Fassung
physikalisch nicht mehr geschlossen werden kann: die Digests stammen seit ADR-0115
aus der CI-Publikation, nicht aus einem lokalen Vor-Bau, und (c) die Abweichung in
releasing.md offen, nicht still steht. Damit ist es kein Konflikt-Pfad je Modul 8;
die Schärfung als Folge-ADR (F-1) ist die Adressierung. Festlegung 2 bliebe sonst
zitierbar gegen jede künftige Release-Prozedur.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Pin-Kette je Stelle: `Makefile:53`, `internal/emit/templates/enforce/traeger.mk:25`, `test/traeger-fetch.bats:133–134` | geprüft, ohne Befund — `v0.11.0` einheitlich; die sechs `TRAEGER_SHA256_*`-Werte stammen aus der Publikation: `make traeger-pins-check TAG=v0.11.0` → „gleich — alle 6 Pins halten gegen die SHA256SUMS von v0.11.0", EXIT 0; Paarung nach Asset-Name nie nach Zeilenposition (`harness/tools/traeger-pins-check.sh` Kopf-Zeile 9) |
| Tap-Nachzug je ADR-0064 | geprüft, ohne Befund — `make tap-check TAG=v0.11.0` → „gleich — Tag v0.11.0, Tap-Kopf Formula/ai-harness-init.rb, sha256 `e259a7d8…`", EXIT 0 |
| Mutations-Fälle 554/555 (`test/mutations/554-traeger-tag-im-fragment-umbenannt-full-smoke.sh`, `555-…-pin-kopplung.sh`) | geprüft, ohne Befund — Anlage-Form (`files:`/`expect:`/`verify:`) vollständig; beide Fälle sind wertunabhängig (Umbenennung `TRAEGER_TAGX`) und vom v0.11.0-Bump nicht berührt; ihr Urteil läuft über den CI-Branch, kein lokales Beleganspruch hier |
| Commit-Form je MR-014 / `AGENTS.md` §3.8/§3.10 | geprüft, ohne Befund — alle drei Pin-Commits tragen Kennungen; kein Norm-Artefakt im Implementer-Zuschnitt |
| je-Check-Keys je ADR-0111 Festlegung 2 | geprüft, ohne Befund — `a5de6365` trägt die elf Keys des Endlaufs `8eb5c44c` (Implementer-Angabe `make gates` Exit 0, `mutate-greift` 824/824; die Keys selbst sind die Transport-Form) |
| `make gates` an diesem Lauf | Exit 0 — über dem Stempel-Fastpfad (ADR-0108 Festlegung 3: der je-Check-Stempel deckt den vollständigen Satz); kein voller Lauf im Review, Beleg bleibt der Stempel-Transport |
| `make traeger-fetch` / Konsum-Lauf am gefetchten Träger | **nicht von diesem Review gefahren** (Netz-Target nach Implementer-Bericht Exit 0, Digest gegen Pin; Konsum `archive-welle welle-fetch` Exit 0 am v0.11.0-Träger, v0.10.0 bricht an der Vorlage) — Verifier-Aufgabe gegen DoD, kein Befund |
| Grenze `[untergrenze]`-Rot (§3.6) | benannt, nicht behoben: die lokale Rot-Wiederholung des Alt-Trägers gelang der Implementierung nie (Implementer-Angabe, hier nicht reproduziert); der Rot-Beleg bleibt die echte CI-Lauf-Messung an `f6dd26c9`; die Grenze gehört in §7 der Closure |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 2 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** „Pin-Naht vom ADR-Wortlaut gelöst, ohne Folge-ADR" · „Grenze benannt ohne ihre Konsum-Folge" · „Herkunfts-Anker am Nachbar-Satz"

## Verdikt

**Merge-blockierend:** nein — kein HIGH, kein MEDIUM; die zwei LOW-Findings tragen
ihre Adressierung (F-1: Folge-ADR zur Festlegung-2-Naht bei der nächsten
Release-Prozedur-Berührung oder in einem eigenen Schnitt; F-2: eine Grenz-Satz-Ergänzung
im selben ADR oder an derselben Stelle).

**Übergabe:** Findings an den Implementer (Rückkante Review → Plan/Folge-ADR bei der
Naht); die Finding-Klassen gehen in die Slice-Closure §7 und von dort in den Zähler.
Dieser Report ist Lauf-Beleg; DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11).
