# Slice slice-fall-406-trifft-die-umgebaute-zerlegung: Mutations-Fall 406 wieder gegen den heutigen `splitWords`-Umbau ankern

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — reaktiv (gemessener Befund aus einem `make mutate`-Lauf
in CI), kein Closure-Kriterium über die DoD dieses Slice hinaus, siehe
Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht
(Modul 6).

**Bezug:** [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (Erfassungs-Policy — „Werte nie im
Span"; nur *aktive* ADRs).

**Berührte Spec-Stellen:** `SPEC-031` — die Wortgrenzen-Regel des
`program`-Felds nennt „Fall 406" dort namentlich als einen ihrer Wächter
(zusammen mit `TestCommandProgramNeverEmitsAssignmentValueFragments`).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-27.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice.

**Ziel:** Mutations-Fall 406
(`test/mutations/406-span-program-wortgrenze-unicode-leerraum.sh`) trifft
wieder eine reale Zeile im heutigen `splitWords`/`commandProgram()` und färbt
`TestCommandProgramNeverEmitsAssignmentValueFragments` tatsächlich rot, wenn
die Zusage verletzt wird, dass Unicode-Leerraum (NBSP, U+2003, U+3000,
U+0085) oder `\r`/`\v`/`\f` nie eine Wortgrenze vortäuschen und kein
Wert-Bruchstück im Feld `program` landet
([`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md)).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Änderung an `internal/span/span.go` (Produktionscode).** [Schicht-Abgrenzung]
  Die geprüfte Eigenschaft ist im heutigen Code unverändert vorhanden:
  `splitWords` (Zeilen 463–492) iteriert byte-weise und vergleicht
  ausschließlich mit den drei ASCII-Bytes `' '`, `'\t'`, `'\n'` (Zeile 468) —
  jede Mehrbyte-UTF-8-Folge (NBSP, U+2003, U+3000, U+0085) sowie die
  Steuerbytes `\r`/`\v`/`\f` bleiben Wortbestandteil, genau wie der
  Doc-Kommentar über `commandProgram` (Zeilen 248–250) zusagt. Es besteht
  keine Code-Lücke — dieser Slice repariert ausschließlich den verwaisten
  Mutations-Fall, keine Verhaltensänderung.
- **Keine Änderung an `internal/span/span_test.go`.** [Bestand bleibt bewusst
  stehen] `TestCommandProgramNeverEmitsAssignmentValueFragments`
  (Zeilen 252–283) prüft bereits alle sieben betroffenen Formen (NBSP,
  U+2003, U+3000, U+0085, `\r`, `\v`, `\f`) direkt gegen `Derive(...).Program`
  und den emittierten Span-Text und bleibt der richtige `# expect:`-Test —
  ein neuer oder umbenannter Test würde dieselbe Zusicherung nur doppeln.
- **Kein genereller Wächter gegen sed-Anker-Drift.** [Anderer Vorgang]
  [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
  benennt als eigenen Auflösungs-Trigger den Fall, dass die Klasse
  „Mutations-Fall wird von berechtigter Änderung entwaffnet" *trotz* der
  Anlage-Regel dreimal weiter auftritt — erst dann ist ein Sensor oder
  Folge-Vorgang die Antwort. Dieser Slice liefert höchstens den nächsten
  Beleg für das bereits verkörperte Register-Muster (§6), keinen neuen
  Sensor.
- **Keine Umbenennung oder Neufassung des Falls 406** (z. B. Aufsplitten in
  mehrere kleinere Fälle je Zeichenklasse). [Anderer Vorgang] Der bestehende
  Fall wird repariert, nicht neu entworfen — `spec/spezifikation.md` §SPEC-031
  zitiert ihn namentlich als „Fall 406"; ein Rename bräche diesen Verweis ohne
  Not.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**. Dieser Slice hat **einen**
Liefer-Punkt; die übrigen Zeilen sind die fünf konstanten Closure-Pflichten
und zählen nicht mit.

- [ ] **(1)** Fall 406 — mit aktualisiertem `sed`-Anker gegen die heutige
      `words`-Struct-Zerlegung
      ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand):
      der Anker misst gegen den Quell-Bestand,
      `grep -c '<Anker-Zeile>' internal/span/span.go` → 1) —
      färbt `TestCommandProgramNeverEmitsAssignmentValueFragments` unter
      `make mutate` (gezielt: `MUTATE_CASES=406-span-program-wortgrenze-unicode-leerraum`
      für den engsten Lauf) tatsächlich rot, mit genau diesem Test in der
      Fehlschlag-Ausgabe. Gegenprobe mit ausgeschriebener Polarität (§3.6):
      Mutation angewandt → rot mit `TestCommandProgramNeverEmitsAssignmentValueFragments`;
      Mutation nicht angewandt (Grün-Vorlauf) → grün.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — bevorzugt
      als weiterer Beleg in
      `BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/evidence/`
      (Zähler stünde danach bei 6×; siehe §6 zur Einordnung). Kein Zähler wird
      gesetzt, er folgt aus den Dateien.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im
      Repo ohne Wellen-Betrieb hier geprüft.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area?

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `test/mutations/406-span-program-wortgrenze-unicode-leerraum.sh` | update | Der bestehende `sed`-Anker `^\tfields := splitWords(cmd)$` existiert seit Commit `92f03d31` (Nachrunde slice-204, 2026-09-27, „`words`-Struct-Umbau für die Navigations-Grenze") nicht mehr wörtlich — heutige Zeile: `w := splitWords(cmd)` gefolgt von `fields := w.fields`. **Planner-Vorschlag (durch Lesen verifiziert, NICHT in Docker kompiliert/gefahren — §3.9, kein Host-Go):** in `splitWords` selbst die Zeile 468 `if c != ' ' && c != '\t' && c != '\n' {` (heute eindeutig — `grep -c` = 1 im Bestand) auf `if c != ' ' && c != '\t' && c != '\n' && c < 0x80 {` erweitern. Jedes Byte ≥ 0x80 — jede Fortsetzungs- oder Startbyte einer Mehrbyte-UTF-8-Folge, also NBSP/U+2003/U+3000/U+0085 — wird dadurch fälschlich zur Wortgrenze; `SECRET` zerfällt in ein eigenes Feld und leakt als `program` — dieselbe Fehlerklasse, die die Fall-Kopfzeile beschreibt. `\r`/`\v`/`\f` (alle < 0x80) bleiben von dieser konkreten Mutation unberührt; das ist unschädlich, weil die vier verbleibenden Unicode-Teilfälle genügen, um die Testfunktion insgesamt rot zu färben. Der Implementer verifiziert diesen Vorschlag gegen `make mutate` und wählt bei Bedarf einen gleichwertigen, aber anders geführten Anker (z. B. einen, der auch `\r`/`\v`/`\f` trifft) — Wahl der Umsetzung ist Implementer-Entscheidung. |
| `internal/span/span_test.go` | keine Änderung (geprüft) | `TestCommandProgramNeverEmitsAssignmentValueFragments` deckt weiterhin alle sieben Formen direkt (siehe §1); keine Testdatei-Zeile nötig. |
| `internal/span/span.go` | keine Änderung (geprüft) | Die Eigenschaft ist im Code unverändert vorhanden (siehe §1) — reiner Anker-Veralterungsfall, keine Code-Lücke. |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): sofort verfügbar — `in-progress/` trägt
aktuell keinen Slice (WIP-Limit frei), keine Abhängigkeit offen.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): falls sich beim
  Reparieren herausstellt, dass `splitWords`/`commandProgram` doch eine
  reale, nicht-triviale Code-Lücke hat (z. B. eine weitere Unicode- oder
  Byte-Form täuscht tatsächlich eine Grenze vor) und die Behebung mehr als
  einen kleinen, lokal begrenzten Patch braucht — dann Zerlegung in einen
  Fall-Reparatur-Slice und einen eigenen Code-Lücken-Slice.
- `in-progress` → `open` (blockiert — Carveout?): falls der
  `make mutate`-Lauf selbst aus einem repo-weiten Infrastruktur-Grund
  blockiert (z. B. Docker-Image-Pin-Defekt), der ein Carveout statt einer
  lokalen Reparatur braucht.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln.

DoD vollständig — Fall 406 färbt den erwarteten Test rot unter Mutation und
bleibt grün ohne Mutation, `make gates` grün — **und** Review-Report liegt vor
**und** Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst.

- **Der vom Planner vorgeschlagene Anker (§3) ist ungeprüft im Docker-Sinn.**
  Er wurde nur durch Lesen des Quellcodes verifiziert (§3.9 verbietet
  Host-Go), nicht durch einen echten `make mutate`-Lauf. Er könnte beim
  realen Lauf aus einem unvorhergesehenen Grund nicht wie erwartet rot
  werden (Typkonflikt, `gofmt`-Formatierung, eine andere
  `failure_form`-Erwartung des Treibers). Das ist kein Risiko außerhalb der
  normalen Implementierungsarbeit — die Verifikation selbst ist DoD (1) —,
  wird hier aber benannt, damit ein Implementer, der den Vorschlag ungeprüft
  übernimmt, nicht überrascht wird.
- **Diese Entwaffnung ist keine neue Beobachtungs-Klasse, sondern eine
  weitere Instanz einer bereits verkörperten.** Geprüft: der Mutations-Fall
  406 wurde am 2026-09-24 (Commit `fb1ca361`) korrekt gegen den damaligen
  Quell-Bestand angelegt — sein Anker traf zu diesem Zeitpunkt exakt
  `fields := splitWords(cmd)`, wie es
  [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
  verlangt. Die Entwaffnung trat erst durch eine spätere, berechtigte
  Änderung ein (Commit `92f03d31`, 2026-09-27, „Nachrunde slice-204"), die
  `splitWords` auf einen `words`-Struct umstellte. Das ist exakt die Klasse
  `BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`
  (bereits **verkörpert** als
  [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand),
  Zähler dort aktuell 5× laut `state.md`). Die Ausgangs-Annahme des
  Auftrags — der Reviewer der `slice-204`-Runde 2 habe die Eigenschaft nur
  manuell geprüft, nie als Fall festgehalten — ist damit durch die Historie
  **widerlegt**: der Fall existierte und war korrekt verankert; er
  driftete nachträglich, wie die Regel selbst als strukturelle Grenze
  benennt („Die Regel verlagert die Prüfung auf die Anlage, nicht auf den
  Lauf"). Es besteht daher kein Bedarf für eine neue, eigene Beobachtung —
  nur für einen weiteren Beleg an der bestehenden.
- **Der eigene Auflösungs-Trigger dieser Regel rückt näher, ist aber noch
  nicht erreicht.**
  [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
  sieht einen Folge-Vorgang vor, „wenn die Klasse trotz
  der Regel wiederkehrt — ein neuer Beleg im Register-Eintrag, drei weitere
  Vorgänge". Mit diesem Slice stünde der Zähler bei 6× (5× + dieser Beleg) —
  das ist der erste von drei weiteren Vorgängen seit der Verkörperung, nicht
  der dritte. Kein Handlungsbedarf über den Register-Eintrag hinaus.

## 7. Closure-Notiz

<!-- wird beim Übergang nach done/ von einem frischen Planner-Kontext gefüllt
(AGENTS.md §3.10) — nicht Teil dieses Anlage-Laufs. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung.

**Vorgelagert — Sub-Area-Wahl prüfen:** Der Slice berührt `test/mutations/`
und `internal/span/` — beides fällt unter die einzige hier einschlägige
Sub-Area `*` (gesamtes Repo, Kürzel `ALL`); weder `harness/tools/` (`TOOLS`)
noch `.codex/` (`CODEX`) sind berührt. `*` erfüllt die Schwelle bereits als
Repo-weite Sub-Area der Modus-Deklaration; keine weitere Ausdifferenzierung
nötig.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen
(`docs/plan/planning/observations/BEO-ALL/`). Treffer mit direktem Bezug:
`mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` (bereits
verkörpert via
[`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand),
Zähler 5× vor diesem Slice — siehe §6). Kein weiterer
Treffer mit Bezug zu Unicode-Wortgrenzen oder zu `internal/span/`
spezifisch.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — `test/mutations/` folgt der in
  [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
  und den Nachbar-Registereinträgen dokumentierten Fall-Form (`# files:` /
  `# expect:` / `sed`-Anker); `internal/span/` trägt die
  [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md)-Policy Zeile
  für Zeile in seinen Doc-Kommentaren.
- **Phase-Reife:** Phase 5 — reifer, seit Monaten stabiler Bestand mit
  eigenem Gate (`make mutate`) und eigener Spec-Stelle (SPEC-031).
- **Evidenz-/Diskrepanz-Risiko:** niedrig — der Fund ist bereits ein
  gemessener CI-Befund, kein Inventur-Risiko; die einzige Diskrepanz ist der
  veraltete `sed`-Anker selbst, Gegenstand dieses Slice.
- **Reconciliation-Aufwand:** keiner — kein Brownfield-Bootstrap-Bezug,
  keine Graduation nötig.
