# ADR-0064: Der Tap-Nachzug ist ein Werkzeug — ein Skript mit zwei Aufrufern (Release-Job und `make`-Ziel), ein eng geschnittenes Zugangsgeheimnis, und eine Kontrolle, die Byte-Gleichheit gegen das veröffentlichte Asset hält

**Status:** Proposed

**Datum:** 2026-09-24

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (die
Plattform-Matrix — das Tap verteilt dieselben Assets; die Formel reist als achtes Asset des
Schnitts),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Kontrolle hält das Tap
gegen das **veröffentlichte** Asset, nicht gegen eine lokal erzeugte Kopie; das Transport-Bild ist
digest-gepinnt),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (der Host braucht weiter
nur git, docker, make),
[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) (**Accepted** — Festlegung 4:
Transport im gepinnten Bild, Netz nur an genau diesem Aufruf, kein Prerequisite, kein Gate; dieses
Muster wird wiederverwendet, nicht abgelöst),
[ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
(**Accepted** — die Formel reist als Release-Asset; ihre Digests stammen aus der `SHA256SUMS`
desselben Schnitts, und der Nachzug füllt sie **nicht** ein zweites Mal),
[ADR-0063](0063-das-werkzeug-sagt-seine-fassung.md) (**Proposed** — die Binaries, die das Tap
ausliefert, tragen die Fassung des Tags; der Nachzug berührt sie nicht),
[ADR-0003](0003-go-native-binaries.md) (**Accepted** — Docker-only),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (**Accepted** — der
Accept-Übergang nennt den Beleg seines Triggers),
[`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (eine Quelle
je Check, versioniert; die CI ruft `make`-Ziele bzw. versionierte Skripte),
[`MR-069`](../../../harness/conventions.md#mr-069--ein-job-der-bewusst-nicht-auscheckt-trägt-seine-prüfung-inline)
(der `publish`-Job bleibt der Job ohne Checkout; er bekommt kein Geheimnis),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl steht neben dem Kommando, das sie liefert; keine ist ein Erwartungswert)

**Schärft:** `—` — Prozess- und Werkzeug-Entscheidung ohne Spec-Stratum. Keine Festlegung unten
bewegt eine `ARC-*`-Zeile oder eine Anforderung des Lastenhefts; die Richtung (ein Werkzeug statt
Handarbeit) trägt die Setzung des Auftraggebers vom 2026-09-24, nicht der Vertrag.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

### Was die Entscheidung auslöst

Das Homebrew-Tap `pt9912/homebrew-ai-harness-init` trägt die Formel, die `brew` liest. Der
Release-Workflow füllt die Formel je Schnitt aus dem Skeleton und hängt sie als Asset an
(`harness/tools/homebrew-formula-fill.sh`); **in das Tap gelangt sie nirgends** — weder ein
Workflow-Schritt noch ein `make`-Ziel noch ein Schritt der Release-Prozedur nennt den Nachzug. Am
Schnitt `v0.2.3` stand das Tap nach der Publikation noch auf `0.2.2`, `brew` fand `0.2.3` nicht;
der Auftraggeber hat den Nachzug von Hand gepusht. Der Slice-Plan zum Nachzug trägt die Frage an
den Architect, ob Handarbeit mit Kontrolle (A), eine lesende Kontrolle als Ziel (B) oder ein
Werkzeug, das den Nachzug selbst fährt (C), die Antwort ist.

**Die Richtung ist gesetzt: C.** Der Auftraggeber hat am 2026-09-24 entschieden, dass ein Werkzeug
die Formel je Release selbst nachzieht. Diese Entscheidung formt sie aus — dieselbe Lage wie in
[ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) §Kontext
(*„Die Richtung ist gesetzt …; diese Entscheidung formt sie aus"*). Offen waren die **Form**
(`make`-Ziel, Release-Job oder beides), das **Zugangsgeheimnis**, die **Docker-only-Einordnung**, die
**Kontrolle samt Rot-Beleg** und das **Verhalten bei einem Fehlschlag**; die verworfenen Wege stehen
mit ihrem Grund in §Verglichene Alternativen.

### Die Lage, gemessen

Vier Messungen tragen die Abwägung, alle datiert (2026-09-24) und neben ihrem Kommando. Keine ist
ein Erwartungswert
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert));
das Tap und das jüngste Release wandern mit jedem Schnitt.

- **Der Release-Workflow kennt kein Zugangsgeheimnis.** Sein `publish`-Job trägt
  `contents: write` mit dem `github.token` des eigenen Repos; ein Push in ein zweites Repo trägt
  dieses Token nicht:

  ```sh
  grep -cE 'secrets\.' .github/workflows/release.yml            # 0
  grep -nE 'permissions|GH_TOKEN' .github/workflows/release.yml  # :46 (contents: read), :132 (contents: write), GH_TOKEN aus github.token
  ```

- **Das Tap ist öffentlich lesbar und nicht geschützt** — die Kontrolle braucht zum Lesen keine
  Anmeldung, ein Schreib-Pfad braucht sie:

  ```sh
  gh api repos/pt9912/homebrew-ai-harness-init --jq '.default_branch,.private'   # main / false
  gh api repos/pt9912/homebrew-ai-harness-init/branches/main --jq .protected     # false
  ```

- **Das Formel-Asset ist je Schnitt vorhanden und vergleichbar.** Das Asset von `v0.2.2` trägt eine
  Formel; gegen den heutigen Tap-Kopf (der Nachzug des Auftraggebers auf `0.2.3`) ist es
  **ungleich** — der erste Unterschied liegt in der `version`-Zeile —, das Asset von `v0.2.3` ist
  **byte-gleich**:

  ```sh
  gh release download v0.2.2 -R pt9912/ai-harness-init -p ai-harness-init.rb -O v022.rb
  gh release download v0.2.3 -R pt9912/ai-harness-init -p ai-harness-init.rb -O v023.rb
  gh api repos/pt9912/homebrew-ai-harness-init/contents/Formula/ai-harness-init.rb \
    -H 'Accept: application/vnd.github.raw' > tap.rb
  cmp v022.rb tap.rb   # verschieden: Byte 726, Zeile 11
  cmp v023.rb tap.rb   # Exit 0
  ```

- **`releases/latest` nennt das jüngste stabile Release** — die Größe, an der ein Nachzug
  entscheiden kann, ob sein Tag der ist, dem das Tap folgt:

  ```sh
  gh api repos/pt9912/ai-harness-init/releases/latest --jq .tag_name   # v0.2.3
  ```

### Die Docker-only-Lage

[`AGENTS.md`](../../../AGENTS.md) §3.9 und [ADR-0003](0003-go-native-binaries.md) schließen
Host-Toolchains aus; [ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 4
hat für einen Netz-Zugriff das Muster gesetzt: Transport im digest-gepinnten Bild, die
Plattform-Erkennung außerhalb, Netz an genau diesem Aufruf. Ein Push braucht dasselbe **plus** ein
Zugangsgeheimnis; er ist damit ein anderes Wagnis als ein Fetch, aber kein anderes Transport-Muster.
Auf dem Release-Runner (`ubuntu-24.04`) ist `make` vorhanden — anders als auf den macOS- und
Windows-Runnern, die der Kopf von `release.yml` als Grund für den Aufruf des Start-Smoke-Skripts
ohne `make` nennt; der Nachzug läuft nicht dort.

## Entscheidung

**Wir ziehen das Tap mit einem Werkzeug nach: ein versioniertes Skript unter `harness/tools/` mit
den zwei Modi `check` und `sync`, aufgerufen über zwei `make`-Ziele (`tap-check`, `tap-nachzug`) und
— als Regelweg — von einem eigenen Job `tap` im Release-Workflow, der nach `publish` läuft und
dasselbe `make`-Ziel ruft. Das Zugangsgeheimnis ist ein auf das Tap-Repo und `Contents`
beschränktes Token, das nur in diesem Job liegt.** Sieben Festlegungen.

**1. Ein Skript, zwei Aufrufer.** Die Logik — Quelle holen, Tap lesen, vergleichen, schreiben,
nachkontrollieren — steht **einmal**, in einem versionierten Skript
([`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) Setzung 1:
ein Check wird nie in der YAML definiert). Zwei `make`-Ziele fahren es:

