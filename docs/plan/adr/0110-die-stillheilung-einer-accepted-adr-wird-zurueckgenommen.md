# ADR-0110: Die Stillheilung einer Accepted-ADR wird zurückgenommen — der Accept-Stand von ADR-0109 trägt wieder, und zwei namentliche Ventile tragen seine drei toten Adressen

**Status:** Accepted

**Datum:** 2026-11-27

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(der Fehlschlag am Wächter und die zwei rot gesehenen Gegenbeispiele unten),
[ADR-0109](0109-gates-lauefer-docker-los-image-weg-opt-in.md) (das Artefakt; ihre
Festlegungen bleiben unberührt),
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) (Festlegung 1 — *kein Byte, auch nicht an
der Adresse*; Festlegung 2 — die Aufnahme-Grenze, die diese ADR erfüllt),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (Festlegung 1 — dieselbe
Linie am Planning-Baum; Festlegung 4 — die Entscheidung wandert vor den Move),
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(Festlegung 2 — der Wert von `refs` ist der aufgelöste Pfad),
[ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (Festlegung 5 — *der nächste Fall wird
einzeln entschieden, mit seiner eigenen Messung*),
[ADR-0101](0101-die-baseline-verweis-form-in-adrs.md),
[ADR-0104](0104-die-fall-beleg-zeile-der-festlegung-4-von-adr-0103-der-erste-bats-fall-ist-rot.md)
und [ADR-0105](0105-die-verweis-form-der-supersedes-zeilen-ist-ab-accept-eingefroren.md) (das
Heilmuster — Nachzug zurück, Färbung darüber trägt eine benannte Ausnahme),
[ADR-0079](0079-tote-adresse-in-den-vendored-baum-aus-zwei-accepted-adrs.md) (Festlegung 1 —
eine Entscheidung zu zweit),
Review
[`docs/reviews/2026-11-27-slice-doku-nachzug-ohne-docker.md`](../../reviews/2026-11-27-slice-doku-nachzug-ohne-docker.md)
(Befund F-1, Klasse *tote Adresse in einer Accepted-ADR still heilt statt einzeln entscheiden*),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie ordnet die Rücknahme eines Nachzugs an und
senkt einen Gate-Prüfumfang um zwei Paare; sie ändert keine Spec-Aussage.

**Abgrenzung — diese ADR supersedet keine.**
[ADR-0109](0109-gates-lauefer-docker-los-image-weg-opt-in.md) bleibt mit allen Festlegungen in
Kraft; nur ihr Byte-Stand kehrt auf den Accept-Stand zurück. Die Aufnahme-Grenzen aus
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) und
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) binden
weiter; diese ADR ist die von ihnen verlangte eigene Entscheidung.

---

## Kontext

### Der Nachzug, drei Zeilen

Commit `95415a38` (der Implementer-Lauf hinter
`slice-doku-nachzug-ohne-docker`) hat im Zug einer Doku-Reparatur drei Zeilen an der
seit `525749b4` `Accepted`-ADR-0109 geändert:

```sh
git show 95415a38 -- docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md | grep -E '^[+-]'
# -…[ADR-0004](0004-durchsetzung-emission.md) (durchgesetzte Emission bleibt)
# +…[ADR-0004](0004-durchsetzungs-emission.md) (durchgesetzte Emission bleibt)
# -…[slice-adr-gates-laeufen-host-native](../../plan/planning/in-progress/slice-adr-gates-laeufen-host-native.md) |
# +…[slice-adr-gates-laeufen-host-native](../planning/done/slice-adr-gates-laeufen-host-native.md) |
# -…[slice-adr-gates-laeufen-host-native](../../plan/planning/in-progress/slice-adr-gates-laeufen-host-native.md) |
# +…[slice-adr-gates-laeufen-host-native](../planning/done/slice-adr-gates-laeufen-host-native.md) |
```

