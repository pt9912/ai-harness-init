# Welle welle-15: Re-Baseline — der vendored Baum zieht auf `v6.0.0`

**Lifecycle:** Diese Datei entsteht bei der **Eröffnung** der Welle und liegt
flach unter `docs/plan/planning/`; bei Closure wandert sie per `git mv` nach
`done/` (neben ihre `welle-<NN>-results.md`). Der Zustand ist die
Verzeichnis-Position — kein Status-Feld. **Geplante Wellen bekommen noch keine
Datei:** Sie stehen in der Roadmap unter *Nächste Wellen* und nirgends sonst —
zwei Positionen, nicht drei.

**Zielmeilenstein:** kein Meilenstein-Bezug — Harness-Wartung, keine Nutzer-Fähigkeit des
Werkzeugs.

**Verantwortlich:** Planner. **Datum:** 2026-09-04.

---

## 1. Welle-Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht.

**Regelwerk und Templates, nach denen dieses Repo arbeitet, stehen auf `v6.0.0` — und jede Pflicht,
die die neue Fassung mitbringt, hat einen verbuchten Ausgang, statt einzeln als Nachzügler
zurückzukommen.**

**Der Schnitt beginnt mit einer Inventur, nicht mit einer Schätzung** (`BEO-010` im
[Register](observations.md), 2×). Wie viele Mitglieder diese Welle bekommt, beantwortet
[slice-176](open/slice-176-inventur-vor-dem-schnitt-v600.md); vorher steht die Zahl nirgends.