- `make tap-check TAG=<tag>` — **nur lesend**: hält die Formel am Tap-Kopf gegen das Asset des
  Tags (Festlegung 2). Keine Anmeldung nötig, solange das Tap öffentlich ist.
- `make tap-nachzug TAG=<tag>` — führt `check`, schreibt bei Abweichung die Formel nach
  (Festlegung 3) und kontrolliert danach erneut. Braucht das Zugangsgeheimnis.

Der **Release-Job `tap`** ist der Regelweg: `needs: publish`, gleiche Bedingung wie `publish`
(`push` auf einen Tag), Checkout des Tags, Aufruf von `make tap-nachzug` — ohne eigene Logik in der
YAML. Das **lokale Ziel** ist der Nachhol- und Ausfallweg: derselbe Aufruf mit dem Push-Recht des
Auftraggebers, ohne dass ein Geheimnis in der CI stehen muss. Beide Ziele stehen **nicht** in
`gates` und **nicht** in `record-gates` — sie brauchen Netz und (`tap-nachzug`) ein Geheimnis; ein
Gate läuft netzlos. Sie stehen in
[`harness/README.md`](../../../harness/README.md) §Werkzeuge mit `kein Gate`.

**2. Die Kontrolle: Byte-Gleichheit, Quelle das veröffentlichte Asset, Ziel der Branch-Kopf.**