Das ist eine Byte-Änderung an einem nach [`AGENTS.md`](../../../AGENTS.md) §3.4 eingefrorenen
Artefakt — nach [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) Festlegung 1 und
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 1
*„kein Byte, auch nicht an der Adresse"* —, und die Klasse ist per
[ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 5 *einzeln entschieden, mit
eigener Messung* vorzunehmen. Der Nachzug hat den Fall still geheilt; der Einzelentscheid liegt
mit dieser ADR vor.

### Zwei Generatoren, dieselbe Klasse

Zwei der drei toten Adressen (Zeilen 182–183) stammen vom Generator, den die Klasse kennt: Die
Geschichte-Zeilen der ADR-0109 tragen den Stand **vor** der Closure des Slices
`slice-adr-gates-laeufen-host-native` fest, und der vorgeschriebene `git mv` in `done/` — der
Vorgang, den Modul 5 der Baseline schreibt — hat sie gebrochen.
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4 verlangte den
Einzelentscheid **vor** dem Move; er wurde nicht gestellt, und der Nachzug danach war der falsche
Träger. Die dritte tote Adresse (Zeile 9) stammt von einem anderen Generator: Der Ziel-Name der
`[ADR-0004]`-Zeile trägt seit dem Schreiben einen Tippfehler — der Verweis
[`ADR-0004`](0004-durchsetzungs-emission.md) (durchgesetzte Emission bleibt) löst in
keiner Fassung dieses Commits. Diese Adresse starb **vor** dem Einfrieren; eine Reparatur wäre
bis zum Accept-Stand legal gewesen, danach ist sie unbehebbar — dieselbe Lage, die
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) für die Klasse benannt hat.
Beide Generatoren fallen unter dieselbe Festlegung: der Befund ist richtig und im eingefrorenen
Artefakt unbehebbar.

### Der Bestand trägt den Nachzug bereits rot

Der vcs-Wächter am Accept-Anker, gemessen mit dem gefetchten Binary und denselben Flags, die
[`d-check.mk`](../../../d-check.mk) dem gepinnten Bild gibt:

```sh
.harness/state/bin/d-check --enable vcs --range 525749b4..HEAD \
  --disable links --disable anchors --disable ids --disable matrix --disable external \
  --disable codepaths --disable spans --disable hostpaths --disable diagrams \
  --disable versions --disable pins --disable immutable --disable commits \
  --disable planning --disable tracked --disable targets --disable citations \
  --disable sources --disable structure --disable workflows --disable reviews \
  --disable mentions --disable file --disable metrics --disable pinsync
# docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md:3  core-drift-vcs
#   Core einer immutablen Datei hat sich über die Commit-Range geändert
# d-check: 3094 Datei(en) geprüft, 1 Befund(e)
```

Derselbe Nachzug, derselbe Wächter wie in
[ADR-0105](0105-die-verweis-form-der-supersedes-zeilen-ist-ab-accept-eingefroren.md):
eine Form, die **beide** Sensoren grün hält, gibt es nicht. Die Wahl fällt — wie dort — auf den
Zustand, der die Hard Rule trägt; die eine Färbung trägt ein benannter Ausnahme-Zug. Kein
host-loser `make`-Rezept-Lauf dieses Wächters existiert; der gepinnte Bild-Lauf trägt den
Beleg am CI ([`AGENTS.md`](../../../AGENTS.md) §3.9, Rezept-Umstellung der Implementation
offen). Eine Senkung braucht dieser Befund nicht — er fällt mit dem Revert.

## Entscheidung

**Wir wählen die Rücknahme des Nachzugs auf den Accept-Stand plus zwei namentlich geschnittene
Referenz-Ventile für die drei toten Adressen.** Drei Festlegungen.

**1. Der Nachzug `95415a38` ist aus ADR-0109 zurückgenommen; die Datei trägt wieder den
Byte-Stand `525749b4` (Blob `41192411`).** Kein Byte über den Accept-Stand hinaus, keines unter
ihm. Das ist die vierte Anwendung des Heilmusters:
[ADR-0101](0101-die-baseline-verweis-form-in-adrs.md) (Entstehungsstand),
[ADR-0104](0104-die-fall-beleg-zeile-der-festlegung-4-von-adr-0103-der-erste-bats-fall-ist-rot.md)
(Accept-Stand, Festlegung 4),
[ADR-0105](0105-die-verweis-form-der-supersedes-zeilen-ist-ab-accept-eingefroren.md) (Accept-Stand),
jede über einem in-place Nachzug an einer `Accepted`-ADR. Die Festlegungen der ADR-0109 bleiben
regierend; ein Teil-`Supersedes` tritt nicht ein, weil keine ihrer Aussagen berührt ist — nur
ihr Byte-Stand.

