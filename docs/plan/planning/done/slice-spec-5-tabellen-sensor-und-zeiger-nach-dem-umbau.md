# Slice slice-spec-5-tabellen-sensor-und-zeiger-nach-dem-umbau: Der Sensor hält die Tabellenform von Spec §5 in allen Tabellen, das Zeiger-Kommando fasst Zitate, und zwei Zeilen tragen ihre Belegklasse

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — keine Closure-Bedingung über die DoD hinaus (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (Arbeits-Bezug),
[`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) (Fitness Zeilen 4 und 5, Festlegung 10),
[`ADR-0075`](../../adr/0075-begruendungen-zu-spec-5-sammel-adr.md),
[`ADR-0076`](../../adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md) (Festlegung 3, Folgepflicht 1),
[`AGENTS.md`](../../../../AGENTS.md) §3.5 (eine Schärfung braucht keine ADR, nur eine Senkung), §3.6, §3.7.

**Berührte Spec-Stellen:** [§5](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) — die Zeilen
`SPEC-040`, `SPEC-059`, `SPEC-060`, `SPEC-062` bis `SPEC-065` (Liefer-Punkt 3) und die 19 `Lücke`-Zeilen (Liefer-Punkt 4); der Sensor liest die Tabellen und ändert sie nicht.

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-09-30.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Drei Bedingungen aus der Verifikation (dazu Liefer-Punkt 4, der Nachzug der Lücke-Zellen) des Umbaus von Spec §5
(`docs/reviews/2026-09-30-slice-spec-aufnahme-regel-und-umbau-verifikation.md`, Übergaben B-2, B-3, B-4 und A-6) sind
erfüllt. Die Bedingung steht in diesem Plan, weil der Lauf, der sie trägt, ihn liest und den Bericht nicht.

**Gegenstand, gemessen am Stand des Verifikationsberichts** (keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025); der Lauf misst neu):

```sh
grep -cE '^\| ID \|.*\| Präzisiert \|$' spec/spezifikation.md   # 5 Kopfzeilen; die Schranke der Fitness-Zeile ist "mindestens 3"
grep -c 'unterscheidbar bleibt' spec/spezifikation.md           # 0 — Zitat in test/mutations/131-span-werkzeugname-leer.sh Z. 9-11
```

1. **Liefer-Punkt 1 — der Sensor.** Die Zahl der Kopfzeilen mit `Präzisiert` als letzter Spalte ist gleich der Zahl der
   Tabellen, die `SPEC`-Zeilen tragen (ein Block aufeinanderfolgender Tabellenzeilen, deren erste Zelle eine `SPEC`-Kennung in Backticks ist), und keine `SPEC`-Zeile trägt eine
   leere letzte Zelle. Beides prüft heute nur die Schranke „mindestens 3", die bei fünf Tabellen kein Sensor ist: eine Spalte
   weniger gibt 4, zwei weniger gibt 3, beides grün. **Träger:** ein bats-Fall (läuft in `make test`, ein Gate) und ein Fall in
   `test/mutations/` (`make mutate` führt nur gelistete Wächter). Vorab liest der Lauf
   `sed -n '/^failure_form()/,/^}/p' harness/tools/mutate.sh`: führt die bats-Stufe kein Fehlschlag-Muster, ist das der
   Befund und geht als Übergabe an den Planner, nicht als stilles Weglassen des Mutations-Falls. Eine Gate-Verschärfung, keine
   Senkung: kein ADR nötig ([`AGENTS.md`](../../../../AGENTS.md) §3.5); der Text der Fitness-Zeile in
   [`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) bleibt stehen, der Sensor ist schärfer als er.
   **Rot gesehen, an der realen Quelle:** die Spalte in **einer** Tabelle der echten `spec/spezifikation.md` streichen — der
   Fall wird rot, der alte Zähler bliebe grün; eine `Präzisiert`-Zelle leeren — der zweite Fall wird rot (heute bleibt
   `make docs-check` dabei grün, die Lücke benennt die ADR selbst).
2. **Liefer-Punkt 2 — der Zeiger.** Der Kommentar in `test/mutations/131-span-werkzeugname-leer.sh` (Zeilen 9 bis 11) zitiert
   keinen Wortlaut mehr, der nicht in der Spec steht, und zeigt auf die Zeile, die die Aussage trägt (`SPEC-082`, ggf. `SPEC-044`;
   der Lauf liest beide). Das Zeiger-Kommando aus dem Plan des Umbaus (`git grep -nE 'spezifikation\.md' -- internal test cmd harness/tools`)
   fasst dieses Zitat nicht — es findet Kennungen und Namen, keinen Wortlaut —, und der Lauf schärft es: ein Kommando, das je Kommentarstelle
   mit Zitat den zitierten Text gegen `grep -c` an der Spec hält, mit Folgezeilen des Kommentars. Wo es lebt (Skript, bats-Fall),
   entscheidet der Lauf und nennt es im Bericht. **Rot gesehen:** der alte Kommentar zurück — das geschärfte Kommando listet ihn;
   das alte Kommando tut es nicht. Nur Kommentarzeilen ändern sich; das Kommando aus dem Plan des Umbaus
   (`git diff -U0 … | grep -vE '^[+-][[:space:]]*(//|#)'`) ist leer.
3. **Liefer-Punkt 3 — zwei Zeilen-Bedingungen in der Spec.** (a) `SPEC-040` führt die Aussage über das Eingabe-Schema von
   `Agent` (`run_in_background`) ohne Belegklasse: der Lauf nennt Stand und Messstelle, oder er kennzeichnet sie als Sicht mit
   ihrem Träger. (b) Die Zeilen `SPEC-059`, `SPEC-060`, `SPEC-062` bis `SPEC-065` nennen als Sensor die Datei der Fälle 108, 109, 113,
   114, 115, 112 und 154; die Fälle tragen ihren Wächter als `# expect:` auf einen Testnamen. Der Lauf trägt den Namen
   ein — die Wächter-Bilanz (`comm -3` gegen `git show <Vorstand>:spec/spezifikation.md`) wächst dann um benannte Verlagerungen, keine unbenannte.

4. **Liefer-Punkt 4 — der Nachzug der 19 `Lücke`-Zellen** ([`ADR-0076`](../../adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md)
   Festlegung 3 und Folgepflicht 1; Lastenheft 0.23.0 trägt das Akzeptanzkriterium *Erfassungs-Umfang* bei
   [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)). Die Ebene je Zeile steht in der
   Ebenen-Tabelle der ADR; der Lauf liest sie dort und übernimmt keine Kopie. Bedingungen (die Kennungen misst der Lauf am Kommando unten neu):
   (a) **Elf Zeilen bekommen den Anker auf [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
   statt `Lücke`:** `SPEC-014`, `037`, `045`, `046`, `047`, `054`, `056`, `060`, `063`, `065`, `082`. In `SPEC-047` wird die Zelle
   gekürzt: der Satz über die Sichtbarkeit des Bruchs der Regel „Rollen-Arbeit läuft als Rolle" ist Prozess-Konvention und gehört nach
   `docs/user/rollen-laeufe.md` — diese Datei schreibt der Architect, der Lauf berührt sie nicht; trägt sie den Satz nicht, geht die Kürzung
   als Übergabe an den Planner. Der Zirkel-Vorbehalt bei `SPEC-014` bleibt benannt.
   (b) **Drei Zeilen (`SPEC-051`, `052`, `053`) bekommen den Anker auf das Akzeptanzkriterium *Erfassungs-Umfang*** (Lastenheft 0.23.0, dasselbe
   Element [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren); der Lauf prüft, ob das Kriterium einen eigenen Anker trägt, und nimmt sonst den Elementanker `#lh-fa-10--erfassungsschicht-emittieren`).
   (c) **Fünf Zeilen verlassen die Spezifikation:** `SPEC-040`, `041`, `084`, `085`, `086`. Ihre Zusagen und Grenzen wandern als
   **Kommentar, nicht als Logik**: `SPEC-041`, `085`, `086` in den Kopfkommentar von `.claude/hooks/pretooluse-agent-guard.sh` und in
   `test/agent-guard.bats`; `SPEC-084` (Grenze der `mustContain`-Gegenproben) als Kommentar am Helfer, der `mustContain` führt (der Lauf sucht ihn);
   `SPEC-040` (Betriebsart) steht in `docs/user/rollen-laeufe.md` — diese Datei schreibt der Architect, `SPEC-039` trägt den Hintergrund, eine
   Messaussage gehört nach `docs/reviews/` (Festlegung 3). Die Kommentare halten [`AGENTS.md`](../../../../AGENTS.md) §3.7 (Zusage, Grenze; kein
   Verlauf, keine Befund-Kennung). **Die `SPEC`-Kennungen bleiben unbenutzt und werden nie neu vergeben.**
   **Wächter-Bilanz:** die Namen der Wächter in `SPEC-084`, `085`, `086` (`test/agent-guard.bats`, Fälle 139 und 150, `TestEnforce_SettingsWiresBothHooks`, …)
   bleiben irgendwo im Repo als Text auffindbar, oder die Bilanz (`comm -3` gegen den Vorstand) führt die Verlagerung **benannt**; eine unbenannte Differenz ist der Befund.
   **Gegenprobe:** nach dem Nachzug gibt das Kommando aus [`ADR-0076`](../../adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md) §Fitness Function (Kommando zu Zeile 4)
   `grep -E '\| Lücke \|$' spec/spezifikation.md | grep -oE '^\| `SPEC-[0-9]+`'` **nichts** aus. **Soll leer, nicht die drei der ADR:** die
   Change-Request-Gruppe der ADR (`SPEC-051` bis `053`) ist mit Lastenheft 0.23.0 angenommen und trägt den Anker. `grep -c 'Lücke' spec/spezifikation.md`
   zählt Prosa mit (die Beschreibung der Spalte und die Historie nennen das Wort) und ist darum kein Sensor; der Lauf nennt seinen Wert im Bericht und nur die
   Tabellen-Form als Soll. **Rot gesehen:** eine der elf Zellen zurück auf `Lücke` — das Kommando listet sie; ein Anker auf ein nicht existierendes Element
   färbt `make docs-check` rot.

   **Größenregel, begründet verletzt:** dieser Slice trägt vier Liefer-Punkte statt drei. Der Auftraggeber hat angeordnet, mit möglichst wenigen Runden
   fortzufahren; Liefer-Punkt 4 ist die mechanische Abarbeitung schon entschiedener Zeilen (keine neue Entscheidung, nur Zellen und Kommentare) und
   liegt in derselben Datei wie Liefer-Punkt 3. **Rückführungs-Bedingung** (`in-progress` → `next`): trägt Liefer-Punkt 4 eine Zeile, deren Ebene der Lauf gegen den
   Wortlaut der ADR nicht bestätigen kann, oder sprengt er die Review-Sitzung, wird Liefer-Punkt 4 als eigener Slice geschnitten und hier gestrichen.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Norm-Text und keine Entscheidung.** Folge-ADR, Rolle für `docs/user/rollen-laeufe.md`, Fitness-Zeile 13 und die Ebenen der
  19 `Lücke`-Zeilen sind entschieden ([`ADR-0076`](../../adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md));
  dieser Slice zieht nur die Zellen nach. `docs/user/rollen-laeufe.md` schreibt der Architect.
- **Kein Parser des Existenz-Sensors.** `slice-feldabdeckung-existenz-sensor` liest die Feldtabelle über Kopfzeilen-Präfix und
  Spalte 2; anderer Vorgang, andere Datei.
- **Keine Änderung an `internal/emit/` und der emittierten Vorlage** — Tool-Ebene, Dogfood gegen emittiert.
- **Kein Lastenheft-Edit, kein Change Request** — Entscheidung des Auftraggebers nach dem Architect-Slice.
- **Keine Logikzeile in `internal/`, `test/`, `cmd/`, `harness/tools/`** außer dem neuen Sensor selbst und dem Zeiger-Kommando (Liefer-Punkt 1 und 2).

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste.

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [x] **Liefer-Punkt 1 — der Sensor** (bats-Fall, Mutations-Fall oder benannte Übergabe; Rot an der realen Quelle gesehen, Meldung gelesen).
- [x] **Liefer-Punkt 2 — der Zeiger** (Kommentar in Fall 131 nachgezogen, Zeiger-Kommando geschärft; Rot gesehen).
- [x] **Liefer-Punkt 3 — zwei Zeilen-Bedingungen** (`SPEC-040` mit Belegklasse oder als Sicht mit Träger; die Sensor-Namen in den Zeilen; Wächter-Bilanz ohne unbenannte Differenz).
- [x] **Liefer-Punkt 4 — der Nachzug der 19 `Lücke`-Zellen** (elf Zeilen mit Anker auf [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), drei auf den Erfassungs-Umfang, fünf verlassen die Spezifikation; Kommando zu Zeile 4 der [`ADR-0076`](../../adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md) gibt nichts aus; Wächter-Bilanz ohne unbenannte Differenz; nur Kommentare, keine Logik).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: `grep -rn 'spezifikation' docs/user | wc -l` steht im Bericht; ein Treffer auf eine geänderte Zeile wird nachgezogen.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `test/` (bats-Fall über `spec/spezifikation.md`) | neu | Liefer-Punkt 1: Kopfzeilen-Zahl gleich Tabellen-Zahl, keine leere letzte Zelle |
| `test/mutations/` | neu | Liefer-Punkt 1: Fall, der die Spalte streicht oder die Zelle leert |
| `test/mutations/131-span-werkzeugname-leer.sh` | update | Liefer-Punkt 2: nur Kommentarzeilen |
| `spec/spezifikation.md` | update | Liefer-Punkt 3: Zeilen `SPEC-040`, `SPEC-059`/`060`/`062`-`065`; Liefer-Punkt 4: die 19 `Lücke`-Zellen |
| `.claude/hooks/pretooluse-agent-guard.sh`, `test/agent-guard.bats`, Helfer der `mustContain`-Gegenproben | update | Liefer-Punkt 4: nur Kommentare (Zusagen und Grenzen von `SPEC-041`, `084`, `085`, `086`) |

- **Reihenfolge im Lauf:** (1) Wächter-Bilanz Vorher sichern; (2) Sensor mit Rot-Probe; (3) Zeiger; (4) Zeilen; (5) Bilanz nachher, `make docs-check`, `make gates`.
- **Der Sensor liest die reale Spec**, nicht eine nachgebaute Tabelle
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6, Fixture gegen reale Quelle): das Rot wird an der echten Datei gesehen.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): `slice-spec-5-wird-nach-adr-0074-umgebaut` liegt in `done/` (`ls docs/plan/planning/done/slice-spec-5-wird-nach-adr-0074-umgebaut.md`).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß): wenn der Zeiger-Sensor (Liefer-Punkt 2) mehr als ein Kommando braucht — dann Liefer-Punkt 2 als eigener Slice.
- `in-progress` → `next` (Liefer-Punkt 4, vier statt drei Liefer-Punkte, begründet in §1): trägt er eine Zeile, deren Ebene sich am Wortlaut der ADR nicht bestätigen lässt, oder sprengt er die Review-Sitzung, wird er ein eigener Slice.
- `in-progress` → `open` (blockiert): wenn die bats-Stufe `test/` nicht über die Spec sieht (Mount) oder `make mutate` für die bats-Stufe kein Fehlschlag-Muster führt — Übergabe an den Planner.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) das Kommando zu Zeile 4 der [`ADR-0076`](../../adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md) gibt nichts aus; die Rot-Fälle der Liefer-Punkte 1, 2 und 4 stehen mit ihrer gelesenen Meldung im Report,
Wächter-Bilanz ohne unbenannte Differenz, `make docs-check` ohne Befund; (2) `make gates` grün mit Stempel, der den
Arbeitsbaum deckt. Dazu der Lerneintrag. Den Abschluss schreibt der Planner ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Sensor zählt Tabellen falsch**, etwa eine Tabelle mit `SPEC`-Zeile in einem Zitat oder eine Tabelle ohne Kopfzeile. —
  **Ausgang:** wird bei der Closure eingetragen.