- **Quelle** ist das Asset `ai-harness-init.rb` des Tags, **aus dem veröffentlichten Release
  geholt** — nicht `dist/` des Bau-Jobs, nicht eine lokal gefüllte Kopie, nicht eine neue Füllung
  aus dem Skeleton. Der Nachzug führt keinen zweiten Füllvorgang: ein zweites Füllen wäre eine zweite
  Fassung derselben Formel
  ([ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) hält die
  Digests an der `SHA256SUMS` des Schnitts).
- **Ziel** ist `Formula/ai-harness-init.rb` am **Kopf des Default-Branch** des Tap, gelesen über die
  GitHub-Schnittstelle (Contents-API), **nicht** über einen zwischengespeicherten Roh-Pfad und nicht
  aus einem lokalen Klon — ein Cache zwischen Push und Lesen zeigte sonst einen alten Stand als
  grünen.
- **Vergleich** ist byte-genau. **Ausgang** in drei Klassen, an der Form erkennbar:

  | Exit | Bedeutung | Meldung |
  |---|---|---|
  | 0 | gleich | nennt Tag, Tap-Kopf und den Digest, den beide tragen |
  | 1 | **Formel-Unterschied** | nennt beide Digests und die erste abweichende Zeile |
  | 2 | **nicht ausführbar** — Asset nicht auffindbar, Tap nicht lesbar, Anmeldung fehlt oder abgelehnt, Aufruf falsch | nennt, was nicht erreicht wurde; **nie** als Unterschied |

  Ein Lesefehler ist damit nie 1 und nie 0: ein Rot, das aus einem Netzfehler kommt, sagt das, und
  ein Grün entsteht nur aus zwei gelesenen, gleichen Dateien.

**3. Der Nachzug ist idempotent, und er schreibt nur vorwärts.** `sync` läuft in dieser Folge:

1. **Vorab-Tag** (SemVer-Präfix mit `-`, Metadatum zuerst abgeschnitten — dieselbe Regel wie im
   `publish`-Job): das Tap folgt dem jüngsten **stabilen** Schnitt; der Lauf endet mit Exit 0 und
   einer ausgesprochenen Meldung *„Vorab-Tag, Tap bleibt"* — ein benannter Nicht-Gegenstand, kein
   stilles Grün.
2. **Nicht das jüngste Release:** ist der Tag ein stabiler, aber **nicht** der, den
   `releases/latest` nennt, endet der Lauf mit Exit 2 — ein Nachzug eines älteren Standes würde das
   Tap auf eine Formel zurückstellen, die kein zugesagter Weg mehr ausliefert.
3. `check`. **Gleich → Exit 0 ohne Schreibzugriff** (Idempotenz: ein Wiederholungslauf ist ohne
   Wirkung).