**2. [`​.d-check.yml`](../../../.d-check.yml) bekommt **zwei** weitere Top-Level-`ignore-refs`-Paare
in derselben Form wie die Klasse — **eine Entscheidung zu zweit**
([ADR-0079](0079-tote-adresse-in-den-vendored-baum-aus-zwei-accepted-adrs.md) Festlegung 1),
beide mit demselben Quelldatei-Namen:**

```yaml
  # Zwölftes und dreizehntes Paar, eine Entscheidung zu zweit (ADR-0110): die ADR-0109
  # traegt am Accept-Stand 525749b4 die zwei toten Adressen — den falsch geschriebenen
  # Ziel-Name am ADR-0004-Verweis (Zeile 9, tot seit dem Schreiben, Reparatur bis zum
  # Accept-Stand legal, danach unbehebbar) und die zwei Geschichte-Zeilen auf den Slice
  # slice-adr-gates-laeufen-host-native VOR dessen Closure-Move (Zeilen 182-183, tot
  # durch den vorgeschriebenen git mv nach Modul 5). Die Quelldatei ist nach AGENTS.md 3.4
  # eingefroren — der Befund ist in ihr nicht behebbar. Warum daraus eine Ausnahme folgt
  # und keine Reparatur, steht in ADR-0110.
  # GRENZE, keine Regel: EXTENSIONAL GESCHLOSSEN auf genau diese zwei Paare (ADR-0110).
  # Jeder weitere Eintrag ist eine neue Senkung nach AGENTS.md 3.5 und braucht seine
  # eigene ADR — auch dann, wenn er dieselbe Bedingung erfuellt.
  # Deckung: 1
  - in: "docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md"
    refs: ["docs/plan/adr/0004-durchsetzung-emission.md"]
  # Deckung: 2
  - in: "docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md"
    refs: ["docs/plan/planning/in-progress/slice-adr-gates-laeufen-host-native.md"]
```

**und keinen weiteren.** Das ist eine Aufnahme-**Grenze**, keine Aufnahme-**Regel**: **jeder
zusätzliche Eintrag, jedes zusätzliche Glob in `in` oder `refs` und jede Verbreiterung eines der
beiden auf ein Verzeichnis ist eine neue Senkung und löst [`AGENTS.md`](../../../AGENTS.md) §3.5
erneut aus — auch dann, wenn sie dieselbe Bedingung erfüllt wie diese.** Die Grenzen der Klasse
([ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) Festlegung 2,
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) Festlegung 2,
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 2,
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Festlegung 2)
gelten unverändert weiter; diese ADR erhöht die Zahl der Paare von elf auf dreizehn und nicht die
Zahl der Entscheidungen, die ein vierzehntes braucht. Die Restbreite beider Paare ist strukturell
null: `in` ist nach §3.4 eingefroren und kann keine weitere Referenz bekommen.

### Das Ventil, gemessen — beide Skopen an roten Gegenproben

Sonde in der Gate-Konfiguration, je ein `make docs-check-host` über dem Accept-Stand der
Quell-Datei, danach zurückgenommen. Der gepinnte d-check ist derselbe, an dem
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) und
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
gemessen haben:

| Sonde | `in` | `refs` | Ergebnis |
|---|---|---|---|
| trägt | ADR-0109 | die zwei Werte, Wortlaut in Festlegung 2 | `3094 Datei(en) geprüft, 0 Befund(e)` |
| Ausgangsstand | — | ohne die zwei Paare | drei Befunde, Zeilen 9, 182, 183, je `target-missing` |
| Gegenprobe Quell-Skopus | `docs/plan/adr/0100-die-gegenmessung-schrumpft-auf-die-einheimische-flaeche.md` (die Gegenprobe-Quelldatei, ortsfest) | wie oben | `3094 Datei(en) geprüft, 3 Befund(e)` — die Befunde stehen |
| Gegenmessung Datei-Achse | — | `scan.ignore` um den Quelldatei-Namen erweitert | `3093 Datei(en) geprüft, 0 Befund(e)` |

**Tragend ist der Unterschied in der ersten Zahl, nicht ihr Betrag** — das Referenz-Ventil lässt
sie bei 3094 stehen, der datei-weite Ausschluss senkt sie auf 3093. Kommandos je Zeile: der
Quelldatei-Namen ist `docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md`, der
Ziel-Skopus ist der Name, ansonsten Wortlaut in Festlegung 2.

