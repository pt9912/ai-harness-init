# Verifikation — slice-das-ziel-prueft-seine-durchsetzung-selbst

**Rolle:** Verifier (Modul 11) · **Datum:** 2026-09-18 · **Kontext:** frisch, hat die Umsetzung
nicht geschrieben.

**Frage dieser Rolle:** *Bauen wir es richtig?* — gegen DoD, Spec und Plan. Nicht gegen den Diff
(Reviewer), nicht gegen den realen Bedarf (Validator).

**Eingang:** DoD-Bestätigung des Implementers plus Sensor-Belege. **Prüfstand:** `4cae6da3`,
Umsetzung in `2bda848a`, `a40fe473`, `2d973c6f`, `18aa8b99`, `afa40616`. Die drei Review-Reports
sind **nicht** Grundlage dieser Prüfung.

**Verdikt gesamt: DoD erfüllt.** Alle drei Liefer-Punkte bestätigt, alle sieben
Akzeptanzkriterien von `LH-FA-11` gehen in ihnen auf, keine Verletzung der Abgrenzung in §1,
keine ADR-/MR-/Hard-Rule-Abweichung. Fünf Befunde, keiner blockierend — zwei davon sind
Übergaben an den Planner für die Closure.

---

## 1. Was ich selbst gefahren habe

Behauptung ohne Bestätigung ist die Verifier-Lücke; darum steht hier, was **in diesem Lauf**
lief, nicht was der Bericht sagt.

| Lauf | Ergebnis |
|---|---|
| `make gates` (eigenes Repo) | **EXIT 0**, `d-check: 1669 Datei(en) geprüft, 0 Befund(e)` |
| `make full-smoke` (eigenes Repo, unmutiert) | **EXIT 0**, Stufe 17 gefahren |
| Bootstrap sprachlos + `make selbstpruefung` im Ziel | **EXIT 0**, beide Ausgänge in einem Lauf |
| Bootstrap `--lang go` + `make selbstpruefung` im Ziel | **EXIT 0**, beide Ausgänge in einem Lauf |
| Fünf Marker einzeln gesetzt (M1–M5) | jeder lenkt den Lauf, je eigene Meldung |
| Vorgabe-Ort `harness/mk/vorgaben.mk` + erneuter Bootstrap | überlebt und lenkt |
| Mutations-Fall `370` über `make full-smoke` | **EXIT 2**, rot aus dem behaupteten Grund |
| Mutations-Fall `371` über `make full-smoke` | **EXIT 2**, rot aus dem behaupteten Grund |
| Repo ohne Commit / kein git-Repo | je Exit 1 mit benanntem Grund, kein Ausrutschen |

Alle Ziel-Bootstraps liegen im Scratchpad dieses Laufs, nicht im Arbeitsbaum. Der Arbeitsbaum
war vor und nach den Läufen sauber (`git status --porcelain` leer); geändert habe ich allein
diese Datei.

---

## 2. Verdikt je DoD-Punkt

### (1) Die Selbstprüfung liegt im Ziel, ist über dessen `make` fahrbar und ist kein Gate — **erfüllt**

Gegen den Wortlaut, Stück für Stück:

- **Ablage und Ausführungs-Bit.** In beiden gebootstrappten Zielen:
  `-rwxr-xr-x tools/harness/selbstpruefung.sh` und `-rw-r--r-- harness/mk/selbstpruefung.mk`.
  Das Bit ist real da, nicht nur im Go-Modus deklariert.
- **Über `make` des Ziels fahrbar.** `make selbstpruefung` läuft in beiden Zielen; das Ziel
  steht in `make help` als *„KEIN Gate"*. Eingebunden über den vorhandenen
  `include harness/mk/*.mk` — ich habe kein Edit am Aggregator gebraucht.
- **Kein Gate.** `make -n gates` nennt `selbstpruefung` in beiden Zielen **0×** (eigene
  Messung, nicht die des Laufs). Die Emitter-Stufe prüft dieselbe Kante und sichert die
  Vorbedingung vorher ab: über einer leeren Kette wäre *„steht nicht darin"* still grün, darum
  verlangt sie zuerst `record-gates.sh` in der gelesenen Kette.