4. **Abweichung:** die Formel wird mit **genau den Bytes des Assets** über die Contents-API in das
   Tap geschrieben, optimistisch gegen den gelesenen Blob-Stand (ein Push dazwischen lässt den
   Schreibvorgang scheitern, statt ihn zu überschreiben) — ein Commit, dessen Message den Tag nennt.
5. **Nachkontrolle:** `check` erneut am Branch-Kopf. Gleich → Exit 0. Nicht gleich → Exit 1.

Ein abgelehnter Schreibvorgang (Anmeldung, Schutz des Branches, Konflikt) endet mit Exit 2; das Tap
bleibt **unverändert**, und die Meldung sagt das.

**4. Das Zugangsgeheimnis: ein Token, das nur dieses Repo und nur `Contents` sieht, und nur dieser
Job.**

- **Art und Scope:** ein *fine-grained* Personal Access Token des Auftraggebers, **beschränkt auf
  das eine Repository** `pt9912/homebrew-ai-harness-init`, mit der Berechtigung *Contents:
  Read and write* und **keiner weiteren**; mit Ablaufdatum (das längste, das die Plattform erlaubt).
  Es öffnet damit das Schreiben einer Datei im Tap und nichts sonst — kein `ai-harness-init`, keine
  Workflows, keine Administration.
