# Review-Report: Nachprüfung der vier Findings zu `slice-commit-traeger-wird-skip-if-present` — 2026-09-16

**Review-Art:** **Nachprüfung der eigenen Findings** aus
[`2026-09-16-slice-commit-traeger-wird-skip-if-present.md`](2026-09-16-slice-commit-traeger-wird-skip-if-present.md)
— nicht die Lieferung neu, sondern je Befund: ist er behoben, und so behoben, wie er formuliert war?
Der Gegenstand dieses Teils ist **F-1 (HIGH), F-2 (MEDIUM), F-4 (LOW), F-5 (LOW)**; **F-3** bleibt
beim Planner (eingefrorene Message) und ist hier nur als offen benannt, **F-6** (INFO) war nicht
Gegenstand des Auftrags und ist unberührt. Kein DoD-Review (Verifier, Modul 11).

**Gegenstand:** Commit `65b78423` („Rolle Implementer: … vier Mutations-Faelle greifen wieder, drei
Aussagen gehen auf den Indikativ", **7 Dateien, +15/−16**) und, für F-2, Commit `919f163a` („Rolle
Architect: ADR-0055 …", 2 Dateien, +325). Beide gegen den von mir geprüften Stand `d7fd8227`.
Die Form-Runde für `ADR-0055` liegt getrennt: [`2026-09-16-adr-0055-konsistenz.md`](2026-09-16-adr-0055-konsistenz.md).

**Skill:** `.harness/skills/reviewer.md` @ `0565f274` (2.0.0) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** deepseek-v4.1-flash:cloud[1m] · **Datum:** 2026-09-16

**Kein Self-Review — als Negativ-Aussage:** Dieser Lauf hat an `65b78423` und `919f163a` **nicht**
geschrieben — kein Byte an `test/mutations/**`, `internal/emit/**`, `harness/README.md`, `ADR-0055`
oder ihrem Index-Eintrag. Die einzigen von diesem Lauf geschriebenen Dateien sind dieser Report und
sein Schwester-Report. **Keine Zahl dieses Reports ist aus der Rückgabe übernommen:** die vier Fälle
sind je in einer eigenen Kopie unter `/tmp` gefahren, jede Fehlschlag-Ausgabe ist gelesen, und die
Trefferzahl jedes neuen Ankers ist am Ziel gemessen (§Eigene Messungen).

**Eingangs-Kontext:** der eigene Report vom 2026-09-16 · `65b78423` · `919f163a` ·
[`ADR-0054`](../plan/adr/0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 1 und 3 ·
[`ADR-0007`](../plan/adr/0007-bootstrap-phasen.md) Festlegung 3 · [`AGENTS.md`](../../AGENTS.md)
§3.6/§3.7/§3.11 · `harness/tools/mutate.sh` Bedingungen 2 und 4 · Baseline `v6.8.0` ·
`regelwerk/modul-08-agentenrollen.md`, `regelwerk/modul-10-review-harness.md`.

---

## Eigene Messungen

```sh
# je Fall eine Kopie unter /tmp (tar ohne .git), Mutation fahren, Hash der Zielliste vor/nach,
# dann make test-go und die '--- FAIL:'-Zeilen gegen die '# expect:'-Zeile halten
for m in 157-hook-wrapper-nicht-emittiert 164-rollentypen-konvergent \
         50-skipifpresent-clobbert 354-agenten-kanal-geht-ins-ziel; do
  (cd "$d" && bash test/mutations/$m.sh) && (cd "$d" && make test-go) | grep -oE -- '--- FAIL: [A-Za-z_0-9]+'
done
# -> alle vier: angewandt · stage_rc=2 · kein Uebersetzungsabbruch · der genannte Waechter faellt
#    157 -> --- FAIL: TestEnforce_ErfassungLiegtMitDemTraeger    (+ TestEnforce_WrapperSuchtDenAblageort)
#    164 -> --- FAIL: TestAgents_SkipIfPresent                    (agents_test.go:249 planner.md clobbert)
#    50  -> --- FAIL: TestTemplates_SkipIfPresent                 (+ TestRootReadme_/TestTemplates_Skills/
#                                                                   TestArchGate_IdempotenzKlassen)
#    354 -> --- FAIL: TestCommitMsgTraeger_ZielTraegtNurDenGitKanal

# Trefferzahl jedes neuen Ankers im Ziel — die Vorbedingung dafuer, dass die Mutation greift
grep -c '{src: "templates/enforce/span-emit.sh",' internal/emit/enforce.go      # 1  (157)
grep -c 'class: SkipIfPresent,' internal/emit/agents.go                        # 1  (164)
grep -c 'return nil // vorhanden' internal/emit/enforce.go                     # 1  (50)
grep -c 'commitMsgHookFile(),' internal/emit/enforce.go                        # 1  (354)
# und die getroffene Stelle selbst, am mutierten Baum gelesen:
#   157: enforce.go verliert GENAU die eine Zeile der Menge (diff gegen HEAD: 180d179)
#   164: agents.go:52  class: Konvergent  -> der Writer liest f.class
#   50 : writeSkipIfPresent schreibt im vorhanden-Fall ueber writeFileMode
#   354: enforce.go:135 ein zweiter Eintrag mit "commit-msg" im Zielpfad

# F-4 und F-5 am Zielartefakt gelesen (keine Messung, ein Lesen):
sed -n '153,160p' harness/README.md
sed -n '51,56p' internal/emit/commitmsg.go ; sed -n '244,252p;436,444p;449,456p' internal/emit/enforce.go

# F-2: der Traeger der abgeschafften Kennung
grep -rn 'TestEnforce_Convergent' --include='*.go' . | wc -l      # 0
grep -n 'ADR-0055' docs/plan/adr/README.md                        # :62 — Eintrag, Status Proposed
```

---

## Urteil je Finding

| Finding | Urteil | Beleg |
|---|---|---|
| **F-1** (HIGH) — vier gelistete Mutations-Fälle entwaffnet | **behoben** | Alle vier greifen wieder, keiner bricht mehr die Übersetzung ab, und jeder fällt mit **seinem** benannten Wächter (§Eigene Messungen). Je Fall trifft der neue Anker die Stelle, die der **Aufrufer** benutzt und nicht ein Nachbau daneben: `157` löscht die Zeile aus `captureFiles()`, über die `Enforce` iteriert; `164` kippt das `class:`-Feld, das `writeEnforceFile` liest; `50` biegt den vorhanden-Zweig von `writeSkipIfPresent` um — den Writer, den der Vorlagen-/Doc-Chain-Emitter direkt ruft; `354` fügt einen Eintrag in `enforceFiles()` ein, dessen Pfad-Menge `EnforcePaths()` und damit der Test liest. Die Trefferzahl jedes Ankers ist **1** — kein Anker trifft mehr als seine Stelle. |
| **F-1, benanntes Restrisiko** (die zwei Textanker) | **nicht blockierend, und es ist dasselbe, das das Register führt** | Die Anker von `157` und `164` zitieren die heutige Quell-Form; fällt sie weg, meldet der Treiber „Mutation hat nicht gegriffen … Patch veraltet?" — laut, aber erst nächtlich. Das ist die offene Grenze der Register-Kennung `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` (*„ein vorgelagerter Durchgang über den `sed`-Anker besteht nicht"*, Träger: *„der Lauf, der einen Fall schreibt oder seinen Anker anfasst"*). Ein Wächter entsteht dafür nicht, und keiner wird behauptet. |
| **F-2** (MEDIUM) — abgeschaffte Kennung in der `Accepted`-ADR | **behoben, mit einem noch offenen Schritt** | `ADR-0055` (`919f163a`, `Proposed`) löst den einen Gegenstand per Teil-`Supersedes` ab und ist über den ADR-Index adressiert (`docs/plan/adr/README.md:62`); die abgeschaffte Kennung hat damit ihren Träger. Der *Lesepfad aus `ADR-0054` heraus* — der Zusatz an ihrer Status-Zelle — ist angeordnete Folgepflicht des **annehmenden** Laufs und heute bewusst nicht gesetzt; die Form-Runde dazu im Schwester-Report. |
| **F-3** (MEDIUM) — die Zahl „vier Stellen" der Commit-Message | **offen, beim Planner** (so auch der Auftrag) | Die Message `d7fd8227` ist gepusht und unveränderlich; der Befund wirkt auf die Closure-Notiz (§7) als Träger des Zahl-Belegs. Hier nur benannt, damit er nicht mit dem Nachzug verschwindet. |
| **F-4** (LOW) — unbedingte Lieferzusage in `harness/README.md` §Traceability | **behoben** | Die Lieferung ist jetzt bedingt formuliert (*„den Träger `.githooks/commit-msg` legt der Lauf daneben nur an einem freien Pfad ab, und der abgelegte Träger ruft die Prüfung über sein eigenes Verzeichnis auf"*) und stimmt mit `ADR-0054` §Konsequenzen überein; der Satz schreibt dem belegten Fall nichts mehr zu, was dort nicht gilt. |
| **F-5** (LOW) — vier Begründungen im Konjunktiv über die verworfene Alternative | **behoben** | Alle vier stehen im Indikativ über den Zustand: `commitmsg.go:54` („Die Klasse steht am Eintrag, und der Lauf liest die liegende Datei, bevor er schreibt"), `enforce.go:246` („die Klassen stehen an den Eintraegen der Aufzaehlung, und ein Test … liest sie hier"), `:439` („jeder Eintrag nennt sie darum"), `:453` („Die Meldung ist die Auskunft an den Adopter …"). Keiner der vier Sätze beschreibt mehr einen nicht gefahrenen Lauf. |
| **F-6** (INFO) — Rang-Zeiger auf `ADR-0007` Festlegung 3 beim klassenlosen Eintrag | **unberührt, weiter offen** | Nicht Gegenstand dieses Auftrags; die Stelle (`internal/emit/enforce.go:448`, Fehlermeldung) ist unverändert, und die zitierte Festlegung nennt für den unentschiedenen Fall weiterhin `skip-if-present` als sicheren Default. Zuständige Rolle: Architect. |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Die vier Mutations-Dateien als Ganzes | **geprüft, ohne Befund.** Keine überschreitet mehr die Übersetzung, jede behält ihren `# expect:`-Namen und ihre Stufe, und `157` wie `164` beschreiben ihre Mechanik im Kopf weiter zutreffend (`captureFiles()` leere Menge bzw. Klasse der Rollen-Typen auf konvergent). |
| `internal/emit/**` nach dem Nachzug | **geprüft, ohne Befund.** Die vier Änderungen sind reine Kommentare; `commitmsg.go` und `enforce.go` tragen danach keine Klassen-Aussage mehr, die die verworfene Alternative beschreibt, und die Klassen-Tabelle selbst ist unangetastet (kein Byte an `class:`). |
| Der übrige Bestand der 32 Fälle mit Ziel in einer Diff-Datei | **nicht nachgefahren.** Diese Runde prüft die vier eigenen Findings; die Vollständigkeit der 32 liegt im Report vom 2026-09-16 und ist von diesem Nachzug nur insoweit berührt, als `agents.go`, `enforce.go`, `commitmsg.go` und `harness/README.md` Kommentare bzw. Anker tragen — die zwei Textanker sind oben benannt. |
| DoD-/Spec-Konformität | **nicht geprüft** — Verifier-Aufgabe (Modul 11). `make mutate` (repo-weit) ist **nicht** gefahren: Post-integration, nächtlich; die vier Fälle liefen einzeln in `/tmp`-Kopien. `make gates` über `65b78423`/`919f163a` ist nicht nachgefahren, sondern nur am Ende dieses Laufs über dem eigenen Report-Stand. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 (F-3 offen, beim Planner) |
| LOW | 0 |
| INFO | 0 (F-6 unberührt, offen) |

**Verdikt Teil A — Nachprüfung:** **F-1, F-2, F-4, F-5 sind behoben**, so wie sie formuliert waren —
je am Zielartefakt bzw. in einer eigenen `/tmp`-Kopie gemessen, nicht aus der Rückgabe übernommen.
**F-3 bleibt offen beim Planner** (eingefrorene Message, Träger ist die Closure-Notiz), **F-6
unberührt** (INFO, Architect). Kein blockierender Rest aus diesem Teil.
