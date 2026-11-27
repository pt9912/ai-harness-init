# ADR-0109: Gates und Lab-Läufer laufen docker-los am Host — der gepinnte Image-Weg bleibt opt-in

**Status:** Accepted

**Datum:** 2026-11-27

**Autor:** pt9912

**Bezug:** [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (docker ist Weg, keine Pflicht — vertraglich durch CR 0.28.0/0.28.1, [`§7 Historie`](../../../spec/lastenheft.md#7-historie)), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Pin-Disziplin je Weg), [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (je Gate-Weg die dortige Werkzeug-Form), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate ohne Träger), [ADR-0003](0003-go-native-binaries.md) (Tool-Build bleibt docker-getrieben), [ADR-0004](0004-durchsetzung-emission.md) (durchgesetzte Emission bleibt)

**Schärft:** [architecture.md §3 Externe Abhängigkeiten](../../../spec/architecture.md) — `ARC-012` (docker) wird von einer unbedingten Abhängigkeit zu einer wegwahl-abhängigen: der Gate-Anteil der Zeile läuft am Host ohne Docker-Daemon, der Tool-Build-Anteil bleibt im gepinnten Image. Aufwärts-Deklaration der Änderungskopplung: wer diese ADR ändert, zieht `ARC-012` und [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) nach.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR) ·
`modul-14-docker-harness.md` §Der zweite Träger: Tool-Pin und Tool-/Versions-Check.

---

## Kontext

Der Auftraggeber hat am 2026-11-27 entschieden: Der Docker-Daemon bleibt für
den Betrieb dieses Repos aus. Vertragsseitig trägt das der CR des Lastenhefts
(0.28.0 Grundsatz, 0.28.1 Folgestellen — [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)-Form):
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
nennt `docker` als **Weg, keine Pflicht**, [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
trägt die Pin-Disziplin je Weg, [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
die Werkzeug-Form je Gate-Weg. Diese ADR trifft die Architektur-Festlegung
dazu, die der CR als Ziel-Bild offen gelassen hat (Soll-Form, Inventar,
`pinsync`).

An dieser Entscheidung hängen zwei Grenzen, die sie nicht auflöst:

- Der **Tool-Build (Release) bleibt docker-getrieben**
  ([ADR-0003](0003-go-native-binaries.md) unangetastet): Cross-Compile im
  gepinnten Build-Image, kein Host-`go` — CI-Runner tragen Docker.
- Die **Mechanik des docker-los Wegs** (Inventar-Datei, Tool-/Versions-Check
  als erster Check der Gates, Host-Rezepte der Lab-Läufer, Workflow-Umbau)
  schreibt die Implementation; diese ADR legt nur Form und Begriffe fest —
  **Tool-Pin, Inventar, Mischform, `pinsync`, erster Check**. Bis sie liegt,
  fahren die gepinnten Image-Rezepte weiter (Übergangs-Satz des CR).
  Ein lokaler `make gates`-Nachweis dieser ADR ist heute nicht herstellbar
  (Daemon aus); er folgt mit der Umstellung, der CI-Nachweis mit der Heilung
  der vorgefundenen CI-Störstellen.

Die Umgebungs-Zusage des Dogfood trägt seither keinen **feststellenden**
Träger: Der Docker-only-Deckel adressiert die Umgebung über die gepinnten
Image-Digests, aber ein Host-Lauf — genau der Weg, der laufen soll — bleibt
unbelegt. Baseline-Regelwerk `modul-14-docker-harness.md` §Der zweite Träger
stellt für genau diese Lage die Wahl frei: Docker oder Tool-Pin + Check, mit
`pin legt fest, Check belegt` als Soll-Form-Raster.

## Entscheidung

Wir wählen: **die Dogfood-Gates und Lab-Läufer fahren docker-los am Host als
Pflicht-Weg; der gepinnte Image-Weg bleibt als opt-in Weg gepinnt und
ungestrichen.** Je Festlegung:

**1. Weg-Form.** Docker-los ist der Pflicht-Pfad von `make gates` und der
Lab-Läufer (mutate-Fächer, smoke/full-smoke, CI-Jobs). Die gepinnten
Image-Pfade werden nicht gestrichen — sie bleiben der opt-in Weg für Läufe,
die den Image-Vertrag prüfen wollen ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
trägt **beide** Wege: Reproduzierbarkeit über Image-Digest bzw. über
Inventar-Pin mit Prüfsumme).

**2. Soll-Form der Umgebungs-Zusage: Mischform.** Nach Baseline-Regelwerk
`modul-14-docker-harness.md` §Woher das Soll kommt leitet die Inventar das
Soll **ab, wo eine maschinen-lesbare Pin-Stelle existiert** (die
`GO_VERSION`-Stelle, die Image-Digests), und trägt es **im Manifest je
Werkzeug ohne Pin-Stelle**. Der Tool-/Versions-Check ist **feststellend** —
Pin legt fest, Check belegt; wo Docker nicht trägt (der docker-los Weg am
Host), ist der Check **selbst der Träger**. Er steht als **erster Check in
`make gates`** — ein Rot dort ist ein Umgebungs-Befund, kein Code-Befund.
Der d-check-Stellen-Abgleich (Modul `pinsync`) hält Manifest gegen
Pin-Stellen. Die je-Werkzeug-Zuweisung steht im Adaptions-Eintrag
([`MR-098`](../../../harness/conventions.md#mr-098--die-umgebungs-zusage-trägt-mischform-die-dogfood-gates-und-lab-läufer-fahren-am-host));
die Inventar-Datei und das Check-Skript schreibt die Implementation.

**3. Ausführungsort.** Host und CI-Runner — der Lauf läuft da, wo seine
Werkzeuge laufen ([`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix):
je Gate-Weg die dortige Werkzeug-Form). Der Docker-los Weg führt keinen
zweiten Kontext-Lauf im Image mit: dem Image-Weg wird der Digest für sein
Inneres vertraut, die zugehörige Lücke (adressiert, nicht verglichen) steht
benannt in [`MR-098`](../../../harness/conventions.md#mr-098--die-umgebungs-zusage-trägt-mischform-die-dogfood-gates-und-lab-läufer-fahren-am-host).
Der Host-Bedarf ist die GNU-Werkzeuge-Annahme auf Linux — die bestehende
Plattform-Grenze (macOS für die Host-Läufer nicht getragen) bleibt mit ihrem
Auflösungs-Trigger unverändert und wird in der neuen §3.9-Fassung bewusst
benannt, nicht eingelöst.

**4. Release-Bau unverändert.** Der Release-Bau bleibt docker-getrieben
([ADR-0003](0003-go-native-binaries.md)): Tool-Build im gepinnten Image, kein
Host-`go` — [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
trägt das unverändert. Die zwei Wege leben nebeneinander: einer ist Pflicht,
der andere opt-in.

**5. §3.9-Anpassung.** `AGENTS.md` §3.9 trägt die neue Fassung: die
Dogfood-Läufer laufen host-native, docker ist Werkzeug-Weg, nicht Gate-Pflicht;
die Befehlspositions-Frage bleibt — direkte Host-Toolchain-Position verboten,
Rezepte laufen über `make`, der PreToolUse-Guard bleibt Stolperdraht
(Befehlsposition) — und der Absatz zur Umgebungs-Zusage wird umgeschrieben
(der Träger kehrt zurück; die vorige Abwägung, die `harness/sensors/environment-check.md`
im Dogfood trägerfrei ließ, wird als **überholt** benannt, nicht gelöscht).

**6. Adaptions-Eintrag als eine Datei.** Die Soll-Form-Wahl und der
Ausführungsort stehen in **einem** Adaptions-Eintrag
([`MR-098`](../../../harness/conventions.md#mr-098--die-umgebungs-zusage-trägt-mischform-die-dogfood-gates-und-lab-läufer-fahren-am-host)),
weil das Baseline-Regelwerk die Ausführungsort-Wahl ausdrücklich *in dieselbe
MR* bindet („das Repo deklariert seine Wahl in derselben `MR-<NNN>`") — der
Anlass-Plan sah zwei Einträge à Adaption vor; zusammengelegt, mit der
Abweichung im Eintrag benannt.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nur Image-Weg (Status quo) | keine Umstellung; die gepinnte Umgebung ist identisch mit dem Tool-Build-Image; der Image-Digest adressiert jede Toolchain | läuft auf keinem Betrieb des Repos mehr — der Daemon bleibt aus; ein Carveout darüber wäre dauerhaft und trägt nie, weil sein Auslöser fehlt; [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) nennt den docker-los Weg vertraglich ausdrücklich |
| B — nur Host-Weg (Image-Pfade streichen) | eine Weg-Form, keine doppelte Pin-Disziplin | vernichtet einen gepinnten, andressierbaren Träger, den Tool-Pins nicht ersetzen (Archiv- gegen Rezept-Form des Belegs, Baseline-Regelwerk `modul-14-docker-harness.md` §Zwei Formen des Belegs); widerspräche [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), der beide Wege trägt, und ließe den docker-getriebenen Tool-Bau von [ADR-0003](0003-go-native-binaries.md) ohne seinen Zwillings-Weg |
| C — beide Wege offen, keine Weg-Form-Pflicht | nichts geschieht | „Pflicht" bliebe beim Docker-Deckel, der nicht läuft — Gates nur per Carveout; die vertragliche Entscheidung (CR 0.28.0/0.28.1) bliebe unbefolgt, und zwei Pflicht-würdige Wege ohne beschließenden Zug duplizieren die Pin-Disziplin ohne Träger |
| **D — docker-los Pflicht-Weg, Image-Weg opt-in, Mischform-Soll (gewählt)** | läuft auf dem beschlossenen Betrieb; der Image-Weg bleibt für Image-Vertrags-Prüfung erhalten; die Umgebungs-Zusage bekommt einen ausführenden Träger (Inventar + Check), der am Host fehlte; ein ADR-Punkt je Frage (Weg, Soll, Ort, Bau, Norm) | ein zweites Pin-System neben den Image-Digests — Drift zwischen den Stellen, getragen vom Stellen-Abgleich (`pinsync`); der Host-Lauf ist nicht isoliert; die Mechanik ist noch nicht da — der Nachweis folgt, er existiert nicht im Bestand dieser ADR |

## Konsequenzen

- Positiv: Gates und Lab-Läufer laufen auf dem beschlossenen Betrieb (Host,
  CI-Runner ohne Daemon); die Umgebungs-Zusage bekommt einen Träger, der
  feststellt statt andressiert; der opt-in Image-Weg bleibt für die
  Image-Vertrags-Seite von [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
  gepinnt.
- Negativ: ein Inventar neben den Image-Digests — die zweite Quelle ist
  bewusst: der Stellen-Abgleich (Modul `pinsync`) hält Manifest gegen
  Pin-Stellen, ohne ihn driften beide. Der Host-Lauf ist nicht isoliert
  (keine Dateisystem-Grenze wie im Container). Ein unbelegter Host-Lauf bleibt
  private Information — der Check ist die Bedingung des Laufs, nicht der
  Nachweis hinterher.
- Folgepflicht — **Folgestellen des Lastenhefts, hier benannt, nicht gelöst**:
  die vier Superset-Sätze nennen `bash + git + docker` als geschlossene
  Abhängigkeits-Menge — [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)
  („Das emittierte Repo braucht über `bash + git + docker` hinaus nichts"),
  [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
  („das Zielrepo bleibt über `bash + git + docker` geschlossen"),
  [`LH-FA-11`](../../../spec/lastenheft.md#lh-fa-11--selbstprüfung-der-durchsetzungsschicht-emittieren)
  („über `git + docker` braucht es nichts"), [`LH-FA-12`](../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren)
  („über `bash + git + docker` braucht er nichts"). Sie sind `LH-*`-Setzungen
  und ändern sich **nur per CR** ([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler));
  bis dahin lesen sie außen-stehend als `git + docker`-Fassung. Hier ist keine
  CR-Zeile angelegt — Übergabe an die Planung des Umbaus.
- Folgepflicht — **weitere Folgestellen** mit eigenem Träger:
  [architecture.md §3](../../../spec/architecture.md) `ARC-012` (docker
  „substituierbar: nein" — fortschreibbar ohne CR, Träger ist das Doku-Update
  der Mechanik; `ARC-013` bleibt unverändert stimmt) und die Sicht-Doku, die
  die alte §3.9-Fassung zitiert (z. B. `harness/sensors/mutate.md` zum
  Host-Bedarf „git, docker und GNU make") — fort-treibbar, ohne CR.
- Die Implementation trägt den rot-sehenden Nachweis: Inventar, Check mit
  Break-Test, Host-Rezepte, Workflow-Umbau — ohne ihn ist die Weg-Form dieser
  ADR eine Setzung ohne Beleg; der lokale `make gates`-Lauf dieser ADR ist
  heute nicht herstellbar und steht offen.

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check-Modul `pinsync` | die Pin-Paarung der Inventar-Soll-Stellen gegen ihre Pin-Quellen (byte-genau) | `make docs-check` *(Paarung entsteht mit der Inventar-Anbindung)* |

**Lücke, mit Grund:** kein Bestand-Sensor hält heute die Weg-Form dieser ADR —
die Inventar-Anbindung, der Break-Test des Checks und der Host-`make gates`-Lauf
entstehen mit der Implementation; ein `make environment-check`-Target existiert
deshalb hier **nicht** (ein benanntes wäre [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
eine Ebene tiefer). Der rot-sehende Nachweis ist Übergabe, nicht Bestand.

## Re-Evaluierungs-Trigger

- Der Image-Weg verliert seinen letzten Standort — kein Target und kein
  CI-Job fährt ihn mehr — dann streichen über Folge-ADR.
- Die Inventar-Prüfform trägt an einem Werkzeug kein tragfähiges Soll (etwa:
  keine versionierbare Prüfform, keine Fähigkeitsprobe) — dann Carveout oder
  Neuzuschnitt, zurück zur Abwägung dieser ADR.
- Eine macOS-CI hält die Host-Läufer — dann entfällt die GNU-Werkzeuge-Grenze
  der Ausführungsort-Festlegung (bestehender Auflösungs-Trigger der §3.9-Fassung).
- Sonst: permanent.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-27 | Proposed | [slice-adr-gates-laeufen-host-native](../../plan/planning/in-progress/slice-adr-gates-laeufen-host-native.md) |
| 2026-11-27 | Accepted — der Auftraggeber-Beschluss trägt die Entscheidung (CR 0.28.0/0.28.1 des Lastenhefts); keine Proposed-Review-Runde | [slice-adr-gates-laeufen-host-native](../../plan/planning/in-progress/slice-adr-gates-laeufen-host-native.md) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0109` (Baseline-Regelwerk `modul-04-adrs.md` §Hard Rule für
Accepted-ADRs).