- **Das geschärfte Zeiger-Kommando meldet Zitate, die kein Wortlaut der Spec sind** (Fehlalarme). — **Ausgang:** wird bei der Closure eingetragen.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Zustand:** Liefer-Punkte 1 bis 4 bestätigt im Verifikationsbericht `docs/reviews/2026-09-30-slice-spec-5-nachlauf-verifikation.md` (Fälle 501 bis 503 `3 ok, 0 Befund(e)`, Ursache gelesen; Kommando zu Fitness-Zeile 4 der [`ADR-0076`](../../adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md) leer; Wächter-Bilanz ohne unbenannte Differenz; `make gates` Exit 0). Review: `docs/reviews/2026-09-30-slice-spec-5-tabellen-sensor-und-zeiger-nach-dem-umbau-review.md`, MEDIUM-1 und LOW-1 nachgezogen (`0a2d4b1e`).
- **Steering-Loop-Eintrag — neuer Sensor:** `test/spec-tabellenform.bats` (Kopfzeilen-Zahl gleich Tabellen-Zahl, keine leere letzte Zelle; Fälle `test/mutations/501-spec-praezisiert-spalte-gestrichen.sh`, `502-spec-praezisiert-zelle-leer.sh`) und `test/spec-zitate.bats` (Zitat hinter `spezifikation.md` gegen die Spec; Fall `503-spec-zitat-ohne-fundstelle.sh`). Kein `liegt in`: beide Beobachtungen stehen unter 3×, es ist keine Regel verkörpert.
- **Grenzen, benannt:** die bats-Stufe von `make mutate` bindet nur `not ok [0-9]+`, nicht den Testnamen; die Ursache der drei Fälle hat der Verifier von Hand gelesen. Der Zitat-Sensor fasst nur Zitate hinter „…“ oder `"` bis 250 Byte nach dem Dateinamen; der Bestand trägt kein reales Zitat, belegt ist er durch Fixture und Fall 503.
- **Beobachtungs-Register:** [`sensor-schranke-wird-durch-tabellenwachstum-unscharf`](../observations/BEO-ALL/sensor-schranke-wird-durch-tabellenwachstum-unscharf/observation.md) und [`zeiger-kommando-faengt-zitat-entfernten-wortlauts-nicht`](../observations/BEO-ALL/zeiger-kommando-faengt-zitat-entfernten-wortlauts-nicht/observation.md) bleiben `offen` (je ein Beleg); der Sensor steht als Gegenmaßnahme. Kein Beleg hinzugefügt, nichts hochgezählt.
- **Risiken aus §6:**
  - Sensor zählt Tabellen falsch (Tabelle im Zitat, ohne Kopfzeile) — *weiter offen*: Register [`sensor-schranke-wird-durch-tabellenwachstum-unscharf`](../observations/BEO-ALL/sensor-schranke-wird-durch-tabellenwachstum-unscharf/observation.md); am Bestand 5 von 5, die Randfälle sind nicht gemessen.
  - Zeiger-Kommando meldet Zitate, die kein Wortlaut der Spec sind — *weiter offen*: Register [`zitat-grep-uebersieht-zeilenumbruch-und-markup`](../observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/observation.md); Fehlalarm am Bestand nicht beobachtbar, weil er kein Zitat trägt.
