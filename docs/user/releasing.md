# Release-Vorgang — ai-harness-init

**Zweck:** Die Prozedur des Release-Schnitts. Diese Datei liegt unter
`docs/user/` und trägt dort den Rang 6 der Source Precedence — Operations,
Quality, Releasing. Sie trägt die Prozedur, nicht die Chronik einzelner
Schnitte: der Release-Text einzelner Releases ist veröffentlicht und liegt
außerhalb des Repos. Was ein Schnitt tut, welche Schritt-Folge er fährt und
was er vor dem Tag-Push prüft, steht hier — einmal, nicht je Release.

## Prozedur

Der Schnitt läuft tag-getrieben: der Release-Workflow
(`.github/workflows/release.yml`) baut am Tag frisch, startet auf allen
sechs Runnern und publiziert; ein `workflow_dispatch`-Lauf baut und startet
und lädt nichts hoch. Die Schritt-Folge:

1. **Den Tag in der Vorlage setzen, dann die Assets bauen und die
   Prüfsummen erzeugen.** Zuerst zeigen `TRAEGER_TAG` in
   `internal/emit/templates/enforce/traeger.mk` und der Tag-Wert in
   `test/traeger-fetch.bats` auf den Tag, der geschnitten wird. Die Vorlage
   ist im Binary eingebettet: ein Bau vor diesem Zug trägt den Tag des
   vorigen Schnitts, und seine Digests sind nicht die der Binaries, die der
   Release-Workflow am Tag baut. Dann baut `make release-artifacts DEST=dist
   TRAEGER_VERSION=<tag>` die sechs Binaries der Plattform-Matrix —
   `linux/amd64`, `linux/arm64`, `darwin/amd64`, `darwin/arm64`,
   `windows/amd64`, `windows/arm64`
   ([`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix)) — und
   erzeugt im selben Lauf die `SHA256SUMS` im selben Verzeichnis
   (`harness/tools/release-sums.sh`, Modus `generate`;
   [`ADR-0059`](../plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
   Festlegung 1). `TRAEGER_VERSION` ist der Wert, den der Release-Workflow am
   Tag übergibt und den `--version` meldet
   ([`ADR-0063`](../plan/adr/0063-das-werkzeug-sagt-seine-fassung.md)
   Festlegung 1); ohne ihn baut der Lauf ein anderes Binary als der
   Workflow.

2. **Digests messen und den Pin ziehen.** Die `SHA256SUMS`-Zeilen sind die
   gemessenen Digests der sechs Assets; der Pin trägt Version und Digest,
   fail-closed gekoppelt
   ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)):
   `TRAEGER_TAG` und die sechs `TRAEGER_SHA256_*`-Werte stehen im Makefile,
   die emittierte Vorlage trägt den Tag (Schritt 1). Das Makefile ist nicht
   eingebettet, seine Werte folgen dem Bau. Alles gehört in den Commit, den
   der Tag tragen wird — der Pin zeigt im selben Vorgang auf den
   geschnittenen Stand
   ([`ADR-0058`](../plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
   Festlegung 2). Dass die gemessenen Digests die des Workflows sind, belegt
   nach der Publikation `make traeger-fetch`: es hält das veröffentlichte
   Asset gegen den Pin.

3. **Die Assets gegen die Prüfsummen halten.**
   `bash harness/tools/release-sums.sh verify <dir>` — fehlt die
   `SHA256SUMS`, weicht eine Zeile in ihrer Form ab, ist die Menge der
   Einträge nicht die Menge der Assets oder weicht eine Datei ab, bricht der
   Lauf, bevor etwas publiziert wird.

4. **Gates am Tag-Baum, bevor der Tag gepusht wird.** `make gates` läuft auf
   dem Stand, den der Tag tragen wird. Der Beleg eines Gates-Laufs reist
   nicht mit dem Tag (Belegbasis-Abschnitt unten); diese Zeile kann der
   Schnitt nicht an die Workflow-Mechanik abgeben — der Release-Workflow
   fährt kein `docs-check`, sein Grün am Tag sagt nichts über den Baum des
   Tags.

5. **Tag-Push und Asset-Publikation.** `git push origin <tag>` — der
   tag-getriebene Lauf baut am Tag frisch, startet das Binary auf allen
   sechs Runnern (Start-Smoke: „beim Erstellen eines Release wird auf allen
   sechs ausgelieferten Dateien geprüft, dass das Programm auf seiner
   Plattform startet. Mehr nicht." — die Zusagen stehen im
   [Handbuch](benutzerhandbuch.md#systemanforderungen)) und publiziert: der
   publish-Job hält die `SHA256SUMS` gegen die Assets, bevor er lädt, und
   hängt die acht Assets ans Release — sechs Binaries, die `SHA256SUMS` als
   siebtes Asset ([`ADR-0059`](../plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
   Festlegung 1) und die Homebrew-Formel als achtes Asset, gefüllt aus dem
   Formel-Skelett je Release (die Tap-Verteilung,
   [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix); fehlt die
   Formel, bricht der Tap-Abzug laut —
   `gh release view <tag> --json assets --jq '.assets | length'`
   → `8`). Der Release-Text entsteht mit `--generate-notes`; Ergänzungen an
   ihm folgen der Stand-Form (Schritt 7). Der manuelle Weg —
   `gh release create <tag> <dir>/*` nach dem `verify`-Modus von Schritt 3 —
   fährt dieselbe Haltung vor der Publikation.

6. **CI am Tag abwarten, bevor der Schnitt vollzogen gemeldet wird.**
   `gh run list --commit <tag-commit-sha>` nennt die Läufe am Tag-Commit;
   die Meldung des vollzogenen Schnitts geht erst, wenn der `ci`-Lauf
   eingetroffen ist.

7. **Meldung des vollzogenen Schnitts.** Die Meldung — und jede Ergänzung am
   Release-Text — trägt die Stand-Form: Zustand und Beleg als auflösbarer
   Anker (Tag, Asset-Menge, Prüfsummen, Läufe), keine Chronik.

## Belegbasis

Ein ge-tagter/gepushter Stand trägt für seinen Baum keinen Gates-Beleg: der
Beleg eines `make gates`-Laufs liegt in `.harness/state/gates-passed.diffsha`
— lokaler, gitignorierter Zustand
(`git check-ignore .harness/state/gates-passed.diffsha` → Pfad), er reist
nicht mit dem Tag. Sein Grün am Tag sagt darum nichts über den Baum des
Tags; die zwei Disziplin-Zeilen der Prozedur (Schritte 4 und 6) sind die
Antwort auf der Prozedur-Seite. Die Klasse trägt das Beobachtungs-Register
unter `BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg`
([`observation.md`](../plan/planning/observations/BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/observation.md)).
Drei Fundstellen der Klasse:

1. Die zwei Pushes nach dem ersten beim `v0.2.0`-Vorfall — der
   [Unfall-Beleg](../plan/planning/observations/BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad/evidence/slice-release-schnitt-koppelt-pin-und-fassung.md)
   trägt die Lage im Abschnitt **CI-Lage**: der Zwischenstand war nicht die
   Spitze eines geprüften Push.
2. Der Tag `v0.2.0` (`git rev-parse --short v0.2.0` → `70139992`) liegt auf
   der beschädigten Baum-Fassung — derselbe Beleg, Abschnitt **Schaden**.
3. Der Tag `v0.2.1` (`git rev-parse --short v0.2.1` → `28337be5`) trägt die
   dritte Fundstelle — geschnitten und veröffentlicht auf der ungeprüften
   Zwischenstufe ([`Klassen-Beleg`](../plan/planning/observations/BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/evidence/slice-release-schnitt-koppelt-pin-und-fassung.md)):
   der Gates-Beleg des Baums reist nicht mit dem Tag, und die CI-Meldung
   traf nach der Veröffentlichung ein.

Grenze: die Zustandsform dieses Abschnitts prüft das Review, kein Gate —
`make docs-check` liest diese Datei wie jede andere; ihre Fundstellen-Links
reisen in seinem Lauf mit.

## Grenze

Der Release-Lauf hat keinen Signier-Schritt. Die Assets tragen Prüfsummen,
keine Signatur: der Ziel-Fetch prüft den Digest gegen die `SHA256SUMS`
desselben Releases
([`ADR-0059`](../plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
Festlegung 1), nicht die Signatur — ein Kanal, der Manifest und Asset
gemeinsam ersetzt, geht durch diese Prüfung. Die Grenze steht, solange das
Release keinen Signier-Schritt bekommt; der Re-Evaluierungs-Trigger dafür
steht in
[`ADR-0058`](../plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md).
Diese Datei dokumentiert die Grenze, sie hebt sie nicht auf.
