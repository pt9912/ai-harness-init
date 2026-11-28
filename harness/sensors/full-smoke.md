# `make full-smoke` — Voll-E2E-Smoke

## Vertrag

Bootstrap in ein tmp-Repo, dann dort der **zusammengeführte** `make gates`
([`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert): docs-check +
Go-Gates in einem Lauf) — der Happy-Path-Beweis
([`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)), dass ein frisch
gebootstrapptes Repo out-of-the-box grün fährt (die Nutzer-Sicht, die
[`make smoke`](smoke.md) mit seinen getrennten Schritten nicht nimmt). Eingeht docker-los
(Träger aus `make host-bin`, d-check-Carrier, [`ADR-0109`](../../docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md));
die Stufen über den emittierten `d-check.mk`-Zielen (Vorlauf-Wächter/Zahn-Läufe
`doc-commits`/`doc-immutable` und die `docs-check`-Zähne) fahren über die Rezept-Auswahl
`$(DCHECK_RUN)` des emittierten Fragmentes am Carrier, wenn die Ablage liegt, sonst bleibt
der docker-Lauf der Rückfall am opt-in Weg; die Archiv-Leseprobe liest am Host durch das
Traeger-Unterkommando `archive-lesen`; die daemon-gebundenen Rest-Stufen (hexslice-/hexagonal-Bootstrap,
Netz-Pull ggf.) trägt
[`slice-full-smoke-gates-echt-gruen`](../../docs/plan/planning/next/slice-full-smoke-gates-echt-gruen.md)
— nicht in `make gates`; gehört an DoD-Verify/CI/Wellen-Closure.

**Host.** Host dieses Laufs ist Linux; macOS ist dafür nicht getragen, Beleg-Ort ist CI auf frischem
Klon (`AGENTS.md` §3.9). `make full-smoke-host` und GNU-`sed` vorn im `PATH` sind Hilfen ohne
Anspruch: ein Lauf darüber ist kein Beleg. Das betrifft die Dogfood-Läufer dieses Repos, nicht das
Produkt-Binary ([`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
[`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) bleiben unberührt). Ein Wächter für
diese Deklaration existiert nicht.

Die Stilllegungs-Kanten `open → done` und `next → done` des emittierten `make slice-mv` misst die
Stufe `slice_mv_kanten_nach_done_im_ziel` an einem frisch emittierten sprachlosen Ziel; was sie
hält und was der Dogfood-Wächter daneben hält, steht in [`slice-mv.md`](slice-mv.md) §Kanten
`open → done` und `next → done`.

**Leseprobe der Archivierungs-Stufe.** An den drei Stellen, an denen ein `archive.zip` nach
einem Vollzug liegt (Welle, Altbestand, gefetchter Träger), liest die Stufe das Archiv am
Host durch das Traeger-Unterkommando `archive-lesen` (`archiv_gueltig` in
`harness/tools/full-smoke.sh`; der Traeger aus `make host-bin` — er öffnet das Zip, liest
jeden Eintrag bis zum Ende, der CRC-Vergleich liegt am Ende des Lesens, und hält
jeden genannten Eintrag in der Namensliste) statt seine Existenz zu halten; docker und
`unzip` braucht sie nicht — `unzip` trägt das Inventar am Host nicht. Gelesen ist die Datei
auf Lesbarkeit (CRC) und auf die genannten Einträge, nicht auf Byte-Gleichheit mit den
Quellen — die hält die Rückleseprobe des Trägers (`internal/archive`) am Schreibzeitpunkt.
Die dritte Stelle fährt den Release-Träger; ein defektes Archiv ist dort nicht herstellbar,
kein Mutations-Fall deckt sie. Lesewächter des Unterkommandos: ein verfaelschter
Eintrag-Inhalt fällt erst beim Lesen bis zum Ende (`TestArchiveLesen_VerletzterEintragBrichtAb`,
Mutations-Anlage 829).

### Deklaration der Stufen

