# Reviewer-Skill — ai-harness-init

**Version:** 2.3.0 · **Datum:** 2026-09-27 ·
**Baseline:** Agents-Regelwerk v6.7.2 (Kurs-Welle 134), Modul 10 §Ziel-Form: Reviewer-Skill
(Kontext-Eingang · Klassifikation · „Was dieser Skill NICHT macht" · Output-Schema mit
Negativbefund-Pflicht · Pflege).

* Status: Accepted
* Bezug: [`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  (ein Rollen-Anweisungssatz gehört der Rolle, die ihn ausführt) ·
  [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules)
* Gilt für: jeden Lauf unter dem Agenten-Typ `reviewer`
  ([`.claude/agents/reviewer.md`](../../.claude/agents/reviewer.md))

## Kontext-Eingang (Pflicht)

Was der Reviewer *immer* mitbringt, bevor er den Diff liest:

- Diff bzw. Commit-Range
- [`spec/lastenheft.md`](../../spec/lastenheft.md) (für referenzierte `LH-*`-IDs)
- die **aktiven** ADRs, deren ID im PR oder in der Commit-Message vorkommt
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules)
- vorherige Findings am gleichen Modul (letzte ~5 PRs) — damit wiederkehrende
  Muster erkennbar sind und nicht jede Sitzung bei null beginnt
- **der Slice-Plan** — Repo-Ergänzung über die Baseline-Fünf hinaus: der Review
  prüft den Diff *gegen* den Plan

Ohne diesen Block sieht der Reviewer den Code, aber nicht *die Verträge, gegen
die er prüft*.

**Nicht** erhalten: die DoD-Abhakung. Plan-/DoD-Konformität prüft die
Verifikation — getrennter Kontext, anderes Prüf-Artefakt.

## Klassifikation

Jeder Anker HIGH/MEDIUM/LOW hat eine *konkrete* Liste — nicht generisch. INFO ist
bewusst kurz (Ergänzungs-Kanal, nicht Hauptkanal).

**HIGH** (blockiert Merge) — eines der folgenden:

- **Verstoß gegen eine aktive ADR oder gegen eine Hard Rule**
  ([`AGENTS.md`](../../AGENTS.md) §3)
- **Gate-Lockerung ohne ADR** — Schwellen-Senkung, Modul-Abschaltung, gelockerte
  Strenge
- **Stilles-Grün-Pfad in einem Gate oder Gate-Skript** — der Lauf meldet grün über
  einem Ausschnitt, den er nicht geprüft hat (Harness-Lüge)
- **Halluziniertes Gate** — ein Target, das die Doku behauptet und das Makefile
  nicht führt
  ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6))
- **Slice referenziert eine superseded ADR** — nur aktive sind normativ
- **Norm nur im Template-Kommentar** — eine Regel steht im `<!-- -->`-Block eines
  `.template.md` und nirgends sonst. Sie ist beim Adopter weg, sobald er die
  Kommentare entfernt. Kein Gate fängt das (Baseline-Regelwerk
  [`grundlagen-harness-dateien.md`](../../.harness/baseline/v6.13.0/regelwerk/grundlagen-harness-dateien.md)
  §Template-Schichtung)
- **Kommentar trägt keine der Kommentar-Klassen** — ein Kommentar in Code, Config
  oder Skript beschreibt die verworfene Alternative („Ohne X wäre …"), einen
  abwesenden Text („früher stand hier …") oder bricht mitten im Satz ab, weil eine
  Teilersetzung den Rest stehen ließ. Kein Gate fängt das
  ([`AGENTS.md`](../../AGENTS.md) §3.7; Baseline-Regelwerk
  `grundlagen-harness-dateien.md` §Was ein Kommentar trägt)
- **Zustandsfeld trägt Chronik** — eine `Stand`-/`Status`-Zelle (Roadmap,
  Beobachtungs-Register, Meilenstein) erzählt, wie der Zustand entstand, statt
  Zustand und Beleg als Anker zu nennen; oder ein Drift-Log protokolliert
  Schließungen und erreichte Meilensteine. Kein Gate fängt das
  ([`AGENTS.md`](../../AGENTS.md) §3.7, *Dieselbe Regel für Zustandsfelder*)

> **Pflicht (Modul 10 §Ziel-Form: Reviewer-Skill):** Die HIGH-Liste muss mindestens
> *zwei* repo-spezifische Regeln nennen, die ein generischer Skill nicht abdeckt.
> Ist der Skill ohne sie, kommt bei einem Lauf auf einem realen Diff keines der
> Repo-HIGHs zur Anwendung.

**MEDIUM** (vor Merge zu klären) — eines der folgenden:

- Spec-Treue-Lücke einer Messmethode
- Bezug-/Abdeckungslücke einer Akzeptanzanforderung
- fehlende Negativtests bei neuem öffentlichen Vertrag
- Reproduzierbarkeits-Risiko
  ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit))
- **Zusicherung über einer Menge, die leer sein kann** — spricht ein Test oder
  Wächter über eine Menge, die er sich selbst besorgt (Ausgabe einer Extraktions-
  oder Filterfunktion, Inhalt eines Verzeichnisses, das ein Aufräum-Trap leert,
  ein Bestand, der derzeit keinen Treffer trägt), und belegt er nirgends, dass
  diese Menge nicht leer ist? Eine Negation (`! grep`, `-z`, „es entsteht nichts")
  über der leeren Menge ist grün, ohne etwas gemessen zu haben. Belastbar ist sie
  mit einer Sonde im selben Test, die zeigt, dass die geprüfte Menge bei einem
  gültigen Lauf nicht leer ist (Positiv-Beleg, Gegenfall über der nicht leeren
  Menge); fehlt sie, kann der Test unter keiner Mutation rot werden, die die Menge
  wegfallen lässt oder leert ([`AGENTS.md`](../../AGENTS.md) §3.6). Kein Gate
  fängt das  (seit slice-mutate-fall-filter-und-die-belegform-vereinigung)
- Wiederholung eines Musters, das schon zweimal LOW war

**LOW** (nice-to-fix) — Doku-Drift (Prosa-Listen, veraltete Beispiele); latente
Wartungsfalle (hart verdrahteter Wert); Ketten-Duplikate in Make-Targets.

**INFO** — dokumentationswürdige, aber undokumentierte Annahme; bewusste
Won't-Fix-Designnotiz.

**LOW/INFO mit Eskalation** — ein Fall, dessen Stufe die Wirkung setzt:

- **Grenzen-Aufzählung einer erkennenden Regel ohne Formen-Probe** — eine Regel, die
  syntaktisch erkennt (Muster über Markdown, YAML, Pfade, Kommandozeilen), nennt in einer
  Doku, einem Test-Kopf oder einer Meldung ihre Grenzen als Liste oder Zahl („fünf Grenzen",
  „vier Ränder"). Der Reviewer fährt die Formen der Sprache, über die die Regel spricht,
  selbst — bei Markdown-Links Titel, Spitzklammer-Ziel, Klammern im Ziel, Ziel hinter dem
  Zeilenumbruch, Referenz-Definition; bei YAML Block- statt Flow-Liste, andere
  Quotierung, anderer Schlüssel-Ort — und hält jedes Ergebnis gegen die genannte
  Aufzählung; er liest die Liste nicht nur. Die Negativbefund-Zeile eines Diffs, der eine
  solche Aufzählung anlegt oder ändert, nennt die gefahrenen Formen; eine Form, die nur
  gelesen wurde, steht als „gelesen, nicht gefahren". Eine gefahrene Form, die in der
  Aufzählung fehlt: INFO; LOW, wenn eine Meldung oder Anleitung aus der Lücke in die Irre
  schickt; HIGH, wenn kein Gate die Folge meldet (Stilles-Grün-Pfad, s. o.). Gilt für
  Aufzählungen, die der Diff anlegt oder ändert, nicht für den Bestand. Kein Gate fängt das;
  Träger ist dieser Review ([`AGENTS.md`](../../AGENTS.md) §3.6)
  (seit slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt)
- **Mehrteilige Regel-Zusage im Kommentar ohne Mutations-Deckung je Teil** — ein Kommentar oder eine
  referenzierte Spec-Zeile sagt einer Regel mehrere Grenzen in einem Satz zu (z. B. „überquert weder
  Link- noch Zeilengrenze", „endet am Verzeichnis", „bricht die Fortsetzung nur vor dem
  Zeilenende"). Der Reviewer prüft für **jede genannte Teil-Grenze einzeln**, ob ein Mutations-Fall
  oder Test sie bindet — dass irgendein Fall zur Zusage existiert, genügt nicht: die Suite kann für
  eine Hälfte grün bleiben, während die andere gebunden ist. Eine Teil-Grenze ohne eigenen,
  bindenden Fall: INFO; LOW, wenn die ungebundene Hälfte praktisch erreichbar ist (Whitespace,
  Maskierung, Sonderzeichen); HIGH, wenn kein Gate die Folge meldet (Stilles-Grün-Pfad). Gilt für
  Zusagen, die der Diff anlegt oder ändert, nicht für den Bestand. Kein Gate fängt das; Träger ist
  dieser Review ([`AGENTS.md`](../../AGENTS.md) §3.6)
  (seit slice-204-das-programm-feld-nennt-das-programm)
- **Mutations-Fall nennt einen Test, die Mutation färbt mehrere** — der `# expect:`-Kopf eines
  neuen oder geänderten Falls nennt einen Test; `make mutate` prüft nur, ob dieser Test unter der
  Mutation rot wird, nicht, ob er der einzige ist (`harness/tools/mutate.sh`: `grep -qF --
  "$expect"` gegen die gefilterte Fehlerausgabe, keine Exklusivitäts-Prüfung). Der Reviewer fährt
  für jeden neuen oder geänderten Fall die Gegenprobe mit ausgeschriebener Polarität — `t.Skip(...)`
  **ausschließlich** im benannten Test, Mutation weiterhin angewandt — und liest, ob die Suite grün
  wird (der benannte Test bindet allein) oder rot bleibt (ein zweiter Test bindet dieselbe
  Quell-Stelle mit). Bleibt sie rot, trennt er zwei Fragen: Bindet der neue oder geänderte Test
  etwas, das kein mitgefärbter Test bindet (kein Befund — struktureller Nebeneffekt einer
  gemeinsamen Stelle, etwa einer einzelnen Ausgabe-Senke für mehrere Erfolgsfälle), oder dupliziert
  er nur, was der mitgefärbte Test bereits allein bindet (LOW — `# expect:` zeigt auf einen
  überflüssigen oder falsch gewählten Test, der Fall trägt nichts Eigenes bei)? Behauptet der
  Fall-Kopf selbst Exklusivität („und nur sie", „ausschließlich"), die die Gegenprobe widerlegt:
  mindestens LOW, unabhängig vom Redundanz-Ausgang — die Behauptung selbst ist falsch (§3.7). Gilt
  für Fälle, die der Diff anlegt oder ändert, nicht für den Bestand. Kein Gate fängt das — eine
  Exklusivitäts-Prüfung im Treiber bräuchte für jeden Fall eine vollständige „das UND NUR das darf
  rot werden"-Zusicherung und träfe legitimes Mitfärben (gemeinsame Ausgabe-Senke) systematisch als
  falschen Befund; Träger ist dieser Review ([`AGENTS.md`](../../AGENTS.md) §3.6)
  (seit slice-fall-406-trifft-die-umgebaute-zerlegung)

**Kontext-Eskalation:** dieselbe Beobachtung im Gate-/Sicherheitspfad steigt eine
Stufe. Streit über eine Kategorisierung ⇒ Regel hier schärfen (§Pflege).

## Was dieser Skill NICHT macht

- Keine Lösungsvorschläge („schreib das so") — Reviewer kategorisiert,
  Implementer entscheidet.
- Kein Refactoring-Vorschlag, der über den Diff hinausgeht.
- Keine Verifikation gegen DoD — das ist Verifier-Aufgabe (Modul 11).
- Keine Validation gegen reale Bedürfnisse — das ist Validator-Aufgabe.
- **Kein Stil-Polizist:** Formatierung oder Benennung ohne Konventions-Anker ist
  kein Finding.
- **Kein Finding ohne Failure-Szenario:** was sich nicht als konkretes Versagen
  erzählen lässt, wird nicht gemeldet.
- **REFUTED nur mit Beleg:** verworfen wird ausschließlich mit Code-/Spec-Zitat,
  nie wegen „spekulativ".

Wenn etwas auffällt, das in diese Kategorien gehört: ein INFO-Finding mit Verweis
auf die zuständige Rolle.

## Output-Schema

Jedes Finding:

- `kategorie`: HIGH | MEDIUM | LOW | INFO
- `quelle`: ADR-ID, `LH-*`-ID, `MR-*`-ID, Hard-Rule-Name oder „Maintainability"
- `pfad`: Datei:Zeile
- `befund`: 1–2 Sätze, beobachtbar, ohne Lösungsvorschlag
- `verifizierbar`: ja/nein — gibt es einen Gate-Lauf, der es bestätigen würde?
- `klasse`: stabile Kurz-Bezeichnung des Fehlermusters, z. B. „Tie-Break in
  sortierender Operation nicht dokumentiert" — speist den Steering-Loop-Zähler
  über die Slice-Closure §7 ins
  [Beobachtungs-Register](../../docs/plan/planning/observations/README.md)
  (siehe §Pflege)

Zusätzlich am Ende: eine Zeile „geprüft, ohne Befund" pro betrachtetem Bereich
(Negativbefund-Zeile — sonst ist „keine Findings" nicht von „nicht geprüft"
unterscheidbar). Report-Gerüst für den ganzen Lauf ist
[`review-report.template.md`](../../.harness/baseline/v6.13.0/templates/docs/reviews/review-report.template.md);
eine eigene Kopie unter `docs/reviews/` hält dieses Repo nicht
([`MR-041`](../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline)).
Ein Report pro Lauf unter `docs/reviews/<YYYY-MM-DD>-<gegenstand>.md`, Folgeläufe
als neue Datei statt Überschreibung.

## Pflege (Steering-Loop)

Das „dreimal" zählt dieser Skill nicht selbst — jeder Lauf steht für sich. Gezählt
wird über die Finding-`klasse` → Slice-Closure §7 → Beobachtungs-Register.

Bei dreimaligem Auftreten desselben Findings:

- ist die Kategorie noch richtig? → Klassifikation schärfen
- gibt es einen ADR-/`AGENTS.md`-Eintrag, der das verhindert hätte?
  → Folge-ADR oder `AGENTS.md`-Update
- gibt es eine Fitness Function, die das prüfen würde? → Modul 13, Gate hinzufügen

Diese Skill-Datei wird **nicht** überschrieben, sondern versioniert
(ADR-Hard-Rule, Modul 4).
