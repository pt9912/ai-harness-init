# Welle-Closure welle-kotlin-skelett — Architect-Verdikt (Schritte 2 ADR-Zweig und 3b)

- **Rolle:** Architect · **an:** Planner, Auftraggeber (eine Frage, unten) · **Eingang:**
  `2026-10-09-welle-kotlin-skelett-audit-vorlage`, Abschnitte A und B · **Bezug:**
  [ADR-0062](../plan/adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md),
  [ADR-0076](../plan/adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md) Festlegung 7,
  [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), Baseline-Regelwerk `v6.17.0`,
  `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 2 und 3
- **Gemessen auf:** `441a1d1d`
- **Ergebnis:** keine Folge-ADR, kein Norm-Artefakt geändert, kein Slice angelegt. Ein Sensor ist
  benannt (B-4); er braucht einen neuen Slice, darum eine Frage an den Auftraggeber.

## A — Trigger-Audit, ADR- und Hard-Rule-Zweig

**ADR-0088, ADR-0089, ADR-0063, `MR-089`:** nicht eingetreten, wie die Vorlage misst. `AGENTS.md`
unverändert, einziger Auflösungs-Trigger *permanent*.

**ADR-0062 Trigger 2: bestätigt, Träger für den Fall ist `slice-151`.** Der Zähler ist gestiegen, aber
der Fall liegt außerhalb dessen, was ADR-0062 trägt. Die ADR nimmt die Spec-Straten unter *„Was hier
NICHT entschieden ist"* ausdrücklich aus und nennt `slice-151` als Adresse
(`grep -n 'NICHT entschieden' docs/plan/adr/0062-*.md`). Trigger 2 fragt, ob der Ort trägt, *„obwohl
der Träger steht"*. Für `spec/architecture.md` stand nie ein Träger, also prüft dieser Beleg den Ort von
ADR-0062 nicht. Eine Folge-ADR hätte keinen Gegenstand. `slice-151` liefert die Rollen-ADR für die
Spec-Straten. Mit ihrem Accept greift Trigger 1, und der Fall verlässt das Residuum. Die go-/cpp-Sätze
bleiben akzeptiertes Negativ bis `slice-151`, wie im Verdikt `2026-10-09-spec-architecture-architect-verdikt`.
**Zählregel für den Eintrag:** Ein Beleg, dessen Artefaktklasse ADR-0062 ausnimmt, zählt im Register
weiter, aber nicht für Trigger 2. Trigger 2 prüfen nur Fälle im Residuum, das ADR-0062 Festlegung 1
besiedelt.

## B — 3b je Eintrag

**Lesart der 4×-Regel: bestätigt.** Sie zählt wie im Vorgänger-Verdikt: Die Schwelle ist erneut
erreicht, wenn nach der Verkörperung drei weitere Vorgänge belegt sind. Steht für die Klasse schon
*kein Sensor möglich*, ist danach nur noch ein neuer Grund oder eine neue Möglichkeit der Anlass
(ADR-0076 Festlegung 7, sinngemäß verallgemeinert). Die Zahl allein ist es nicht.
`kosten-einer-emittierten-pruefung-im-ziel-ungemessen` hat 1 Beleg nach `MR-089` und **greift nicht**.

| Eintrag | Verdikt | Grund |
|---|---|---|
| **B-1** `plan-abweichung-…` | kein Sensor angemessen, **akzeptiertes Negativ** mit neuer Begründung | Das Hindernis *„ein Commit trägt keine Slice-Kennung"* ist für die Namensform entfallen. Ein zweites bleibt: Spalte 1 von §3 ist *„Datei / Komponente"* aus der vendored Vorlage ([`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) und keine geschlossene Pfad-Form (`slice-kotlin-freshness` §3: *„`kotlin-freshness.sh` unter `harness/tools/`"*, `test/mutations/`). Ein Abgleich wäre also heuristisch. Der Träger trägt: alle 7 Belege hat der Plan-vs-Code-Diff von Verifier oder Review vor der Closure gefunden, und §3 wurde nachgezogen. Ein Sensor würde nur einen Träger automatisieren, der schon funktioniert. Fällt beim Auftraggeber B-4 auf *schneiden*, kann der Wächter dort dieselbe Commit-Menge zusätzlich als Liste ausgeben (*Datei nicht in §3*, beratend). Das ist eine Option, keine Pflicht. |
| **B-2** `mutations-fall-…` | kein Sensor möglich, **Begründung unverändert** | Die vorgeschlagene Prüfung *„der genannte Test steht unter den roten"* gibt es schon: Bedingung 4 des Treibers (`grep -n "faellt nicht — falscher Grund" harness/tools/mutate.sh`). Der Kotlin-Fall ist auch keine Gegenrichtung. Unter der Mutation war `TestRun_BootstrapKotlinRoot` rot (`git show a96c30e0`: *„Die Mutation faerbt zwei Tests rot"*). Die `t.Skip`-Probe zeigt, dass er die Stelle **nicht allein** bindet. Das ist die Exklusivitäts-Frage, und die schließt `state.md` begründet aus. Keine neue Möglichkeit, nichts für `slice-mutations-anker-greift-in-den-gates`. |
| **B-3** `emittierte-zusage-…` | kein Sensor möglich (Unterklasse *Kurzbeschreibung gegen Stufenkörper*), **akzeptiertes Negativ** | Die Beschreibung sagte *„die Host-Toolchain"* zu, die Stufe schickt allein `gradle build` durch den Guard. Ein Token-Abgleich (jedes genannte Kommando steht im Körper) hätte das nicht gefunden: Die Zusage war generisch, nicht falsch benannt. Ob eine Prosa-Aussage die Reichweite eines Laufs trifft, ist ein Vergleich von Bedeutungen, wie im Verdikt zu slice-195. Das Review hat den Fall gefangen (LOW-1, behoben). Die Bedingungs-Hälfte bleibt unverändert beim Auftraggeber. |
| **B-4** `fremdes-rollen-artefakt-…` | **Sensor benannt**, kein bestehender Slice trägt ihn → Frage an den Auftraggeber | Neue Möglichkeit: Die Subjects tragen inzwischen die Rolle (`Rolle <R>: <kennung> --`, `git log --format=%s d82ac7be..HEAD \| grep -c '^Rolle '`). Und *„git sieht Dateien, nicht Abschnitte"* (`AGENTS.md` §3.8) gilt für den Diff nicht, denn ein Hunk lässt sich seinem `## N.`-Abschnitt zuordnen. 9 der 10 Belege sind so fassbar: DoD-Zeilen, §1, §5, §6, §7, Register-Dateien, `.harness/skills/`, `harness/conventions/`. Nicht fassbar ist der Kotlin-Beleg: eine §3-Zeile ist Implementer-Abschnitt, ihr Fehler war der Inhalt (außerhalb §6 der Welle). Spezifikation unten. |
| **B-5** `waechter-misst-die-fixture-…` | Unterklasse ohne eigenen Ausgang, **akzeptiertes Negativ** | Der geplante Kopplungs-Sensor hält doppelt geführte **Werte** gegen ihre Quelle. Nachgebautes **Verhalten eines Fremd-Werkzeugs** fängt er nicht und muss es nicht. Die reale Quelle hat einen Halter: Die `full-smoke`-Stufe fährt a-check echt (Hinweis *„0 von N Import-Symbolen"*), und `full-smoke` läuft in CI auf jedem Push ([`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)). Bei einem a-check-Pin-Sprung, der die Auflösung ändert, wird diese Stufe rot. Was fehlte, war der Name dieses Halters im Testkopf. Das ist §3.6 (Lücke benennen), kein fehlender Sensor. Ausgang bleibt *geplant*, der Geltungsbereich des Slice bleibt unverändert. |

### B-4 — der benannte Sensor

- **Form:** ein Werkzeug (kein Gate), wie `make adr-immutable`, über einer Range (`RANGE=<claim>..HEAD`
  des Slice). Je Commit liest es die Rolle aus `^Rolle <R>:` im Subject. Es meldet:
  (a) einen Implementer-Commit, der in einem Slice-Plan einen Hunk außerhalb von §3 hat (Abschnitte jenseits der Vorlage, etwa ein Protokoll-Abschnitt, legt der Slice fest), oder
  Pfade unter `docs/plan/planning/observations/`, `harness/conventions*`, `docs/plan/adr/`,
  `.harness/skills/`, `AGENTS.md` berührt;
  (b) einen Architect- oder Reviewer-Commit mit Hunks in DoD, §5, §6, §7 oder mit Register-Dateien.
- **Bindepunkt:** Der Planner fährt es bei der Slice-Closure vor dem `git mv`, das Review darf es
  früher fahren. Nicht `make gates`: Die Range ist eine Eigenschaft des Slice, nicht des Baums.
- **Rot an der realen Quelle:** die Commits der 9 fassbaren Belege (je `evidence/*.md`) werden gemeldet,
  die Arbeits-Commits von `slice-kotlin-freshness` nicht.
- **Grenze:** Ein Commit ohne `Rolle`-Präfix bleibt ungesehen, und die Rolle im Subject ist
  deklariert, nicht geprüft. Für einen Inhalts-Übergriff in einem eigenen Abschnitt (der Kotlin-Beleg)
  ist der Abschnitt das falsche Maß.
- **Folge für die Norm:** Der liefernde Slice zieht die Sätze *„Ein Wächter existiert nicht"* in
  `AGENTS.md` §3.10 (und, soweit gedeckt, §3.8) nach. Das ist ein DoD-Punkt mit eigenem
  Architect-Commit. Es schärft, darum ohne ADR (§3.5).

## Frage an den Auftraggeber

**Wird der Sensor aus B-4 als Slice geschnitten?** Gegenstand: das Werkzeug oben samt Mutations-Fall
und Nachzug von §3.10. Begründung: Die Klasse hat 6 Belege nach der Verkörperung (`seit welle-15`), und
jeder davon hat eine Review- und Nachbesserungsrunde gekostet. Die Prosa-Form ist ausgeschöpft, und das
Werkzeug fasst 9 von 10 Belegen.

- **Option A, schneiden (Empfehlung).** Neuer Slice, Ausgang wechselt auf *geplant* mit seiner Kennung.
- **Option B, nicht schneiden.** Ausgang bleibt *verkörpert*, die Lücke steht dann als akzeptiertes
  Negativ mit dem Sensor als benannter Möglichkeit.

## Für den Planner (3c)

`state.md`-Ergänzungen, je ein Absatz unter dem bestehenden Stand:

- `eigentums-frage-ohne-quelle-…`: *„Trigger 2 von ADR-0062 bestätigt (Verdikt
  `2026-10-09-welle-kotlin-skelett-architect-verdikt`): Der Beleg `slice-kotlin-hexslice-mit-arch-gate`
  liegt in den Spec-Straten, die ADR-0062 ausnimmt. Träger ist `slice-151`. Für Trigger 2 zählen nur
  Belege im Residuum von Festlegung 1."*
- `plan-abweichung-…`: Begründung ersetzen durch *„Die Commit-Kennung ist für die Namensform
  vorhanden. Spalte 1 von §3 (*Datei / Komponente*, vendored Vorlage) hat aber keine geschlossene
  Pfad-Form, ein Abgleich wäre heuristisch. Der Plan-vs-Code-Diff des Verifiers findet die Klasse
  zuverlässig: akzeptiertes Negativ."*
- `mutations-fall-nennt-…`: Zusatz *„Bedingung 4 des Treibers hält, dass der genannte Test unter den
  roten steht. Dass er allein bindet, ist die ausgeschlossene Exklusivitäts-Prüfung."*
- `emittierte-zusage-…`: Zusatz *„Unterklasse Kurzbeschreibung einer E2E-Stufe gegen ihren Körper:
  kein Sensor möglich (Bedeutungsvergleich), Träger Review."*
- `fremdes-rollen-artefakt-…`: Zusatz *„Sensor benannt (Abschnitts-Wächter über Rolle im Subject,
  Verdikt `2026-10-09-welle-kotlin-skelett-architect-verdikt` B-4). Ob er einen Slice bekommt,
  entscheidet der Auftraggeber."* Bei Option A Stand → *geplant* mit Kennung.
- `waechter-misst-die-fixture-…`: Zusatz *„Unterklasse Fremd-Werkzeug-Verhalten nachgebaut: Halter der
  realen Quelle ist die `full-smoke`-Stufe in CI. Der geplante Kopplungs-Sensor deckt sie nicht und
  muss es nicht."*

**Keine Ergänzung an bestehenden Slices.** `slice-mutations-anker-greift-in-den-gates` und
`slice-ziel-traegt-keine-kennung-dieses-repos` bleiben unverändert, und keiner der fünf Punkte gehört in
sie.
