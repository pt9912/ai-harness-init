# Slice slice-167: Aufgelöste Adaptionen bekommen ihre Verzeichnis-Position

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** — (ohne Welle)

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (Anker- und Kennungs-Verträge des Doku-Gates bleiben unverändert streng),
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) (der Adaptions-Block gehört dem Architect),
[`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) (Rumpf-Rückbau bei vollständiger Aufhebung),
[`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (die Index-Tabelle ist derivativ).

**Berührte Spec-Stellen:** — (kein Spec-Stratum berührt; `harness/conventions.md` rangiert außerhalb der drei Straten).

**Verantwortlich:** Architect

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

**Der Adaptions-Block bekommt die zweite Hälfte seiner Ziel-Form: ein `done/` unter
[`harness/conventions/`](../../../../harness/conventions/) trägt die aufgelösten Einträge, und die drei Auflösungs-Trigger, die
[slice-166](../done/slice-166-adaptions-block-wird-ein-verzeichnis.md) gefeuert hat, bekommen je
ein Urteil.**

### Der gemessene Anlass

Die vendored Vorlage
[`conventions.template.md`](../../../../.harness/baseline/v5.18.0/templates/harness/conventions.template.md)
führt **zwei** Tabellen: *Aktive Adaptionen* und daneben *Aufgelöste Adaptionen* mit den Spalten
`MR | aufgelöst durch`, deren Zeilen auf `conventions/done/` zeigen. Die Eintrags-Vorlage
[`MR-NNN-titel.template.md`](../../../../.harness/baseline/v5.18.0/templates/harness/conventions/MR-NNN-titel.template.md)
sagt den Mechanismus aus: *„Ist der Auflösungs-Trigger eingetreten, wandert die Datei per `git mv`
nach `done/`; der Zustand ist die Verzeichnis-Position, kein Status-Feld."*
[slice-166](../done/slice-166-adaptions-block-wird-ein-verzeichnis.md) hat die erste Tabelle
gebaut und die zweite ausgelassen — alle Einträge liegen flach:

```sh
ls -1 harness/conventions/MR-*.md | wc -l              # 46 Einträge, alle flach
ls -d harness/conventions/done 2>&1                    # existiert nicht
```

**Der Mechanismus ist in diesem Repo kein Neuland.** `docs/plan/carveouts/done/` fährt ihn seit
Modul 7 (`ls docs/plan/carveouts/done/ | wc -l` → 3), und das Schwester-Repo führt ihn für genau
diesen Block (`ls -1 /Development/a-check/harness/conventions/done/*.md | wc -l` → 10).

### `ÜBERHOLT` und *aufgelöst* sind zwei verschiedene Mengen

[`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
§Zwei Instrumente trennt sie ausdrücklich: **Teil-Ablösung** → Rumpf bleibt, Kopf-Marke, der Rest
bindet fort · **vollständige Aufhebung** → Rumpf entfällt, `Aufgehoben durch`-Zeile
([`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)).
*„Ein Eintrag trägt genau eines von beiden."* Nur das zweite ist *aufgelöst*. Drei Kommandos,
keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
grep -c '^- \*\*Aufgehoben durch' harness/conventions/MR-*.md | grep -vc ':0$'  #  4 vollständig aufgehoben
grep -c '^> \*\*ÜBERHOLT'         harness/conventions/MR-*.md | grep -vc ':0$'  # 11 Kopf-Marke (Teil-Ablösung)
grep -c '^> \*\*HISTORIE'         harness/conventions/MR-*.md | grep -vc ':0$'  #  2 ältere Beschriftung derselben Klasse
```

Ein `grep -l 'ÜBERHOLT'` zählt **13** und damit zwei Einträge mit, die das Wort in ihrer eigenen
Prosa führen statt als Marke; ein `grep -li 'gegenstandslos'` zählt **6** und trifft dasselbe
Prosa-Muster. Beide sind keine Form-Kriterien.

**Damit steht der Umfang, getrennt nach Form und Urteil.** Form-sicher wandern **vier**:
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird),
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung),
[`MR-022`](../../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline),
[`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung).
Fünf sind **Urteil**, nicht Muster: die drei aus
[`BEO-020`](../observations.md) —
[`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger),
[`MR-039`](../../../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines),
[`MR-043`](../../../../harness/conventions.md#mr-043--ein-nachgetragenes-pflichtfeld-schlägt-die-einordnung-im-rumpf)
— und zwei, deren Marken-`<Reichweite>` den ganzen Eintrag benennt statt eines Satzes:
[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
(*„die Adaption"*) und
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(*„dieser Eintrag, mit einer Ausnahme"*). Obergrenze also **9 von 46**, Untergrenze **4**.

### Der Umzug kostet keinen Verweis

Die Doppel-Anker der Index-Zeile aus
[`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
reisen mit der Zeile in die zweite Tabelle; die Vorlage nennt das als ihren Zweck. Auf die vier
form-sicheren Dateien zeigt außerhalb von `harness/conventions/` **kein** Pfad-Verweis außer ihrer
eigenen Index-Zeile:

```sh
git grep -n 'conventions/MR-016\|conventions/MR-018\|conventions/MR-022\|conventions/MR-023' -- ':!harness/conventions/'
```

→ vier Treffer, alle in `harness/conventions.md`. Nachzuziehen ist allein die Tiefe der
relativen Ziele **in** den gewanderten Rümpfen (dort 1 + 3 + 3 + 3 Vorkommen von `](../`).

### Vorbefund zu den drei Triggern — je eine Frage, kein Verdikt

Das Verdikt gehört dem Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Was der Schnitt
liefert, ist die Frage, die je Eintrag zu entscheiden ist:

- [`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  — sein Trigger sagt, die Verzeichnis-Position trage den Zustand und die Marke werde
  gegenstandslos. **Zu prüfen:** Die Position ist binär (aktiv / aufgelöst); die Marke trägt die
  **Teil**-Ablösung, deren Eintrag aktiv bleibt. Trägt die Position diesen dritten Zustand nicht,
  ist der Trigger nur für die *vollständige* Aufhebung eingetreten.
- [`MR-039`](../../../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  — sein Trigger benennt die Folge selbst: *„Setzung 2 verliert ihren Gegenstand, Setzung 1 und 3
  sind neu zu prüfen."* **Zu prüfen:** ob Setzung 1 (Pflichtfeld nachtragen) und Setzung 3 (ein
  Fork bleibt im Block) vom Träger überhaupt abhängen.
- [`MR-043`](../../../../harness/conventions.md#mr-043--ein-nachgetragenes-pflichtfeld-schlägt-die-einordnung-im-rumpf)
  — seine Setzung ordnet zwei Aussagen **innerhalb** eines Eintrags (Feld schlägt Einordnung);
  nur ihr Schlusssatz hängt an der Kopf-Marke. **Zu prüfen:** ob damit mehr fällt als dieser
  Schlusssatz.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**.

- [ ] **(1) Das `done/` unter [`harness/conventions/`](../../../../harness/conventions/) und die Sektion *Aufgelöste Adaptionen* bestehen.** Jeder
      Eintrag, dessen Auflösungs-Trigger eingetreten ist, liegt dort; seine Index-Zeile steht mit
      **beiden** Ankern in der zweiten Tabelle (Spalten `MR | aufgelöst durch`) und nicht mehr in
      der ersten. Bewegung und Pfad-Berichtigung sind getrennte Commits
      ([`AGENTS.md`](../../../../AGENTS.md) §3.3).
- [ ] **(2) Die drei Auflösungs-Trigger aus [`BEO-020`](../observations.md) tragen je ein
      einzeln begründetes Urteil** — *aufgelöst* (dann `Löst auf` im ablösenden Eintrag und Umzug
      nach `done/`) oder *bindet fort* (dann steht im Block, welcher Teil des Triggers nicht
      eingetreten ist). Drei Urteile, keine Sammelaussage.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations.md`) fortgeschrieben — `BEO-020` und `BEO-014` mit
      Beleg `slice-167`; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7
      notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo läuft ohne
      Wellen-Betrieb, sie werden hier geprüft.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/conventions.md` §Adaptions-Block | update | zweite Tabelle *Aufgelöste Adaptionen* nach der Ziel-Form; die Zeilen der aufgelösten Einträge wechseln die Tabelle samt beider Anker |
| `done/` unter [`harness/conventions/`](../../../../harness/conventions/) | neu | Ablage-Ort; die aufgelösten Rümpfe wandern per `git mv` |
| `harness/conventions/MR-*.md` (gewanderte) | update | Pfad-Tiefe der relativen Ziele, eigener Commit nach der Bewegung |
| neuer Eintrag in [`harness/conventions/`](../../../../harness/conventions/), nächste freie Nummer | neu | trägt die drei Urteile aus DoD (2), soweit eines eine Adaption setzt oder ablöst — per `cp` aus der Eintrags-Vorlage |
| `.d-check.yml` (`ids`, `MR-\d{3}`) | update *(bedingt)* | nur, falls die Messung aus §6 zeigt, dass `target: harness/conventions/` das Unterverzeichnis nicht deckt |

## 4. Trigger

**Start** (`next` → `in-progress`): Architect übernimmt; Arbeitsbaum sauber, kein anderer Slice in
`in-progress/`.

**Rückführungen — vorab benennen:**

- `in-progress` → `next` (zu groß): die drei Urteile aus DoD (2) verlangen jeweils eine eigene ADR
  — dann trägt dieser Slice den Umzug und die Urteile werden einzeln geschnitten.
- `in-progress` → `open` (blockiert): der `ids`-Prüfbereich deckt das neue Unterverzeichnis
  nicht und die Deckung ist ohne Schwellen-Senkung nicht herstellbar
  ([`AGENTS.md`](../../../../AGENTS.md) §3.5) — dann Carveout.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Closure-Notiz §7 geschrieben. Zwei beobachtbare Kriterien:
(a) `ls harness/conventions/done/*.md` listet genau die Einträge, die DoD (1)/(2) als aufgelöst
ausweisen, und `grep -c` über die zweite Index-Tabelle liefert dieselbe Zahl; (b) `make docs-check`
meldet null tote Links und null blanke Kennungen.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst.

- **Der `ids`-Prüfbereich könnte das Unterverzeichnis nicht decken.**
  [`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
  Setzung 2 setzt `target: harness/conventions/`; ob d-check das als Pfad-Präfix (dann deckt es
  `done/`) oder als direkte Kinder liest, ist **nicht gemessen** — das Schwester-Repo fährt hier
  `target: harness/conventions.md` und beantwortet die Frage nicht. Erst messen, dann bewegen.
  — **Ausgang:** <eingetreten / entfallen / weiter offen>
- **[`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  ist ein vierter Trigger, der hier sichtbar wird und nicht im Umfang steht.** Die Verzeichnis-Form
  bewahrt den Rumpf (das Schwester-Repo legt volle Rümpfe in `done/`), unsere Retirierungs-Form
  entfernt ihn ([`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)). Die vier
  form-sicheren Einträge wandern deshalb als Kopf-und-Zeiger-Rest. Ob die Position den Rückbau
  überflüssig macht, ist eine eigene Entscheidung.
  — **Ausgang:** <eingetreten: slice-NNN / entfallen: Grund / weiter offen: → BEO-NNN>
- **[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
  und [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  könnten den Umfang über die neun hinaus dehnen.** Ihre Marken-`<Reichweite>` benennt den ganzen
  Eintrag; der zweite nimmt ausdrücklich eine Ausnahme aus. Beide sind Urteil, nicht Muster.
  — **Ausgang:** <eingetreten / entfallen / weiter offen>

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations.md`):** <`BEO-020` auf 2× erhöht, Beleg slice-167 ergänzt; `BEO-014` auf 3× — Schwelle, siehe §8>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung.

**Umfang.** Alle berührten Sub-Areas sind GF; der Block unten steht trotzdem, weil die berührte
Sub-Area offene Beobachtungen trägt.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) aus der Modus-Deklaration
in [`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area.
Der feinere Schnitt *Harness-Konventionen* erfüllte 3 von 3 Inklusions-Achsen — er wird hier so
wenig vollzogen wie in [slice-166](../done/slice-166-adaptions-block-wird-ein-verzeichnis.md): die
Modus-Deklaration zu ändern ist ein eigener Vorgang.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen
(`docs/plan/planning/observations.md`, gemergter Stand). Treffer auf `*` (gesamtes Repo), die
diesen Slice betreffen:

- [`BEO-020`](../observations.md) — **1×**, Beleg `slice-166`. **Dieser Slice ist ihr Gegenstand:**
  Der Eintrag sagt, das Urteil über einen gefeuerten Trigger habe im migrierenden Vorgang keinen
  Träger. DoD (2) **ist** dieser Träger; mit der Closure steht der Zähler auf 2×.
- [`BEO-014`](../observations.md) — **2×**, Belege `slice-150`, `slice-166`. Gegenstand ist die
  Buchführung des Blocks über sich selbst; die vier Einträge dieses Slice
  ([`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf),
  [`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger),
  [`MR-039`](../../../../harness/conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines),
  [`MR-043`](../../../../harness/conventions.md#mr-043--ein-nachgetragenes-pflichtfeld-schlägt-die-einordnung-im-rumpf))
  sind genau sie. **Mit diesem Slice erreicht der Eintrag 3×** — Schwelle. Er ist dann keine Notiz
  mehr, sondern eine Lücke und braucht einen eigenen Folge-Slice; der Lese-Schritt fällt bei der
  Closure an, weil dieses Repo ohne Wellen-Betrieb läuft
  ([`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)).
- [`BEO-016`](../observations.md) — **1×**, Beleg `slice-136` (Plan-Länge). Bindet diesen Plan als
  Auflage, nicht als Liefer-Punkt.

**Welle oder nicht.** Der Auslöser-Test ist seit
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
der Baseline-Test: *eine beobachtbare Closure-Bedingung, die mehr beobachtet, als die DoDs ihrer
Slices schon belegen.* Die Closure-Trigger aus §5 sind vollständig aus dieser DoD ableitbar —
kein repo-weiter Beleg tritt hinzu. **Ohne Welle.**

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — der Gegenstand **ist** das Konventionsdokument; die Form der
  zweiten Tabelle steht in der vendored Vorlage, die Umzugs-Regel in der Eintrags-Vorlage.
- **Phase-Reife:** Phase 5 — Form und Sensor bestehen; die Dateien liegen unter `docs-check` und
  unter der `ids`-Linkpflicht.
- **Evidenz-/Diskrepanz-Risiko:** niedrig für den Inhalt (Doc führt), **erhöht für den
  Prüfbereich**: ob `ids` das neue Unterverzeichnis deckt, ist ungemessen (§6, erstes Risiko).
  `BEO-014` erreicht mit diesem Slice die Schwelle 3×.
- **Reconciliation-Aufwand:** keiner (GF). Graduation entfällt.
