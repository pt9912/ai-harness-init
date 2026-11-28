# Slice slice-stamp-records-konsum-v1: Treiber-Unterkommando `--stamp-records` — der Mutations-Result-Konsum in Fall-Form

Träger des Konsum-Zugs, den
[`ADR-0107`](../../adr/0107-die-mutations-record-granularitaet-ist-je-fall.md)
Festlegung 5 dem Planner überlässt: der Mutations-Treiber bekommt das
Unterkommando, die Fall-Files akkumulieren je Fall, der Wächter-Zug läuft
über dem realen Werkzeug.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle ([`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst):
der Baseline-Test ist das *Mehr* — eine beobachtbare Closure-Bedingung, die mehr
beobachtet als die DoD dieses Slice; es gibt keine, der Closure-Trigger unten
wäre die Abschrift der eigenen DoD). Wellenlose Arbeit erscheint nicht in der
Roadmap (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(das Unterkommando urteilt nicht — es verwandelt eine Fassung; was es nicht
hält, ist die Grenze aus
[`ADR-0107`](../../adr/0107-die-mutations-record-granularitaet-ist-je-fall.md)
Festlegung 3, unten benannt),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(derselbe Result-File-Eingang, dieselbe Fall-Zeilen-Fassung — der Konsum ist
eine deterministische Transformation, die vom Ort des Laufes unabhängig ist),
[`ADR-0107`](../../adr/0107-die-mutations-record-granularitaet-ist-je-fall.md)
(die bindende Fassung: Ablage und Zeilen-Form — Festlegung 1, Fall-Kennung —
Festlegung 2, Unterkommando samt Grenzen — Festlegung 3, Erstbestand und
Klassen — Festlegung 4, Kopf-Bedarf und Wächter-Zug — Festlegung 5),
[`ADR-0103`](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
(Ablageort und Hash-Ausnahme bleiben regierend — `HASH_AUSNMEN` trägt den
Unterbaum bereits),
[`ADR-0083`](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
(Fall-Files sind Stempel-Klasse — sie blocken kein Turn-Ende),
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(die Kennungs-Form),
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
(die Kopf-Form der Fall-Files — je Zahl ein Kommando),
[`MR-059`](../../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang)
(die Fall-Kennungs-Erkennung trägt die zugelassenen Formen; die Fundliste
steht im Aufgabensatz des Konsums),
[`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
/ [`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
(Anlage-Disziplin des Mutations-Falls, Anker am Commit).

**Berührte Spec-Stellen:** `—` — die Record-Ablage liegt außerhalb jeder
Spec-Stelle ([`ADR-0107`](../../adr/0107-die-mutations-record-granularitaet-ist-je-fall.md)
*„Schärft: — Prozess-ADR ohne Spec-Stratum"*); die Form der Werkzeug-Aussage
trägt [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md)
§CI-Branch. Der Verweis zeigt **aufwärts**: Die Spec nennt diesen Slice nie.

**Verantwortlich:** pt9912
<!-- BEDIENHINWEIS: Verantwortlich hält die Arbeit — der Rolleninhaber der
Implementer-Rolle, gesetzt beim Übergang open→next (Baseline-Regelwerk
modul-05-planning-harness.md §Lifecycle als State Machine). Der Autor schrieb
den Plan; zwei Felder, zwei Fragen. Kein Statuswert: der Zustand bleibt das
Verzeichnis. Kein Sensor prüft das Feld — es ist Deklaration.
Paralleler Lauf — ein WIP-Slot, ein Zweig, ein `git worktree`: Das WIP-Limit
zählt pro Lauf. Hält ein Mensch mehrere Implementer-Läufe parallel, trägt das
Feld ab next→in-progress Person und Zweig — `<Name> (Zweig <branch-name>)` —,
und jeder Lauf arbeitet in seinem eigenen Arbeitsbaum (`git worktree` oder ein
weiterer Klon), nie zwei Läufe in derselben Arbeitskopie. Ein Slice gehört
einem Implementer-Lauf. -->

**Autor:** pt9912. **Datum:** 2026-11-26.

---

## 1. Ziel und Abgrenzung


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — vier Klassen ausdrücklich ausgeschlossener Punkte sind ein
Suchraster, keine Ausfüll-Liste.

**Ziel:** Der Mutations-Treiber konsumiert sein CI-Result-File in Fall-Form —
das Unterkommando `bash harness/tools/mutate.sh --stamp-records <result-file>`
(verb-Schalter vor `main`, Form-Vorbild der `--greift`-Schalter
([`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) Ende) und
des `--entscheide`-Modus des Fast-Pfades
([`harness/tools/gates-fast.sh`](../../../../harness/tools/gates-fast.sh) Kopf))
liest `mutate-ergebnis.txt` **einmal vollständig**, prüft **vor** jedem Anhang
und hängt je Fall die Urteils-Zeile
`<datum> · commit <sha8> · form ok|befund[ · qualifikator infra|last] · run <id> attempt <n>`
an das Fall-File `.harness/stamp/mutate/<fall-kennung>.txt`; je neuem Fall-File
trägt der Kopf Run, Attempt und geprüften Commit
([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)-Form,
in der Fall-Form statt der Lauf-Form). Die Form und ihre Grenzen trägt
[`ADR-0107`](../../adr/0107-die-mutations-record-granularitaet-ist-je-fall.md)
Festlegung 1–5; der Anhang urteilt nicht, er verwandelt.