- **Keine neue Abhängigkeit (`LH-QA-03`).** Befehlsposition der Vorlage, gemessen:
  `case chmod command commit echo exit fehler for git if printf set trap` — dazu inline
  `mktemp`, `sed`, `bash`, `make`. Kein Netz, kein Paketmanager, kein zweites Bild; die Suche
  nach Netz- und Paketmanager-Aufrufen in beiden Vorlagen ist leer.
- **Rot-Bedingung.** `make test` trägt sie über `internal/emit/selbstpruefung_test.go` (sieben
  Fälle: Ablage/Modus, Inventur + Klasse, keine Gate-Kette, Marker in beiden Dateien und sonst
  keiner, Fragment ruft den emittierten Ort, konvergentes Überschreiben, Vorgabe-Ort wird von
  keinem Lauf geschrieben) und über die zwei neuen Zeilen in `internal/emit/baumaussage_test.go`.
  In meinem `make gates`-Lauf EXIT 0 mitgelaufen.

### (2) Beide Ausgänge in einem Lauf — und die Marker sind adaptierbar — **erfüllt, über die Zusage hinaus**

Aus meinem eigenen Lauf im sprachlosen Ziel, in dieser Reihenfolge und in **einem** Lauf:

```
selbstpruefung: der frische Klon traegt lokal keinen core.hooksPath — der Traeger reist mit, seine Aktivierung nicht.
selbstpruefung: aktiviert — core.hooksPath=.githooks
selbstpruefung: in Betrieb ist [.githooks/commit-msg] — git ruft ihn als .githooks/commit-msg.
selbstpruefung: ROT — die Message [Selbstpruefung ohne Kennung] faellt am Traeger (Exit 1) und HEAD steht unveraendert.
selbstpruefung: GRUEN — die Message [Selbstpruefung mit Kennung LH-FA-01] geht durch, HEAD traegt: Selbstpruefung mit Kennung LH-FA-01
selbstpruefung: GATE — [make gates] im Klon ist Exit 0.
```

Dasselbe im `--lang go`-Ziel, dort mit der vollen Code-Gate-Kette im Klon. Die vom DoD
verlangten Schärfen stehen alle darin: der Leer-Zustand ist aus `git config --get --local`
gelesen (nicht aus einer Meldung), der rote Ausgang belegt **Exit ≠ 0 *und* unbewegten HEAD**,
der grüne belegt **Exit 0 *und* den Betreff von HEAD**.

**Adaptierbar — als Wirkung gemessen, nicht als Form.** Ich habe jeden der fünf Marker einzeln
gesetzt und den Ausgang gelesen:

| Marker gesetzt | Ausgang | Meldung trägt den Marker als Grund |
|---|---|---|
| `SELBSTPRUEFUNG_GATE='make baseline-verify'` | Exit 0 | Gate-Zeile nennt den gesetzten Wert, die Ausgabe trägt dessen Spur |
| `SELBSTPRUEFUNG_TRAEGER=Makefile` | Exit 2 | *„ist nicht der Traeger, den der Aktivierungsschritt in Betrieb nimmt"* |
| `SELBSTPRUEFUNG_AKTIVIERUNG=true` | Exit 2 | *„ist core.hooksPath im Klon weiter leer — der Schritt meldet Erfolg, ohne einen zu haben"* |
| `SELBSTPRUEFUNG_MSG_ROT='Falsch aber mit LH-FA-01'` | Exit 2 | *„geht durch — er sollte am Traeger … fallen"* |
| `SELBSTPRUEFUNG_MSG_GRUEN='Gruen ohne Kennung'` | Exit 2 | *„faellt am Traeger (Exit 1) — erwartet war ein Durchgang"* |

Die erste Zeile jedes Laufs nennt die **gesetzten** Werte, nicht die Defaults — auch das habe
ich gelesen, nicht übernommen.