### Die Deklaration, an roten Gegenbeispielen gesehen

Der Restbreite-Wächter `test/ignore-refs-restbreite.bats` zählt über dem Accept-Stand der
Quelldatei **ein** auflösenden Markdown-Link auf den ADR-0004-Zielnamen und **zwei** auf den
Slice-Zielnamen; die Deklarationen oben tragen genau diese zwei Zahlen. Rot-Gegenbeispiele, je
einmal rot gesehen ([`AGENTS.md`](../../../AGENTS.md) §3.6):

```sh
bats test/ignore-refs-restbreite.bats   # Deklaration 1/2 ueber dem Accept-Stand
#   Paar A und B nicht gemeldet — der Wächter hält die Deklaration (1/2) und schweigt
sed 's|# Deckung: 1$|# Deckung: 9|' .d-check.yml > /tmp/p.yml; bats test/ignore-refs-restbreite.bats
#   docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md ->
#     docs/plan/adr/0004-durchsetzung-emission.md: 1 aufloesende(r) Link(s), deklariert sind 9
```

**3. Der vcs-Wächter am Accept-Anker schweigt nach dem Vollzug.** Der Lauf, der die Rücknahme
committet, wiederholt den Befehl über dem Revert-Commit und zeigt ihm grün; der Vorher-Lauf steht
oben. Damit ist die Färbung des Nachzugs beseitigt, **ohne** dass ein Byte über den Accept-Stand
hinaus bleibt — der Wächter und die Hard Rule tragen denselben Zustand, und die Klasse der toten
Adressen ist im Bestand dokumentiert, nicht im Artefakt.

**Das ist eine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5** — der Prüfbereich verliert
zwei Referenzen, die dieses Repo autoritativ schreibt, derselbe Test, mit dem
[`MR-029`](../../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
Scoping von Senkung trennt. Darum diese ADR, und sie ist der Einzelentscheid, den
[ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 5 für diesen Fall verlangt.

**Diese ADR wendet die Verweis-Form auf sich selbst an:** sie nennt die Slices und die
Ziel-ADRs bei der Kennung; die zwei Ziel-Pfade stehen nur als Zitat der Config in Festlegung 2 —
der Gegenstand des Eintrags, nicht Zeiger.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — Nachzug legitimieren: eine Einzel-ADR „praezisiert" die drei Zeilen nachträglich | kein Revert, kein Paar, sofort grün | bestätigt einen Byte-Nachzug nach `Accepted`, denselben Weg, den [ADR-0105](0105-die-verweis-form-der-supersedes-zeilen-ist-ab-accept-eingefroren.md) Alternative A verwirft — der Wächter am Accept-Anker bliebe dauerhaft rot, und die Klasse der Stillheilung fände ihre Belohnung: der nächste Lauf hätte den Vorbild-Beleg, der Nachzug sei der Weg. Und sie setzte in eine Zeile, die den Stand **vor** der Closure festhält, die Adresse nach ihr — dieselbe Verfälschung, die [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) Option B |
| B — Nachzug stehen lassen und aussprechen, kein weiteres Tun | keine Senkung, keine Änderung | der vcs-Wächter am Accept-Anker bleibt dauerhaft rot (1 Befund, gemessen). Ein Dauer-Rot mit Zähler 1 ist kein Sensor mehr: jeder echte neue Befund erscheint als Zähler 2 in einem Lauf, den man ohnehin rot erwartet ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| C — Zustand `95415a38` stehen lassen, ein Paar als Dekoration anlegen | dokumentiert den Fall in der Config | an der reparierten Quelldatei schaltet das Paar **nicht** stumm — gemessen 0 Treffer (die zwei Ziel-Pfade lösen am Nachzug nicht); eine Deklaration ohne Wirkung ([`AGENTS.md`](../../../AGENTS.md) §3.6), und sie legitimierte durch Config den fehlerhaften Byte-Stand |
| D — `scan.ignore` auf die Quelldatei (Datei-Achse, wie [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)) | eine Zeile, sofort grün | nimmt die **ganze Datei** aus der Prüfung statt der drei toten Referenzen; gemessen fällt die Datei-Zahl auf 3093 (Sonden-Tabelle), was das Referenz-Ventil gerade nicht tut. Und der vcs-Wächter bleibt rot — die Datei-Achse hält nur das Doku-Gate, nicht den Commit-Range |
| **E — gewählt: Revert auf den Accept-Stand plus zwei namentliche Paare** | der Kern trägt den Accept-Stand; beide Sensoren enden grün; die Restbreite ist strukturell null; die Grenze hängt an §3.5 statt an einer Prognose; die Klasse steht als dokumentierter Befund in der Config und nicht als still geheilter Zustand im Artefakt | es sind die zwölfte und dreizehnte Ausnahme unter demselben Schlüssel und die nächste Gate-Senkung dieser Klasse; die Aufnahme-Grenze bleibt in Kraft. Der Revert selbst ist ein weiterer Werkzeug-Lauf über §3.4-Artefakt — er trägt denselben Preis, den drei Vorgänger-ADRs je bezahlt haben, und er hebt die Färbung, statt sie zu legitimieren |

## Konsequenzen

- **Positiv:** Der Accept-Stand der ADR-0109 trägt wieder; der vcs-Wächter am Accept-Anker
  endet nach dem Vollzug grün (Festlegung 3), und `make docs-check-host` bleibt bei
  `3094 Datei(en) geprüft, 0 Befund(e)` — die Datei-Zahl bewegt sich durch die zwei Paare nicht
  (Sonden-Tabelle).
- **Positiv:** Die Restbreite beider Paare ist strukturell null: eine eingefrorene Datei bekommt
  keine weitere Referenz.
- **Negativ:** [`AGENTS.md`](../../../AGENTS.md) §3.5 hat **keinen Sensor**. Die Schranke gegen
  ein vierzehntes Paar ist prozessual, wie bei jeder anderen Senkung dieses Repos.
- **Negativ:** Der vcs-Wächter hat **kein host-loses make-Rezept** — er fährt im gepinnten Bild
  (CI). Der Beleg über dem Revert-Commit trägt der Lauf, der die Rücknahme committet, mit dem
 selben Befehl über dem gefetchten Binary oder dem CI-Lauf; **diese ADR liefert ihn nicht**
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)), sie
  trägt den Vorher-Lauf und benennt die Lücke.