**Übernimmt:** [`slice-gates-pruefgegenstand-stempel-v1`](../done/slice-gates-pruefgegenstand-stempel-v1.md)
— die zwei Design-Posten aus dessen §3/§6/§7: (a) der **Zuordnungs-Rest** der
Tafel-Mengen — `bash harness/tools/gates-keys.sh rest` nennt 34 Dateien
außerhalb jeder Menge; ob sie je Check in die Mengen aufgenommen werden oder
als benannter Rest deklariert bleiben, ist eine Plan-Entscheidung je
[`ADR-0108`](../../adr/0108-stempel-synthese-je-check-pruefgegenstand.md)
Abwägung E — und (b) der **Record-only-Vertrag** an der engeren Menge
`.harness/stamp/mutate/` ([`ADR-0103`](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
Festlegung 2); die Plan-Fassung des Gebers las `.harness/stamp/**`, die
Schärfung liegt in dessen §3/§6 (Closure-Zug `623a6798`).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- *(Folge-Slice übernimmt es.)* Die Tier-2-Fast-Pfad-Kante (je-Check-Prüfgegenstände
  über der `record-gates`-Kante) trägt
  `slice-gates-pruefgegenstand-stempel-v1` — ihr Architektur-Zug nahm den
  Treiber ausdrücklich aus (§1, Abgrenzung 1, *„anderer Vorgang"*); seine
  Keys und seine Kante werden weder angetastet noch hier fortgeschrieben.
- *(Bestand bleibt bewusst stehen.)* Die vier Lauf-Urteil-Files des
  Erstbestands unter `.harness/stamp/mutate/` bleiben ohne Nachrüsten in der
  Beleg-Form der Lauf-Urteil-Granularität — der Fassung, die
  [`ADR-0103`](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
  beim Ablageort-Wechsel unverändert von ihrer Vorgänger-Fassung nahm
  ([`ADR-0107`](../../adr/0107-die-mutations-record-granularitaet-ist-je-fall.md)
  Festlegung 4) — neue Läufe schreiben in der Fall-Form, der Altbestand wird
  nicht konvertiert und nicht konsumiert.
- *(Es wäre ein anderer Vorgang.)* Der CI-Branch-Ablauf selbst —
  Vorlaufs-Verschiebung, Shard-Ergebnis, `ergebnis`-Job-Push, die
  Result-Form `mutate-ergebnis.txt` an der Branch-Wurzel — bleibt unangetastet
  ([`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt):
  ein eigener Vorgang); der Konsum liest die Form, die der Vorgang schreibt,
  und verändert den Vorgang nicht.
- *(Schicht-Abgrenzung.)* Das Unterkommando bekommt kein `make`-Target,
  keinen Gate-Index-Eintrag und kein Doku-Gate-Modul: der Konsum urteilt
  nicht über den Arbeitsbaum
  ([`ADR-0107`](../../adr/0107-die-mutations-record-granularitaet-ist-je-fall.md)
  Festlegung 3: *„der Exit meldet nur die Transformation"*;
  [`ADR-0083`](../../adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md):
  Fall-Files sind Stempel-Klasse) — sein Wächter ist die Anlagen-Form
  (Liefer-Punkt 2), nicht die Gate-Schicht.

## 2. Definition of Done

- [x] **Liefer-Punkt 1:** das Unterkommando
      `--stamp-records <result-file>` in
      [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) —
      verb-Schalter vor `main`, liest das Result-File einmal vollständig und
      prüft **vor** jedem Anhang: fehlendes, leeres oder unlesbares
      Result-File · doppelte Bestimmung (derselbe Fall zweimal im
      Result-File, oder das Paar `(fall, run, attempt)` steht bereits im
      Fall-File) · unbekannte oder mehrdeutige Fall-Kennung gegen
      `test/mutations/` ([`MR-059`](../../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang)-Formen);
      jede Grenze bricht mit Meldung, ohne den Fall-File-Bestand anzutasten
      ([`ADR-0107`](../../adr/0107-die-mutations-record-granularitaet-ist-je-fall.md)
      Festlegung 3); je Fall eine Zeile nach der Festlegungs-1-Form, ein
      `FEHLT`-Ergebnis wird **nicht** angehängt; je neuem Fall-File der Kopf
      mit Run, Attempt und geprüftem Commit
      ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)-Form
      je Zahl ein Kommando, Festlegung 5).
- [x] **Liefer-Punkt 2:** der Wächter über dem **realen** Werkzeug —
      `test/stamp-records-mechanik.bats` (Happy: je Fall-Zeile angehängt,
      Kopf je neuem Fall-File; Negative: jede fail-closed-Grenze bricht mit
      Meldung, doppeltes `(fall, run, attempt)`-Paar, unbekannte/mehrdeutige
      Kennung, leeres Result-File — der Fall-File-Bestand bleibt unverändert)
      plus ein Mutations-Fall über dem Quell-Bestand, dessen `sed`-Anker
      gegen den Bestand gemessen ist
      ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand))
      und dessen Anker am Commit steht
      ([`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit))
      — der Rot-Beleg je Zusage, nicht die grüne Suite
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [x] **Liefer-Punkt 3:** die Granularitäts-Zeile in
      [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md)
      §CI-Branch trägt die Fall-Form — Ort
      `.harness/stamp/mutate/<fall-kennung>.txt`, Zeilen-Form, das
      Unterkommando samt Grenzen, Kopf-Form-Verweis; die Lauf-Urteil-Form der
      [`ADR-0103`](../../adr/0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
      steht als Teil-Ablösung benannt daneben
      ([`ADR-0107`](../../adr/0107-die-mutations-record-granularitaet-ist-je-fall.md)
      Konsequenzen, Folgepflicht).

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update für das Treiber-Unterkommando, falls ein öffentlicher
      Vertrag berührt — die Form-Stelle ist
      [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md)
      §CI-Branch, getragen als Liefer-Punkt 3.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — die Tabelle hält die Pfad-Kandidaten; Berührung ist
nicht hinreichend und eine Aussagen-Berührung steht hier nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) | update | verb-Schalter `--stamp-records <result-file>` vor `main` samt Konsum-Kern (liest einmal vollständig, prüft, hängt je Fall an); Form-Vorbild der `--greift`-Dispatch und der `--entscheide`-Modus des Fast-Pfades — LP 1 |
| `test/stamp-records-mechanik.bats` | neu | Happy (je Fall eine Zeile, Kopf je neuem File) / Boundary (Result-File-Formen: `FEHLT`, leer, `befund infra`, `befund last`) / Negative (je Grenze mit behaupteter Meldung; doppeltes `(fall, run, attempt)`-Paar; unbekannte/mehrdeutige Kennung) — je LP 1/LP 2 |
| `test/mutations/<nr>-stamp-records-konsum-bricht-mit-meldung.sh` | neu | Mutations-Fall über dem realen Werkzeug (`<nr>` folgt aus dem Bestands-Stand): der Patch nimmt die Konsum-Prüfung heraus, sein Wächter färbt rot — Anlage misst den `sed`-Anker gegen den Quell-Bestand ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)), Anker am Commit ([`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)) — LP 2 |
| [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) | update | §CI-Branch: die Granularitäts-Zeile trägt die Fall-Form und nennt Ort, Zeilen-Form, Unterkommando und Grenzen — LP 3 |

**Plan-Fortschreibung §3 (Implementer-Zug, vor dem Code, [`ADR-0108`](../../adr/0108-stempel-synthese-je-check-pruefgegenstand.md) Abwägung E je
Posten)** — die zwei übernommenen Design-Posten:

- **Posten (a) Zuordnungs-Rest — gemischte Form, je Rest-Datei an der
  Abwägung E entschieden.** *Aufnahme-Form* für die Dateien, deren Lesung
  gezeigt ist: die `test`-Menge erweitert um `./internal/emit/templates/*`
  und `./internal/emit/testdata/*` — `go:embed all:templates/enforce|agents|commands`
  liest die Vorlagen beim Kompilieren der Test-Pakete und die
  emit-Golden-Tests (`templates_test.go`) lesen den Vorlagen-Baum; eine
  veränderte oder gelöschte Vorlage erreicht zuerst den `test`-Check
  (Kompilier-Existenz und Golden-Lesung), `lint` und `build` urteilen über
  Vorlagen-Inhalt nicht (Daten, kein Code — eine Deletion bricht am
  `test`-Kompilieren, das sie mitkompilieren). Rot-Beleg: der
  Vorlagen-Edit im Fixture dreht den `test`-Key (Wächter am
  `test/gates-keys.bats`). *Deklarations-Form* für die übrigen — Dateien,
  über die kein Check der Kante urteilt (`LICENSE`, Root-Repo-Metadaten,
  `.gitkeep`, `docs/user/images/`, das Homebrew-Formular, die
  Erfassungs-awk-Helper, Wächter-Verdrahtung): als **deklarierter
  Zuordnungs-Rest** an genau einer Stelle im Satzerzeuger deklariert
  ([`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  Festlegung 3-Form: je Klasse-Glob einer Zeile mit genanntem
  Grund, als Rest gezählt statt als Deckung), aus der `rest`-Beurteilung
  ausgenommen — `rest` leer → Exit 0; Inhalt außerhalb jeder Menge und
  jeder deklarierten Klasse → Liste und Exit 1 (der fail-closed
  Gap-Detektor bleibt). Mess-Beleg: der Stop-Hook-Mischform-Zug — über
  `eb7619e2` blockt der Hook über deckenden Keys an der unzugeordneten
  Rest-Menge (rot gesehene Gegenbeispiel, `stop-require-gates.sh`-Aufruf,
  „files outside every declared Menge"); am Ende der Zug fährt er über der
  deklarierten Form approve. Undeklarierte Rest-Neuzugänge drehen den
  `rest ist leer`-Wächter (neuer Mutations-Fall je
  [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)-Form).
- **Posten (b) Record-only-Vertrag — Wächter-Fassung der engeren Menge.**
  Die engere Menge ist in Bestand (`HASH_AUSNMEN` trägt
  `.harness/stamp/mutate`, `rest`-Walk und `MENGE_AUSSCHLUESS` tragen die
  Ablage-Klasse); die fehlende Hälfte am Wächter-Satz ist die
  `rest`-Richtung: der Fixtures-Record-Zug in `test/gates-keys.bats`
  assertiert, dass eine Record-Datei in keiner `menge`- und keiner
  `rest`-Ausgabe auftaucht (Form des Record-Zug-Tests am selben
  Fixture).

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/gates-keys.sh` | update | die `test`-Menge-Zuschläge, die deklarierten Rest-Klassen am Kopf je Eintrag mit Grund, das `rest`-Lesen der deklarierten Klasse | Posten (a) |
| `test/gates-keys.bats` | update | Wächter über dem Rest-Zustand (`rest ist leer`) und dem Record-only-Vertrag (`menge`/`rest` trägt keine Record-Ablage, Vorlagen-Zuschlag dreht den `test`-Key) | Posten (a)/(b) |
| `test/mutations/<nr>-deklarierter-rest-entzaubert.sh` | neu | Mutation an der Rest-Deklaration; der `rest ist leer`-Wächter färbt rot ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)-Form) | Posten (a) |

## 4. Trigger

**Start** (`next` → `in-progress`):
[`ADR-0107`](../../adr/0107-die-mutations-record-granularitaet-ist-je-fall.md)
ist `Accepted` (Architektur-Zug `4f344a74` — liegt vor; beobachtbar an der
Status-Zeile der ADR-Datei). Ein weiterer Architektur-Zug braucht es davor
nicht: den Wächter-Bedarf trägt die ADR selbst (Festlegung 5, ehrlich
benannt).

**Rückführungen — vorab benennen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): gerät die
  Retro-Konversion des Erstbestands, ein `make`-Target oder ein
  Gate-Index-Eintrag in den Umfang — beides ist in §1 ausdrücklich
  ausgeschlossen ([`ADR-0107`](../../adr/0107-die-mutations-record-granularitaet-ist-je-fall.md)
  Festlegung 4, Schicht-Abgrenzung).
- `in-progress` → `open` (blockiert — Carveout?): der Treiber-Dispatch
  (die `--greift`-Stelle, `main`) verändert sich in einem parallelen Zug, oder
  die Konsum-Form brauchte eine zweite Hash-Ausnahme neben `HASH_AUSNMEN` —
  der Unterbaum `.harness/stamp/mutate` ist bereits ausgenommen
  (Festlegung 4); eine zweite Ausnahme wäre ADR-Pflicht
  ([`AGENTS.md`](../../../../AGENTS.md) §3.5).

## 5. Closure-Trigger


Beobachtbar an dem realen Werkzeug: der Happy-Lauf von
`test/stamp-records-mechanik.bats` hängt über einem
`mutate-ergebnis.txt`-Eingang je Fall genau eine Zeile (und je neuem Fall-File
den Kopf) an, die drei Grenzen brechen mit Meldung und lassen den
Fall-File-Bestand unverändert, und der Mutations-Fall färbt den Konsum rot,
wenn seine Prüfung herausgenommen wird — `make gates` grün, Review-Report
liegt unter `docs/reviews/`, Closure-Notiz mit Lerneintrag (`AGENTS.md`
§3.6-Form: der Rot-Beleg je fail-closed-Grenze, nicht irgendeine).

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- Ein Stamp-Lauf bricht mitten im Anhängen (Sammel-Result-File — 87
  Fall-Zeilen der letzten Sammel-Züge): ein Teil liegt an, der Rest nicht, und
  ein Wiederholungs-Lauf bricht an der `(fall, run, attempt)`-Doppelung des
  bereits gestempelten Anteils fail-closed, statt fortzuführen — die
  Wiederaufnahme hat die ADR-Form nicht. — **Ausgang:** *weiter offen* →
  `BEO-ALL/stamp-abbruch-hinterlaesst-teilbestand` im Register, Beleg
  `evidence/slice-stamp-records-konsum-v1.md` — die Messung des
  Verifikations-Berichts (R1) trägt: bricht der Konsum zwischen zwei Anhängen,
  bleibt ein Teilbestand, und der Wiederhol-Lauf bricht an der Paar-Doppelung
  fail-closed (`test/stamp-records-mechanik.bats` Test 7, Suite 17/17), ohne
  Wiederaufnahme-Form.
- Die Fall-Kennung einer gestempelten Datei löst nach dem Umbenennen ihrer
  Mutations-Datei nicht mehr (Datei-Formen unter `test/mutations/` wandern je
  [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)-
  Bestands-Messung am Commit) — künftige Anhänge für den Fall brechen
  fail-closed, die Geschichte bleibt an der alten Fall-Adresse. —
  **Ausgang:** *entfallen* — der Umbenennungs-Fall ist im bats-Zug gezeigt
  (Test 10 `die umbenannte Fall-Quelle loest nicht mehr auf und bricht, die
  Geschichte bleibt an der alten Adresse`, Suite 17/17 je
  Verifikations-Bericht); die fail-closed-Meldung nennt den Fall und die
  umbenannte Quelle, die Grenze gilt als erwartbar.
- Zweiter Konsum-Lauf desselben Sweep-Ergebnisses über denselben geprüften
  Commit nach einem Retry des `ergebnis`-Jobs mit neuer `run <id>` — die
  Paar-Prüfung hält nur exaktes `(fall, run, attempt)`; ein zweites Urteil
  über denselben Commit trägt scheinbar ein neues Paar. — **Ausgang:**
  *entfallen* — Test 9 grün (`ein Retry mit neuer run-id haengt an; der
  gepruefte Commit steht im Kopf`); die Kopf-Zeile des Fall-Files trägt den
  geprüften Commit
  ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)-Form),
  die Doppelung ist am Kopf lesbar.

## 7. Closure-Notiz

<!-- BEDIENHINWEIS — keine Norm; faellt beim Kopieren weg (README.md
§Verwendung, Schritt 5) und darf deshalb nichts Tragendes halten. Reihenfolge:
diese Sektion vor dem `git mv` nach done/ fuellen — einzige Ausnahme ist das
letzte DoD-Item in §2 (die Paarungen suchen in `done/`, also nach dem `git mv`).
Im Repo ohne Wellen-Betrieb braucht die Closure dadurch drei Commits: Inhalt,
`git mv`, Haekchen — das folgt aus der Hard Rule, es widerspricht ihr nicht. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** der Konsum in der
  [`ADR-0107`](../../adr/0107-die-mutations-record-granularitaet-ist-je-fall.md)-Form
  (einmal-Lesung, Vorab-Prüfung, je-Zeile-Anhang, Kopf je neuem Fall-File nach
  [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung))
  gegen die Szenario-Batterie und 17/17
  (`test/stamp-records-mechanik.bats`); `make mutate-greift` 806/806; die zwei
  übernommenen Design-Posten getragen — `rest` leer (Exit 0) und der
  Record-only-Vertrag byte-gleich am `MENGE_REST`-Wächter.
- **Was ging anders als geplant:** drei Befunde des Verifikations-Berichts —
  B-1 (MEDIUM, Bestand): der dokumentierte Teillauf
  `make mutate MUTATE_CASES='<fälle>'` fällt im Grün-Vorlauf, die
  Umgebungs-Auswahl erreicht `greift_main`; die Rot-Züge dieses Laufs liefen
  darum als Substitution je Fall-Kopf am Bestand statt über den Teillauf;
  B-2: der gepushte Mutations-Branch trägt eine divergente Linie
  (Lösch-Posten unten, Entscheidung nicht allein getroffen); B-3: die in §1
  datierte Zahl 34 des Zuordnungs-Rests ist am Verifikations-Stand nicht mehr
  der Ist — Messung unten.
- **Steering-Loop-Eintrag:** Lernkandidat, **gezählt statt verkörpert** — der
  Konsum liest das Result-File einmal vollständig und prüft vor jedem Anhang;
  die Fall-Zeile trägt kein Urteil (der Anhang verwandelt, er urteilt nicht).
  Verkörpert wurde nichts über den gelieferten Umfang hinaus — die Teil-Zeile
  `— liegt in …` entfällt ersatzlos; die Form selbst steht in
  [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) §CI-Branch
  als Lieferung (LP 3), nicht als Steering-Loop-Regel.
- **Beobachtungs-Register (`../observations/`):** `BEO-ALL/stamp-abbruch-hinterlaesst-teilbestand/`
  neu angelegt, Beleg `evidence/slice-stamp-records-konsum-v1.md`;
  `evidence/slice-stamp-records-konsum-v1.md` in
  `BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf/` ergänzt — Zähler
  steht damit bei 2 × (`ls evidence | wc -l`); die berührte Ebene
  Konsum/Record-Ablage trägt über die beiden Belege hinaus keinen Eintrag
  (§8-Sichtung).
- **Folge-Slices:** `slice-mutate-cases-leakt-nicht-am-teillauf` (der Teillauf
  des Mutations-Treibers bricht nicht mehr am Grün-Vorlauf) — ist eine Datei
  in `next/`.
- **Risiken aus §6:** R1 *weiter offen* → `BEO-ALL/stamp-abbruch-hinterlaesst-teilbestand` ·
  R2 *entfallen* (Test 10) · R3 *entfallen* (Test 9) — je mit Beleg, siehe §6.
- **Rest-Frische-Messung:** `bash harness/tools/gates-keys.sh rest` → leer,
  Exit 0 (2026-11-28); die deklarierten `MENGE_REST`-Klassen treffen exakt
  15 Dateien (`git ls-files | grep -cE '(^|/)\.gitkeep$|^docs/user/images/.+|^harness/tools/.+\.awk$|^harness/tools/homebrew-formula\.rb\.tmpl$|^\.claude/settings\.json$|^\.codex/hooks\.json$|^\.gitattributes$|^\.gitignore$|^\.viper\.sh$|^LICENSE$'`
  → 15, 15/15) — statt der datierten 34 aus §1 (Geber-Closure
  [`slice-gates-pruefgegenstand-stempel-v1`](../done/slice-gates-pruefgegenstand-stempel-v1.md),
  `623a6798`).
- **Übergabe — Lösch-Posten (Verify-Befund B-2):** der divergente Branch
  `mutate/slice-stamp-records-konsum-v1-b63291e6` auf `origin` — sein
  geprüfter Commit `b63291e64d00` ist kein Commit der verifizierten Kette,
  sein Resultat ist kein Verifikations-Beleg für `HEAD 3c7bed9a`. Lösch-Posten:
  `git push origin :refs/heads/mutate/slice-stamp-records-konsum-v1-b63291e6` —
  **Entscheidung offen und nicht allein getroffen** (Auftraggeber; der
  CI-Branch-Zug trägt der Verifier). Bis dahin ist auch die offene Hälfte von
  B-2 benannt: der reale Konsum-Stamp an einem echten Result-File über der
  verifizierten Kette (`mutate-auswahl` → Push → Konsum) fehlt.
- **Drei Paarungen:** geprüft am 2026-11-28, nach dem `git mv` — (a) Anker:
  kein Steering-Loop-Eintrag mit `liegt in` getragen (der §7-Eintrag ist gezählt
  statt verkörpert, die Teil-Zeile entfällt); (b) Folge-Slice:
  `ls docs/plan/planning/*/slice-mutate-cases-leakt-nicht-am-teillauf.md` →
  genau eine Datei (`next/`); (c) Register: `BEO-ALL/stamp-abbruch-hinterlaesst-teilbestand`
  und `BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf` existieren mit
  nicht leerem `evidence/` (je Belegdatei); **zweite Hälfte: 1 Verzeichnis
  ohne Beleg**, namentlich `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`
  (`for d in docs/plan/planning/observations/BEO-ALL/*/; do …; done`-Lauf,
  [ADR-0069](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  Festlegung 2) — nicht als getragen behauptet.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `harness/tools/`
(Kürzel `TOOLS`, Modus-Deklaration
[`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area) — die Schwelle ≥ 2 von 3 Achsen ist erfüllt
(Strukturregeln über den Adaptions-Block, Phase-Reife Phase 5 — die Tools
laufen in `make gates`); die Tests und die Sensor-Doku daneben laden dieselbe
Sub-Area, keine zweite.

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen
(`docs/plan/planning/observations/BEO-ALL/`). Die Treffer der Sub-Area hängen
am Host-Varianten-Cluster des Treibers (`mutate-treiber-braucht-bash-4-…`,
`mutate-greift-braucht-gnu-sed-…`, `mutate-auswahl-paste-ohne-operand-…`,
`mutate-shard-kosten-…`) — macOS/BSD-Läufer-Ebene und Shard-Kosten, nicht die
Konsum-Form. Keine Treffer an der berührten Ebene (Stempel-Konsum und
Record-Ablage); falls im Lauf eine anfällt, trägt sie die Closure
(`evidence/slice-stamp-records-konsum-v1.md`).

### Sub-Area: `harness/tools/`

- **Konventionen-Dichte:** hoch — [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed),
  [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand),
  [`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit),
  [`MR-059`](../../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang).
- **Phase-Reife:** Phase 5 — die Tools laufen in `make gates`, ihr Wächter
  (`mutate`) in der Nacht-CI.
- **Evidenz-/Diskrepanz-Risiko:** niedrig — der Konsum ist neu (GF), die
  Grenzen trägt
  [`ADR-0107`](../../adr/0107-die-mutations-record-granularitaet-ist-je-fall.md)
  in der Form selbst; keine offene Beobachtung an dieser Ebene.
- **Reconciliation-Aufwand:** kein Inventur-Fund im Zug; Graduation-Trigger
  nichts — der Unterbaum `HASH_AUSNMEN` trägt die Fall-Files bereits.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt. Alle berührten
Sub-Areas GF — der Block entfällt; die vier Pflichtkriterien stehen im
Block oben.
