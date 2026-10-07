# ADR-0083: Das Handoff-Gate bindet an den Commit, nicht an jedes Turn-Ende — der strenge Modus bleibt per Schalter

**Status:** Proposed

**Datum:** 2026-10-07

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:** [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`MR-002`](../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks),
[`MR-003`](../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung),
[ADR-0080](0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md) (Ort des Schalters
im Ziel)

**Schärft:** — keine Spec-Stelle trägt das Stop-Verhalten
(`grep -n -i -E 'stop-hook|handoff-gate|stop-require' spec/spezifikation.md spec/architecture.md | wc -l`
→ **0**); die Anforderung steht in [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren).

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR); `AGENTS.md` §3.5 — die
Entscheidung lockert ein Gate, diese ADR ist ihr Träger.

---

## Kontext

**Ist, in beiden Fassungen gleich.** Der Stop-Hook (`.claude/hooks/stop-require-gates.sh` im
Dogfood, `internal/emit/templates/enforce/stop-require-gates.sh` emittiert) gibt frei bei
`stop_hook_active`; ohne Nachweis-Datei bei sauberem Baum; sonst nur, wenn der Inhalts-Hash des
Arbeitsbaums gleich `.harness/state/gates-passed.diffsha` ist. Damit blockiert **jedes** Turn-Ende
mit einer ungedeckten Änderung — auch Rückfrage und Zwischenstand. Die zwei Dateien unterscheiden
sich nur in Kommentaren (Umlaute transliteriert, Umbruch, MR-Verweis allein im Dogfood) und im Pfad
des Hash-Werkzeugs (`harness/tools/` hier, `tools/harness/` im Ziel):
`diff .claude/hooks/stop-require-gates.sh internal/emit/templates/enforce/stop-require-gates.sh`.

**Baseline.** `grundlagen-durchsetzungsschicht.md` (v6.17.0, Z. 30) setzt das Handoff-Gate *„bevor
der Agent ‚fertig' meldet"*; `modul-09-implementierung.md` Schritte 5/6 legen den Gate-Lauf vor den
Handoff. Das Turn-Ende ist strenger als beides.

**Anlass.** CR-1 eines Adopters (v0.4.0); Auftraggeber-Entscheidung 2026-10-07: umsetzen, Default
„nur bei Commit".

**Variante Subagent-Erkennung — ohne Objekt.** Laut Claude-Code-Hooks-Referenz (Abschnitte
`Stop`/`SubagentStop`; im Repo nicht gemessen) trägt die Stop-Eingabe `session_id`,
`transcript_path`, `cwd`, `permission_mode`, `hook_event_name` und `stop_hook_active` — kein Feld,
das einen Subagenten oder ein „fertig" kennzeichnet; das Ende eines Subagenten feuert
`SubagentStop`, und das ist in keiner Fassung verdrahtet
(`grep -c SubagentStop .claude/settings.json internal/emit/templates/enforce/settings.json` → **0**,
**0**).

## Entscheidung

Wir wählen **Commit-Bindung als Default, das heutige Verhalten als Schalter**.

**1. Default.** Der Hook blockiert nur, wenn **beides** gilt: HEAD ≠ der beim letzten grünen Lauf
gestempelte HEAD, **und** Inhalts-Hash ≠ Hash-Nachweis. Turn-Ende ohne Commit seit dem letzten
grünen Lauf: frei. Commit, dessen Inhalt der letzte grüne Lauf deckt: frei. Commit mit ungedecktem
Inhalt: blockiert. `stop_hook_active` gibt wie heute beim zweiten Mal frei.

**2. Ein roter Lauf gibt nie frei.** Er schreibt keinen Stempel: der Nachweis entsteht nur hinter
der Ordnungskante `record-gates: <checks>` (Wächter `test/gate-nachweis-kante.bats`); ein Commit
bleibt blockiert, bis ein grüner Lauf ihn deckt.

**3. Der HEAD-Stempel ist eine eigene Datei, keine Änderung des Gate-Laufs.** `record-gates.sh`
(beide Fassungen) schreibt nach dem Hash zusätzlich `.harness/state/gates-passed.head`. Checks,
Kante, Hash-Funktion und Format von `gates-passed.diffsha` bleiben unverändert — die Datei hat
weitere Leser (`harness/tools/full-smoke.sh`, `harness/tools/mutate.sh`), die ein Formatwechsel
bräche. Das ist die Lesart des Nicht-Ziels der CR: ein Zusatz neben dem Nachweis.

**4. Ohne HEAD-Stempel gilt der strenge Zweig** (fail-closed) — nach dem Update bis zum ersten
grünen Lauf, auf einem Klon mit Änderungen und ohne Lauf. Akzeptiertes Negativ: einmalig, der erste
`make gates` beendet es.