- **Folgepflicht 1 (der Lauf der F-1-Verantwortung):** die zwei Paare — **samt Config-Kommentar
  und Zeiger auf diese ADR** — und der Revert der ADR-0109 auf den Accept-Stand **in einem
  Commit** anlegen: jedes Zwischenteil-Stand ist entweder rot (Revert vor Paar) oder führt eine
  tote Referenz unerwähnt (Paar vor Revert); der gemeinsame Stand ist zu `3094 … 0` gemessen. Mit
  zwei `make docs-check-host`-Läufen belegen (Vorher: drei Befunde — der Ausgangsstand, Nachher:
  0). `scan.ignore` bleibt unverändert.
- **Folgepflicht 2 (derselbe Lauf):** den vcs-Wächter über dem Revert-Commit wiederholen
  (Befehl im Kontext) und ihm grün zeigen; der Vorher-Lauf steht oben. Beide Belege an die
  Closure-Notiz des Slices.
- **Folgepflicht 3 (die Klasse, nicht der Fall):** die Aufnahme-Grenze liest die vier Paare der
  Vorgänger-ADRs und diese zwei als **eine** fortlaufende Liste — der Index trägt beide Stande,
  und der nächste Einzelentscheid liest die Zahl der Paare (dreizehn), nicht die Zahl der
  Entscheidungen. Die Grenze aus
  [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) Festlegung 2 bindet unverändert weiter.

## Fitness Function (falls maschinell prüfbar)

**Gebaut — und was es nach dieser Senkung noch prüft:**

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check `links` + `anchors` | jede Referenz aus der Quelldatei **außer** den drei ausgenommenen löst auf; jede Referenz **auf** die Datei bleibt vollständig bewacht — der Eintrag wirkt auf der Ziel-Achse, nicht auf der Quell-Achse | `make docs-check-host` (in `make gates`) |
| bats, `test/ignore-refs-restbreite.bats` | jede Deklaration des Top-Level-Blocks wird in beiden Richtungen gehalten; eine unbekannte Zeilenform färbt rot statt still zu bleiben. Für die zwei neuen Paare misst er die reale Restbreite (1 und 2) — je einmal rot gesehen (Deklaration 9) | `make test` (in `make gates`) |
| d-check `vcs` | der Kern der Quelldatei bleibt über dem Accept-Anker unverändert — nach dem Vollzug | gepinntes Bild, `make adr-immutable RANGE=525749b4..HEAD` (CI) |

