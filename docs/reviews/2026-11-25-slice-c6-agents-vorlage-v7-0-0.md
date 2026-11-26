# Review-Report: slice-c6-agents-vorlage-v7-0-0 — 2026-11-25

**Review-Art:** Code — geprüft gegen die AGENTS-Vorlage `v7.0.0` ·
`templates/AGENTS.template.md` (§3.1, Zeilen 97–109 und 250–261), den
Slice-Plan und die Hard Rules.

**Gegenstand:** `0a86afa7` (Claim, reiner Move `next/` → `in-progress/`, 0/0
Zeilen) · `a45df66b` (Architect-Sub-Zug, allein `AGENTS.md`, +22 Zeilen:
Umgebungs-Zusage-Block nach Vorlage §3.1, dogfood-adaptierte Träger-Satz-Fassung
mit Fundstellen-Form am Verweis; Parallele-Läufe-Absatz byte-genau) ·
`f4a94a75` (Ruhe-Marker der Offenen Wellen gezogen, allein `roadmap.md`,
−2 Zeilen; Plan §7 Übergabe-Artefakte, +26 Zeilen).

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** Claude Opus 4.5 · **Datum:** 2026-11-25 (gefahren am 2026-11-26,
Commits `05:14 UTC`)

> **Zitier-Form.** Der Report friert ein; was er zitiert, bewegt sich weiter.
> Der Slice-Plan ist Kennung zitiert, nicht Adresse; die Baseline-Stellen sind
> Tag + Pfad in Inline-Code. `pfad`-Felder auf `AGENTS.md` und die
> `internal/emit/`-Dateien zitieren den geprüften Stand des Laufs.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan `slice-c6-agents-vorlage-v7-0-0.md` (§1 Ziel/Abgrenzung samt
  Sub-Zug-Kennzeichnung, §2 DoD, §6 Risiken, §7 Übergabe-Artefakte)
- `v7.0.0` · `templates/AGENTS.template.md` §3.1 (97–109),
  Parallele-Läufe-Absatz (250–261); `v7.0.0` ·
  `templates/docs/plan/planning/slice.template.md` (Abschnitts-Satz §1–§8)