**Der Vorgabe-Ort trägt.** Ich habe `harness/mk/vorgaben.mk` mit
`SELBSTPRUEFUNG_GATE = make baseline-verify` angelegt, den Bootstrap **erneut** über dasselbe
Ziel gefahren und danach gemessen: die Datei liegt noch da, die Vorgabe lenkt den Lauf, und
`tools/harness/selbstpruefung.sh` ist byte-gleich zur Template-Quelle — konvergent geheilt,
ohne die Vorgabe mitzunehmen. Das ist die Zusage, die beide Köpfe geben, und sie hält.

**Die Grenze steht im Kopf der Vorlage** (Abschnitt *DIE GRENZE*) und noch einmal in der
Schluss-Zeile jedes Laufs: `--no-verify`, Werkzeug-Commits, Aufrufformen außerhalb der
aktivierten Träger-Form, Anwesenheit statt Wahrheit der Kennung.

### (3) Der Emitter fährt sie einmal real, und ihr Rot ist gesehen — **erfüllt**

- `make full-smoke` in meinem eigenen Lauf: **EXIT 0**. Stufe 17 deklariert über
  `e2e_abdeckung "LH-FA-11 LH-FA-02"`, liest den Exit-Code **und** die Ausgabe, und belegt beide
  Commit-Ausgänge sowie zwei Spuren der Gate-Kette.
- `docs/user/e2e-abdeckung.md` trägt Stufe 17 mit beiden Kennungen. Der genannte Ort
  (`harness/tools/full-smoke.sh:2786`) löst auf — die Zeile ist der Anker der Stufe, dieselbe
  Konvention wie bei Stufe 16. Gehalten wird die Datei von `test/e2e-abdeckung.bats` in
  `make test`, das in meinem grünen `make gates` lief.
- **Zwei gelistete Mutations-Fälle, beide selbst gefahren und die Meldung gelesen.** Ich habe
  den Baum je außerhalb des Repos kopiert, die Mutation angewandt und `make full-smoke`
  gefahren:

  `370` (nimmt der Vorlage den fallenden Commit) → EXIT 2:
  > `full-smoke: FEHLER — sprachlos: die Selbstpruefung belegt den Ausgang 'selbstpruefung: ROT — die Message [' nicht …`

  `371` (nimmt der Vorlage den Gate-Marker) → EXIT 2:
  > `full-smoke: FEHLER — sprachlos: der Lauf mit gesetztem Gate-Marker traegt weiter die Spur 'Datei(en) geprüft' der Belegung — das Doku-Gate haengt allein in make gates, der gesetzte Wert hat den Lauf also nicht gelenkt, sondern nur danebengestanden …`

  Beide Meldungen nennen **den behaupteten Grund**, nicht irgendeinen Abbruch. Beide
  `# expect:`-Zeichenketten stehen als Teilstring in der `full-smoke: FEHLER`-Zeile, und genau
  darauf urteilt der Treiber (`failure_form` → `full-smoke: FEHLER`). `make mutate` würde beide
  als bewacht melden; das Urteil hängt damit nicht am Nacht-Job, und der Rot-Beleg aus
  `AGENTS.md` §3.6 liegt unabhängig davon vor.

### Untere DoD-Punkte

| Punkt | Verdikt |
|---|---|
| `make gates` grün; Arbeitsbaum sauber | **erfüllt** — eigener Lauf EXIT 0, Baum leer |
| `make full-smoke` Exit 0 gefahren | **erfüllt** — eigener Lauf EXIT 0 |
| Review durchgeführt, Report liegt vor | **erfüllt** — drei Runden unter `docs/reviews/` |
| Doku-Update entfällt für dieses Repo | **erfüllt und belegt** — `harness/README.md`, `harness/sensors/**` und `Makefile` sind im Diff **0×** berührt; es entsteht kein neues Repo-Target |
| Closure-Notiz · Register · Risiko-Ausgänge · drei Paarungen | **offen — Planner-Arbeit** (`AGENTS.md` §3.10); Belege dafür liefert Abschnitt 6 dieses Berichts |

