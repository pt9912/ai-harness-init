# ADR-0114: Der Mutations-Grün-Vorlauf fährt je Drift-Fächer — der Treiber liest dieselbe Kante wie der Fast-Pfad, Fall-Läufe sinken von Stunden auf Minuten

**Status:** Accepted

**Datum:** 2026-11-28

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Revidiert:** — Die Voll-Suite-Fassung des Grün-Vorlaufs war nie Festlegung einer
Accepted-ADR; sie entstand an [harness/tools/mutate.sh](../../../harness/tools/mutate.sh)
(Review-Befund slice-026 F-6) und wird hier ersetzt, nicht widerrufen — §3.4
([`AGENTS.md`](../../../AGENTS.md)) berührt keine Bestands-ADR: die committed je-Check-Keys
(Festlegung 1) und das Frisch-Rechnen-Vertrauens-Modell (Festlegung 2) von
[ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) bleiben unverändert und werden
hier konsumiert, nicht geändert.

**Bezug:**
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(derselbe Satzerzeuger, kein zweiter Drift-Maßstab — der Treiber liest dieselbe Kante wie der
Fast-Pfad),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Drift-Fächer behauptet nur, was die Tafel-Menge deckt — die Verengung ist benannt, nicht
begraben),
[ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
(Festlegungen 1/2: die committed je-Check-Keys `.harness/state/gates-passed-<check>.key` und
Frisch-Rechnung gegen Transport — hier derselbe Mechanismus, nicht derselbe Konsum-Ort),
[ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md)
(die Tafel-Mengen des Satzerzeugers
[`harness/tools/gates-keys.sh`](../../../harness/tools/gates-keys.sh) — hier als Deckungs-Form),
[ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
(die deklarierten Ausschlüsse und der Rest — keine Menge deckt sich selbst),
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
(der Beleg-Slot und der benannte Rest — unverändert),
[ADR-0107](0107-die-mutations-record-granularitaet-ist-je-fall.md)
(die Record-Granularität je Fall — der CI-Vollsweep bleibt unverändert),
[ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 5 (der nächste Fall wird
einzeln entschieden — diese Verengung ist der Fall),
[`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed),
[`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
(Anlagen-Disziplin),
[`BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf`](../../../docs/plan/planning/observations/BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf/state.md)
(Zähler 2; das Leack, das mit dem Vorlauf-Wechsel entfällt — Festlegung 2)

**Schärft:** — Prozess-ADR ohne Spec-Stratum. Der Mutations-Treiber trägt keinen Gate-Vertrag
([`harness/sensors/mutate.md`](../../../harness/sensors/mutate.md): kein Gate); die Ordnungskante
`record-gates: <checks>` bleibt unberührt, und keine Gate-Schwelle senkt sich — §3.5
([`AGENTS.md`](../../../AGENTS.md)) bindet die Verengung trotzdem: die Vorlauf-Zusicherung ist
eine Messgrenze des Sensors, ihre Verkleinerung ist diese ADR, kein Skript-Kommentar.

---

## Kontext

[harness/tools/mutate.sh](../../../harness/tools/mutate.sh) fährt je Fall einen Grün-Vorlauf
VOLL in der Isolationskopie — `make test-bats` und `make test-go` ganz, je Worker je Modus vor dem
ersten Fall. Das war die Attributions-Leistung des Vorlaufs: der ganze Baum wird im Vorzug grün
gesehen, damit ein roter Fall der Fall-Mutation zurechenbar ist. Der Preis wächst je Fall mit
Suite und Fall-Bestand (gemessen 10–40 min je Fall, [harness/sensors/mutate.md](../../../harness/sensors/mutate.md)) —
690+ bats-Fälle und 9 Pakete je Kopie, davon misst der Fall selbst fast nie den größten Teil.
Daneben leckt die Treiber-Eigene-Umgebung in den Vorzug: `MUTATE_CASES` erreicht das
verschachtelte `make test-bats` und bricht an `test/mutate-driver.bats` (Fall `greift_main`),
gemessen zweimal (`BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf`, Zähler 2). Mit den
committed je-Check-Keys ([ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
Festlegungen 1/2) ist dieselbe Attributionsleistung schärfer und billiger lesbar: der Fall
verändert genau die Tafel-Mengen, die seine Zieldateien tragen, und ein Vergleich Frisch-Rechnung
über der Kopie gegen den committeten Satz nennt genau die Checks, die das messen.

## Entscheidung

Wir wählen: **Der Grün-Vorlauf fährt je Drift-Fächer der Tafel statt voll — in zwei Zügen:
ein Vorzug über der unmutierten Kopie und je Fall ein Fall-Fächer post mutationem; der
Voll-Suite-Zug entfällt.** Sechs Festlegungen:

**1. Der Vorlauf je Drift-Fächern, in zwei Zügen.** Ein Vorzug rechnet je Check der Kante
(`record-gates: environment-check … span-check`, [harness/tools/gates-keys.sh](../../../harness/tools/gates-keys.sh)
Modus `key`) den Frisch-Wert über der UNmutierten Isolationskopie und vergleicht gegen den
committeten Satz je Form von [ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
Festlegung 2 (Fehlen, Unformalität, Satzerzeuger-Fehler zählen als Drift, fail-closed
[`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)).
Die Checks, die dort schon driftet haben, fahren im Vorzug — rot dort bricht den Lauf ab,
BEVOR die erste Mutation läuft: das ist die Attributions-Zusage, sie hat jetzt genau ihre
Trägermenge (ein Check, dessen Inhalt seit dem letzten grünen Stempel ungedeckt ist, ist
vorangehend ungemessen). Je Fall wendet der Fall-Fächer die Fall-Fassung an der Kopie an
(Bedingungen 1–2 von `run_case` unverändert), rechnet dieselben Keys frisch über der Kopie und
fährt nur die gedrifteten Checks. Die Voll-Suite-Fassung — `make test-bats` und `make test-go`
ganz, je Worker je Modus — entfällt mit dem Wechsel. Die Fächer-Breite folgt der Tafel, nicht
der Fall-Menge: ein Fall mit `# files: Makefile` dreht jede Tafel und zahlt die volle Kante —
die fail-closed-Richtung, bezahlt in Minuten statt in Behauptungen
([ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Festlegung 3-Form).

**2. Das Leack entfällt mit — vollständig erst mit dem env-Auszug.** Der verschachtelte
Voll-Suite-Zug entfällt, erreicht wird er von `MUTATE_CASES` nicht mehr. Was von der
Leack-Klasse übrig bliebe, ist der Fall-Fächer über drifted `test` — darum zieht JE
Check-Zug des Treibers einen env-Auszug nach sich: `env -u` über jede Treiber-eigene
Lauf-Variable (`MUTATE_CASES`, `MUTATE_FORCE`, `MUTATE_JOBS`, `MUTATE_STALL_SECONDS`) an jedem
inneren `make <check>`. Die Beobachtung `BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf`
entfällt am Vorlauf-Wechsel — geschlossen erst durch diesen Auszug, sonst erhielt dieselbe
Befund-Klasse einen neuen Ort. Der Slice mit der Kennung `slice-mutate-cases-leakt-nicht-am-teillauf`
(die Kennung, nicht der Pfad — §3.11 [`AGENTS.md`](../../../AGENTS.md)) ist damit gegenstandslos;
sein Ausgang steht in Festlegung 6.

**3. Die Wächter des Fall-Zugs bleiben.** `run_case` trägt Bedingung 3 und 4 unverändert am
benannten Wächter — der Fall-Sensor (aus der `# verify:`-Zeile, sonst `narrow_sensor`) läuft wie
heute und trägt die Rot-Erwartung samt Fehlschlag-Form. Unter den übrigen gedrifteten Checks
trägt nur der Fall-Sensor die Rot-Erwartung: rot an einem unbenannten gedrifteten Check ist ein
BEFUND des Falls — die Mutation trifft mehr, als ihre Zusage trägt. Einen Check fährt der Zug
einmal; überlappt der Fall-Sensor als Kante-Check (`test`, `ci-lint`, `shell-lint`) mit dem
Fächer, ist der Fall-Zug derselbe Lauf. Die fünf fail-closed-Bedingungen, der Lock, die
Isolation und die Vollständigkeits-Zusagen des Treibers bleiben unverändert; die
Umgebungs-Vorbedingung (Inventar-Check, Docker-Abfrage je `full-smoke`-Fall) bleibt vor der
ersten Kopie.

**4. Kein Stempel-Schreiber am Mutations-Zug.** Die Mutations-Züge rechnen die Keys lesend;
kein Lauf schreibt `.harness/state/gates-passed-<check>.key` — die Schreiber-Kette von
[ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Festlegung 5 (`record-gates`,
`gates-fast`, `full-smoke`) trägt weiter allein. Der Beleg-Slot
([ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)) bleibt wie er ist:
ein voller Lauf schreibt ihn nach dem Bericht, ein Teillauf nie. Der CI-Vollsweep (`mutate.yml`,
je Shard seine `MUTATE_CASES`) fährt unverändert die volle Fall-Menge — die Verengung trifft den
Vorlauf, nicht die Fall-Deckung
([ADR-0107](0107-die-mutations-record-granularitaet-ist-je-fall.md)).

**5. Die Abwägung: die Zusicherung verengt sich, und ihre Lücke steht benannt.** Der Vorzug
zusagte bisher „der ganze Baum war vor der Mutation grün"; er sagt jetzt „die Checks, deren
Tafeln der Fall trägt, und die Checks, deren Stempel schon stie, waren grün". Was nicht driften
kann, misst die Treiber nichts mehr: ein Fall-Skript, das außer seinen `# files:`-Zeilen schreibt
(falsch gelistete Anlage —
[`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand),
[`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)),
trifft in der Kopie Tafeln ohne Fächer, und der Treiber sieht es nicht — **ein Wächter
existiert nicht** für diesen Rest; sein Träger ist die Anlagen-Disziplin je Fall und der
Bedingung-2-Vergleich von `run_case` für die gelisteten Dateien. Ebenso ungemessen bleibt aus
`MENGE_REST` ([ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
Festlegung 2-Form), was kein Check der Kante urteilt — kein SKIP/Fächer behauptet über ihn ein
Urteil, dieselbe Grenze wie beim Fast-Pfad.

**6. Konsum-Skizze, Kennung `slice-mutate-vorlauf-je-driftfaecher-v1`.** Drei Liefer-Punkte,
eine Schicht (Harness-Mechanik): (a) der Treiber-Zug je Form in
[harness/tools/mutate.sh](../../../harness/tools/mutate.sh) — Vorzug über der unmutierten Kopie,
Fall-Fächer post mutationem, env-Auszug je Check-Zug; (b) die Wächter — hermetische bats-Züge
über Fixture (`--wurzel`) für die Fächer-Klassifikation und den Vorzug-Abbruch, dazu
Mutations-Fälle mit Nummern nach dem Bestand je
[`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit):
die Fächer-Rechnung fällt still weg → Wächter rot am Treiber, der Vorzug fällt still weg → rot,
der env-Auszug entfällt → der bestehende Leack-Wächter rot; (c) der Ausgang des Leack-Slices
`slice-mutate-cases-leakt-nicht-am-teillauf` — §7 trägt `Gegenstand: entfallen:` mit dem Grund
aus Festlegung 2, der `git mv` folgt dem Lifecycle (Modul 5) und ist Planner-Arbeit je
[`AGENTS.md`](../../../AGENTS.md) §3.10 (Closure mit Risiko-Ausgängen), nicht die Implementation
dieses Slice.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun (Vorlauf voll je Fall) | die Zusicherung über den ganzen Baum, keine Anlagen-Voraussetzung | 10–40 min je Fall, wachsend je Suite und Fall-Bestand; das Leack bleibt am Vorzug (Zähler 2, wiederkehrend); gemessen ist der Preis an `report_times` |
| B — Vorlauf nur auf der Stufe des Falls (`test-bats` statt beider Ströme) | halbe Kosten, gleiche Zusicherungs-Form | deckt nur den Fall-Modus, nicht die übrigen Tafeln — dieselbe Verengung, weniger Nutzen; der Preis bleibt Suite-Nähe je Fall; das Leack bleibt strukturell |
| C — Fall-Fächer ohne jeden Vorzug | kleinste Laufzeit | die Attributions-Leistung verliert ihren Träger: vorangehend rot lief als Fall-Befund aus dem falschen Grund — die F-6-Fassung kehrt leise zurück; der Vorzug über der unmutierten Kopie ist in der gewählten Form meist leer und kostet sonst exakt das, was die Vollform kostete |
| **D — Vorzug über der unmutierten Kopie je Drift, Fall-Fächer post mutationem, env-Auszug (gewählt)** | derselbe Satzerzeuger wie der Fast-Pfad, kein zweiter Maßstab; Attributionsleistung aus ihrer Trägermenge statt aus Baumbreite; das Leack entfällt am Ort und nicht latent; Fall-Läufe sinken an Sekunden-Nähe | ein Stale-Key-Zug kostet den vollen Check (fail-closed Richtung — Minuten statt Stunden); ein Fall am `Makefile` dreht die ganze Kante; der ungelistete Schreibzug eines Falls bleibt ungemessen (Festlegung 5, Träger: Anlagen-Disziplin) |

## Konsequenzen

- Positiv: Fall-Läufe sinken von Stunden auf Minuten — der Treiber fährt die Fächer über
  Tafel-Mengen (Sekunden) und den Fall-Sensor; `report_times` misst den Kurs weiter und nennt
  ihn statt ihn als Zahl hier zu behaupten. Ein Mechanismus, keine zweite Drift-Definition:
  [ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md) Tafel-Mengen,
  [ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Frisch-Rechnung.
- Negativ: Die Vorlauf-Zusicherung verengt sich vom ganzen Baum auf die Drift-Fächer. Der Rest
  steht in Festlegung 5 — ungelisteter Schreibzug und `MENGE_REST`-Klassen — mit ihrem Träger,
  nicht als stilles Grün.
- Negativ: Die Fächer-Breite hängt am Stempel-Altbestand — ein forget-getrackter
  Stempel-Nachzug fährt im Vorzug genau die volle Kante. Die fail-closed-Richtung bezahlt das
  in Minuten, nicht in Behauptungen
  ([ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Festlegung 2-Form).
- **Kein Eintrag im Adaptions-Block**, nach der Lesart von
  [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage): die Baseline kennt
  keinen Mutations-Treiber (`grep -rl 'make mutate' .harness/baseline/v7.0.0/regelwerk/ |
  wc -l` → 0) — von dem abgewichen werden könnte; diese ADR legt die Form erst.

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| bats, `test/mutate-driver.bats` (hermetisch über Fixture, Form `mutate-driver.bats` heute) | **Happy:** Fall, dessen `# files:` genau die Tafeln von genau einem Kante-Check neben dem Fall-Sensor tragen → der Fall-Zug fährt genau diese Menge, Bericht nennt sie; committeter Key fehlt · unformal · Satzerzeuger-Fehler → der Check fährt (fail-closed). **Negative:** der Vorzug liest keinen committeten Key → er fährt nichts (stille Leerform, [`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)); vorangehend rot → Abbruch vor der ersten Mutation, kein Fall-Urteil; rot am unbenannten gedrifteten Check → Fall-BEFUND. **Boundary:** ein Fall am `Makefile` dreht die ganze Kante; jeder Check-Zug läuft mit env-Auszug — keine Treiber-eigene Variable erreicht das innere `make`. Der **rot-Beleg** steht erst im Konsum-Zug (Festlegung 6): jede Klasse am realen Treiber nach [`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit) gebrochen, nicht an einer Fixture-Fassung desselben Werts | `make test` (nicht in `make gates`) |
| Mutations-Fälle, `test/mutations/` (drei neu, Nummern nach dem Bestand, Festlegung 6) | (a) die Fächer-Rechnung fällt im Treiber still weg (Vollauf leise) → Wächter rot am benannten Grund; (b) der Vorzug fällt still weg (kein Abbruch vor der ersten Mutation) → rot; (c) der env-Auszug entfällt → der bestehende Leack-Wächter in `test/mutate-driver.bats` rot | [`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand), [`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit), `make mutate-auswahl` |

**Was hier nicht behauptet wird:** der Rot-Beleg steht nicht in dieser ADR — die Wächter
entstehen erst im Konsum-Zug, und das Einweihungs-Kriterium des Slices misst die drei Klassen am
realen Treiber ([`AGENTS.md`](../../../AGENTS.md) §3.6). Was **kein Wächter hält**: dass der
Treiber die committeten Keys vom Host liest statt von der Kopie — die Keys rotieren mit dem
Stempel-Commit und reisen mit dem Klon
([ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Festlegung 1), ihre Lesung
ist Teil des Satzerzeuger-Aufrufs; und dass die Fall-Sets vollständig gelistete Anlagen tragen
(Festlegung 5) — Träger ist die Anlagen-Disziplin je Fall.

## Re-Evaluierungs-Trigger

Nicht permanent. Vier beobachtbare Bedingungen, jede einzeln auslösend:

1. **Die Kante ändert sich** (ein Check tritt in `record-gates:` ein oder aus, oder die
   Tafel-Lesung ändert sich) — dann ist die Fächer-Zuordnung je Check neu zu zeigen, **bevor**
   der Treiber weiter fährt; Form der
   [ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Trigger 2.
2. **Eine Fall-Anlage mutiert außerhalb ihrer `# files:`-Deckung** — gemessen an einem
   Fall-Skript, das in der Kopie Tafeln ohne Fächer trifft (beobachtbar an divergierenden
   Kopie- und Host-Fingerabdrücken über `# files:` hinaus) — dann ist die Anlage neu
   geschnitten und die Lücke in ihr benannt
   ([`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
3. **Der Stempel-Altbestand dreht die Fächer voll wieder** — `report_times` misst über den
   Vorzügen einen Kurs, der die Vollform erreicht — dann ist der Preis der Attributions-Leistung
   neu zu wägen, im Extremfall per Folge-ADR mit `Supersedes ADR-0114`.
4. **Der emittierte Baum oder ein Adopter-Target bekommt die Mutations-Treiber-Form** — eigene
   Entscheidung mit eigener Deckungs-Messung, einzeln entschieden
   ([ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 5-Form; Form der
   [ADR-0108](0108-stempel-synthese-je-check-pruefgegenstand.md) Trigger 4).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-28 | **Accepted** | Architektur-Übergabe-Artefakt auf die Auftraggeber-Entscheidung
(*„der Mutations-Treiber fährt den Grün-Vorlauf je Drift-Fächer der Tafel statt der vollen Suite
je Fall"*); Annahme durch den Auftraggeber am 2026-11-28. Die Abweichung vom Auftragsentwurf
steht am Kopf von Festlegung 1: der Vorzug über der unmutierten Kopie trägt die
Attributions-Leistung, die im reinen Fall-Fächer (Alternative C) ihren Träger verlöre — dieselbe
Zwei-Züge-Form wie der Fast-Pfad, an der Trägermenge gemessen |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0114` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
