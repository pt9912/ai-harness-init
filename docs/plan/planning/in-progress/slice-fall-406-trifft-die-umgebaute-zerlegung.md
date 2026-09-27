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

- [x] **(1)** Fall 406 — mit aktualisiertem `sed`-Anker gegen die heutige
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
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — bevorzugt
      als weiterer Beleg in
      `BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/evidence/`
      (Zähler stünde danach bei 6×; siehe §6 zur Einordnung). Kein Zähler wird
      gesetzt, er folgt aus den Dateien.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] `make gates` grün.
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
  übernimmt, nicht überrascht wird. — **Ausgang:** *entfallen* — der Anker
  wurde real geprüft (Implementer-Lauf, unabhängig wiederholt von Reviewer
  und Verifier je in eigenem, isoliertem Lauf), traf sofort auf Anhieb und
  ohne Nachbesserung; kein Rest-Risiko.
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
  nur für einen weiteren Beleg an der bestehenden. — **Ausgang:** *entfallen*
  — bestätigt durch die Historie: kein neuer Registereintrag nötig, nur ein
  weiterer Beleg an der bestehenden, bereits verkörperten Klasse (siehe §7,
  Register-Fortschreibung).
- **Der eigene Auflösungs-Trigger dieser Regel rückt näher, ist aber noch
  nicht erreicht.**
  [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
  sieht einen Folge-Vorgang vor, „wenn die Klasse trotz
  der Regel wiederkehrt — ein neuer Beleg im Register-Eintrag, drei weitere
  Vorgänge". Mit diesem Slice stünde der Zähler bei 6× (5× + dieser Beleg) —
  das ist der erste von drei weiteren Vorgängen seit der Verkörperung, nicht
  der dritte. Kein Handlungsbedarf über den Register-Eintrag hinaus. —
  **Ausgang:** *entfallen* — der Beleg ist mit diesem Slice an der
  bestehenden, verkörperten Klasse ergänzt (jetzt 6×, 1 von 3 weiteren
  Vorkommen seit MR-071); MR-071s eigener Auflösungs-Trigger ist damit
  weiterhin nicht erreicht, und die Fortschreibung des Registers trägt das
  Risiko vollständig — kein zusätzlicher, separater Registereintrag nötig.

## 7. Closure-Notiz

Geschrieben von der Rolle Planner in frischem Kontext
([`AGENTS.md`](../../../../AGENTS.md) §3.10), nach Review (Commit `f3f3c828`) und Verifikation
(Commit `89fd0b79`).

- **Kontext — CI-Release-Blocker.** Dieser Slice ist ein reaktiver Notfall-Fix: `make mutate`
  meldete in GitHub CI „Patch veraltet" für Fall 406, weil ein späterer, berechtigter Commit
  (`92f03d31`, Nachrunde slice-204) den `sed`-Anker entwaffnet hatte. Der Lauf blockierte einen
  `mutate`-Durchgang, der für ein mögliches Release gedacht war. Das ist Kontext für die Eile dieses
  Slice, keine Norm dieser Notiz.
- **Was hat funktioniert.** Der Planner-Vorschlag aus §3 (die Bedingung um `&& c < 0x80` erweitern)
  traf beim Implementer auf Anhieb: Rot-vor-Grün am Produktionscode, dreifach unabhängig gesehen —
  Implementer-Lauf, Reviewer-Lauf, Verifier-Lauf, jeder in eigener isolierter Scratch-Kopie, keiner
  im Arbeitsbaum. Der MR-071-Anker (`grep -c` gegen den heutigen Quell-Bestand) traf beide Male
  eindeutig eine Stelle. Weder `internal/span/span.go` noch `internal/span/span_test.go` wurden
  angerührt (Plan §1 eingehalten, von allen drei Rollen unabhängig per `git diff --stat` bestätigt).
- **F-1 (MEDIUM, Reviewer/Verifier) — Entscheidung: lassen, nicht nachbessern.** Die Mutation färbt
  neben dem im `# expect:`-Kopf genannten `TestCommandProgramNeverEmitsAssignmentValueFragments`
  auch `TestCommandProgramNamesAProgramNotAnOperator` mit (Gegenprobe mit ausgeschriebener
  Polarität, von Reviewer und Verifier je unabhängig gefahren: nur der benannte Test übersprungen,
  Mutation aktiv → bleibt rot über dem zweiten Test). Dagegen abgewogen: (1) Der `# expect:`-Kopf
  beansprucht keine Exklusivität — er nennt einen Test, der rot werden **muss**, nicht den einzigen,
  der rot werden **darf**; `harness/tools/mutate.sh` prüft laut eigener Meldungsform nur, ob der
  genannte Test in der roten Ausgabe steht. (2) Beide Rollen haben den Befund ausdrücklich als
  **nicht merge-blockierend** eingestuft. (3) Die Klasse ist mit diesem Beleg zum **dritten** Mal
  aufgetreten (siehe Register-Fortschreibung unten) — das ist die vom Regelwerk vorgesehene Reaktion
  auf eine wiederkehrende Beobachtung (3×-Schwelle, Modul 6), nicht ein Fall, den ein einzelner
  Slice im Vorbeigehen still mitkorrigiert. Eine Nachbesserung hieße entweder den Fall 406 enger zu
  fassen (Aufsplitten in zwei Fälle je Test) oder `make mutate` selbst um eine
  Exklusivitäts-Prüfung zu erweitern — beides sind Änderungen mit eigenem Entwurfsraum (welche
  Fälle bekommen künftig eine Exklusivitäts-Zusage? bricht ein schärferer Treiber heute grüne,
  historisch gewachsene Fälle?), keine lokal begrenzten Patches, und §1 dieses Slice schließt genau
  das aus („Kein genereller Wächter gegen sed-Anker-Drift … Dieser Slice liefert höchstens den
  nächsten Beleg"). Der Slice selbst ist ein Notfall-Fix für einen CI-Release-Blocker — eine
  zusätzliche, unabgestimmte Verzögerung für eine als nicht-blockierend eingestufte Systemfrage ist
  hier die falsche Priorität. Die richtige Route ist die normative: der 3×-Übertritt geht mit
  zugewiesenem „offen, Übergabe an den Architect" in dieses Closure (siehe Register-Fortschreibung),
  und die Architect-Entscheidung entscheidet über Zielort/Verkörperung oder benannte Lücke — nicht
  dieser Slice.
- **V-1 (LOW, Verifier) — Lerneintrag (Form: geschärfte Sichtungs-Disziplin).** Die
  §8-Sichtungszeile dieses Slice-Plans behauptete „Kein weiterer Treffer … zu `internal/span/`
  spezifisch", obwohl `mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere` zu diesem
  Zeitpunkt bereits 2× belegt war — beide Belege aus Arbeit an `internal/span/`, einer davon Fall 406
  selbst namentlich nennend (`docs/reviews/2026-09-24-slice-program-feld-nennt-weder-operator-noch-wertfragment-gegenprobe.md`
  Zeile 53). Der Sichtungs-Schritt hatte den **einen** einschlägigen Treffer
  (`mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`) korrekt notiert und den zweiten,
  ebenso einschlägigen, übersehen — nicht falsch gezählt, sondern schlicht nicht gefunden. Modul 6
  verlangt „Keine Treffer sind ebenfalls eine Antwort und werden notiert"; hier lag ein Treffer vor
  und wurde als „kein Treffer" notiert. Die Lehre: Der Sichtungs-Schritt braucht mehr als eine
  Stichwort-Suche nach der zuerst gefundenen einschlägigen Klasse — er muss **alle** Verzeichnisse
  mit erkennbarem Bezug zur berührten Datei/Funktion durchgehen, nicht nur bis zum ersten Treffer.
  Diese Lücke ist neu und eigenständig registriert (siehe unten), statt sie unter der bereits
  verkörperten Nachbarklasse `sichtungs-schritt-zitiert-falschen-zaehler-stand` (falscher Zähler,
  nicht fehlender Treffer — andere Fehlerrichtung) mitzuzählen.
- **Register-Fortschreibung (`../observations/`).** Zwei bestehende Verzeichnisse um je einen Beleg
  ergänzt:
  [`mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`](../observations/BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/observation.md)
  (F-1) — Zähler jetzt **3×**, **3×-Übertritt erreicht**. Ausgang: **offen, mit Übergabe an den
  Architect** — der Lese-Schritt (diese Slice-Closure, Repo ohne Wellen-Betrieb) erkennt den
  Übertritt, weist aber keinen der drei Ausgänge selbst zu: Verkörperung ist eine
  Architect-Entscheidung (`modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle, Schritt 3b).
  Details der Übergabe stehen in `state.md` der Beobachtung. Und
  [`mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md)
  (Entwaffnung durch berechtigte Änderung) — Zähler jetzt **6×**; Ausgang unverändert
  **verkörpert** (MR-071); MR-071s eigener Auflösungs-Trigger (drei weitere Vorkommen seit der
  Verkörperung) steht bei 1 von 3, noch nicht erreicht. Eine neue Beobachtung angelegt:
  [`sichtungs-schritt-uebersieht-treffenden-registereintrag`](../observations/BEO-ALL/sichtungs-schritt-uebersieht-treffenden-registereintrag/observation.md)
  (V-1, 1×, `offen` — unterhalb der Schwelle, Normalzustand).
- **Folge-Slices:** keine neu geschnitten. Die F-1-Systemfrage (Exklusivitäts-Zusage von
  Mutations-Fällen) geht über den 3×-Übertritt an den Architect, nicht als eigener Slice — die
  Architect-Entscheidung kann selbst einen Folge-Slice adressieren, das ist nicht Sache dieses
  Laufs.
- **Risiken aus §6:** je ein Ausgang, siehe §6 (entfallen · entfallen · entfallen).
- **Drei Paarungen** (ohne Wellen-Betrieb hier, nach dem `git mv` gelesen) — Ergebnis in einem
  eigenen Commit nach dem Move, wie in dieser Ablage üblich (AGENTS.md §3.3).

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