---

## 3. Die sieben Akzeptanzkriterien von `LH-FA-11`

Gehen sie wirklich in den drei Liefer-Punkten auf? Ja — keines steht daneben, keines fällt
durch.

| AC | geht auf in | bestätigt durch |
|---|---|---|
| Happy Path | (1) + (2) | eigener Lauf in **zwei** Zielen, Exit 0, Träger aktiviert |
| Zähne — beide Ausgänge in einem Lauf | (2) | ROT und GRÜN in derselben Ausgabe, mit Exit-Code **und** HEAD-Lage; Fall `370` belegt, dass ein Lauf ohne den roten Ausgang auffliegt |
| Adaptierbar | (2) | fünf Marker, **Wirkung** je gemessen; Fall `371` belegt, dass ein bloß danebenstehender Marker auffliegt |
| Kein aus dem Nichts | (3) | Stufe 17 fährt die **real emittierte** Vorlage im real gebootstrappten Ziel |
| Minimal | (1) | Befehlsposition gemessen; kein Netz, kein Paketmanager |
| Messung im Emitter-Lauf | (3) | eigener `make full-smoke`-Lauf; die Stufe prüft zusätzlich vorab, dass das Ziel selbst keinen `core.hooksPath` trägt |
| Benannte Grenze | (2) | Kopf der Vorlage **und** Schluss-Zeile des Laufs |

Zwei Kriterien verdienen die ausdrückliche Bestätigung, um die der Auftrag bittet:

- **„beide Ausgänge in einem Lauf"** ist nicht nur behauptet, sondern strukturell erzwungen:
  eine Schleife `for fall in rot gruen` über *einem* Klon, mit HEAD-Vergleich auf beiden
  Seiten. Der gelistete Zahn `370` greift genau an dieser Schleife an und färbt die
  Emitter-Stufe rot — die Zusage hat ihr Gegenbeispiel.
- **„adaptierbar, nicht 1:1 hart"** ist als *Wirkung* belegt, nicht als *Form*. Das ist der
  Punkt, an dem Risiko 5 des Plans hing: eine Prüfung, die nur das Vorkommen der Variablen im
  Text sieht, wäre unter keiner Mutation rot geworden. Die Stufe liest stattdessen die **Spur**
  des gefahrenen Kommandos, und `371` beweist, dass diese Unterscheidung trägt.