- [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ·
  [`MR-057`] · [`MR-051`] (Bezug-Feld des Plans); C4-Abwägung
  `slice-c4-environment-check-v7-0-0.md` (Weg B entfällt) und C3-Setzung
  `slice-c3-d-check-faecher-v7-0-0.md` §1 (`scan.ignore` des Dogfood
  unverändert)
- `AGENTS.md` §3 (§3.6, §3.7, §3.8, §3.10, §3.11)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | LOW | Der Plan trägt den Vorlagen-Abschnitt „3. Plan (vor Code)" nicht: die Überschriften-Folge springt von „## 2. Definition of Done" zu „## 4. Trigger"; die Pfad-Tabelle, die §8 ihre Kandidaten liefert, steht in keiner Sektion — die Sub-Zug-Kennzeichnung der Commit-Zuschnitte liegt deshalb in §1 (Zeilen 41–43). Bestand vor dem Review-Range (Planner-Commits `0e0c2998`/`d7329a02`, vor dem Claim); der Zugs-Diff erbt die Form, er legte sie nicht an, und d-check `planning` meldet keinen Struktur-Befund (3014/0). | Maintainability (`v7.0.0` · `regelwerk/modul-05-planning-harness.md` §Ziel-Form: Slice — „Ein Slice-Plan folgt der Vorlage") | Plan `slice-c6-agents-vorlage-v7-0-0.md` · `## 2. Definition of Done` → `## 4. Trigger` | ja — `grep -n '^## '` über den Plan gegen den Vorlagen-Abschnitts-Satz (§1–§8) | „Vorlagen-Abschnitt fehlt am Slice-Plan" |
| F-2 | INFO | Plan §1 (b) und LP2 zitieren die Form-Quelle des Parallel-Läufe-Absatzes als „Zeilen 250–251"; der Absatz läuft in der Vorlage 250–261 (12 Zeilen, byte-verifiziert gegen `AGENTS.md` 552–563). Kein Verweis bricht — kein Anker hängt am Zitat, und §7 trägt die Byte-Zusage —, aber ein Leser mit der genannten Spanne prüft zwei Zeilen statt zwölf. Fundklasse wie C5-INFO-1, zweites Auftreten. | Maintainability | Plan `slice-c6-agents-vorlage-v7-0-0.md` §1 (b) und LP2 · wörtlich „Zeilen 250–251" | ja — `sed -n` je Spanne, `diff`/`cmp` der Blöcke (dieser Lauf: byte-gleich) | „Zitat-Spanne enger als der Ist-Bereich" |
| F-3 | INFO | Der Ruhe-Marker der Offenen Wellen zog zwei Commits nach dem Claim: `0a86afa7` (Claim) liegt vor `f4a94a75` (−2 Zeilen); beide Zwischen-HEADs tragen den Marker gegen einen belegten Slice in `in-progress/`. Die reine-Move-Regel trennt die zwei Commits und keine Quelle bindet ihre Reihenfolge; der d-check `planning`-Drift meldete den Stand, und die Commit-Message von `f4a94a75` nimmt ihn. Zweites Auftreten der Form nach C5 (`d29be86c`). | Maintainability (`v7.0.0` · `regelwerk/modul-06-roadmap.md` — Ruhe-Marker folgt der Position von `in-progress`) | `roadmap.md` · Abschnitts-Zeile `**Nichts in Arbeit.**` am Stand `a45df66b` | ja — `git show` über der Range; `make docs-check` am Zwischenstand | „Marker-Ziehung folgt dem Claim mit Versatz" |

## Prüffelder je Auftrag (Urteile)

1. **Rollengrenze (§3.8) — sauber.** `git show --stat` je Commit: `a45df66b`
   berührt allein `AGENTS.md` (+22), Message trägt `Rolle Architect:`; `f4a94a75`
   berührt Plan und `roadmap.md` (+26/−2), Message trägt `Rolle Implementer:`.
   Kein `harness/conventions*`-Rumpf (MR-047/048) in einem der beiden Commits —
   die Terminologie-Formen blieben bei C7, wie §1 Punkt 3 ausschließt. Die
   Kennzeichnung steht Plan-seitig in §1 `Sub-Zug-Kennzeichnung` — Plan-Sektion
   §3 (Form des Vorlagen-Abschnitts „Plan (vor Code)") existiert nicht, F-1.
2. **Byte-Genauigkeit je Vorlage — belegt.** Der Parallele-Läufe-Absatz ist
   byte-gleich: `sed -n '250,261p' .harness/baseline/v7.0.0/templates/AGENTS.template.md`
   gegen `sed -n '552,563p' AGENTS.md` → `diff` leer, `cmp` stimmt. Der
   Docker-Block-Absatz „Umgebungs-Zusage" trägt den v7-Träger-Satz
   („Docker ist hier der Träger der Umgebungs-Zusage (`Baseline-Regelwerk`
   `modul-14-docker-harness.md`)", Vorlage Zeile 109, dogfood-adaptiert als
   eigener Absatz je LP1-Abwägung §7) neben dem unveränderten
   Dogfood-Begründungs-Satz (§3.9, „Reproduzierbar ist ein Lauf über das
   gepinnte Image") — die zwei Sätze sind byte-differenziert, beide stehen.
3. **`d-check:ignore`-Form — konsistent.** Der Inline-Marker sitzt an der
   Fundstelle (`AGENTS.md:404`, dieselbe Zeile wie der Pfad), Begründung in
   Klammern, und die Abwägung ist als Link nebenan verlinkt
   (`slice-c4-environment-check-v7-0-0`, „Weg B entfällt"). Die
   Verweis-Datei trägt das Dogfood nicht (`ls harness/sensors/environment-check.md`
   → nicht gefunden) — kein Träger, also kein behauptetes-Gate-Gegenstand. Die
   v7-Regel-Form („legt ein Werkzeug ihn ins Repo …, steht der Pfad im
   `ignore` der `.d-check.yml`") ist bedingt und nicht ausgelöst:
   `.claude/worktrees/` existiert nicht (`ls -d` → nicht gefunden),
   `.gitignore:26` führt die Zeile, `.d-check.yml` trägt keinen
   `worktrees`-Eintrag (`grep -n 'worktrees' .d-check.yml` → 0) — C3-Entscheidung
   unverändert, `scan.ignore` des Dogfood bleibt unverändert.
4. **LP3-Korrektur — nachgezogen und belegt.** Die Kommandos des Plans §7
   nachgefahren: `internal/emit/templates.go:206` trägt `"AGENTS.template.md",`
   in der `rootMarkers()`-Liste, der Rename-Schutz-Kommentar steht an Zeile 165
   („ein Upstream-Rename haette den Bootstrap … gebrochen", Review-Befund
   slice-022b N-4); `internal/emit/agents.go` existiert und trägt die
   Rollen-Typen (`//go:embed all:templates/agents`, Zeile 23) — kein AGENTS-Kern;
   `grep -c 'Docker\|Parallele' internal/emit/agents.go` → `0`. Die Korrektur zur
   Formel §1 („ein `agents.go` mit Form-Konstanten existiert nicht" → exakt
   belegte Form) steht in Plan §7 am selben Ort wie die übrigen
   Fundlisten — Fundklasse aus dem C5-Review („Übergabe-Beleg steht nur im
   Lauf-Kontext") trägt dieser Plan im Block selbst, nicht nur in der
   Übergabe-Meldung.
5. **R1–R3-Ausgänge — belegt; die Ausgänge je §6 schreibt die Formal-Closure
   (Planner, §3.10).** R1: kein MR-Rumpf berührt (Commit-Stat je oben) — die
   C7-Kennung bleibt Adresse. R2: die beobachtete Form steht in §7 —
   `codepaths` misst auch `AGENTS.md` (Befund an `AGENTS.md:404`, dieselbe Zeile
   wie heute), die Fundstellen-Form trägt die Zeile, keine `ignore-refs`-Weitung
   nötig (`.d-check.yml` unberührt in beiden Commits). R3: zwei Commits, beide
   Messages tragen die Kennung (`slice-mv`/`Rolle`-Formen) — die Vorgabe
   „zwei Commits, Kennung je Message" ist erfüllt.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Commit-Zuschnitte je Rolle (§3.8) und Message-Kennungen (R3) | geprüft, ohne Befund (`git show --stat` je Commit) |
| Parallele-Läufe-Absatz byte-genau gegen Vorlage 250–261 | geprüft, ohne Befund (`diff`/`cmp` → byte-gleich) |
| Docker-Block-Form (Träger-Satz, beide Sätze byte-differenziert) | geprüft, ohne Befund (`AGENTS.md` 400–406 gegen Vorlage 97–109) |
| `d-check:ignore`-Fundstellen-Form gegen C4-Abwägung und C3-`scan.ignore` | geprüft, ohne Befund (`ls`, `grep -n worktrees .d-check.yml` → 0, `.gitignore:26`) |
| LP3-Kommandos gegen den Emitter-Code | geprüft, ohne Befund (`templates.go:165/206`, `agents.go`-Embed) |
| Ruhe-Marker-Richtung (Marker bei belegtem Slice entfernt, f4a94a75) | geprüft, ohne Befund in der Richtung; Versatz des Zeitpunkts siehe F-3 |
| Neue Kommentare je §3.7 (Umgebungs-Zusage-Block, `d-check:ignore`-Marker am Fundort) | geprüft, ohne Befund (Abgrenzung/Zusage-Klassen) |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** „Vorlagen-Abschnitt fehlt am Slice-Plan" ·
„Zitat-Spanne enger als der Ist-Bereich" · „Marker-Ziehung folgt dem Claim mit Versatz"

## Sensors

- `make docs-check` am Zug-Stand: `3014 Datei(en) geprüft, 0 Befund(e)` (vor dem
  Report; nach dem Report siehe Übergabe).
- Gate-Stempel: `.harness/state/gates-passed.head` = `f4a94a75…` = HEAD.

## Verdikt

**Merge-blockierend:** nein — HIGH 0, MEDIUM 0. F-1 betrifft den Planungs-Bestand
vor dem Zugs-Range und bindet die Formal-Closure nicht; sie ist an den Planner
zurückzumelden (Abschnitt nachziehen oder die Abweichung dort begründen), die
Zugs-Artefakte tragen die Prüffelder selbst.

**Übergabe:** Findings gehen an den Implementer (F-1 über die Rollen-Grenze an
den Planner, §3.10-Form bei der Closure); die Finding-Klassen gehen in die
Slice-Closure §7. Dieser Report ist ein Lauf-Beleg; er ersetzt keine
Verifikation.