Jede Stufe nennt an sich selbst, welche Anforderung sie trägt. Unmittelbar nach ihrer
Kopfzeile steht in `harness/tools/full-smoke.sh` ein Aufruf
`e2e_abdeckung "<Kennungen>" "<Kurzbeschreibung>" "<Anker>"`; das dritte Argument ist ein
wörtlicher Ausschnitt aus einer Zeile **dieser** Stufe. Der Aufruf läuft im E2E mit und
bricht ab, wenn sein Anker in der Region seiner Stufe nicht mehr wörtlich vorkommt — die
Stufe wurde dann umgebaut, und die Deklaration verlöre ihren Ort.

`make e2e-abdeckung` liest dieselben Aufrufe als **Text** — kein Docker, kein E2E-Lauf —
und schreibt daraus [`docs/user/e2e-abdeckung.md`](../../docs/user/e2e-abdeckung.md), die
Tabelle *Anforderung · Kurzbeschreibung · Stufe · Ort*. Beide Lücken-Richtungen fallen
dort laut aus: eine Deklaration, deren Anker in ihrer Stufe nicht auflöst, und eine
Stufe ohne Deklaration. Was die Deklaration **nicht** prüft, ist die Zuordnung selbst:
ob die genannte Anforderung noch zu ihrer Stufe gehört, bleibt ein Urteil, das der
Review hält — der Anker kann auflösen, während sich die Aussage der Stufe ändert.

**Dieselbe Mechanik reist ins Ziel** ([`LH-FA-12`](../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren)),
**und eine Stufe des Laufs misst sie dort.** Das gebootstrappte Repo bekommt
`tools/harness/e2e-abdeckung.sh` und
`harness/mk/e2e-abdeckung.mk` <!-- d-check:ignore (die Pfade entstehen erst im gebootstrappten Ziel) -->,
und seine mitgelieferte Selbstprüfung trägt eine Stufe mit ihrer Deklaration — die Sicht
des Ziels hat damit eine Zeile. Der Lauf fährt dort `make e2e-abdeckung`, hält die eine
Zeile samt Spaltenfolge, verlangt vom zweiten Lauf *unverändert*, setzt den Ziel-Marker am
Aufruf und nimmt der Stufe ihre Deklaration, bis der Erzeuger rot wird. Der Erzeuger fügt
dem Ziel dabei keine Abhängigkeit hinzu — er liest Text, ohne Container und ohne Netz
([`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).

**Genau eine Regel trennt die zwei Fassungen, und sie ist gewollt: den Verweis.** Die
Kennungsspalte der **emittierten** Sicht trägt **Code-Spans**, nie Links. Ein Link
brauchte einen Anker, und ein Anker entsteht aus dem *gerenderten* Text einer Überschrift;
wer ihn aus der Rohzeile ableitet, bildet einen Markdown-Renderer nach — Satzzeichen,
Inline-Syntax, Whitespace, Entities. Jede Regel, die diese Nachbildung nicht trifft, ergibt
einen Link, der aussieht wie ein Verweis, bei Exit 0 entsteht und erst im Doku-Gate des
Adopters rot wird. **Eine Nachbildung ist nur zu verantworten, wo ihr Gate läuft:** hier
hält [`make docs-check`](docs-check.md) in `make gates` den Ausgang unseres Erzeugers
([`docs/user/e2e-abdeckung.md`](../../docs/user/e2e-abdeckung.md)) bei jedem Lauf — eine
Abweichung wird dort rot statt still. Im Ziel gibt es diesen Träger nicht, und das Werkzeug
bringt keinen mit. Unsere Fassung leitet deshalb ab und verlinkt, die emittierte nicht; wer
die zwei angleicht, hebt eine Zusage auf. Beide Verhalten hält ein Fall in
[`test/e2e-abdeckung.bats`](../../test/e2e-abdeckung.bats) nebeneinander, und ein zweiter
misst, dass die emittierte Fassung **keine** der Ableitungs-Stellen führt.

**Was das für unsere Fassung offen lässt.** Ihre Ableitung ist an gemessenem
Gate-Verhalten kalibriert, nicht an einer Markdown-Spezifikation; welche Überschriften-Formen
geprüft wurden, steht im Kopf von `harness/tools/e2e-abdeckung.sh`. Ein Sprung des
Doku-Gates oder eine Überschrift in einer dort nicht geprüften Form bleibt nicht still — sie
fällt an `make docs-check` über der committeten Sicht —, aber sie fällt **nach** dem
Schreiben, nicht davor. Die vier ziel-spezifischen Stellen der Vorlage sind davon unberührt:
gesetzte, überschreibbare Marker
([`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)); die
Spec-Datei benennt seit dem Wegfall der Verweise den Maßstab des **Lesers** und steht im
Kopf der erzeugten Sicht.

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

