# Slice slice-werkzeug-zellenlaenge-hat-einen-sensor: Die Zellenlänge der Werkzeuge- und Sensors-Tabelle ist maschinell begrenzt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — keine Closure-Bedingung, die mehr beobachtet als die DoD
([`MR-037`](../../../../harness/conventions.md#mr-037)).

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist die `.d-check.yml` dieses Repos.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(eine Zusage „Zellen bleiben kurz" ohne Sensor ist behauptet),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Messung gegen den in
[`d-check.mk`](../../../../d-check.mk) gepinnten Digest, netzlos),
[`MR-001`](../../../../harness/conventions.md#mr-001) (Schärfung der Gate-Konfiguration statt Senkung).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-05.

---

## 1. Ziel und Abgrenzung

**Ziel:** Eine `structure`-Regel in [`.d-check.yml`](../../../../.d-check.yml) begrenzt die Zellen der
Spalten `Tut was` (Werkzeuge-Tabelle) und `Vertrag` (Sensors-Tabelle) von
[`harness/README.md`](../../../../harness/README.md); `make docs-check` fährt sie in `make gates` mit.

**Die Lage, am Ort benannt.** Der eingefrorene Plan `slice-werkzeug-zellen-tragen-ihre-prosa-unter-sensors`
schreibt in §1 und §2, ein Schwellen-Sensor existiere nicht und kein Sensor halte die Zellenlänge. Am
gepinnten Stand `v0.79.0` stimmt das nicht: `structure` begrenzt eine Spalte über ihren Kopfzeilen-Namen
(`table.column[].name` mit `cell-max-chars`, Befund `section-cell-oversized`). Der Plan bleibt
unverändert (`AGENTS.md` §3.4, §3.11).

**Sonde am Pin** (Wegwerf-Kopie des Baums, `git archive HEAD | tar -x -C <kopie>`; Block vor der Zeile
`# targets (hermetisch` der Kopie-`.d-check.yml` eingefügt; Lauf wie in
[`doc-structure.md`](../../../../harness/sensors/doc-structure.md) §Grenze, Mount `:ro`, `--network none`):

- Der Block unter `section: "## Sensors (Feedback-Gates)"` trifft **beide** Tabellen: ohne die Spalte
  wird eine Tabelle übergangen. Grün über dem Bestand mit Grenze 260 (`Tut was`) und 150 (`Vertrag`).
- Grenzlage in Zeichen (Runen): `Tut was` 257 grün, 256 ein Befund; `Vertrag` 149 grün, 148 ein Befund.
- Rot: eine um 10 Zeichen verlängerte `Tut was`-Zelle → `section-cell-oversized` auf der Zeile der Zelle;
  dasselbe für `Vertrag`; der Kopf `Tut was` umbenannt → `section-column-missing`.
- Mit `hint:` fehlt in der Meldung „hat N Zeichen, erlaubt sind M" — der Plan setzt keinen.

Die Zahlen sind kein Erwartungswert ([`MR-025`](../../../../harness/conventions.md#mr-025)); sie
wandern mit dem Bestand.

**Schwelle aus dem Bestand.** Die Zelle, nicht die Zeile, ist die Einheit (die längste Tabellenzeile
misst 771 Zeichen und ist die Summe ihrer Zellen). Gemessen in Zeichen, nicht in Bytes (`awk length`
zählt Bytes und das Füll-Leerzeichen mit):

```sh
awk '/^### Werkzeuge/{f=1} f&&/^\| /&&!/^\|---/&&!/^\| Target/{split($0,a,"|"); c=a[3]; gsub(/^ +| +$/,"",c); print c}' harness/README.md \
  | while IFS= read -r l; do printf '%s' "$l" | wc -m; done | sort -n | tr '\n' ' '
# 36 Zellen; die vier längsten: 199 207 212 257; Median 59
```

(`Vertrag`: dasselbe Muster mit `/^## Sensors/{f=1} /^### Werkzeuge/{f=0}` und der Spalte `a[3]`; 11 Zellen,
Maximum 149.) Zwischen dem 90. Perzentil (162) und der nächsten Zelle (199) liegt die einzige Lücke der
Verteilung. **Gesetzt wird 260 und 150:** Bestand plus drei Zeichen — der Bestand bleibt stehen, jedes
Wachstum färbt. 200 setzte vier Zeilen zurück und wäre ein Umbau dieser Zeilen, ein anderer Vorgang.

**ADR-Bedarf: keiner.** `docs-check` wird strenger und nimmt nichts aus; das Modul `structure` ist schon
in `modules:`. Das ist eine Schärfung ([`AGENTS.md`](../../../../AGENTS.md) §3.5 bindet Senkungen;
[`MR-001`](../../../../harness/conventions.md#mr-001): *Gate-Anheben → Steering-Loop*). Die Anmerkung am
`structure:`-Block („Ein weiterer Eintrag ist eine Senkung") steht im Absatz zu `exempt-paths` und meint
einen weiteren Eintrag **dieser Ausnahme-Liste**; die neue Regel trägt keine. Ein späterer
`exempt-paths`-Eintrag an ihr wäre eine Senkung und braucht eine ADR.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Keine Grenze auf der Spalte `Bindung`. Sie trägt Kennungs-Listen, deren Länge mit der Zahl der Bindungen
  wächst; eine Obergrenze dort misst keine Prosa. *(Bestand bleibt stehen.)*
- Keine Kürzung der vier längsten `Tut was`-Zellen und kein Senken der Grenze auf 200. Das wäre eine
  Umarbeitung des Wortlauts, kein Sensor-Einbau. *(Anderer Vorgang; die Prosa-Verlagerung nach
  `harness/sensors/` leistete der eingefrorene Plan.)*
- Keine Untergrenze (`cell-min-chars`) und keine Regel für andere Tabellen von `harness/README.md`. Die
  Zusage ist „Prosa gehört unter `sensors/`", nicht „jede Zelle ist gefüllt". *(Bestand bleibt stehen.)*
- Keine Änderung der emittierten Startkonfiguration. Ebene Dogfood; die emittierte Modul-Menge hängt an
  [`MR-054`](../../../../harness/conventions.md#mr-054) und ist `slice-zellenlaenge-sensor-geht-ins-ziel`.
  *(Folge-Slice mit Kennung; er startet erst, wenn dieser Slice in `done/` liegt.)*
- Keine Review-Report-Tabellen: `slice-214-zellengrenze-wird-gemessen-statt-gesetzt` misst eine andere
  Bezugsmenge (Reports in `docs/reviews/`) mit eigener Regel. *(Anderer Vorgang.)*

## 2. Definition of Done

- [ ] **(1) Die Regel steht und ist grün.** Ein `structure`-Eintrag in
      [`.d-check.yml`](../../../../.d-check.yml): `files: harness/README.md`,
      `section: "## Sensors (Feedback-Gates)"`, `table.column` mit `Vertrag` (`cell-max-chars: 150`) und
      `Tut was` (`cell-max-chars: 260`), kein `exempt-paths`, kein `hint`. Der Kommentar am Eintrag nennt
      Zusage, Schwelle und das Kommando, das sie liefert (`AGENTS.md` §3.7, [`MR-025`](../../../../harness/conventions.md#mr-025)). `make doc-structure`
      und `make docs-check` melden 0 Befunde.
      *Bricht die Zusage, wenn:* eine Zelle der Spalte die Grenze überschreitet oder der Spalten-Kopf
      umbenannt wird. Beides ist an der realen `harness/README.md` rot zu sehen (Punkt 2), nicht an einer
      Nachbildung.
- [ ] **(2) Das Rot ist an der realen Quelle gesehen, die Lage steht in
      [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) §Modul `structure`.** In
      einer Kopie außerhalb des Repos: je eine Zelle über der Grenze in `Tut was` und in `Vertrag`, und der
      umbenannte Kopf, jeweils mit gelesener Meldung (`section-cell-oversized` mit Spalte und Zeichenzahl,
      `section-column-missing`); dazu die Grenzlage 257/256 bzw. 149/148. Die Sensor-Datei nennt Pin
      (`v0.79.0`), Kommandos und Ergebnis und benennt die Grenze: ein Dauer-Wächter für die Regel selbst
      existiert nicht — `make mutate` führt für `docs-check` kein Fehlschlag-Muster
      (`sed -n '/^failure_form()/,/^}/p' harness/tools/mutate.sh`), die Zusage trägt die Sonde.

Standard (zählen nicht): `make gates` grün · Review-Report unter `docs/reviews/` (kein Self-Review) ·
Closure-Notiz mit Lerneintrag · Beobachtungs-Register fortgeschrieben · jedes Risiko aus §6 mit Ausgang ·
drei Paarungen getragen.

## 3. Plan (vor Code)

| Datei | Änderungs-Art | Begründung |
|---|---|---|
| [`.d-check.yml`](../../../../.d-check.yml) | update | DoD (1): ein Eintrag im `structure:`-Block, nach der bestehenden Regel |
| [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) | update | DoD (2): Lage, Sonde, Grenze unter §Modul `structure` |

## 4. Trigger

**Start** (`next` → `in-progress`): Implementer übernimmt, WIP-Limit frei; keine Abhängigkeit.

**Rückführungen:**

- `in-progress` → `next`: die Sonde am Pin ergibt für den Bestand ein anderes Bild als hier (etwa weil eine
  Zelle mit Zeilenumbruch-Marken anders zählt) — Schwelle neu messen.
- `in-progress` → `open`: `make docs-check` meldet nach dem Eintrag Befunde außerhalb von
  `harness/README.md`, die der Bestand nicht trägt.

## 5. Closure-Trigger

Zwei beobachtbare Kriterien: `make gates` grün mit dem Eintrag in `.d-check.yml`; die Sonde (DoD 2) steht
in `docs-check.md` mit gelesener Meldung. Dazu ein Lerneintrag in einer der drei Formen.

## 6. Risiken und offene Punkte

- Die `docs-check`-Zeile der Sensors-Tabelle liegt mit ihrer `Vertrag`-Zelle an der Grenze (149 Zeichen,
  Grenze 150): jede Ergänzung dort färbt rot. — **Ausgang:** entfallen: gewollt, ein Zusatz gehört nach
  [`docs-check.md`](../../../../harness/sensors/docs-check.md); die Regel meldet ihn.
- Eine Obergrenze auf Bestand + 3 hält das Wachstum, nicht die Zusage „kurz": Zeilen unter 260 gelten als
  in Ordnung, auch wenn der Median bei 59 liegt. — **Ausgang:** weiter offen →
  `BEO-ALL/sensor-schranke-wird-durch-tabellenwachstum-unscharf` (dieselbe Klasse: eine für den Bestand
  gesetzte Schranke, die mit der Menge unscharf wird).

## 7. Closure-Notiz

*Wird bei der Closure gefüllt (Planner, `AGENTS.md` §3.10).*

- **Was hat funktioniert:**
- **Was ging anders als geplant:**
- **Steering-Loop-Eintrag:**
- **Beobachtungs-Register (`../observations/`):**
- **Folge-Slices:**
- **Risiken aus §6:**
- **Drei Paarungen:**

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, `ALL`) — `.d-check.yml` und
`harness/sensors/`; `harness/tools/` bleibt unberührt. Eine Sub-Area, Inklusionskriterium erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** ein Treffer,
[`BEO-ALL/sensor-schranke-wird-durch-tabellenwachstum-unscharf`](../observations/BEO-ALL/sensor-schranke-wird-durch-tabellenwachstum-unscharf/observation.md),
Zähler-Stand 1 (`ls docs/plan/planning/observations/BEO-ALL/sensor-schranke-wird-durch-tabellenwachstum-unscharf/evidence | wc -l`
→ 1, gemergter Stand 2026-10-05). Berührung: die Schranke bei Bestand + 3 (§6). Ein Beleg dieses Slice
brächte ihn auf 2, nicht auf 3.

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — [`MR-001`](../../../../harness/conventions.md#mr-001) trägt die Gate-Schärfung, der `structure`-Block besteht.
- **Phase-Reife:** Phase 5 — der Gate läuft in `make gates`.
- **Evidenz-/Diskrepanz-Risiko:** niedrig; der Bestand ist gemessen (§1).
- **Reconciliation-Aufwand:** keiner.