**Nicht gebaut, und hier ehrlich zu benennen: der vcs-Wächter hat kein host-loses make-Rezept.**
Er fährt im gepinnten Bild ([`d-check.mk`](../../../d-check.mk)); ein Lauf am gefetchten Binary
mit denselben Flags misst dieselbe Achse und ist hier einmal gefahren (Kontext). Ein Rezept
host-los trägt die Rezept-Umstellung der Implementation
([`AGENTS.md`](../../../AGENTS.md) §3.9), nicht diese ADR — die Lücke ist benannt, nicht
behauptet geschlossen.

## Re-Evaluierungs-Trigger

- **Wenn ein vierzehntes Paar gesetzt werden soll** *(am Vorgang ablesbar; §3.5 greift von
  selbst)*: dann ist zu prüfen, ob die Verweis-Form der Klasse in ihren Festlegungen nicht
  getragen hat, ob die Folgepflichten übergangen wurden oder ob der Fall neu ist. Drei
  Diagnosen mit drei Antworten, in einer eigenen ADR, nicht hier. Diese Entscheidung deckt
  keinen weiteren Fall.
- **Wenn der Revert unterbleibt und der Nachzug legitimiert würde** *(am Byte-Stand der
  Quelldatei ablesbar; der vcs-Wächter färbt am Accept-Anker, bis der Revert vollzogen oder die
  ADR superseded ist)*: dann tritt der Fall der
  [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Alternative G ein — die Prämisse,
  unter der die Vorgänger-ADRs ihren Preis gewählt haben, fällt, und die Paare aus Festlegung 2
  sind **zurückzunehmen**, nicht stillschweigend mitzuführen.
- **Wenn ein dritter Generatortyp in derselben Quelldatei eine zweite tote Referenz bekommt**
  *(nicht beobachtbar — dieselbe Grenze wie bei
  [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) Re-Eval. 4)*: die Datei ist
  §3.4-immutabel und kann keinen neuen Defekt erwerben. Tritt es doch ein, war der Accept-Stand
  nicht durchgesetzt, und das ist die größere Frage.
- **Wenn [`AGENTS.md`](../../../AGENTS.md) §3.4 eingeschränkt würde** *(am Text ablesbar)*: dann
  fällt die Voraussetzung der Klasse, der Befund wäre im Artefakt behebbar, und die Paare aus
  Festlegung 2 sind zurückzunehmen, nicht stillschweigend mitzuführen.
- **Wenn der gepinnte d-check das geteilte `ignore-refs` verlöre** *(feedforward — eine
  Werkzeug-Version, kein Sensor; sichtbar wird sie, wer den CHANGELOG des neuen Pins gegen den
  alten liest)*: dann fällt die Voraussetzung der Festlegung 2, und die drei Befunde kehren
  zurück.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-27 | **Proposed** | Architect-Entscheid zu review F-1 der Klasse *tote Adresse in einer Accepted-ADR still heilt statt einzeln entscheiden*: der Nachzug `95415a38` an der seit `525749b4` `Accepted`-ADR-0109. Sechs Läufe am gefetchten Binärstand tragen ihn: der Befund am vcs-Wächter (1 `core-drift-vcs` am Accept-Anker), das Referenz-Ventil, seine rote Gegenprobe (Quell-Skopus), die Gegenmessung auf der Datei-Achse, die Deklaration am Restbreite-Wächter mit dem einmal rot gesehenen Gegenbeispiel (9 gegen 1) und der Vorher-Lauf der drei Befunde |
| 2026-11-27 | **Accepted** | Angenommen in der Architect-Rolle ([`AGENTS.md`](../../../AGENTS.md) §3.8) auf den Review-Befund F-1 (Befund in `docs/reviews/2026-11-27-slice-doku-nachzug-ohne-docker.md`); keine eigene Proposed-Review-Runde — dasselbe Verfahren, das [ADR-0105](0105-die-verweis-form-der-supersedes-zeilen-ist-ab-accept-eingefroren.md) fuhr. Festlegung 2 regiert diese Tabelle selbst — die Slices und Ziel-ADRs stehen bei der Kennung, Ziel-Pfade nur als Config-Zitat |