- **Drei Paarungen (nach dem `git mv` geprüft):** (a) kein `liegt in`, kein Gegenstand; (b) kein Folge-Slice genannt; (c) die zwei genannten Register-Verzeichnisse existieren, jedes trägt ein nicht leeres `evidence/`.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist die Sub-Area `*` (gesamtes Repo, Kürzel `ALL`, Modus
Greenfield laut Modus-Deklaration in `harness/conventions.md`). Die Deklaration führt für `spec/` keine feinere
Sub-Area, und alle Beobachtungen des Registers tragen diese eine; die Schwelle ≥ 2 von 3 Achsen lässt sich damit
nicht feiner prüfen, als die Deklaration es zulässt — benannt, nicht gelöst.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen, gemergter Stand; Zähler = Dateien unter
`evidence/` (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`). Treffer am Gegenstand „Sensor-Schranke, Zeiger auf
entfernten Wortlaut, Zusage ohne Sensor":

- [`sensor-schranke-wird-durch-tabellenwachstum-unscharf`](../observations/BEO-ALL/sensor-schranke-wird-durch-tabellenwachstum-unscharf/observation.md) — offen; dieser Slice ist sein Ausgang.
- [`zeiger-kommando-faengt-zitat-entfernten-wortlauts-nicht`](../observations/BEO-ALL/zeiger-kommando-faengt-zitat-entfernten-wortlauts-nicht/observation.md) — offen; dieser Slice ist sein Ausgang.
- [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md) — geplant; berührt die Spalte `Sensor` (Liefer-Punkt 3 b).
- [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md) — geplant; berührt `SPEC-040` (Liefer-Punkt 3 a).

**Modus-Begründungsblock:** alle berührten Sub-Areas GF.