Die Spec nennt als dritten Marker das *„Sprach-/Build-Modell"*; verkörpert ist er als
`SELBSTPRUEFUNG_GATE` — das Kommando, das im Klon grün laufen muss. Der Kopf sagt es so
(*„Ein Ziel mit anderem Bau- oder Sprachmodell setzt hier seines"*), und mein `--lang go`-Lauf
zeigt, dass die Default-Belegung auch ein Ziel mit Code-Gate-Kette trägt.

---

## 4. Plan gegen Code

**Geplant und nicht gebaut: nichts.** Alle neun Zeilen der §3-Tabelle sind geliefert.

**Gebaut und nicht geplant — vier Posten, alle additiv:**

1. **`test/mutations/371-selbstpruefung-ignoriert-den-gate-marker.sh`** — §3 plant *einen*
   Zahn (`370`). Der zweite deckt die Marker-Wirkung und damit die andere Hälfte von
   Liefer-Punkt (2). Ohne ihn hätte die Adaptierbarkeits-Zusage kein Gegenbeispiel.
2. **Fünf statt drei Marker** — `SELBSTPRUEFUNG_MSG_ROT` und `SELBSTPRUEFUNG_MSG_GRUEN` kommen
   hinzu. Sie sind nicht Kür: ein Adopter, der an `.githooks/commit-msg` seinen **eigenen**
   Träger führt — der Zustand, den `ADR-0054` Festlegung 1 ihm freistellt —, brächte eine
   eigene Kennungs-Menge mit, und die Prüfung fiele ohne diese zwei Marker konstruktionsbedingt.
3. **Ein benannter Vorgabe-Ort `harness/mk/vorgaben.mk`** samt Go-Zahn
   (`TestSelbstpruefung_DerGenannteVorgabeOrtWirdVonKeinemLaufGeschrieben`). §3 nennt die
   Konvergenz-Falle nur als Satz; hier ist die Antwort darauf gebaut und von mir gemessen.
4. **Ein eigenes, fünftes Bootstrap-Ziel (`tmprepo_selbst`) und drei Teil-Läufe der Stufe.**
   §3 plant *„eine neue Stufe"* auf dem bestehenden Ziel und *„einmal durchfahren"*. Real
   entsteht ein eigenes Ziel — begründet im Code: die übrigen Ziele tragen absichtliche Drift
   als geführte Zusage, ihr Klon wäre nie grün, und das Rot käme aus dem Fixture statt aus dem
   Prüfgegenstand. Und die Stufe ruft `make selbstpruefung` **dreimal** (Default,
   Gate-Marker, Träger-Marker).

**Verletzt etwas die Abgrenzung in §1? Nein.** Gemessen, nicht angenommen:

| Ausschluss | Befund |
|---|---|
| Jede Änderung an der Durchsetzungsschicht selbst | **gehalten** — `commit-msg-hook.sh`, `commit-msg-traceability.sh`, `hooks-install.mk`: 0 Dateien im Diff |
| Ein neues `make`-Ziel dieses Repos und die Prosa darüber | **gehalten** — `Makefile`, `harness/README.md`, `harness/sensors/**`: 0 im Diff |
| Der bestehende Abschnitt `COMMIT-KENNUNG IM ZIEL` | **gehalten** — in `harness/tools/full-smoke.sh` ist genau **eine** Zeile gelöscht (die `cleanup()`-Zeile, um das neue Ziel aufzunehmen), alles übrige additiv |
| Ein Vergleichs-Sensor zwischen Dogfood- und emittierter Fassung | **gehalten** — nicht gebaut |
| Die Emitter-seitige Messung des Aktivierungs-Rezepts | **teilweise berührt** — siehe Befund V-2 |

---

## 5. ADR-, MR- und Hard-Rule-Konformität

| Quelle | Verdikt | Beleg |
|---|---|---|
| `ADR-0007` (Idempotenz-Klassen) | **konform** | Die Klassen-Tabelle führt `tools/harness/*` und `harness/mk/*.mk` (tool-Fragmente) als **konvergent**; beide neuen Dateien sind so klassiert. Gemessen: nach erneutem Bootstrap ist die abgelegte Datei byte-gleich zur Vorlage |
| `ADR-0054` (skip-if-present-Träger) | **konform** | Der Träger `.githooks/commit-msg` ist unberührt; die Selbstprüfung **liest** ihn und ändert ihn nicht. Beide Köpfe sagen ausdrücklich, dass die skip-if-present-Klasse nicht abfärbt — sie hängt am Namen, den git fixiert, und den führt keine der zwei Dateien |
| `LH-FA-02` | **erfüllt** | Marker als Variablen mit Default-Belegung, Wirkung gemessen |
| `LH-QA-03` | **erfüllt** | `git`, `make`, coreutils; kein Netz, kein Paketmanager |
| `MR-005` | **konform** | Emittiertes Layout `tools/harness/`, nicht das lokal adaptierte `harness/tools/` — im Konstanten-Kommentar benannt |
| `MR-025` | **konform** | Keine freistehende Zahl ohne ihr Kommando in den neuen Dateien |
| `AGENTS.md` §3.2 | **konform** | Keine `shellcheck disable`, kein `//nolint` |
| `AGENTS.md` §3.5 | **konform** | Keine Gate-Config berührt (`.d-check.yml`, `d-check.mk`, golangci: 0 im Diff) |
| `AGENTS.md` §3.6 | **erfüllt** | Zwei gelistete Fälle, beide von mir rot gesehen, die Meldung gelesen und gegen den behaupteten Grund gehalten |
| `AGENTS.md` §3.7 | **konform** | Keine Befund-Kennung, keine Slice-Nummer, keine Chronik, kein Lauf-Protokoll in den Kommentaren der neuen Dateien |

---

## 6. Belege für die fünf Risiko-Ausgänge (§6) — an den Planner

Der Ausgang selbst ist Planner-Arbeit; hier steht, was ich dafür gemessen habe.

- **Risiko 1 — zwei Schreibende auf `harness/tools/full-smoke.sh`.**
  *Beleg für „entfallen":* Der Folge-Slice liegt weiter in `open/` und hat nicht geschrieben.
  Dieser Slice löscht in der Datei genau **eine** Zeile (`cleanup()`), alles übrige ist
  additiv — ein Nachzug für den zweiten Schreibenden fällt damit nicht an.
- **Risiko 2 — die Selbstprüfung fährt `make gates` im Klon, und das kostet.**
  *Beleg für „eingetreten":* Die Stufe fährt **drei** `make selbstpruefung`-Läufe, nicht einen.
  Gemildert ist es dadurch, dass die Stufe ein **sprachloses** Ziel benutzt — der Klon fährt
  dort das doku-only-Gate, den billigsten Vertreter der Kette. Mein eigener
  `make full-smoke`-Lauf endete trotzdem Exit 0. Im Adopter-Repo bleibt die Kosten-Frage offen:
  mein `--lang go`-Ziel fuhr im Klon die volle Code-Gate-Kette (Exit 0, aber deutlich teurer).
  Ein Ausgang *weiter offen* ins Register wäre die ehrliche Antwort; *entfallen* trüge nur mit
  der Begründung, dass die Emitter-Stufe das billigste Ziel wählt — für das Adopter-Repo gilt
  sie nicht.
- **Risiko 3 — der Zahn läuft nur nächtlich.**
  *Beleg für „eingetreten, aber entschärft":* Beide Fälle tragen `# verify: full-smoke` und
  laufen damit nur im Nacht-Job. Ich habe sie **in diesem Lauf** beide gefahren und ihr Rot
  gelesen; der Rot-Beleg aus DoD (3) liegt damit vor, unabhängig vom Nacht-Job. Die Lücke
  zwischen Landung und Nacht bleibt strukturell und ist keine Eigenschaft dieses Slice.
- **Risiko 4 — der Klon braucht eine Ausgangslage, die nicht jedes Ziel hat.**
  *Beleg für „entfallen":* Beide Fälle sind benannt statt ausgerutscht — selbst gefahren:
  Repo ohne Commit → Exit 1, *„traegt keinen Commit — … Ein erster Commit macht die Pruefung
  fahrbar."*; kein git-Repo → Exit 1, *„liegt in keinem git-Repo"*. Die im Plan genannte
  zweite Hälfte (`user.email`/`user.name`) ist **strukturell** entfallen: der Lauf bringt die
  Identität der zwei Commit-Versuche selbst mit (`git -c user.email … -c user.name …`).
- **Risiko 5 — der Marker-Nachweis misst die Form statt der Wirkung.**
  *Beleg für „entfallen":* Die Stufe misst die **Spur** des gefahrenen Kommandos, nicht die
  Ankündigungs-Zeile; der Mutations-Fall `371` fährt genau das Gegenbeispiel und färbt rot.
  Ich habe zusätzlich alle fünf Marker einzeln gefahren und je den Ausgang gelesen.

---

## 7. Befunde

| Kennung | Schwere | Befund |
|---|---|---|
| V-1 | LOW | **Plan-vs-Code-Delta.** Vier gebaute, in §3 nicht geplante Posten (zweiter Mutations-Fall, zwei zusätzliche Marker, Vorgabe-Ort, eigenes Bootstrap-Ziel mit drei Teil-Läufen). Alle additiv und innerhalb §1 — aber die Closure-Notiz §7 sollte sie unter *„Was ging anders als geplant"* führen, sonst ist der Plan im Nachhinein die schwächere Aussage. |
| V-2 | MEDIUM | **Ein §1-Ausschluss ist inhaltlich mitgeliefert.** §1 schließt *„der Nachweis, dass der Träger mit dem Klon reist und seine Aktivierung nicht"* aus und verweist ihn an `slice-aktivierung-reist-nicht-mit-dem-klon`. Die neue Stufe liefert ihn — an zwei Stellen: die Vorbedingung im Emitter-Lauf und die erste Ausgabezeile der Vorlage. **Kein Verstoß:** die Akzeptanzkriterien von `LH-FA-11` verlangen genau das (*„`core.hooksPath` ist **vor** der Aktivierung leer"*), und das Lastenheft steht auf Rang 1 gegenüber dem Slice-Plan. Der Ausschluss war zu weit gefasst. **Folge für den Planner:** DoD (1) des Folge-Slice (*„Der Klon-Weg ist gefahren — der Träger reist, seine Aktivierung nicht"*) ist teilweise vorweggenommen und beim `open → next` neu zuzuschneiden; sonst liefert er eine Zusage zum zweiten Mal. |
| V-3 | LOW | **„einmal durchfahren" gegen drei Läufe.** §3 und die AC *Messung im Emitter-Lauf* sprechen von *einmal*; die Stufe ruft `make selbstpruefung` dreimal. Keine Zusage ist gebrochen — *einmal* heißt dort *überhaupt real*, und DoD (2) verlangt den Marker-Lauf ausdrücklich. Aber Risiko 2 verdreifacht sich dadurch, und sein Ausgang sollte diese Zahl nennen statt einer geschätzten. |
| V-4 | INFO | **Zwei Zusicherungen hängen am Wortlaut fremder Werkzeug-Ausgaben.** `Integritaet + Vollstaendigkeit` (aus `baseline-verify`) und `Datei(en) geprüft` (aus d-check) tragen die Unterscheidung des Marker-Laufs. Ein Fassungs-Sprung eines der beiden Werkzeuge nimmt der Stufe die Zähne, **ohne sie rot zu färben**; kein Sensor liest, ob die zwei Zeichenketten noch entstehen. Die Stufe benennt diese Grenze selbst — das ist die richtige Form —, aber es ist ein Kandidat für das Beobachtungs-Register. |
| V-5 | INFO | **Kosmetik.** Der `e2e_abdeckung`-Aufruf der neuen Stufe ist als einziger tab-eingerückt. Das Rufmuster des Helpers (`^[[:space:]]*e2e_abdeckung "`) lässt es ausdrücklich zu; kein Defekt, nur uneinheitlich. |

**Kein HIGH.** Kein Befund hält die Closure auf; V-2 und V-3 sind Übergaben, die in die
Closure-Notiz und in die Risiko-Ausgänge gehören.

---

## 8. Was diese Verifikation *nicht* deckt

Damit das Grün oben nicht weiter gelesen wird, als es reicht:

- **`make mutate` selbst habe ich nicht gefahren** (ein Lauf über den gesamten Fall-Bestand
  kostet den Nacht-Job). Gefahren habe ich die zwei Fälle einzeln über denselben Sensor, den
  der Treiber benutzt, und ihre `# expect:`-Zeichenketten gegen die reale
  `full-smoke: FEHLER`-Zeile gehalten — das ist genau das Urteil, das der Treiber fällt, aber
  nicht sein Lauf. Dass **kein anderer** Fall durch diesen Slice seine Zähne verloren hat, ist
  damit nicht gemessen.
- **Nur zwei Sprachmodelle gefahren** — sprachlos und `--lang go`. Über `cpp` und die
  Schicht-Layouts sagt dieser Bericht nichts; `make full-smoke` fährt sie, aber nicht mit der
  Selbstprüfungs-Stufe.
- **Der Adopter-Fall „eigener Träger an `.githooks/commit-msg`"** ist konstruktiv vorgesehen
  (die zwei Message-Marker) und von mir über gesetzte Marker gegen den mitgelieferten Träger
  gemessen — **nicht** gegen einen real fremden Träger.