- **Ort:** ein Repository-Secret `TAP_TOKEN` in `pt9912/ai-harness-init`. Anlage und Rotation sind
  **Handlung des Auftraggebers außerhalb des Repos**; das Repo trägt weder das Token noch eine Datei
  dafür. Das Secret steht **nur im Step-`env` des Jobs `tap`**, nicht auf Workflow-Ebene und nicht im
  `publish`-Job (der `contents: write` trägt und bewusst nichts anderes bekommt,
  [`MR-069`](../../../harness/conventions.md#mr-069--ein-job-der-bewusst-nicht-auscheckt-trägt-seine-prüfung-inline)).
  Der Job `tap` trägt für das eigene `github.token` nur `contents: read` und checkt mit
  `persist-credentials: false` aus.
- **Umgang im Werkzeug:** das Token reist als Umgebungsvariable **durchgereicht** (`docker run -e
  TAP_TOKEN`, ohne Wert in der Kommandozeile), wird nie ausgegeben, nie als Argument übergeben, das
  Skript läuft ohne `set -x`. Lokal liest `make tap-nachzug` dieselbe Variable aus der Umgebung des
  Aufrufers; wo der Auftraggeber sie hält, ist seine Sache.
- **Fehlt das Geheimnis, bricht der Nachzug laut.** Im Job ist der erste Schritt der Nachweis, dass
  `TAP_TOKEN` gesetzt ist; fehlt es, endet der Job mit Exit ≠ 0 und einer Meldung, die den lokalen
  Ausfallweg nennt (`make tap-nachzug`). Ein übersprungener Nachzug ist genau der Zustand, der am
  Schnitt `v0.2.3` eintrat; **still überspringen ist die falsche Antwort**.

**5. Docker-only und Netz.** Der Transport läuft im **digest-gepinnten** Bild
([ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 4, dieselbe Bauart wie
`make traeger-fetch`): der Host braucht git, docker, make, sonst nichts
([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)). Das Netz ist an genau
diesem Aufruf nötig. Das Skript trägt eine **Pin-Prüfung** wie `traeger-fetch.sh` (ein nicht
digest-gepinntes Bild bricht mit Exit 2). Reicht das Bild von `traeger-fetch` für Lesen, Vergleichen
und Schreiben, steht sein Pin **nicht ein zweites Mal** da; ein eigenes Bild wird nur gepinnt, wenn
das vorhandene nachweislich nicht reicht — die Wahl belegt der Implementierer im Slice. Der
Entscheidungskern (Vergleich, Vorab-Regel, Exit-Klassen) ist **hermetisch** prüfbar: die Quellen sind
injizierbar, damit ein `bats`-Fall ohne Netz läuft.

**6. Ein Fehlschlag bricht laut, und die Meldung des Schnitts wartet.** Schlägt der Job `tap` fehl,
ist das Release **veröffentlicht und bleibt es** — ein Rückbau eines veröffentlichten Releases wäre
schlimmer als ein veraltetes Tap. Der Lauf ist rot; die Meldung des vollzogenen Schnitts geht erst,
wenn `make tap-check TAG=<tag>` mit Exit 0 endet (Schritt der Release-Prozedur in
[`docs/user/releasing.md`](../../user/releasing.md), neben der Wartestelle für die CI). Der
Wiederholungslauf des Jobs und der lokale Aufruf von `make tap-nachzug` sind **konvergent**
(Festlegung 3). Der `tap-check` der Prozedur ist ein **vom Job unabhängiger Beleg**: er hält auch
dann, wenn der Job grün endete und nichts geschrieben hat.

**7. Wechselwirkung mit den Accepted-ADRs — nichts wird abgelöst.**
[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) bleibt in Kraft: der Träger-Pin, das
Ziel `traeger-fetch` und dessen Transport-Bild bleiben unberührt; der Nachzug nutzt sein Muster.
[ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) bleibt: die
Formel ist das achte Asset, ihre Digests stammen aus der `SHA256SUMS` des Schnitts, und der Nachzug
liest sie nur; kein Wert der Formel hängt von einem zweiten Bau ab.
[ADR-0063](0063-das-werkzeug-sagt-seine-fassung.md) bleibt: die Binaries, auf die die Formel zeigt,
melden den Tag, aus dem sie gebaut sind; die Kontrolle vergleicht **Bytes**, keine Versions-Strings.
Das Kriterium *„kein Wert im Binary, der eine Funktion des Bau-Ergebnisses ist"*
([ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
Festlegung 2) wird von einem Nachzug **außerhalb** des Binaries nicht berührt. Die Release-Prozedur
bekommt ihren Schritt; den Wortlaut trägt der Slice, nicht diese Entscheidung.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — Handarbeit des Auftraggebers, die Kontrolle als Kommando in der Prozedur | kein Code, kein Geheimnis; der Schritt, der fehlte, ist benannt | derselbe Fehler bleibt: ein Schritt, den ein Mensch vergessen kann, und den kein Sensor hält; die Kontrolle als Kommando in einer Prozedur ist unversioniert ausführbar und ohne Rot-Beleg; das Kommando braucht auf dem Host `gh`/`curl` oder eine Kopie in der Prosa |
| B — Handarbeit, die Kontrolle als lesendes `make`-Ziel im gepinnten Bild | die Kontrolle ist versioniert, Docker-only, hat ihren Rot-Beleg; kein Geheimnis | der Nachzug bleibt Handarbeit: `v0.2.3` versagte, weil ein Schritt fehlte, B liefert den Schritt und die Kontrolle, aber nicht den Vollzug; die Kontrolle sagt nach dem Vergessen nur *dass* es fehlt |
| C1 — nur ein lokales `make`-Ziel, das mit dem Push-Recht des Auftraggebers nachzieht | kein Geheimnis in der CI, keine neue Vertrauensgrenze; ein Kommando statt Handarbeit | bleibt ein Aufruf, den ein Mensch nach dem Schnitt tun muss — dieselbe Fehlerklasse wie A, nur billiger; der rote Fall zeigt sich nicht im Release-Lauf |
| C2 — nur ein Release-Job mit Token (kein lokales Ziel) | der Nachzug geschieht ohne Zutun; Fehlschlag rot im Release-Lauf | ein abgelaufenes oder widerrufenes Token blockiert den Nachzug ohne Ausweg außer Handarbeit außerhalb des Werkzeugs; die Kontrolle wäre nur im Job erreichbar |
| D — Release-Job mit **Deploy-Key** (SSH) statt Token | der Schlüssel gilt inhärent nur für ein Repo, läuft nicht ab | die Contents-API nimmt keinen SSH-Schlüssel: der Weg wird `git clone`/`push` im Bild mit Identität, `known_hosts` und Schlüssel-Datei im Container — mehr bewegliche Teile ohne den Vorteil der optimistischen Einzeldatei-Schreibung; die Kontrolle (Lesen) bräuchte den zweiten Transport daneben |
| E — Pull: ein Workflow **im Tap-Repo** holt die Formel vom jüngsten Release (Zeitplan oder Dispatch) und committet mit dem eigenen Token | kein Geheimnis in diesem Repo | die Logik liegt in einem Repo außerhalb dieses Baums (unversioniert hier, ohne Test in `make test`), ein Fehlschlag ist im Release-Lauf nicht sichtbar, die Latenz hängt am Zeitplan; ein Dispatch aus dem Release-Lauf brauchte wieder ein Zugangsgeheimnis für ein zweites Repo |
| **F — ein Skript, zwei Aufrufer: Release-Job als Regelweg, `make`-Ziel als Nachhol- und Ausfallweg, Token auf ein Repo und `Contents` beschränkt (gewählt)** | der Nachzug geschieht ohne Zutun und ist im Release-Lauf sichtbar; die Kontrolle ist unabhängig davon aufrufbar; das lokale Ziel ist der Weg, wenn das Token fehlt oder abgelaufen ist; die Logik steht einmal | eine neue Vertrauensgrenze (ein Geheimnis für ein zweites Repo); ein zweiter Aufrufer kostet eine `make`-Zeile und eine README-Zeile; ein Token mit Ablaufdatum wird gepflegt |

**Warum beides und nicht das Kleinere.** C1 kostet am wenigsten und wäre der Weg, wenn das
Versäumnis am Zeitaufwand gelegen hätte; gemessen fehlte am Schnitt `v0.2.3` aber **der Träger**, der
den Vollzug ohne Erinnerung fährt — C1 lässt ihn weg. C2 schließt diese Lücke, macht aber ein
abgelaufenes Token zu einem Schnitt, der nicht mehr vollzogen werden kann. Der zweite Aufrufer von F
kostet eine `make`-Zeile über demselben Skript und öffnet den Ausfallweg, der C2 fehlt.

## Konsequenzen

- **Positiv:** der Nachzug hängt nicht mehr an der Erinnerung; die Kontrolle „Tap-Formel ==
  Release-Asset" ist ein versioniertes Werkzeug mit Exit-Klassen statt einer Prosa-Zeile; ein
  Fehlschlag ist im Release-Lauf rot und nicht im Tap stumm; das Geheimnis öffnet ein Repo und eine
  Berechtigung.
- **Negativ:** eine Vertrauensgrenze, die der Workflow bisher nicht überschritt — wer einen Tag
  pushen oder den Workflow am Tag ändern kann, erreicht das Token (siehe §Grenze); ein Token mit
  Ablaufdatum ist zu erneuern; ein Fehlschlag des Jobs lässt das Release veröffentlicht und das Tap
  veraltet, bis der Ausfallweg gelaufen ist.
- **Folgepflicht 1 — das Werkzeug:** Skript, die zwei `make`-Ziele, die zwei Zeilen in
  [`harness/README.md`](../../../harness/README.md) §Werkzeuge (`kein Gate`; das `targets`-Modul hält
  beide Richtungen) und `bats`-Fälle für den hermetischen Kern (Vergleich, Vorab-Regel, Exit-Klassen,
  Idempotenz), jeder mit dem Rot-Beleg nach [`AGENTS.md`](../../../AGENTS.md) §3.6.
- **Folgepflicht 2 — der Release-Job:** Job `tap` in `release.yml` (`needs: publish`, Checkout des
  Tags, `make tap-nachzug`, Secret nur im Step-`env`, Fehlt-Nachweis als erster Schritt) samt einem
  `bats`-Fall über die Job-Form. **Vorbedingung, außerhalb des Repos:** das Secret `TAP_TOKEN`
  existiert (`gh secret list -R pt9912/ai-harness-init` nennt den Namen, nie den Wert) — die Anlage ist
  Handlung des Auftraggebers; ohne sie endet der erste Tag-Lauf laut.
- **Folgepflicht 3 — die Prozedur:** [`docs/user/releasing.md`](../../user/releasing.md) führt den
  Schritt (Nachzug-Ergebnis des Jobs, `make tap-check TAG=<tag>` als unabhängiger Beleg, der lokale
  Ausfallweg) und macht die Meldung des vollzogenen Schnitts von ihm abhängig. Jede Schritt-Nummer,
  die ein lebendes Artefakt nennt, stimmt nach dem Einfügen; die Messung über beide Adress-Formen
  geht dem Einfügen voraus
  ([`AGENTS.md`](../../../AGENTS.md) §3.11).
- **Folgepflicht 4 — die Vorab-Regel hat eine Quelle je Ort und eine Kopplung:** die Regel steht im
  `publish`-Job (inline, bewusst ohne Checkout) und im Skript; ein Fall hält beide gegen dieselben
  Tags, damit sie nicht auseinanderlaufen.
- **Folgepflicht 5 — das Handbuch:** Weg C sagt, die Formel werde je Release-Schnitt nachgezogen. Der
  Satz ist wahr, sobald Job und Ziel stehen; bis dahin trägt ihn nur die Handarbeit des
  Auftraggebers. Ob der Wortlaut nachzuziehen ist, misst der Slice der Prozedur gegen den Stand.
- **Folgepflicht 6 — kein `Supersedes`.** Keine Festlegung dieser Entscheidung löst eine Festlegung
  einer `Accepted`-ADR ab (Festlegung 7).

## Grenze

Die Kontrolle sagt zu: **zum Zeitpunkt des Aufrufs hat `Formula/ai-harness-init.rb` am Kopf des
Default-Branch dieselben Bytes wie das Asset `ai-harness-init.rb` des genannten Tags.** Sie sagt
**nicht** zu:

- **Installierbarkeit.** Byte-Gleichheit sagt nichts über `brew install` oder `brew audit`; die
  Formel kann gleich sein und trotzdem nicht laden (etwa am fehlenden Vertrauen des Fremd-Taps, das
  das Handbuch nennt).
- **dass das Asset selbst richtig gefüllt ist.** Das hält die Füll-Prüfung in
  `test/release-matrix.bats`, nicht dieser Vergleich; ein falsch gefülltes Asset wird bytegenau nachgezogen.
- **die übrigen Dateien des Tap** (README, weitere Formeln) und **keinen Zustand nach dem Aufruf** —
  ein späterer Push ins Tap ist nicht Gegenstand.
- **Vorab-Tags und ältere Releases** — die Vorab-Regel und der Vorwärts-Schutz aus Festlegung 3
  benennen sie als Nicht-Gegenstand.
- **Herkunft.** Es gibt keinen Signier-Schritt
  ([ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) benennt die Grenze): ein Asset,
  das ersetzt wurde, wird nachgezogen wie das echte.
- **dass der Job je läuft.** Dass `release.yml` den Job `tap` trägt, hält ein `bats`-Fall; dass die
  Prozedur den `tap-check` fährt, hält allein der Prozedur-Schritt (dieselbe Klasse wie die
  Schritt-Folge jeder Prozedur, ohne Sensor benannt im Beobachtungs-Register).
- **einen Schreib-Pfad, den ein Test in `make test` fährt.** Der Schreib-Vorgang am **realen** Tap ist
  ohne einen Schreibzugriff auf ein Fremd-Repo nicht herstellbar; der hermetische Test fährt ihn
  gegen eine nachgebildete Schnittstelle, und **der erste reale Lauf nach dem Job-Slice ist sein
  Beleg** — benannt, nicht als bewiesen behauptet.

**Die Vertrauensgrenze, benannt:** wer einen Tag pushen oder den Workflow-Text am Tag ändern kann,
erreicht `TAP_TOKEN` (der Job führt das Skript des Tag-Baums aus). Der Schaden ist auf das Schreiben
einer Datei im Tap begrenzt — das aber ist der Verteilweg von `brew`. Der Scope des Tokens begrenzt
den Umfang, nicht das Ziel.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `make test` (bats) | **Kern hermetisch:** gleich → Exit 0; verschieden → Exit 1 mit beiden Digests und der ersten abweichenden Zeile; nicht lesbar → Exit 2 und **nicht** 1 (unter der geschwächten Zusicherung — jeder Fehler als Exit 1 — bleibt der Lese-Fall rot) | `make test` |
| `make test` (bats) | **Idempotenz:** bei Gleichheit kein Schreibzugriff (unter einer geschwächten Fassung, die immer schreibt, bleibt der Fall rot); **Vorwärts-Schutz:** ein stabiler Tag, der nicht `latest` ist, endet mit Exit 2 ohne Schreibzugriff | `make test` |
| `make test` (bats) | **Vorab-Tag:** Exit 0 mit der Meldung *„Vorab-Tag, Tap bleibt"*; die Vorab-Regel des Skripts und des `publish`-Jobs entscheidet dieselben Tags gleich | `make test` |
| `make test` (bats) | **Job-Form:** `release.yml` trägt einen Job `tap` mit `needs: publish`, der `make tap-nachzug` ruft; `TAP_TOKEN` steht in keinem Workflow-`env` und nicht im `publish`-Job (entfällt `needs`, oder steht das Secret im `publish`-Job, wird der Fall rot) | `make test` |
| **Rot-Beleg am realen Zustand, kein Gate** | die Kontrolle gegen das Asset von `v0.2.2` und den Tap-Kopf endet **rot mit der Meldung eines Formel-Unterschieds** (Exit 1, nicht 2), gegen `v0.2.3` grün (Exit 0) — der Vorfall-Zustand, ohne Push herstellbar; die Ausgabe wird gelesen, nicht nur der Exit-Code ([`AGENTS.md`](../../../AGENTS.md) §3.6, Meldung lesen) | `make tap-check TAG=…` |
| `make mutate` | Vorwärts-Schutz oder Idempotenz-Zweig entfernt → der Wächter fällt (kuratiertes Set; kein Gate) | `make mutate` |

## Re-Evaluierungs-Trigger

- **Wenn der Nachzug an einem Schnitt am Token scheitert** (abgelaufen, widerrufen), und das ein
  **zweites Mal** eintritt *(beobachtbar am roten Job `tap` mit Exit 2 aus der Anmeldung)*: die
  Pflege eines Tokens mit Ablaufdatum trägt nicht; neu zu wägen sind eine GitHub-App, ein Deploy-Key
  (Alternative D) oder der Pull-Weg im Tap (Alternative E).
- **Wenn das Tap geschützt oder privat wird** *(beobachtbar am Schutz-Zustand des Branches oder an
  `.private` des Repos)*: der Schreib-Pfad (Contents-API ohne Pull-Request) und der anonyme Lese-Pfad
  der Kontrolle tragen nicht mehr.
- **Wenn das Release einen Signier-Schritt bekommt**
  ([ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Re-Evaluierungs-Trigger): die
  Kontrolle vergleicht dann gegen ein signiertes Asset; der Satz *„ein ersetztes Asset wird
  nachgezogen"* fällt.
- **Wenn das Tap eine weitere Datei oder ein zweites Tap dazukommt** *(beobachtbar an der Menge der
  Dateien, die der Schnitt nachzieht)*: aus *einer* Byte-Gleichheit wird eine Menge; Skript und
  Kontrolle sind neu zu schneiden.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) (Festlegung 4),
[ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) und
[`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) auf
Konsistenz geprüft hat und ihr Report ohne blockierenden Befund an der **Substanz** der sieben
Festlegungen in `docs/reviews/` liegt.** Ein blockierender Befund an der **Darstellung** (Adressform,
Zahl ohne Kommando) wird behoben und hindert die Annahme nicht. Der Beleg ist eine Runde der
prüfenden Rolle; die Nachmessung durch den Kontext, der einen Befund aufgelöst hat, ist keine
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2); die
Accept-Zeile der §Geschichte nennt ihn als **Kennung**, nicht als Pfad-Link (ebenda, Festlegung 1).
**Die Annahme selbst ist die Entscheidung des Auftraggebers.**

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-24 | **Proposed** | Architect-Lauf zum Slice-Plan des Tap-Nachzugs (§6 Frage 1), ausgelöst durch den Befund am Schnitt `v0.2.3` und die Setzung des Auftraggebers vom 2026-09-24 (Variante C: ein Werkzeug zieht die Formel je Release nach). Ausgeformt: ein Skript mit zwei Aufrufern (Release-Job und `make`-Ziel), Token auf ein Repo und `Contents` beschränkt, Byte-Kontrolle gegen das veröffentlichte Asset, Fehlschlag laut mit wartender Meldung. Der Acceptance-Trigger steht oben |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0064` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