**5. Schalter `STOP_GATE_STRENG`.** Wert `1` stellt das heutige Verhalten her. Der Hook führt kein
`make` aus; er liest zuerst die Umgebungsvariable, sonst eine Zuweisungszeile
`STOP_GATE_STRENG = 1` (`=`, `:=`, `?=`) in `repo.mk` (Ziel, ADR-0080) bzw. im `Makefile`
(Dogfood). **Grenze:** bedingte Zuweisung, `include` oder ein make-Aufrufparameter erreichen ihn
nicht; dann gilt der Default — die Seite, die entschieden ist.

**6. Kein Folge-Eintrag zu [`MR-002`](../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)/[`MR-003`](../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung).** Beider Aussagen bleiben wahr: der Hook vergleicht
den Hash (nach dem HEAD-Vergleich), und ein Commit ohne Gate-Lauf macht ihn nicht grün (der
Default-Block). Über Turn-Enden ohne Commit sagt keiner etwas; die Lockerung trägt diese ADR. Die
Begründung von [`MR-002`](../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) (*„gegen ‚Erfolgsmeldung ohne Gate-Lauf'"*) gilt damit für den Commit, nicht
für eine Meldung ohne Commit — akzeptiertes Negativ, das Netz dort ist CI auf dem Push.

**Offene Entscheidung des Auftraggebers:**

- **Modus im Dogfood.** (a) Default wie im Ziel — **Empfehlung**: das Dogfood fährt, was
  ausgeliefert wird; (b) streng per Zeile im `Makefile`. Bei (a) zieht der Folge-Slice den
  Stop-Hook-Satz in `CLAUDE.md` nach; bei (b) bleibt er.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun | kein Aufwand, strengste Lesart | blockiert Rückfrage und Zwischenstand; strenger als die Baseline; die CR bleibt offen |
| B — Subagent-Erkennung | trifft den Fall, den die CR nennt | die Stop-Eingabe trägt kein solches Feld (§Kontext); ohne Objekt |
| C — Zeitvergleich: Commit-Datum von HEAD gegen mtime des Nachweises | `record-gates.sh` bleibt unberührt | Uhrzeit ist keine Abstammung: `checkout`/`reset` auf einen älteren Commit liest sich als „kein Commit" |
| D — HEAD in `gates-passed.diffsha` mitschreiben | eine Datei | ändert das Format eines Nachweises mit drei Lesern |
| **E — HEAD-Stempel als eigene Datei, Default Commit-Bindung, Schalter** | bindet an den Handoff wie die Baseline; Nachweis-Format und Gate-Lauf unverändert; heutiges Verhalten per Zeile | eine „fertig"-Meldung ohne Commit ist gate-frei; der Schalter liest nur die einfache Zeilenform |

## Konsequenzen

- Positiv: Turn-Enden ohne Commit kosten keinen Gate-Lauf mehr; der Commit bleibt gebunden.
- Negativ: §Entscheidung 4 und 6; ein `checkout` auf einen anderen Zweig zählt als Commit
  (strenge Seite).
- Folgepflicht: ein Slice (Planner) — beide Hook- und `record-gates.sh`-Fassungen, Schalter,
  Selbstprüfungs-Stufe, bats, Mutationsfall, Dogfood-Modus nach der offenen Entscheidung; Release
  `v0.5.0` (minor: verhaltensändernd im Ziel).

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| bats, über dem **echten** Hook und dem echten `record-gates.sh` in einem tmp-Repo (kein Nachbau, `AGENTS.md` §3.6) | Turn-Ende ohne Commit mit ungedeckter Änderung → `approve`; Commit ohne neuen grünen Lauf → `block`; Commit gedeckten Inhalts → `approve`; `STOP_GATE_STRENG=1` ohne Commit → `block`; fehlender HEAD-Stempel bei ungedeckter Änderung → `block`; `stop_hook_active` → `approve` | `make test` |
| Selbstprüfung des Ziels, am emittierten Hook | Turn-Ende ohne Commit frei; Commit ohne Nachweis blockiert | `make selbstpruefung` (kein Gate), gefahren von `make full-smoke` |
| Mutationsfall | der HEAD-Vergleich wird so verfälscht, dass ein Commit als „kein Commit" gilt → der bats-Fall *Commit ohne neuen grünen Lauf* wird rot | `make mutate` |

## Re-Evaluierungs-Trigger

- Die Stop-Eingabe von Claude Code führt ein Feld, das Abschluss von Zwischenstand trennt —
  dann Variante B neu prüfen.
- Eine Beobachtung *„Handoff ohne Commit mit rotem Stand durchgelassen"* erreicht 3× im
  Beobachtungs-Register.
- Der Kurs ändert die Definition des Handoff-Gates.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-07 | Proposed | Auftraggeber-Entscheidung zu CR-1 eines Adopters (v0.4.0) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0083` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
