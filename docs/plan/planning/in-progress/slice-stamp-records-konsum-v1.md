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

**Verantwortlich:** pt9912 (Zweig impl/slice-stamp-records-konsum-v1)
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

- [ ] **Liefer-Punkt 1:** das Unterkommando
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
- [ ] **Liefer-Punkt 2:** der Wächter über dem **realen** Werkzeug —
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
- [ ] **Liefer-Punkt 3:** die Granularitäts-Zeile in
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

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update für das Treiber-Unterkommando, falls ein öffentlicher
      Vertrag berührt — die Form-Stelle ist
      [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md)
      §CI-Branch, getragen als Liefer-Punkt 3.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

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
  Wiederaufnahme hat die ADR-Form nicht. — **Ausgang** (Beleg-Zeilen je
  Closure): *weiter offen* → `BEO-ALL/stamp-abbruch-hinterlaesst-teilbestand`
  im Register, wenn das Ergebnis den Fall trägt; *entfallen* mit Grund, wenn
  der Test-Lauf (bats über kopiertem Bestand) zeigt, dass ein Abbruch vor dem
  Anhang aus dem vollständigen Prüfverlauf unmöglich ist.
- Die Fall-Kennung einer gestempelten Datei löst nach dem Umbenennen ihrer
  Mutations-Datei nicht mehr (Datei-Formen unter `test/mutations/` wandern je
  [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)-
  Bestands-Messung am Commit) — künftige Anhänge für den Fall brechen
  fail-closed, die Geschichte bleibt an der alten Fall-Adresse. — **Ausgang**
  (Beleg-Zeilen je Closure): *weiter offen* →
  `BEO-ALL/fall-datei-adresse-loest-nach-umbenennen-nicht` im Register,
  falls die Beobachtung im Lauf anfällt; *entfallen* mit Grund, wenn der
  Umbenennungs-Fall im bats-Zug gezeigt ist (fail-closed-Meldung nennt den
  Fall und die umbenannte Quelle) und diese Grenze als erwartbar gilt.
- Zweiter Konsum-Lauf desselben Sweep-Ergebnisses über denselben geprüften
  Commit nach einem Retry des `ergebnis`-Jobs mit neuer `run <id>` — die
  Paar-Prüfung hält nur exaktes `(fall, run, attempt)`; ein zweites Urteil
  über denselben Commit trägt scheinbar ein neues Paar. — **Ausgang** (Beleg
  je Closure): *entfallen* mit Grund, wenn die Kopf-Zeile des Fall-Files den
  geprüften Commit trägt, so dass die Doppelung am Kopf lesbar ist
  ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung));
  sonst *weiter offen* → `BEO-ALL/retry-ergebnis-job-stempelt-doppelt` im
  Register.

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

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Gegenstand:** <übernommen von `slice-<Kennung>` | entfallen: <Grund>>
  *(nur beim Ausgang ohne Arbeit; sonst Zeile löschen)*
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<KUERZEL>/<slug>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

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