## Der E2E-Stempel und der Skip-Griff

Der grüne Lauf schreibt am Ende **sieben** committete E2E-Stempel — je Variante
eine Datei `.harness/state/full-smoke-passed-<variante>.key` (sprachlos, go, cpp,
kotlin, java, python, csharp;
[ADR-0113](../../docs/plan/adr/0113-der-e2e-stempel-wird-je-variante-gestempelt.md)
Festlegungen 1 und 4), je zwei Zeilen: `variante <name>` (Form- und
Selbst-Bindung — der Name der Datei wird gegen diese Zeile gelesen) und
`mengen-hash <64-hex>` — der Wert ist **nicht** ein Baum-Hash, sondern der am
**Grün-Ende** frisch gerechnete Hash der Vorlagen-Menge der Variante, gelesen vom
Satzerzeuger
[`harness/tools/full-smoke-varianten.sh`](../../harness/tools/full-smoke-varianten.sh)
(Modus `alle`). Die Mengen je Variante stehen als Tafel im Satzerzeuger
(Festlegung 2): der gemeinsame Teil (cmd/** und internal/** ohne Tests und
testdata, die vendored Baseline, die drei Treiber-Skripte) plus der je-Sprachige
Teil (die Profil-Dateien unter `internal/gen/`). Die tmp-Repos der E2E liegen
außerhalb des Baums; die committete Stempel-Klasse ist als deklarierte
Hash-Ausnahme aus dem Baum-Hash genommen, der eigene Schreibzug rotiert den
getragenen Vergleichswert also nicht. Kein Commit-SHA-Feld
([ADR-0111](../../docs/plan/adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
Festlegung 3: zirkulär), kein Datumsfeld. `make` committiert nicht ([`ADR-0111`](../../docs/plan/adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
Festlegung 5) — der committende Zug trägt die sieben Dateien mit ihrem Inhalt.

Der Skip-Griff läuft **nur am push-`main`-Job der CI** ([`ADR-0111`](../../docs/plan/adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Festlegung 2):
der Job
setzt `FULL_SMOKE_SKIP_KONSULT=1`, das Rezept konsultiert die sieben Stempel je
gegen die frisch gerechnete Vorlagen-Menge über
[`harness/tools/full-smoke-skip.sh`](../../harness/tools/full-smoke-skip.sh) und SKIPpt
nur bei voller Deckung aller sieben, mit der Varianten-Menge und dem benannten Rest
([`ADR-0113`](../../docs/plan/adr/0113-der-e2e-stempel-wird-je-variante-gestempelt.md) Festlegung 3: die Verfügbarkeit des Traeger-Releases, Registry- und
Netz-Zustände, die Runner-Fassung). Je Variante fehlend, unformal, fremd oder bei
Parser-Zweifel fährt der Job voll (fail-closed,
[`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)).
Am Host bleibt die Umgebung ungesetzt: der Lauf ist der Schreiber der sieben Stempel und
fährt unverändert voll. Wächter:
[`test/full-smoke-varianten-keys.bats`](../../test/full-smoke-varianten-keys.bats) —
die Mengen-Tafel hermetisch (Determinismus, je-Teil-Drift vor Gemeinsam-Drift,
Mengen-Vollständigkeit), die Klassifikation des Konsums über `--entscheide`
(deckende Sieben → SKIP mit Rest, fehlend, unformal, fremder Name oder fremder
Hash → voll) und die Schreiber-Form am Treiber; die gitignore-/CI-Verdrahtung
haelt [`test/ci-stempel-committed.bats`](../../test/ci-stempel-committed.bats);
Mutations-Fälle 822 (push-main erzwungen voll), 832 (fremdes Feld im Konsum),
833 (Ausnahme fällt still weg) und 834 (Baum-Hash statt Mengen-Rechnung) an
[`test/mutations/`](../../test/mutations/). Die Verdrahtung der Workflows belegt
der reale CI-Lauf selbst ([`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Form:
die CI ist dort das Netz). Was der Stempel nicht deckt: Runner-Fassung und
Netz-Zustand der CI ([`ADR-0113`](../../docs/plan/adr/0113-der-e2e-stempel-wird-je-variante-gestempelt.md) Festlegung 3), die Schreiber-Kette am `main`-Push (der
benannte Rest der ADR, kein Wächter); **nicht gemessen bis zur Einzelfahrt:**
der je-Variante-Skip wird nicht teilaufgelöst — SKIP verlangt alle sieben gedeckt
(Festlegung 3), die Einzelfahrt `VARIANTE=<name>` (Festlegung 4, zweite Hälfte)
ist in diesem Stand **nicht gebaut**, der serialisierte Lauf fährt alle Varianten
und stempelt alle sieben Keys.

## Ausgabe und Ausgänge

| Exit | Bedeutung |
|---|---|
| 0 | jede Stufe grün; je Stufe steht ihre Abdeckungs-Zeile `full-smoke: Abdeckung der Stufe …` im Lauf |
| 1 | eine Stufe brach ab, mit `full-smoke: FEHLER — …`; der Ausgang des Abbruchs steht in der Zeile `AUSGANG LEITUNG` oder `AUSGANG BAUM` |

Die Tabelle nennt den Exit des Skripts; über `make full-smoke` meldet `make` einen Exit ungleich null
als `Fehler <n>` und endet selbst mit 2.

**Sein Grün sagt das eine, sein Rot sagt zwei Dinge:** der Lauf fragt je Durchgang fremde
Registries nach gepinnten Bildern und GitHub-Releases nach dem gepinnten Release-Asset samt
`SHA256SUMS` (Stufe `make traeger-fetch im frischen Klon`) und macht jede dieser Anfragen zur
Bedingung seines Grüns. Ein nicht abrufbares Release-Asset steht mit der Zeile
`curl: (22) … 404` als `AUSGANG LEITUNG` da — auch dann, wenn nicht das Release fehlt, sondern
der Pin falsch gesetzt oder der Asset-Name im Fetch-Skript falsch gebildet ist; der Text trennt
die drei nicht (Grenze im Kopf von `harness/tools/full-smoke-ausgang.sh`, Muster 5).
Bricht ein Abschnitt ab, ordnet `harness/tools/full-smoke-ausgang.sh` ihn einem von zwei
Ausgängen zu — `AUSGANG LEITUNG` (eine ausgehende Anfrage nach einem gepinnten Artefakt wurde
nicht mit 2xx beantwortet) oder `AUSGANG BAUM` (keine der geführten Formen steht in den
gelesenen Zeilen, der Fehlschlag wird dem geprüften Baum zugerechnet). Der Exit-Code
unterscheidet die zwei bewusst nicht — ein eigener Code lüde dazu ein, den Leitungs-Fall
durchzuwinken, und das wäre die Schwellen-Senkung, die [`AGENTS.md`](../../AGENTS.md) §3.5 an
ein ADR bindet.

Abgedeckt ist **jeder Abschnitt, der ein Bild anfordern kann** — ein Kriterium, keine
Fundstellen-Liste; die mechanische Abgrenzung, ihre Gleichung und die fünf Formen, die
nachprüfbar **kein** Bild anfordern (Trockenlauf, `make span-clean`, der Hook-Wrapper,
`make help`,
`make e2e-abdeckung` im Ziel) stehen
im Kopf von `harness/tools/full-smoke.sh`. Die mechanische Abgrenzung dort zählt jede
make-Stufe mit eigenem Exit-Code, also auch `make traeger-fetch im frischen Klon`, die statt
eines Bildes ein Release-Asset anfordert; sie trägt ihre Einordnung wie jede andere. Die Ausgangs-Muster, ihre Messung und ihre weiteren
Grenzen (Paketquellen der C++-Kette fallen in den Baum-Fall) stehen im Kopf von
`harness/tools/full-smoke-ausgang.sh`.

## Sperren

Keine: der Lauf bricht vor seiner ersten Stufe nicht ab. Davor legt `harness/tools/full-smoke.sh`
nur Arbeitsverzeichnisse an; jeder Abbruch liegt in einer Stufe.

## Bindung

Kein Gate-Versprechen; slice-024, [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen).