**Zwei Fragen entscheidet diese Datei nicht.** Wer den Zielstand bewegt, steht in
[`ADR-0018`](../adr/0018-ziel-fassung-regiert-die-migration.md) §*Wer den Zielstand bewegt*; **wo**
die Setzung verbucht wird, in
[`ADR-0031`](../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 —
§Baseline von [`harness/conventions.md`](../../../harness/conventions.md), drei Teile, und die
Datei gehört dem Architect ([`AGENTS.md`](../../../AGENTS.md) §3.8). Welche Fassung die
Migrations-Prozedur **dieses** Sprungs stellt, ist offen: Festlegung 1 jener ADR gilt nur für
`v5.12.0` → `v5.18.0`, ihr erster Re-Evaluierungs-Trigger verlangt für den nächsten Sprung eine
neue Messung. Beide Posten trägt [slice-176](open/slice-176-inventur-vor-dem-schnitt-v600.md) §6
als Übergabe an den Architect.

## 2. Trigger (Welle startet)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Roadmap-Regeln — ein Trigger ist **beobachtbar** dann, wenn ein *anderer*
Mensch ohne Rückfrage sagen kann, ob er eingetreten ist; ein Datum darf erwähnt
werden, aber nie Trigger sein. Und der **Start**-Trigger ist **kein Ergebnis
dieser Welle**: Steht er in der Slice-Liste unten, ist er falsch platziert.

- **`make baseline-freshness` meldet VERALTET.** Gefahren am 2026-09-04: `gepinnt: v5.18.0`,
  `latest: v6.0.0`, Exit ≠ 0. Beide Angaben wandern mit dem Upstream-Stand und sind keine
  Erwartungswerte
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — beobachtbar ist der Ausgang des Kommandos, nicht die Zahl.
- **[welle-14](done/welle-14-re-baseline.md) liegt in `done/`.** Beobachtbar ohne Rückfrage: die
  Plan-Datei liegt neben ihrer Ergebnis-Notiz. Der Grund ist **ordnend**: Der Sprung geht vom
  adoptierten Stand `v5.18.0` aus, und den hat jene Welle gesetzt.

## 3. Closure-Trigger (Welle schließt)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht — der Trigger muss das *Mehr* gegenüber den
einzelnen Slice-DoDs benennen; kann er das nicht, liegt keine Welle vor.

- Alle Slices dieser Welle liegen in `done/`.
- `make gates` grün.
- `make full-smoke` grün.
- Der Pin ist vollzogen: `make baseline-verify` meldet `v6.0.0 OK`, und §Baseline von
  [`harness/conventions.md`](../../../harness/conventions.md) nennt denselben Tag.
- Closure-Notiz geschrieben.

**Das *Mehr* sind die zwei repo-weiten Läufe und der Pin-Beleg** — sie stehen in keiner einzelnen
Slice-DoD, weil keine einzelne über den ganzen Baum urteilt. `make full-smoke` ist genannt, weil
der Baum-Tausch von [welle-10](done/welle-10-re-baseline.md) genau dort brach und für
`make gates` unsichtbar blieb ([slice-133](done/slice-133-emittierter-baum-ohne-platzhalter-links.md)).

## 4. Slices in dieser Welle

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Lifecycle als State Machine — der Zustand eines Slice ist sein
Lifecycle-Verzeichnis und wird hier **nicht** gespiegelt.

| Slice | Titel | Bezug |
|---|---|---|
| [slice-176](open/slice-176-inventur-vor-dem-schnitt-v600.md) | Inventur vor dem Schnitt — der Form- und Regel-Diff `v5.18.0` → `v6.0.0` | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0031`](../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) |
| [slice-177](open/slice-177-beobachtungs-register-verzeichnis-form.md) | Das Beobachtungs-Register läuft in der Verzeichnis-Form | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`MR-045`](../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form) |
| [slice-178](open/slice-178-regierende-fassung-des-sprungs-v600.md) | Die regierende Fassung dieses Sprungs wird entschieden (Architect) | [`ADR-0031`](../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md), [`ADR-0018`](../adr/0018-ziel-fassung-regiert-die-migration.md) |
| [slice-179](done/slice-179-register-ortsfestigkeit-vor-dem-umzug.md) | Die Form des Beobachtungs-Registers wird entschieden — vor dem Umzug (Architect) | [`ADR-0030`](../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |

**Vier Mitglieder, und die übrigen Zeilen folgen dem Katalog.** Die Mitglieder-Zahl steht bewusst
nicht vorab: `BEO-010` ([Register](observations.md)) misst an einer Re-Baseline den Abstand
zwischen geschnittenen und geschlossenen Slices, und die Ursache war der Schnitt **vor** der
Inventur. Die Umplanung, die die weiteren Mitglieder aufnimmt, trägt das Drift-Log der
[Roadmap](in-progress/roadmap.md).

**Zeile 2 folgt nicht dem Katalog, sondern einer Messung neben ihm** — dieselbe Ausnahme, die
[welle-14](done/welle-14-re-baseline.md) §4 für zwei ihrer Zeilen führt. Die Position ist einzeln
gemessen (`git diff --name-status v5.18.0 v6.0.0 -- lab/templates/docs/plan/planning` am lokalen
Kurs-Klon: die Register-Vorlage wird durch eine Vorlage je **Beobachtung** ersetzt), und der Anlass
kommt von außerhalb des Sprungs: eine flache Datei, in die **jede** Slice-Closure schreibt, ist ein
Kollisions-Punkt für parallel arbeitende Rolleninhaber — begründet in
[slice-177](open/slice-177-beobachtungs-register-verzeichnis-form.md) §1. Der Katalog weist diese
Position jenem Slice zu, statt einen zweiten zu erzeugen.

**Zeile 3 und 4 sind die zwei Entscheidungen, ohne die diese Welle kein Konformitäts-Urteil
fällen darf.** [slice-178](open/slice-178-regierende-fassung-des-sprungs-v600.md) löst Übergabe 1
aus §5 ein — die Präzedenz ist derselbe Gegenstand eine Runde früher
([slice-163](done/slice-163-regierende-fassung-des-sprungs.md), Mitglied von
[welle-14](done/welle-14-re-baseline.md)).
[slice-179](done/slice-179-register-ortsfestigkeit-vor-dem-umzug.md) geht Zeile 2 voraus: Die
Ziel-Form nimmt dem Register seine flache Datei, und
[`ADR-0030`](../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4 verlangt
für genau diesen Fall die Entscheidung **vor** dem Move.

**Was diese Welle noch nicht führt, und was von ihm erwartet wird.** Der **Baum-Tausch** hat noch
keinen Slice — er geht aus dem Katalog in
[slice-176](open/slice-176-inventur-vor-dem-schnitt-v600.md) §9 hervor und wird nicht vorab
erfunden (`BEO-010`: gemessen statt geschätzt). Wenn er geschnitten ist, trägt **er** die
Zielstand-Buchung nach
[`ADR-0031`](../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 — die
Zeile in §Baseline von [`harness/conventions.md`](../../../harness/conventions.md) mit Ziel-Tag,
Datum des **Vollzugs** und dem Zeiger auf den Delta-Nachweis in
[slice-176](open/slice-176-inventur-vor-dem-schnitt-v600.md). Präzedenz ist
[slice-156](done/slice-156-baum-tauschen-pins-ziehen.md), der die Zeile für den vorigen Sprung
schrieb. **Nicht** dorthin gehört sie in
[slice-176](open/slice-176-inventur-vor-dem-schnitt-v600.md): Vor dem Tausch trüge sie ein Datum
für ein Ereignis, das nicht stattgefunden hat. Hier steht der Platz, nicht der Slice.

## 5. Abhängigkeiten

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Roadmap-Struktur: fünf Abschnitte.

- **Wird blockiert von: keiner.** Der Start-Trigger ist gefahren und eingetreten (§2).
- **Blockiert: offen, und das ist hier die Antwort statt einer Kante.** Kandidaten sind
  [welle-11](welle-11-traeger-aussage.md) (jede ihrer Messungen läuft über den vendored Baum) und
  [welle-13](welle-13-regeln-bekommen-ihren-sensor.md) (zwei ihrer Slices bauen Sensoren auf Formen
  aus `modul-05`/`modul-06`). Beide Kanten hingen bis zur Closure von
  [welle-14](done/welle-14-re-baseline.md) und sind mit ihr gefallen; sie erneut zu setzen wäre
  eine Umplanung auf eine Annahme. **Ob** dieser Sprung ihre Gegenstände bewegt, misst
  [slice-176](open/slice-176-inventur-vor-dem-schnitt-v600.md) — der Katalog ist die Grundlage der
  Kante, nicht ihre Folge.
- **Zwei Übergaben an den Architect** stehen in
  [slice-176](open/slice-176-inventur-vor-dem-schnitt-v600.md) §6 und haben jetzt getrennte Träger.
  Übergabe 1 — die **regierende Fassung dieses Sprungs** — trägt
  [slice-178](open/slice-178-regierende-fassung-des-sprungs-v600.md). Übergabe 2 — die **Buchung
  der Zielstand-Setzung** nach
  [`ADR-0031`](../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 —
  trägt der Baum-Tausch-Slice, den es noch nicht gibt (§4, letzter Absatz). Sie blockieren die
  **Eröffnung** nicht — ein Diff-Katalog ist eine Messung und fällt kein Konformitäts-Urteil —,
  wohl aber jeden Durchgang, der eines fällt.
- **Eine Kante innerhalb der Welle ist tragend:**
  [slice-179](done/slice-179-register-ortsfestigkeit-vor-dem-umzug.md) →
  [slice-177](open/slice-177-beobachtungs-register-verzeichnis-form.md). Ohne die entschiedene
  Kennungs- und Index-Gestalt hat der Umzug kein Ziel, und
  [`ADR-0030`](../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4
  verlangt die Entscheidung vor dem Move. Die zweite Kante ist ordnend:
  [slice-176](open/slice-176-inventur-vor-dem-schnitt-v600.md) →
  [slice-178](open/slice-178-regierende-fassung-des-sprungs-v600.md), weil die Wahl auf der
  zweistufigen Messung jenes Slice steht.

## 6. Out-of-Scope für diese Welle

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Eröffnung Schritt 1 — Out-of-Scope gehört zur
Zielsetzung: Was nicht ausdrücklich ausgeschlossen ist, dehnt die Welle, bis
der Closure-Trigger unerreichbar wird.

- **Sensor-Neubauten** — sie tragen [welle-13](welle-13-regeln-bekommen-ihren-sensor.md).
- **Die Archivierung des Altbestands** — der Wellen, die vor der Einführung des
  Archivierungs-Schritts schlossen. Die adoptierte Fassung stellt sie frei; ob die **laufende**
  Regel hier greift, ist eine Position des Katalogs.
- **Der d-check-Pin** ([slice-135](open/slice-135-d-check-pin-v0661.md)) — eigene Linie, eigener
  Trigger; er hängt an keiner Baseline-Version.
- **Jede Senkung einer bestehenden Schwelle.** Wird ein Gate nur durch eine Lockerung grün, ist das
  ein ADR ([`AGENTS.md`](../../../AGENTS.md) §3.5) und ein Rückführungs-Grund, kein Zwischenschritt.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-traceability.md`
§Herkunfts-Anker für Steering-Loop-Regeln — dort die **Ruheort-Regel**: Die
beiden Zeiger unten sind so zu schreiben, wie sie vom Ruheort `done/` auflösen,
nicht vom Schreibort.

Die Ergebnis-Notiz ist `welle-15-results.md` — Geschwister im Ruheort `done/`; der Zähler ist das
Beobachtungs-Register eine Ebene darüber. Beide Zeiger werden bei der Closure als Link gesetzt und
lösen dann vom Ruheort auf; vom Schreibort aus zeigen sie ins Leere.
