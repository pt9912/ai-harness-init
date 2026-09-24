# C++-Skelett erfüllt die Messmethode von `LH-QA-02` nicht

**Sub-Area:** `*` (gesamtes Repo)

Das C++-Skelett pinnt das Base-Image per **Tag** (`ubuntu:${CXX_VERSION}`) und installiert in seiner
`toolchain`-Stufe `build-essential`, `cmake` und `clang-tidy` mit apt **ohne Versionen**. Die
**Anforderung** von
[`LH-QA-02`](../../../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) — Sprachskelett auf
Tag/Digest gepinnt — lässt beide Pin-Formen zu und ist damit erfüllt. Ihre **Messmethode**, *zwei
Läufe mit gleichem Tag erzeugen identische Ausgabe*, ist es nicht: ein wandernder Tag und eine
Installation ohne Versionen liefern an zwei Tagen zwei Toolchains unter demselben Tag.

Der Zielort der Abweichung ist
[`MR-048`](../../../../../../harness/conventions.md#mr-048): er deklariert das Tag-Pinnen der
Skelette und nennt die apt-Installation. Neu ist hier nur die Aussage über die Messmethode; der
Eintrag wird nicht dupliziert.

**Eine Form, die das Problem löst.** Ein Werkzeug-Basisimage, das aus einer Dockerfile mit apt-Schicht
gebaut, von Hand per Workflow veröffentlicht und im Haupt-Dockerfile per **Digest** gepinnt wird: der
Digest ist der Anker, kein apt-Pin. Das ist die Archiv-Form, die
[`MR-048`](../../../../../../harness/conventions.md#mr-048) für dieses Repo als nicht vorhanden benennt — kein gebautes Image wird aufbewahrt, und
[`ADR-0003`](../../../../../plan/adr/0003-go-native-binaries.md) streicht das eigene OCI-Image als
Vertriebsmittel.

**Entscheidungsbedarf des Auftraggebers**, als Text und nicht als Slice: ein Change Request nach
[`MR-015`](../../../../../../harness/conventions.md#mr-015) an [`LH-QA-02`](../../../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (eine Messmethode, die für das
Sprachskelett gilt) und ein Architect-Verdikt, ob und wie die Archiv-Form emittiert wird.

## Benannt, nicht gezählt

Aufgenommen am 2026-09-24 auf Anweisung des Auftraggebers. Das Vorkommen trägt keinen abgeschlossenen
Vorgang — es entstand außerhalb einer Slice-Closure, im Lauf, der den Slice
`slice-program-feld-nennt-weder-operator-noch-wertfragment` schloss, und gehört ihm nicht. Es bewegt
keinen Zähler.
