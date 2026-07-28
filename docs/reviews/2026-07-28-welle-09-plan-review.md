# Review-Report: welle-09 + slice-059 (Plan) — 2026-07-28

**Review-Art:** **Plan** — geprüft wird der **Plan** gegen Spec, aktive ADRs, Hard Rules und das
adoptierte Regelwerk, *bevor* implementiert wird (Modul 10 §Drei Review-Arten). Es gibt keinen
Produktiv-Diff; Eingabe sind die Plan-Artefakte selbst. **Nicht** geprüft: Code, DoD-Abhakung
(Modul 11, getrennter Kontext).

**Gegenstand:** `git log origin/main..HEAD` → `2645f9f` + `65a97ce`, konkret

- `docs/plan/planning/welle-09-modul-15-konformitaet.md` (neu)
- `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md` (neu)
- `docs/plan/planning/in-progress/roadmap.md` (§Aktuelle Welle geändert)

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-28

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Plan-Artefakte: die drei oben genannten Dateien
- Regelwerk (Baseline v3.5.2, vendored): `modul-15-observability.md` (der Gegenstand),
  `modul-05-planning-harness.md` §Ziel-Form: Slice, `modul-06-roadmap.md`,
  `modul-07-carveouts.md`, `modul-09-implementierung.md` §Rücksprungkanten,
  `modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin)
- Vorlagen: `.harness/baseline/v3.5.2/templates/docs/plan/planning/{welle,slice}.template.md`,
  `.harness/baseline/v3.5.2/templates/harness/conventions.template.md`
- Adaptionen: [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage), [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks), [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption), [`MR-008`](../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert), [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler), [`MR-016`](../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird), [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
- Hard Rules: [`AGENTS.md`](../../AGENTS.md) §3, besonders §3.4/§3.5/§3.6
- Spec: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)
- Vorherige Findings derselben Klasse: `docs/reviews/2026-07-27-slice-058-plan-review.md`
  (F-2 „kein ADR geplant, obwohl die Präzedenz einen verlangt" → wurde ADR-0010)
- Gate-Läufe dieser Sitzung: `make gates` **Exit 0**, `make docs-check` → **d-check 227/0**,
  `comment-claims 31/0`

---

## Findings

### F-1 — Die widerrufene `MR-000`-Begründung lebt in vier Plan-Stellen weiter, davon in der kanonischen Roadmap

- `kategorie`: **MEDIUM**
- `quelle`: [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) · [`AGENTS.md`](../../AGENTS.md) §2 (Source Precedence, Roadmap = Rang 4) · [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `docs/plan/planning/in-progress/roadmap.md:25-30` · `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md:10-11` · `docs/plan/planning/welle-09-modul-15-konformitaet.md:105` und `:109`
- `befund`: Der zweite Commit (`65a97ce`) widerruft die Begründung der Welle ausdrücklich —
  „Das war **über-gelesen**" (welle-09 §1, Zeile 32–41) — und stellt fest, dass die vendored
  Vorlage `MR-000` auf vier Bereiche eingrenzt. Die Korrektur landete jedoch **nur** in der
  Welle-Datei. Die Roadmap trägt weiter die widerrufene Fassung wörtlich („zugleich erklärt
  `MR-000` ‚keine inhaltlichen Adaptionen‘ … Damit trägt das Repo heute eine **nicht deklarierte
  Abweichung**"); slice-059 führt `MR-000` als ersten **Bezug** mit derselben Lesart in Klammern
  („Baseline ohne inhaltliche Adaption — Modul 15 ist adoptiert und unumgesetzt"); die
  Slice-Tabelle der Welle nennt `MR-000` als Bezug für slice-060 und slice-064. Damit steht in
  der **höherrangigen** Quelle (Roadmap, Rang 4) eine Aussage, die die niederrangige Welle-Datei
  eine Seite später als falsch ausweist. Failure-Szenario: der Planner der Welle-Closure oder der
  Autor von slice-064 liest die Roadmap, leitet daraus erneut „nicht deklarierte Abweichung" ab
  und misst den Bestand gegen eine Prämisse, die der Plan selbst als über-gelesen protokolliert
  hat — dieselbe Fehlableitung, die den ersten Entwurf dieser Welle bereits einmal getragen hat.
  Es ist zugleich die vom Repo selbst zweimal dokumentierte Klasse „derselbe Stand an zwei Orten,
  einer altert" (Roadmap `:39-40`, Drift-Log-Eintrag 2026-07-25 zu slice-047/048).
- `verifizierbar`: ja — `grep -n "nicht deklarierte Abweichung" docs/plan/planning/in-progress/roadmap.md`
  gegen `docs/plan/planning/welle-09-modul-15-konformitaet.md:32-41`. Kein Gate deckt es
  (`make gates` Exit 0 mit beiden Fassungen im Baum).

### F-2 — DoD (1) nennt ein „Pflicht-Minimum", das nicht das Pflicht-Minimum von Modul 15 ist

- `kategorie`: **HIGH**
- `quelle`: `modul-15-observability.md` §Span-/Audit-Attribut-Regeln · [`AGENTS.md`](../../AGENTS.md) §3.6 · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md:37-42`
- `befund`: Modul 15 führt **zwei getrennte** Aufzählungen: die *Mindestfelder eines
  Tool-Call-Spans* (`tool.name`, `tool.arguments` redacted, `tool.result.status` plus
  Korrelations-IDs) **und**, im Absatz *Audit-Span-Schema*, ein ausdrücklich so benanntes
  „**Pflicht-Minimum: Slice-ID, Agent-Rolle, Cache-Status, `requirement.id`** — jede Abweichung
  davon begründest du." DoD (1) verschmilzt beide zu einer Liste und deklariert sie als *das*
  Pflicht-Minimum: `slice.id`, `agent.role`, `tool.name`, `tool.arguments`, `tool.result.status`.
  **`requirement.id` und Cache-Status fehlen** — und weil der Plan seine eigene, kürzere Liste
  zur Messlatte erklärt („Jede Abweichung vom Minimum wird begründet"), löst ihr Fehlen die vom
  Modul verlangte Begründungspflicht **nicht** aus. Failure-Szenario: der Implementer erfüllt DoD
  (1) buchstabengetreu, der Verifier hakt sie ab, die Closure-Matrix der Welle trägt für Block 1 /
  Repo den Wert **„Sensor"** — während zwei der vier normativ verlangten Pflicht-Felder fehlen und
  nirgends als Abweichung deklariert sind. Das ist genau das „Schweigen", zu dessen Beendigung die
  Welle geschnitten wurde, eine Ebene tiefer reproduziert. Zusatzfolge: der fehlende Cache-Status
  entzieht slice-060 (Blöcke 2–3) die eigene Datenquelle und wirft dessen Cache-Zähler auf das
  Transkript zurück, das die Welle in §4 gerade als untaugliche Quelle verworfen hat.
- `verifizierbar`: ja — Zitat-Abgleich gegen
  `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` §Span-/Audit-Attribut-Regeln,
  dritter Bullet. Kein Gate deckt es.

### F-3 — Der benannte Erfassungsort sieht nur `Bash`; Schreibzugriffe erzeugen keinen Span, und die Messliste fragt nicht danach

- `kategorie`: **HIGH**
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · [`AGENTS.md`](../../AGENTS.md) §3.6 · `modul-15-observability.md` §Kernidee („ein Span **pro Tool-Call**")
- `pfad`: `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md:26-30`, `:37-42` (Incident-Frage zu `slice.id`), `:62-66` (Ist-Messung), `:68-76` (Fragen A–E)
- `befund`: Der Plan verankert die Erfassung auf dem bestehenden `PreToolUse`-Hook. Dieser ist in
  `.claude/settings.json` mit `"matcher": "Bash"` registriert — er feuert **ausschließlich für
  Bash-Tool-Calls**. Der Plan beschreibt das in §1 und §3 korrekt („sieht jeden **Bash**-Aufruf"),
  zieht daraus aber die Zusage „**Jeder** Tool-Call schreibt einen Span" (§1) und begründet
  `slice.id` mit der Incident-Frage „auf wessen Rechnung lief der **Schreibzugriff**?" — während
  Schreibzugriffe im Ziel-Werkzeug über `Write`/`Edit` laufen, die der Matcher nicht erfasst.
  Die Messliste A–E fragt nach Events (A), Subagenten (B), `slice.id` (C), `agent.role` (D) und
  Latenz (E) — die **Tool-Klassen-Abdeckung des Matchers** kommt darin nicht vor, und die
  Änderungstabelle sieht an `.claude/settings.json` nur „das Nach-Event verdrahten" vor.
  Failure-Szenario: der Slice liefert ein JSONL, in dem jeder `git`-, `make`- und `grep`-Aufruf
  steht und **keine** einzige Datei-Änderung; DoD (2) („Spans liegen vor, Felder vollständig")
  ist trotzdem erfüllbar und grün, die Closure-Matrix trägt „Sensor", und die forensische Frage,
  auf deren Formulierung DoD (1) das Pflichtfeld stützt, ist mit den erfassten Daten **nicht**
  beantwortbar. Zweite Instanz derselben Lücke: `.codex/hooks.json` kennt nur `SessionStart` —
  Codex-Läufe hinterlassen unter diesem Zuschnitt gar keinen Span, was die Rollen-Bilanz aus
  slice-060 systematisch verzerrt.
- `verifizierbar`: ja — `grep -n matcher .claude/settings.json` → `"matcher": "Bash"`;
  `cat .codex/hooks.json` → nur `SessionStart`. Kein Gate deckt es.

### F-4 — Keine ADR vor slice-059, obwohl dort die Artefakt-Klasse und die Sicherheitsfläche real entstehen

- `kategorie`: **MEDIUM**
- `quelle`: Präzedenz [`ADR-0009`](../plan/adr/0009-hexslice-arch-realisierung.md)/[`ADR-0010`](../plan/adr/0010-hexagonal-arch-realisierung.md) (aus dem Plan-Review-Befund F-2 vom 2026-07-27) · [`ADR-0006`](../plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) (Dogfood → Emission) · [`AGENTS.md`](../../AGENTS.md) §5
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:130-137` · `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md:78-84`
- `befund`: Die Welle verortet die ADR bei **slice-062** („Ein ADR ist wahrscheinlich, weil eine
  neue Artefakt-Klasse mit Sicherheitsfläche … im Ziel entsteht") und begründet die Reihenfolge
  zugleich mit „**Erprobung → Entscheidung → Emission**: was wir ins Ziel legen, haben wir hier
  erprobt". Beide Sätze zusammen bedeuten: die Entscheidungen, die slice-062 formal treffen soll —
  welche Felder, welche Redaktions-Strategie, wo die Senke liegt, wie lange sie lebt — sind zum
  Zeitpunkt von 062 im Dogfood bereits festgelegt. slice-059 sieht als Ablage dafür einen
  `MR`-Eintrag in [`harness/conventions.md`](../../harness/conventions.md) vor, also ein
  Struktur-Regel-Artefakt, und trägt dafür **keinen** eigenen DoD-Punkt (nur die Standard-Zeile
  „Doku-Update, falls ein öffentlicher Vertrag berührt ist"). Failure-Szenario: slice-062
  „entscheidet" ein Fait accompli und dokumentiert es rückwirkend; die eigentliche Entscheidung
  — inklusive der Sicherheitsfläche — ist nur im Slice-Text und in einem `MR`-Eintrag auffindbar,
  während [`AGENTS.md`](../../AGENTS.md) §3.4 ADRs gerade deshalb immutabel hält, damit
  Architektur-Entscheidungen nicht in Artefakten leben, die nach `done/` wandern. Das ist
  wortgleich der Befund F-2 des slice-058-Plan-Reviews, der dort zu
  [`ADR-0010`](../plan/adr/0010-hexagonal-arch-realisierung.md) führte.
- `verifizierbar`: nein — Konsistenz-Urteil gegen die eigene, 24 Stunden alte Präzedenz; kein Gate.

### F-5 — Der Redaktions-Zahn misst die bekannte Muster-Instanz, nicht die Eigenschaft

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 („ein Test, dessen Name eine Eigenschaft behauptet, muss die Eigenschaft messen, nicht ihre heutige Implementierung") · [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
- `pfad`: `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md:48-51` (DoD 3) · `:108-109` (§6)
- `befund`: Die Redaktion ist im Plan **an der richtigen Stelle** verankert — DoD (3), mit eigenem
  `test/mutations/`-Fall, und nicht als bloßes Risiko. Die Zusage lautet aber „ein Span mit einem
  **unredigierten Secret** in `tool.arguments` ist ein Befund", ohne festzulegen, ob die Redaktion
  als **Allowlist** (nur bekannte, unverdächtige Felder werden geloggt — fail-closed) oder als
  **Denylist** (bekannte Secret-Muster werden geschwärzt — fail-open) gebaut wird. Bei einer
  Denylist prüft der Mutations-Fall notwendig ein Muster, das die Implementierung ohnehin kennt;
  er kann unter keiner realen Lücke rot werden. Failure-Szenario: ein Secret in unvorgesehener
  Form (`--token=…`, ein Base64-Blob, eine expandierte Umgebungsvariable, ein Here-String) passiert
  die Musterliste, landet im JSONL unter `.harness/state/`, `make mutate` bleibt grün, und das
  Audit-Log sammelt genau das, was §6 selbst als „Schaden, kein Sensor" bezeichnet. Verschärfend:
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  ist für emittierte Prüfbereiche bindend („laut falsch schlägt leise falsch"), und die Welle
  plant genau diese Emission in slice-063 — die Fehlrichtung würde mit ausgeliefert.
- `verifizierbar`: ja, aber erst am Artefakt — `make mutate` gegen den Fall aus DoD (3); der
  Plan-Stand ist per Lektüre prüfbar (die Wörter „Allowlist"/„Denylist"/„fail-closed" kommen in
  slice-059 nicht vor).

### F-6 — `full-smoke` grün ist ein Nicht-Regressions-Beleg, kein Anwesenheits-Beleg — der rot gesehene Zahn fehlt

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · Präzedenz `docs/plan/planning/done/welle-08-cpp-hexslice.md:47-50`
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:88-90`
- `befund`: Die Welle verankert für die gesamte **Tool**-Spalte genau einen Beleg: „was emittiert
  wird, ist im frisch gebootstrappten Ziel out-of-the-box grün (`make full-smoke`)". `full-smoke`
  fährt im Ziel dessen zusammengeführten `make gates`; kein Gate im Ziel hängt an der Existenz
  oder Funktion eines Span-Emitters. Ein grüner Lauf ist damit auch dann grün, wenn der emittierte
  Emitter nie feuert (falscher Hook-Pfad, nicht ausführbare Datei, leeres JSONL). Die
  Vorgänger-Welle hat genau diese Lücke geschlossen und den Unterschied explizit gemacht: welle-08
  verlangte `full-smoke` grün **und** den verbotenen Import „**rot gesehen**". welle-09 übernimmt
  die grüne Hälfte und lässt die rote weg; der zweite Closure-Bullet („jeder neue **Wächter** hat
  seinen `test/mutations/`-Fall") greift nicht, weil ein Span-Emitter kein Wächter ist.
  Failure-Szenario: slice-063 emittiert einen Emitter, der im Ziel nichts schreibt; `full-smoke`
  ist grün; die Closure-Matrix trägt in vier Tool-Zellen „emittiert" mit grünem Beleg; die Welle
  schließt auditierbar über einem Prüfbereich, den nichts geprüft hat.
- `verifizierbar`: ja — `sed -n '43,56p' docs/plan/planning/done/welle-08-cpp-hexslice.md` gegen
  `sed -n '88,92p' docs/plan/planning/welle-09-modul-15-konformitaet.md`.

### F-7 — Die Werte-Tabelle lässt die Tool-Spalte ohne Auflösungs-Trigger schließen, entgegen dem eigenen §1

- `kategorie`: **MEDIUM**
- `quelle`: `modul-07-carveouts.md` §Kernidee („Ein Carveout ohne Auflösungs-Trigger ist ein permanenter Carveout, der lügt") · welle-09 §1
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:16-18` gegen `:81-86`
- `befund`: §1 formuliert das Welle-Ziel so, dass jede Zelle „entweder einen laufenden Sensor oder
  eine deklarierte Entscheidung **mit Auflösungs-Trigger**" trägt. Die Werte-Tabelle in §3 setzt
  das für den Wert *deklariert* um (Geltungsbereich, Begründung, Auflösungs-Trigger), definiert
  den nur für die Tool-Spalte zulässigen dritten Wert aber als „*die Entscheidung selbst ist der
  Beleg, nicht ihr Ausgang*" — **ohne** Auflösungs-Trigger. Failure-Szenario: welle-09 schließt
  auditierbar mit vier Tool-Zellen „nicht emittiert", die von einem ADR-Satz getragen werden, an
  dem keine Bedingung hängt, unter der die Frage je wieder aufgeht; die Tool-Ebene bleibt dauerhaft
  und ohne Wiedervorlage stumm, während das Closure-Protokoll „nichts dazwischen" bescheinigt.
  Das ist der Fall, den Modul 7 als „permanenter Carveout, der lügt" benennt, in der Form einer
  Welle-Closure statt eines `CO-*`.
- `verifizierbar`: nein — Widerspruch innerhalb desselben Dokuments, per Lektüre feststellbar; kein Gate.

### F-8 — Der Schnitt trägt einen Slice, der außerhalb der eigenen Closure-Matrix liegt und ihren Umfang öffnet

- `kategorie`: **MEDIUM**
- `quelle`: [`MR-016`](../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 1 Frage 2 · `modul-06-roadmap.md` §Welle ≠ Meilenstein ≠ Release · welle-09 §6
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:109` und `:143-147` gegen `:76-87` und `:174-176`
- `befund`: Der [`MR-016`](../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)-Test
  ist im Plan beantwortet, und für slice-059…063 trägt die Antwort: die 4 × 2-Matrix ist eine
  Bedingung, die erst wahr wird, wenn alle fertig sind, und schreibt keinen Einzel-DoD ab.
  **slice-064 fällt heraus.** Sein Gegenstand ist nicht Modul 15, sondern „welche
  Regelwerk-Abschnitte sind adoptiert, aber unumgesetzt?" über **alle** 21 vendored Dateien; er
  besetzt keine Zelle der Matrix, und sein Ergebnis ist per Konstruktion eine offene Liste, aus
  der weitere Entscheidungen folgen. Weil aber „**Alle Slices dieser Welle in `done/`**" der erste
  Closure-Trigger ist, hängt der Abschluss von welle-09 an einer unbegrenzten Bestandsaufnahme.
  Der Plan formuliert die Gegenregel im selben Dokument selbst: „Wer mehr hineinzieht, verliert
  das Closure-Kriterium" (§6). Failure-Szenario: die vier Blöcke sind auf beiden Ebenen längst
  belegt, die Matrix ist voll, und die Welle bleibt offen, weil ein Inventar über das gesamte
  Regelwerk noch läuft — oder sie wird geschlossen, indem slice-064 auf eine Stichprobe verkürzt
  wird, womit der Slice seine eigene Zusage verliert. Messung zum Größenvergleich: welle-09 ist
  mit **sechs** Slices die größte Welle der Repo-Historie, gleichauf allein mit welle-02 — der
  einzigen, die mitten im Lauf umgeplant werden musste (Drift-Log 2026-07-20).
- `verifizierbar`: ja — Slice-Zahlen je Welle:
  `awk '/^## 4\./,/^## 5\./' <welle>.md | grep -cE '^\| *(\[)?slice-'` → welle-01…09:
  4 · 6 · 3 · 4 · 5 · 3 · 4 · 2 · **6**.

### F-9 — Die eingefaltete Roadmap-Achse steht weiter als ungeschnittener Kandidat

- `kategorie`: **MEDIUM**
- `quelle`: `modul-06-roadmap.md` §Nächste Wellen · die Format-Regel der Roadmap selbst
- `pfad`: `docs/plan/planning/in-progress/roadmap.md:46` (Kandidat *Regeln ohne Feedback-Quadrant schließen*, Achse (1)) gegen `docs/plan/planning/welle-09-modul-15-konformitaet.md:54-58`
- `befund`: Die Welle „**faltet den Roadmap-Kandidaten hinein**, statt eine zweite Wahrheit
  danebenzustellen: dessen Achse (1) … **ist** Modul-15-Block-4" und weist sie slice-061 zu.
  Die Kandidaten-Tabelle der Roadmap führt Achse (1) unverändert und unannotiert weiter, obwohl
  die Tabelle unmittelbar darüber ihre eigene Regel notiert: „Diese Tabelle führt nur, was *noch
  nicht* geschnitten ist — … sonst wird derselbe Stand an zwei Orten gepflegt und einer davon
  altert (real passiert mit slice-047/048)". Failure-Szenario: nach der welle-09-Closure verspricht
  die Kandidaten-Zeile weiterhin einen Sensor, den slice-061 gebaut hat; die nächste
  Wellen-Planung schneidet ihn ein zweites Mal oder streicht ihn irrtümlich mitsamt den fünf
  übrigen Achsen, die tatsächlich offen sind.
- `verifizierbar`: ja — `grep -n "Gate-Tabellen in" docs/plan/planning/in-progress/roadmap.md`
  liefert die Achse (1) in der Kandidaten-Tabelle, während `welle-09` sie slice-061 zuweist.

### F-10 — Kein Drift-Log-Eintrag für den Schnitt von welle-09

- `kategorie`: **LOW**
- `quelle`: `modul-06-roadmap.md` §Roadmap-Struktur („Historische Trigger-Verschiebungen — jede Umplanung mit Datum, Änderung, Grund")
- `pfad`: `docs/plan/planning/in-progress/roadmap.md:93-106`
- `befund`: Der Schnitt einer neuen Welle **plus** das Einfalten eines bestehenden Kandidaten ist
  eine Umplanung. Der unmittelbare Präzedenzfall steht in der ersten Zeile derselben Tabelle: der
  Schnitt von welle-08 am 2026-07-27 hat seinen Drift-Log-Eintrag inklusive
  [`MR-016`](../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)-Begründung
  bekommen. Für welle-09 fehlt er; die jüngste Zeile bleibt der 2026-07-27.
  Failure-Szenario: die Roadmap-Vergangenheit ist an dieser Stelle nicht auditierbar — weder der
  Grund für den Schnitt noch die Umwidmung der Kandidaten-Achse (1) hinterlässt eine Spur,
  sobald welle-09 ins Closure-Log wandert und §Aktuelle Welle überschrieben wird.
- `verifizierbar`: ja — `grep -c "2026-07-28" docs/plan/planning/in-progress/roadmap.md` → 1
  (nur die Zeile in §Aktuelle Welle, kein Drift-Log-Eintrag).

### F-11 — Eine Ist-Messung nennt eine Datei, die nicht existiert

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 („Kommando neben der Aussage") · [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- `pfad`: `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md:65`
- `befund`: Zeile 4 der als „Ist-Messung (2026-07-28, live)" überschriebenen Tabelle belegt den
  gitignorten Ablageort mit „`.harness/.gitignore` → `state/`". Diese Datei existiert nicht; die
  Regel steht in der Wurzel-`.gitignore` (Zeile 5, `.harness/state/`). Die **Aussage** stimmt
  (`git check-ignore -v .harness/state/gates-passed.diffsha` bestätigt sie), der **Beleg** nicht.
  Failure-Szenario: der Implementer verifiziert den Plan-Punkt am genannten Pfad, findet nichts
  und legt entweder eine zweite, redundante `.harness/.gitignore` an — die gegen die Wurzel-Datei
  driften kann — oder schließt, der Ablageort sei ungeschützt, und wählt einen anderen, womit
  DoD (2) seine Begründung verliert. Der Doc-Gate fängt es nicht: `codepaths.roots` ist auf
  `[spec, docs, harness]` beschränkt, `.harness/**` liegt außerhalb des Prüfbereichs
  (`make docs-check` → 227/0 mit dem falschen Pfad im Baum).
- `verifizierbar`: ja — `test -e .harness/.gitignore` → false; `grep -n "harness/state" .gitignore`
  → `5:.harness/state/`.

### F-12 — Die Deklaration steht am Ende, obwohl der undeklarierte Zustand heute besteht und bereits als falsch gemessen ist

- `kategorie`: **MEDIUM**
- `quelle`: [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) · `.harness/baseline/v3.5.2/templates/harness/conventions.template.md` §`MR-000` · [`AGENTS.md`](../../AGENTS.md) §2
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:45-47` und `:143-147` gegen `harness/conventions.md:38-41`
- `befund`: Der Plan stellt fest — und der Reviewer bestätigt es am Vorlagen-Text —, dass
  [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) gegenüber der vendored Vorlage
  eine **Verschärfung** ist: die Vorlage grenzt „keine inhaltlichen Adaptionen" auf
  Verzeichniskonvention, Lifecycle-Regeln, Carveout-Disziplin und ID-Schema ein, unser Eintrag hat
  die Aufzählung fallen gelassen. Der Plan nennt das eine „Adaption, die behauptet, es gebe keine",
  und legt ihre Behandlung in **slice-064** — den letzten von sechs, hinter drei Repo- und zwei
  Tool-Slices. Bis dahin bleibt in [`harness/conventions.md`](../../harness/conventions.md) — der
  Datei, auf die [`AGENTS.md`](../../AGENTS.md) §1 für alle Struktur- und Adaptionsfragen verweist
  — eine Konformitätsaussage stehen, die der Autor bereits als unzutreffend gemessen hat.
  Failure-Szenario: der Autor des CR und der ADR zu slice-062 muss beurteilen, ob der **emittierte**
  Harness von der Baseline abweicht, liest dafür `MR-000`, findet „keine inhaltlichen Adaptionen"
  und leitet daraus dieselbe Fehlschluss-Kette ab, die den ersten Entwurf dieser Welle bereits
  einmal getragen hat — die Wiederholung ist in `65a97ce` protokolliert, nicht hypothetisch.
- `verifizierbar`: ja — `diff <(sed -n '96,110p' .harness/baseline/v3.5.2/templates/harness/conventions.template.md) <(sed -n '34,44p' harness/conventions.md)`;
  kein Gate deckt es.

## Negativbefunde

- geprüft, ohne Befund: **die Trigger-Messung der Welle** (§2) — nachgezählt und exakt bestätigt:
  `git log --all -- '*modul-15-observability.md'` → **vier** Commits (`554cade` 2026-07-17 =
  slice-011, `fa41121` slice-019, `33fc908` slice-043, `ce4b611` slice-049), alle vier
  Re-Vendor-Läufe; `git log --grep='Observabilit\|Telemetri' -i` → **null** vor `2645f9f`. Die
  Behauptung „adoptiert, in keinem Block umgesetzt und nie diskutiert" hält der Messung stand.
- geprüft, ohne Befund: **die Selbstkorrektur in §1** — sachlich richtig. Die vendored Vorlage
  (`conventions.template.md:100-103`) grenzt `MR-000` verbatim auf vier Bereiche ein; die Baseline
  behauptet an keiner Stelle, jede Regel jedes Moduls sei umgesetzt. Die neue, schwächere
  Begründung („adoptiert, unumgesetzt, nie entschieden") trägt eigenständig und ist **nicht** zu
  schwach: sie ist genau die Bedingung, die Modul 6 für einen beobachtbaren Trigger verlangt. Die
  Korrektur ist inhaltlich abgeschlossen — offen ist nur ihre Verteilung (→ F-1) und ihr Zeitpunkt
  (→ F-12).
- geprüft, ohne Befund: **die vier Regelblöcke** — `modul-15-observability.md` führt genau vier
  Regel-Abschnitte (Span-/Audit-Attribut · Token-Attribution · Cache-Counter ·
  Doku-Konsistenz-Drift). Die 4 × 2-Matrix bildet den Gegenstand vollständig ab; kein Block ist
  vergessen, keiner doppelt gezählt.
- geprüft, ohne Befund: **Slice-Größe (Modul 5 §Ziel-Form)** — slice-059 trägt **drei**
  slice-eigene DoD-Punkte plus die drei Standard-Zeilen (`make gates` · Doku-Update ·
  Closure-Notiz), also genau die Lesart, unter der die Roadmap für die letzten neun Slices 9/9
  Überschreitungen gemessen hat. Die berührte Fläche bleibt bei zwei Schichten (Hook-Verdrahtung +
  `harness/tools/`-Skript); Tests und Normativ-Eintrag sind Begleitartefakte, keine dritte
  Schicht. Die Regel wird hier eingehalten, nicht nur behauptet — die Zahl ist am Artefakt
  nachzählbar.
- geprüft, ohne Befund: **cp-Disziplin ([`MR-008`](../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert))** —
  beide Artefakte tragen die Abschnittsfolge ihrer vendored Vorlage vollständig und in Reihenfolge
  (Welle §1–§7, Slice §1–§8 inklusive der §8-Sub-Area-Begründung); die Welle-Tabelle ergänzt eine
  `Ebene`-Spalte, was additiv ist und keine Status-Spalte (die Vorlage verbietet ausdrücklich nur
  Letztere).
- geprüft, ohne Befund: **`open → next`-Reife / Spike-Frage (Modul 9)** — „Messen im ersten
  Implementer-Lauf" ist hier regelkonform: Modul 9 kennt für diesen Fall die Rücksprungkanten 5→4
  und 6→4, Modul 5 verlangt bei zu großem Schnitt `in-progress→next` statt stillem Weiterschieben,
  und slice-059 §4 **deklariert beide Kanten vorab und konkret** (B negativ → `next` mit benanntem
  Re-Slice; A negativ → `open` mit benannter Normativ-Frage). Ein vorgelagerter Spike ist damit
  nicht erzwungen. Die Reife-Lücke dieses Slice liegt nicht in der Methode, sondern in der
  **Vollständigkeit** der Messliste (→ F-3).
- geprüft, ohne Befund: **Verankerung der Redaktion** — sie steht in DoD (3) mit eigenem
  `test/mutations/`-Fall, nicht nur unter §6 Risiken, und ist ausdrücklich als „nicht später
  härten" markiert. Der **Ort** ist richtig; beanstandet wird allein die Zahn-Form (→ F-5).
- geprüft, ohne Befund: **Gate-Nachweis-Kollision** — die Ablage in `.harness/state/` ist korrekt
  begründet und real gitignored (`git check-ignore -v` bestätigt es); der `working-tree-hash` deckt
  getrackte **und** untrackte Dateien, ein Span im Baum machte den Stop-Hook zum Selbstblockierer.
  Der Plan nimmt die slice-031-Lehre vorweg, statt sie erneut zu lernen.
- geprüft, ohne Befund: **[`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  (CR-Pflicht)** — die Welle verortet den CR korrekt: eigener Commit des Auftraggebers **vor**
  slice-062, und §6 grenzt ausdrücklich aus, den Adopter-Vertrag ohne ihn zu bewegen. Kein Artefakt
  dieses Commit-Range berührt `spec/lastenheft.md`; ein CR ist zum jetzigen Zeitpunkt nicht fällig.
- geprüft, ohne Befund: **[`MR-008`](../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)-Linie
  „was gehört dem Kurs"** — §6 grenzt `conventions.template.md` und die übrige Doc-Chain als
  Upstream-Eigentum aus und verbietet eine repo-eigene Kopie. Die Aussage „das Tool emittiert das
  vollständige Regelwerk ins Ziel" ist gegen
  [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) geprüft und trifft zu
  (der Bootstrap holt den gepinnten Kurs-Stand und schreibt ihn als committet-vendored Baseline
  des Ziels). Der Plan behandelt an keiner Stelle Kurs-Inhalt als von uns emittierbar —
  emittierbar ist allein **unsere** Realisierung.
- geprüft, ohne Befund: **beide Ebenen wirklich betrachtet** — Repo (059–061) und Tool (062–063)
  sind getrennt geführt, mit unterschiedlichen Verträgen und einer begründeten Reihenfolge
  (Erprobung → Entscheidung → Emission, [`ADR-0006`](../plan/adr/0006-durchsetzung-commands-tool-als-quelle.md)-Linie).
  Die Tool-Ebene ist nicht als „aufgeschoben" abgelegt. Beanstandet wird die **Beleg-Form** der
  Tool-Spalte (→ F-6) und ihr fehlender Auflösungs-Trigger (→ F-7), nicht ihre Existenz.
- geprüft, ohne Befund: **Carveout-Disziplin (Modul 7)** — §3 verankert das Carveout-Audit als
  Closure-Trigger mit namentlichem Bezug auf
  [`CO-001`](../plan/carveouts/CO-001-bats-shell-lint.md) (Status *Aktiv*, letzte Prüfung
  2026-07-27); slice-059 §6 erklärt „kein Carveout absehbar". Beides entspricht der
  Wellen-Closure-Prozedur Schritt 2.
- geprüft, ohne Befund: **[`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
  (Abhängigkeiten)** — die Erfassung bleibt bash+awk gegen den bereits vorhandenen
  `harness/tools/json-encode.awk`; §6 grenzt den OTel-*Stack* (Collector/Backend/Dashboard/SDK)
  sauber gegen die *Erfassung* ab. Keine neue Laufzeit-Abhängigkeit, kein Host-Toolchain-Bedarf
  ([`ADR-0003`](../plan/adr/0003-go-native-binaries.md)).
- geprüft, ohne Befund: **Doc-Gate-Regeln** — `make gates` Exit 0; `make docs-check` → **227
  Dateien, 0 Befunde**; `comment-claims` 31/0. Plan-Artefakte verlinken auf ADRs (erlaubt; die
  `matrix`-Regel verbietet nur Abwärts-Verweise aus den `spec/`-Straten), alle
  `LH-`/`ADR-`/`MR-`-Kennungen sind als Links geführt, und die relativen Tiefen stimmen
  (`../../../../` aus `planning/{open,in-progress}/`, `../../../` aus `planning/`). Die einzige
  nicht existierende Pfad-Nennung liegt außerhalb des `codepaths`-Prüfbereichs (→ F-11).
- geprüft, ohne Befund: **[`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)
  (Ablage-Ort)** — das Span-Skript ist nach `harness/tools/` verortet, mit ausdrücklicher Vorsorge
  gegen einen später erschwerten Umzug in die emittierte Ablage und ohne Quell-Repo-Identität
  (Lehre aus slice-031/032/033).
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.4/§3.5** — der Plan lockert kein Gate
  und ändert keine Accepted-ADR; die geplanten Ergänzungen sind ausschließlich Verschärfungen bzw.
  neue Sensoren.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 2 |
| MEDIUM | 7 |
| LOW | 2 |
| INFO | 0 |

## Verdikt

**Blockierend für `open → next`:** **ja.**

**Warum.** Zwei HIGH treffen den ersten Slice unmittelbar an seiner Definition of Done, und beide
sind vom selben Typ: der Plan sagt eine Eigenschaft zu, die sein eigener Zuschnitt nicht messen
kann. **F-2** erklärt eine unvollständige Feldliste zum „Pflicht-Minimum" von Modul 15 und
entzieht damit der Abweichungs-Begründung, die das Modul verlangt, ihren Auslöser. **F-3**
verankert die Erfassung auf einem Hook, der ausschließlich `Bash` sieht, während die DoD „jeder
Tool-Call" zusagt und ihr Pflichtfeld mit der Incident-Frage nach dem *Schreibzugriff* begründet —
der von diesem Hook nie erfasst wird. Beide würden in der Umsetzung **grün** aussehen: DoD
abgehakt, Closure-Zelle „Sensor", `make gates` und `make mutate` ohne Befund. Genau dafür sieht
Modul 10 den Plan-Review vor.

**Die Welle selbst trägt.** Ihre Begründung ist gemessen und hält (Negativbefund 1), die
Selbstkorrektur zu [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) ist sachlich
richtig und in der neuen Fassung weder zu stark noch zu schwach (Negativbefund 2), der
[`MR-016`](../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)-Test
ist für fünf der sechs Slices korrekt beantwortet, und beide Ebenen sind real betrachtet statt
abgelegt. Die sieben MEDIUM sind **keine** Einwände gegen die Welle, sondern gegen die Haltbarkeit
ihrer Belege: der Closure-Beleg der Tool-Spalte kann nicht rot werden (F-6), ihr dritter Zellwert
kennt keinen Auflösungs-Trigger (F-7), ein sechster Slice steht außerhalb der Matrix, an der die
Welle schließt (F-8) — und die widerrufene Begründung lebt in der höherrangigen Roadmap weiter
(F-1), während die als falsch gemessene Konformitätsaussage in
[`harness/conventions.md`](../../harness/conventions.md) bis zum letzten Slice stehen bleibt
(F-12).

**Antwort auf die ADR-Frage, weil die Vorlage dafür kein Feld hat:** ja, und **vor slice-059**,
nicht vor slice-062 — die Artefakt-Klasse, der Datenfluss und die Sicherheitsfläche entstehen im
Dogfood, und die Welle erklärt den Dogfood ausdrücklich zum Prüfstand, dessen Ergebnis das Ziel
übernimmt (F-4). Das ist dieselbe Konstellation, die im slice-058-Plan-Review als F-2 gemeldet
wurde und zu [`ADR-0010`](../plan/adr/0010-hexagonal-arch-realisierung.md) führte — **zweite
Instanz derselben Klasse innerhalb von 24 Stunden** und damit nach dem Reviewer-Skill
(§Kontext-Eskalation) ein Steering-Loop-Signal: „ADR-Bedarf beim Schnitt entscheiden, nicht im
Plan-Review nachtragen" gehört in die Planner-Checkliste, nicht in den nächsten Report.

**Übergabe:** an die **Planung** (Rückkante Review → Plan). Es gibt keinen Diff; nichts geht an die
Implementation. Der Report ersetzt keine Verifikation — DoD-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
