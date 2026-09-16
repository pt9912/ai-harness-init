# `make full-smoke` — Voll-E2E-Smoke

## Vertrag

Bootstrap in ein tmp-Repo, dann dort der **zusammengeführte** `make gates`
([`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert): docs-check +
Go-Gates in einem Lauf) — der Happy-Path-Beweis
([`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)), dass ein frisch
gebootstrapptes Repo out-of-the-box grün fährt (die Nutzer-Sicht, die
[`make smoke`](smoke.md) mit seinen getrennten Schritten nicht nimmt). Host-Docker + ggf.
Netz-Pull → nicht in `make gates`; gehört an DoD-Verify/CI/Wellen-Closure.

### Deklaration der Stufen

Jede Stufe nennt an sich selbst, welche Anforderung sie trägt. Unmittelbar nach ihrer
Kopfzeile steht in `harness/tools/full-smoke.sh` ein Aufruf
`e2e_abdeckung "<Kennungen>" "<Kurzbeschreibung>" "<Anker>"`; das dritte Argument ist ein
wörtlicher Ausschnitt aus einer Zeile **dieser** Stufe. Der Aufruf läuft im E2E mit und
bricht ab, wenn sein Anker in der Region seiner Stufe nicht mehr wörtlich vorkommt — die
Stufe wurde dann umgebaut, und die Deklaration verlöre ihren Ort.

`make e2e-abdeckung` liest dieselben Aufrufe als **Text** — kein Docker, kein E2E-Lauf —
und schreibt daraus [`docs/user/e2e-abdeckung.md`](../../docs/user/e2e-abdeckung.md), die
Tabelle *Anforderung · Stufe · Ort · Kurzbeschreibung*. Beide Lücken-Richtungen fallen
dort laut aus: eine Deklaration, deren Anker in ihrer Stufe nicht auflöst, und eine
Stufe ohne Deklaration. Was die Deklaration **nicht** prüft, ist die Zuordnung selbst:
ob die genannte Anforderung noch zu ihrer Stufe gehört, bleibt ein Urteil, das der
Review hält — der Anker kann auflösen, während sich die Aussage der Stufe ändert.

**Die committete Tabelle hat einen Halter.** Ein Fall in
[`test/e2e-abdeckung.bats`](../../test/e2e-abdeckung.bats) fährt den Erzeuger über dem
geprüften Skript und hält sein Ergebnis **byte-gleich** gegen
[`docs/user/e2e-abdeckung.md`](../../docs/user/e2e-abdeckung.md); er läuft in `make test` —
und damit in `make gates`, das `test` über `record-gates` als Voraussetzung führt.
Ungeprüft bleibt damit allein die Zuordnung selbst: dass die
committete Datei der aktuelle Ausgang ihres Erzeugers ist, entscheidet kein Urteil und
wird darum gehalten.

## Grenze — was das Grün nicht abdeckt

**Die Stufen-Menge hängt an einer Textform.** Eine Stufe eröffnet für den Aufruf wie für
den Erzeuger nur, wenn ihre Kopfzeile `echo "full-smoke: … ..."` lautet. Eine Stufe, die
anders eröffnet wird, ist für beide keine — die Lücke fiele in der Richtung *Stufe ohne
Deklaration* nicht auf, weil die Region dann zur vorigen Stufe gehört. Beide Seiten lesen
dasselbe Muster aus derselben Datei; es steht an zwei Stellen, weil der Aufruf zur
Laufzeit kein zweites Werkzeug ruft, und wer es ändert, ändert beide.

## Ausgabe und Ausgänge

| Exit | Bedeutung |
|---|---|
| 0 | jede Stufe grün; je Stufe steht ihre Abdeckungs-Zeile `full-smoke: Abdeckung der Stufe …` im Lauf |
| 1 | eine Stufe brach ab, mit `full-smoke: FEHLER — …`; der Ausgang des Abbruchs steht in der Zeile `AUSGANG LEITUNG` oder `AUSGANG BAUM` |

**Sein Grün sagt das eine, sein Rot sagt zwei Dinge:** der Lauf fragt je Durchgang fremde
Registries nach gepinnten Bildern und macht jede dieser Anfragen zur Bedingung seines Grüns.
Bricht ein Abschnitt ab, ordnet `harness/tools/full-smoke-ausgang.sh` ihn einem von zwei
Ausgängen zu — `AUSGANG LEITUNG` (eine ausgehende Anfrage nach einem gepinnten Artefakt wurde
nicht mit 2xx beantwortet) oder `AUSGANG BAUM` (keine der geführten Formen steht in den
gelesenen Zeilen, der Fehlschlag wird dem geprüften Baum zugerechnet). Der Exit-Code
unterscheidet die zwei bewusst nicht — ein eigener Code lüde dazu ein, den Leitungs-Fall
durchzuwinken, und das wäre die Schwellen-Senkung, die [`AGENTS.md`](../../AGENTS.md) §3.5 an
ein ADR bindet.

Abgedeckt ist **jeder Abschnitt, der ein Bild anfordern kann** — ein Kriterium, keine
Fundstellen-Liste; die mechanische Abgrenzung, ihre Gleichung und die drei Formen, die
nachprüfbar **kein** Bild anfordern (Trockenlauf, `make span-clean`, der Hook-Wrapper) stehen
im Kopf von `harness/tools/full-smoke.sh`. Die Ausgangs-Muster, ihre Messung und ihre weiteren
Grenzen (Paketquellen der C++-Kette fallen in den Baum-Fall) stehen im Kopf von
`harness/tools/full-smoke-ausgang.sh`.

## Sperren

Keine: der Lauf bricht vor seiner ersten Stufe nicht ab. Davor legt `harness/tools/full-smoke.sh`
nur Arbeitsverzeichnisse an; jeder Abbruch liegt in einer Stufe.

## Bindung

Kein Gate-Versprechen; slice-024, [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen).
