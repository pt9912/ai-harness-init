# ADR-0064: Der Tap-Nachzug ist ein Werkzeug — ein Skript mit zwei Aufrufern (Release-Job und `make`-Ziel), ein eng geschnittenes Zugangsgeheimnis im Umgebungs-Secret, und eine Kontrolle, die Byte-Gleichheit gegen das veröffentlichte Asset hält

**Status:** Proposed

**Datum:** 2026-09-24

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Kontrolle hält das Tap
gegen das **veröffentlichte** Asset, nicht gegen eine lokal erzeugte Kopie; das Transport-Bild ist
digest-gepinnt),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (der Host braucht weiter
nur git, docker, make — und die `bash`, unter der die Rezepte des Repos schon laufen),
[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) (**Accepted** — Festlegung 4:
Transport im gepinnten Bild, Netz nur an genau diesem Aufruf, kein Prerequisite, kein Gate; dieses
Muster wird wiederverwendet, nicht abgelöst),
[ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
(**Accepted** — Festlegung 1: das Manifest `SHA256SUMS` reist als Release-Asset, und Festlegung 2:
*„Das Binary trägt keinen Wert, der vom Bau-Ergebnis abhängt"*; die Formel wird aus diesem Manifest
gefüllt, und der Nachzug füllt sie **nicht** ein zweites Mal — dass die Formel selbst als Asset
reist, führt diese ADR nicht, die Quelle dafür ist der Release-Workflow
[`.github/workflows/release.yml`](../../../.github/workflows/release.yml) mit
[`harness/tools/homebrew-formula-fill.sh`](../../../harness/tools/homebrew-formula-fill.sh)),
[ADR-0063](0063-das-werkzeug-sagt-seine-fassung.md) (**Proposed** — die Binaries, die das Tap
ausliefert, tragen die Fassung des Tags; der Nachzug berührt sie nicht),
[ADR-0003](0003-go-native-binaries.md) (**Accepted** — Docker-only),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (**Accepted** — der
Accept-Übergang nennt den Beleg seines Triggers),
[`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (eine Quelle
je Check, versioniert; die CI ruft `make`-Ziele bzw. versionierte Skripte; gilt für jeden Job, der
auscheckt),
[`MR-069`](../../../harness/conventions.md#mr-069--ein-job-der-bewusst-nicht-auscheckt-trägt-seine-prüfung-inline)
(der `publish`-Job bleibt der Job ohne Checkout; er bekommt kein Geheimnis),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl steht neben dem Kommando, das sie liefert; keine ist ein Erwartungswert)

**Kein Bezug — [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix):** die Matrix
fordert Binaries für sechs Plattformen und ihren Plattform-Nachweis; ein Tap führt der Vertragstext
nicht (`grep -ciwE 'tap|homebrew' spec/lastenheft.md` → 0, gemessen 2026-09-24; das Wort steht in keiner
Anforderung und in keiner Historien-Zeile). Der Workflow-Kopf und die Release-Prozedur nennen [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) für die
Tap-Verteilung; das trägt der Vertrag nicht, und diese Entscheidung übernimmt den Bezug nicht.

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
der Auftraggeber hat den Nachzug von Hand gepusht. Vorgelegt waren drei Formen: Handarbeit mit
Kontrolle (A), eine lesende Kontrolle als Ziel (B) und ein Werkzeug, das den Nachzug selbst fährt
(C).

**Die Richtung ist gesetzt: C.** Der Auftraggeber hat am 2026-09-24 entschieden, dass ein Werkzeug
die Formel je Release selbst nachzieht. Diese Entscheidung formt sie aus — dieselbe Lage wie in
[ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) §Kontext
(*„Die Richtung ist gesetzt …; diese Entscheidung formt sie aus"*). Offen waren die **Form**
(`make`-Ziel, Release-Job oder beides), das **Zugangsgeheimnis samt seinem Ort**, die
**Docker-only-Einordnung**, die **Kontrolle samt Rot-Beleg** und das **Verhalten bei einem
Fehlschlag**; die verworfenen Wege stehen mit ihrem Grund in §Verglichene Alternativen.

### Die Lage, gemessen

Fünf Messungen tragen die Abwägung, alle datiert (2026-09-24) und neben ihrem Kommando. Keine ist
ein Erwartungswert
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert));
das Tap und das jüngste Release wandern mit jedem Schnitt.

- **Der Release-Workflow kennt kein Zugangsgeheimnis.** Sein `publish`-Job trägt
  `contents: write` mit dem `github.token` des eigenen Repos; ein Push in ein zweites Repo trägt
  dieses Token nicht:

  ```sh
  grep -cE 'secrets\.' .github/workflows/release.yml                # 0
  grep -nE 'contents: (read|write)|GH_TOKEN' .github/workflows/release.yml
  # 47: contents: read (Workflow-Ebene) · 133: contents: write (publish-Job) · 157: GH_TOKEN aus github.token
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

- **Was das Transport-Bild trägt.** Das Bild, das `make traeger-fetch` im Digest-Pin führt, hat für
  die Nutzlast `curl`, `base64` (mit `-w`), `cmp`, `sha256sum`, `sed`, `awk`, `od` und die
  Shell-Builtins; es hat **kein** `jq`, kein `bash`, kein `git`, kein `gh`:

  ```sh
  docker run --rm --pull=never --entrypoint sh <Bild aus harness/tools/traeger-fetch.sh> -c \
    'for p in curl base64 cmp sha256sum sed awk od jq bash git gh; do command -v $p >/dev/null && echo "$p ja" || echo "$p nein"; done'
  # curl ja · base64 ja · cmp ja · sha256sum ja · sed ja · awk ja · od ja · jq nein · bash nein · git nein · gh nein
  ```

- **`releases/latest` ist die falsche Größe für einen Vorwärts-Schutz.** Die Schnittstelle nennt das
  jüngste **erstellte** stabile Release, nicht die höchste SemVer-Fassung; ein später veröffentlichter
  stabiler Tag einer älteren Linie wäre `latest`:

  ```sh
  gh api repos/pt9912/ai-harness-init/releases/latest --jq .tag_name   # v0.2.3
  ```

  Die Größe, gegen die ein Nachzug **nicht zurückstellen** darf, ist die Fassung, die das Tap
  **trägt** — sie steht in der `version`-Zeile der Formel am Tap-Kopf (Festlegung 3).

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
beschränktes Token, das als Umgebungs-Secret nur einem Job zugänglich ist, der an einem Tag läuft.**
Sieben Festlegungen.

**1. Ein Skript, zwei Aufrufer, ein Ablauf.** Die Logik — Quelle holen, Tap lesen, vergleichen,
schreiben, nachkontrollieren — steht **einmal**, in einem versionierten Skript
([`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) Setzung 1:
ein Check wird nie in der YAML definiert; der Job `tap` checkt aus und trägt darum **keine**
Prüfung inline). Zwei `make`-Ziele fahren es:

- `make tap-check TAG=<tag>` — **nur lesend**: hält die Formel am Tap-Kopf gegen das Asset des
  Tags (Festlegung 2). Keine Anmeldung nötig, solange das Tap öffentlich ist.
- `make tap-nachzug TAG=<tag>` — schreibt bei Abweichung die Formel nach (Festlegung 3) und
  kontrolliert danach erneut. Braucht das Zugangsgeheimnis.

Der **Ablauf** ist für beide Modi **einer**; die Schritte, die ein Modus nicht kennt, entfallen, die
Reihenfolge der übrigen bleibt:

| Schritt | `check` | `sync` |
|---|---|---|
| a. Tag-Form prüfen (Tag als Eingabe, s. u.) | ja | ja |
| b. Zugangsgeheimnis vorhanden | — | ja |
| c. Vorab-Tag → Exit 0, das Tap bleibt | ja | ja |
| d. Vorwärts-Schutz | — | ja |
| e. Vergleich (Festlegung 2) | ja | ja |
| f. Schreiben, optimistisch | — | bei Abweichung |
| g. Nachkontrolle | — | nach dem Schreiben |

**Der Tag ist Eingabe aus einer nicht vertrauenswürdigen Quelle.** Ein Git-Ref-Name darf `$`, `(`, `)`,
`;` und Backtick tragen. Darum gilt an **allen** Stellen, an denen er in ein Kommando reicht:

- **Übergabe über die Umgebung, nie über Text.** Der Job reicht `github.ref_name` als Step-`env`
  durch; im `run:`-Text steht kein `${{ … }}`-Ausdruck. Das `make`-Rezept expandiert den Tag nicht in
  Shell-Text (`$(TAG)` in einer Rezeptzeile wäre die zweite Injektionsstelle), sondern übergibt ihn
  als Umgebungsvariable an das Skript.
- **Formprüfung vor jeder Verwendung** (Schritt a, auf dem Host, vor `docker`): SemVer mit führendem
  `v`, Pre-Release- und Build-Feld nur aus `[0-9A-Za-z.-]`. Jede andere Form endet mit Exit 2, bevor
  ein Netz-Zugriff oder ein Container-Start stattfand.

Der **Release-Job `tap`** ist der Regelweg: `needs: publish`, gleiche Bedingung wie `publish`
(`push` auf einen Tag), `environment:` mit dem Umgebungs-Secret (Festlegung 4), Checkout des Tags,
ein Schritt, der `make tap-nachzug` ruft — ohne eigene Logik in der YAML, insbesondere **ohne**
eigenen Nachweis, dass das Secret gesetzt ist: den Fall fängt das Skript (Schritt b). Das **lokale
Ziel** ist der Nachhol- und Ausfallweg: derselbe Aufruf mit dem Token des Auftraggebers aus seiner
Umgebung, ohne dass ein Geheimnis in der CI liegen muss. Beide Ziele stehen **nicht** in `gates` und
**nicht** in `record-gates` — sie brauchen Netz und (`tap-nachzug`) ein Geheimnis; ein Gate läuft
netzlos. Sie stehen in [`harness/README.md`](../../../harness/README.md) §Werkzeuge mit `kein Gate`
und in `targets.exempt-targets` der [`.d-check.yml`](../../../.d-check.yml) (exakt, kein Glob).

**2. Die Kontrolle: Byte-Gleichheit, Quelle das veröffentlichte Asset, Ziel der Branch-Kopf.**

- **Quelle** ist das Asset `ai-harness-init.rb` des Tags, **aus dem veröffentlichten Release
  geholt** (die Download-Adresse des Assets, wie sie `make traeger-fetch` für die Binaries nutzt) —
  nicht `dist/` des Bau-Jobs, nicht eine lokal gefüllte Kopie, nicht eine neue Füllung aus dem
  Skeleton. Der Nachzug führt keinen zweiten Füllvorgang: ein zweites Füllen wäre eine zweite
  Fassung derselben Formel, deren Digests an der `SHA256SUMS` des Schnitts hängen
  ([ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
  Festlegung 1).
- **Ziel** ist `Formula/ai-harness-init.rb` am **Kopf des Default-Branch** des Tap, gelesen über die
  GitHub-Schnittstelle (Contents-API), **nicht** über einen zwischengespeicherten Roh-Pfad und nicht
  aus einem lokalen Klon — ein Cache zwischen Push und Lesen zeigte sonst einen alten Stand als
  grünen. Das Lesen führt das Token mit, wenn es gesetzt ist (kein Rate-Limit-Rot auf einem geteilten
  Runner), und bleibt sonst anonym.
- **Vergleich** ist byte-genau. **Ausgang** in drei Klassen, an der Form erkennbar:

  | Exit | Bedeutung | Meldung |
  |---|---|---|
  | 0 | gleich — oder ein benannter Nicht-Gegenstand (Vorab-Tag) | nennt Tag, Tap-Kopf und den Digest, den beide tragen; bei einem Vorab-Tag *„Vorab-Tag, Tap bleibt"* |
  | 1 | **Formel-Unterschied** | nennt beide Digests und die erste abweichende Zeile |
  | 2 | **nicht ausführbar** — Tag-Form falsch, Asset nicht auffindbar, Tap nicht lesbar, Anmeldung fehlt oder abgelehnt, Vorwärts-Schutz, Aufruf falsch | nennt, was nicht erreicht wurde; **nie** als Unterschied |

  Ein Lesefehler ist damit nie 1 und nie 0: ein Rot, das aus einem Netzfehler kommt, sagt das, und
  ein Grün entsteht nur aus zwei gelesenen, gleichen Dateien — oder aus der ausgesprochenen
  Meldung eines Nicht-Gegenstands.

**3. Der Nachzug ist idempotent, und er schreibt nur vorwärts.** `sync` läuft in der Folge der
Tabelle aus Festlegung 1:

- **b. Kein Geheimnis → Exit 2** vor jedem Netz-Zugriff, mit einer Meldung, die den lokalen
  Ausfallweg nennt (`make tap-nachzug`). Ein übersprungener Nachzug ist genau der Zustand, der am
  Schnitt `v0.2.3` eintrat; **still überspringen ist die falsche Antwort**. Der Nachweis steht vor
  der Vorab-Regel, damit ein Vorab-Schnitt — die Probe der ganzen Kette — ein fehlendes Secret
  zeigt; **seine Gültigkeit und das Schreibrecht zeigt er nicht**, die belegt erst der erste
  stabile Lauf.
- **c. Vorab-Tag** (SemVer-Präfix mit `-`, Metadatum zuerst abgeschnitten — dieselbe Regel wie im
  `publish`-Job): das Tap folgt dem jüngsten **stabilen** Schnitt; der Lauf endet mit Exit 0 und
  der Meldung *„Vorab-Tag, Tap bleibt"* — ein benannter Nicht-Gegenstand, kein stilles Grün. Diese
  Regel gilt in **beiden** Modi: ein `tap-check` eines Vorab-Schnitts endet ebenso mit Exit 0, sonst
  könnte die Prozedur (Festlegung 6) für ihn nie grün werden.
- **d. Vorwärts-Schutz:** verglichen wird der Kern (`major.minor.patch`, **numerisch je Feld**)
  des Tags mit dem Kern der Fassung, die das Tap **trägt** — der `version`-Zeile der Formel am
  Tap-Kopf. Ist der Tag **kleiner**, endet der Lauf mit Exit 2 und schreibt nichts: ein Nachzug
  eines älteren Standes stellte das Tap auf eine Formel zurück, die kein zugesagter Weg mehr
  ausliefert. **Gleich** oder größer läuft weiter (ein erneut veröffentlichtes Asset desselben Tags
  wird nachgezogen). Ist die `version`-Zeile am Tap-Kopf nicht lesbar, ist das Exit 2. Der Maßstab
  ist der Tap-Stand, nicht die Reihenfolge der Veröffentlichungen: ein später erstellter, älterer
  Stabil-Tag geht nicht durch.
- **e. Vergleich.** **Gleich → Exit 0 ohne Schreibzugriff** (Idempotenz: ein Wiederholungslauf ist
  ohne Wirkung).
- **f. Abweichung:** die Formel wird mit **genau den Bytes des Assets** über die Contents-API in das
  Tap geschrieben, optimistisch gegen den gelesenen Blob-Stand — der Stand, gegen den geschrieben
  wird, gehört zu den Bytes, die verglichen wurden (aus derselben Antwort oder aus diesen Bytes
  berechnet). Ein Push dazwischen lässt den Schreibvorgang scheitern, statt ihn zu überschreiben;
  einen zweiten Versuch gibt es nicht. Ein Commit, dessen Message den Tag nennt.
- **g. Nachkontrolle:** `check` erneut am Branch-Kopf. Gleich → Exit 0. Nicht gleich → Exit 1.

Ein abgelehnter Schreibvorgang (Anmeldung, Schutz des Branches, Konflikt) endet mit Exit 2; das Tap
bleibt **unverändert**, und die Meldung sagt das.

**4. Das Zugangsgeheimnis: ein Token, das nur dieses Repo und nur `Contents` sieht, als
Umgebungs-Secret, und nie in einer Kommandozeile.**

- **Art und Scope:** ein *fine-grained* Personal Access Token des Auftraggebers, **beschränkt auf
  das eine Repository** `pt9912/homebrew-ai-harness-init`, mit der Berechtigung *Contents:
  Read and write* und **keiner weiteren**; mit Ablaufdatum (das längste, das die Plattform erlaubt).
  **Reichweite, vollständig:** *Contents: write* öffnet **jede Datei und jeden Ref** des Tap — die
  Formel, die README, weitere Branches und Tags —, nicht eine Datei; die Datei-Beschränkung auf
  `Formula/ai-harness-init.rb` liegt im Skript, nicht im Token. Workflow-Dateien des Tap verlangen
  eine eigene Berechtigung, die das Token nicht trägt; Administration und das Repository
  `ai-harness-init` erreicht es nicht.
- **Ort: ein Umgebungs-Secret, kein Repository-Secret.** `TAP_TOKEN` liegt als Secret einer
  **Umgebung** (`environment:` des Jobs `tap`) in `pt9912/ai-harness-init`, deren
  Bereitstellungs-Regel auf Tags `v*` beschränkt ist. Damit **erzwingt** die Plattform, dass nur ein
  Lauf an einem `v*`-Tag das Secret liest; ein Repository-Secret wäre dagegen von jedem Workflow
  jeder Branch-Fassung mit Schreibrecht lesbar, und *„nur in diesem Job"* bliebe Konvention. Anlage
  der Umgebung, ihrer Regel und des Secrets sowie Rotation sind **Handlung des Auftraggebers
  außerhalb des Repos**; das Repo trägt weder das Token noch eine Datei dafür. Das Secret steht
  **nur im Step-`env` des Schritts, der `make tap-nachzug` ruft**, nicht auf Workflow- oder
  Job-Ebene und nicht im `publish`-Job (der `contents: write` trägt und bewusst nichts anderes
  bekommt,
  [`MR-069`](../../../harness/conventions.md#mr-069--ein-job-der-bewusst-nicht-auscheckt-trägt-seine-prüfung-inline)).
  Der Job `tap` trägt für das eigene `github.token` nur `contents: read` und checkt mit
  `persist-credentials: false` aus.
- **Umgang im Werkzeug: nie in einer Kommandozeile, nie in der Ausgabe.** Das Token reist als
  Umgebungsvariable durchgereicht (`docker run -e TAP_TOKEN`, ohne Wert), auf dem Host wie im Bild.
  Im Bild schreibt die Nutzlast den Header **mit einem Shell-Builtin** in eine Datei mit
  Modus 0600 und übergibt sie an `curl` als `-H @<Datei>`; ein Bearer-Header als `-H`-Argument stünde
  in der Prozess-Kommandozeile des Containers und in der Prozessliste des Hosts. Die Datei wird
  beim Verlassen der Nutzlast entfernt (auch bei einem Fehler), das Skript läuft ohne `set -x`, und
  keine Meldung — auch keine Fehlermeldung mit einer Antwort der Schnittstelle — gibt das Token aus.
  Lokal liest `make tap-nachzug` dieselbe Variable aus der Umgebung des Aufrufers; wo der
  Auftraggeber sie hält, ist seine Sache.
- **Fehlt das Geheimnis, bricht der Nachzug laut** — das leistet Schritt b des Skripts (Festlegung 3),
  nicht die YAML.

**5. Docker-only, Aufteilung Host/Bild, Netz.** Der Transport läuft im **digest-gepinnten** Bild
([ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 4, dieselbe Bauart wie
`make traeger-fetch`); das Netz ist an genau diesem Aufruf nötig. Die Aufteilung ist entschieden:

- **Auf dem Host** läuft das Skript unter `bash` (dieselbe Voraussetzung wie `traeger-fetch.sh` und
  die Rezepte des Repos): Eingaben lesen, Tag-Form prüfen, Pin-Prüfung des Bildes, Schritt b, Vorab-Regel
  (Schritt c), `docker run`. Der Host trägt **kein** `gh`, `jq`, `curl` und `base64` — der Host braucht
  weiter git, docker, make
  ([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- **Im Bild** läuft eine **POSIX-`sh`-Nutzlast** über `curl`, `base64`, `cmp`, `sha256sum`, `sed`, `awk`
  und die Builtins: Asset und Tap-Stand holen, Vorwärts-Schutz und Vergleich, Schreiben,
  Nachkontrolle. Skalare Felder der Schnittstelle (Blob-Stand, Inhalt) liest sie mit `sed`/`awk`; ein
  `jq` gibt es dort nicht (§Lage).
- **Maßstab für ein eigenes Bild:** die Nutzlast ruft nur Programme des gemessenen Bestands (§Lage)
  auf; ein Programm außerhalb dieses Bestands erlaubt ein eigenes, gepinntes Bild, und **der Beleg**
  ist die Sonde `command -v <Programm>` im Bild, die es nicht findet. Ohne solchen Beleg steht der Pin
  des Bildes **nicht ein zweites Mal** da.
- Das Skript trägt eine **Pin-Prüfung** wie `traeger-fetch.sh` (ein nicht digest-gepinntes Bild bricht
  mit Exit 2).
- Der Entscheidungskern (Tag-Form, Vorab-Regel, Vorwärts-Schutz, Vergleich, Exit-Klassen) und die
  Nutzlast sind **hermetisch** prüfbar: die Quellen (Asset, Tap-Stand, Schreib-Antwort) sind
  injizierbar, die Nutzlast ist eine eigene Datei, die ein `bats`-Fall mit einem `curl`-Stub ohne Netz
  und ohne Container fährt.

**6. Ein Fehlschlag bricht laut, und die Meldung des Schnitts wartet.** Schlägt der Job `tap` fehl,
ist das Release **veröffentlicht und bleibt es** — ein Rückbau eines veröffentlichten Releases wäre
schlimmer als ein veraltetes Tap. Der Lauf ist rot; die Meldung des vollzogenen Schnitts geht erst,
wenn `make tap-check TAG=<tag>` mit Exit 0 endet (Schritt der Release-Prozedur in
[`docs/user/releasing.md`](../../user/releasing.md), neben der Wartestelle für die CI; für einen
Vorab-Tag endet er mit Exit 0 und der Meldung des Nicht-Gegenstands, Festlegung 3). Der
Wiederholungslauf des Jobs und der lokale Aufruf von `make tap-nachzug` sind **konvergent**
(Festlegung 3). Der `tap-check` der Prozedur ist ein **vom Job unabhängiger Beleg**: er hält auch
dann, wenn der Job grün endete und nichts geschrieben hat.

**7. Wechselwirkung mit den Accepted-ADRs — nichts wird abgelöst.**
[ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) bleibt in Kraft: der Träger-Pin, das
Ziel `traeger-fetch` und dessen Transport-Bild bleiben unberührt; der Nachzug nutzt sein Muster.
[ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) bleibt: die
Digests der Formel stammen aus der `SHA256SUMS` des Schnitts (der Füllschritt des Release-Workflows),
und der Nachzug liest die fertige Formel nur; kein Wert der Formel hängt von einem zweiten Bau ab.
[ADR-0063](0063-das-werkzeug-sagt-seine-fassung.md) bleibt: die Binaries, auf die die Formel zeigt,
melden den Tag, aus dem sie gebaut sind; die Kontrolle vergleicht **Bytes**, keine Versions-Strings.
Die Festlegung 2 von ADR-0059 (*„Das Binary trägt keinen Wert, der vom Bau-Ergebnis abhängt"*) wird
von einem Nachzug **außerhalb** des Binaries nicht berührt. Die Release-Prozedur bekommt ihren
Schritt; den Wortlaut trägt die Umsetzung der Folgepflicht 3, nicht diese Entscheidung.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — Handarbeit des Auftraggebers, die Kontrolle als Kommando in der Prozedur | kein Code, kein Geheimnis; der Schritt, der fehlte, ist benannt | derselbe Fehler bleibt: ein Schritt, den ein Mensch vergessen kann, und den kein Sensor hält; die Kontrolle als Kommando in einer Prozedur ist unversioniert ausführbar und ohne Rot-Beleg; das Kommando braucht auf dem Host `gh`/`curl` oder eine Kopie in der Prosa |
| B — Handarbeit, die Kontrolle als lesendes `make`-Ziel im gepinnten Bild | die Kontrolle ist versioniert, Docker-only, hat ihren Rot-Beleg; kein Geheimnis | der Nachzug bleibt Handarbeit: `v0.2.3` versagte, weil ein Schritt fehlte, B liefert den Schritt und die Kontrolle, aber nicht den Vollzug; die Kontrolle sagt nach dem Vergessen nur *dass* es fehlt |
| C1 — nur ein lokales `make`-Ziel, das mit dem Push-Recht des Auftraggebers nachzieht | kein Geheimnis in der CI, keine neue Vertrauensgrenze; ein Kommando statt Handarbeit | bleibt ein Aufruf, den ein Mensch nach dem Schnitt tun muss — dieselbe Fehlerklasse wie A, nur billiger; der rote Fall zeigt sich nicht im Release-Lauf |
| C2 — nur ein Release-Job mit Token (kein lokales Ziel) | der Nachzug geschieht ohne Zutun; Fehlschlag rot im Release-Lauf | ein abgelaufenes oder widerrufenes Token blockiert den Nachzug ohne Ausweg außer Handarbeit außerhalb des Werkzeugs; die Kontrolle wäre nur im Job erreichbar |
| D — Release-Job mit **Deploy-Key** (SSH) statt Token | der Schlüssel gilt inhärent nur für ein Repo, läuft nicht ab | die Contents-API nimmt keinen SSH-Schlüssel: der Weg wird `git clone`/`push` im Bild mit Identität, `known_hosts` und Schlüssel-Datei im Container — mehr bewegliche Teile ohne den Vorteil der optimistischen Einzeldatei-Schreibung; das Bild trägt kein `git`; die Kontrolle (Lesen) bräuchte den zweiten Transport daneben |
| E — Pull: ein Workflow **im Tap-Repo** holt die Formel vom jüngsten Release (Zeitplan oder Dispatch) und committet mit dem eigenen Token | kein Geheimnis in diesem Repo | die Logik liegt in einem Repo außerhalb dieses Baums (unversioniert hier, ohne Test in `make test`), ein Fehlschlag ist im Release-Lauf nicht sichtbar, die Latenz hängt am Zeitplan; ein Dispatch aus dem Release-Lauf brauchte wieder ein Zugangsgeheimnis für ein zweites Repo |
| G — das Token als **Repository-Secret** statt als Umgebungs-Secret | keine Umgebung anzulegen | *„nur in diesem Job"* ist Konvention: jeder Workflow jeder Branch-Fassung mit Schreibrecht liest `secrets.TAP_TOKEN`; die Plattform erzwingt nichts |
| **F — ein Skript, zwei Aufrufer: Release-Job als Regelweg, `make`-Ziel als Nachhol- und Ausfallweg, Token auf ein Repo und `Contents` beschränkt, als Umgebungs-Secret an `v*`-Tags gebunden (gewählt)** | der Nachzug geschieht ohne Zutun und ist im Release-Lauf sichtbar; die Kontrolle ist unabhängig davon aufrufbar; das lokale Ziel ist der Weg, wenn das Token fehlt oder abgelaufen ist; die Logik steht einmal; die Plattform bindet das Secret an einen Tag-Lauf | eine neue Vertrauensgrenze (ein Geheimnis für ein zweites Repo); eine Umgebung samt Regel ist einmal außerhalb des Repos anzulegen; ein zweiter Aufrufer kostet eine `make`-Zeile und eine README-Zeile; ein Token mit Ablaufdatum wird gepflegt |

**Warum beides und nicht das Kleinere.** C1 kostet am wenigsten und wäre der Weg, wenn das
Versäumnis am Zeitaufwand gelegen hätte; gemessen fehlte am Schnitt `v0.2.3` aber **der Träger**, der
den Vollzug ohne Erinnerung fährt — C1 lässt ihn weg. C2 schließt diese Lücke, macht aber ein
abgelaufenes Token zu einem Schnitt, der nicht mehr vollzogen werden kann. Der zweite Aufrufer von F
kostet eine `make`-Zeile über demselben Skript und öffnet den Ausfallweg, der C2 fehlt.

## Konsequenzen

- **Positiv:** der Nachzug hängt nicht mehr an der Erinnerung; die Kontrolle „Tap-Formel ==
  Release-Asset" ist ein versioniertes Werkzeug mit Exit-Klassen statt einer Prosa-Zeile; ein
  Fehlschlag ist im Release-Lauf rot und nicht im Tap stumm; das Geheimnis öffnet ein Repo und eine
  Berechtigung und ist für einen Lauf an einem `v*`-Tag bestimmt.
- **Negativ:** eine Vertrauensgrenze, die der Workflow bisher nicht überschritt — wer ein `v*`-Tag
  pushen kann, erreicht das Token (siehe §Grenze); ein Token mit Ablaufdatum ist zu erneuern; eine
  Umgebung samt Regel ist zu pflegen; ein Fehlschlag des Jobs lässt das Release veröffentlicht und
  das Tap veraltet, bis der Ausfallweg gelaufen ist.
- **Folgepflicht 1 — das Werkzeug:** Skript samt Nutzlast, die zwei `make`-Ziele, die zwei Zeilen in
  [`harness/README.md`](../../../harness/README.md) §Werkzeuge (`kein Gate`), **beide Ziele als Einträge
  in `targets.exempt-targets` der [`.d-check.yml`](../../../.d-check.yml)** (die Liste ist exakt; ohne
  Eintrag färbt das Doku-Gate im ersten Lauf rot) und `bats`-Fälle für den hermetischen Kern, jeder
  mit dem Rot-Beleg der §Fitness Function und nach [`AGENTS.md`](../../../AGENTS.md) §3.6.
- **Folgepflicht 2 — der Release-Job:** Job `tap` in `release.yml` (`needs: publish`, `environment:`,
  Checkout des Tags mit `persist-credentials: false`, `permissions: contents: read`, ein Schritt mit
  `make tap-nachzug`, Tag und Secret nur im Step-`env`, kein `${{ }}` im `run:`-Text) samt einem
  `bats`-Fall über die Job-Form. **Vorbedingung, außerhalb des Repos:** die Umgebung samt
  Tag-Regel und das Secret `TAP_TOKEN` existieren — die Anlage ist Handlung des Auftraggebers; ohne
  sie endet der erste Tag-Lauf laut (Schritt b).
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
  Auftraggebers. Ob der Wortlaut nachzuziehen ist, misst die Umsetzung der Folgepflicht 3 gegen den
  Stand.
- **Folgepflicht 6 — der Bezug [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) der Tap-Verteilung:** Workflow-Kopf, Formel-Füllschritt und
  Prozedur nennen ihn, der Vertragstext trägt ihn nicht (§Bezug). Ob das Tap eine Anforderung des
  Lastenhefts wird — oder der Bezug in diesen Artefakten entfällt — ist eine Entscheidung des
  Auftraggebers außerhalb dieser ADR; sie bindet keine Festlegung oben.
- **Folgepflicht 7 — kein `Supersedes`.** Keine Festlegung dieser Entscheidung löst eine Festlegung
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
  benennen sie als Nicht-Gegenstand. Der Vorwärts-Schutz vergleicht den Kern `major.minor.patch`; eine
  Formel, deren `version`-Zeile nicht lesbar ist, wird nicht angerührt (Exit 2) und ist von Hand zu
  heilen.
- **Herkunft.** Es gibt keinen Signier-Schritt
  ([ADR-0058](0058-traeger-per-fetch-aus-dem-gepinnten-release.md) benennt die Grenze): ein Asset,
  das ersetzt wurde, wird nachgezogen wie das echte.
- **dass der Job je läuft.** Dass `release.yml` den Job `tap` in seiner Form trägt, hält ein `bats`-Fall;
  dass die Prozedur den `tap-check` fährt, hält allein der Prozedur-Schritt (dieselbe Klasse wie die
  Schritt-Folge jeder Prozedur, ohne Sensor benannt im Beobachtungs-Register).
- **die Umgebung.** Dass die Umgebung existiert und ihre Regel auf `v*`-Tags steht, ist eine Einstellung
  außerhalb des Baums; kein Test in `make test` und kein Gate liest sie. Ihr Beleg ist die
  Einstellung selbst und der erste reale Tag-Lauf.
- **einen Schreib-Pfad, den ein Test in `make test` am realen Tap fährt.** Der Schreib-Vorgang am
  **realen** Tap ist ohne einen Schreibzugriff auf ein Fremd-Repo nicht herstellbar; der hermetische
  Test fährt ihn gegen eine nachgebildete Schnittstelle, und **der erste reale stabile Tag-Lauf mit
  dem Job ist sein Beleg** — benannt, nicht als bewiesen behauptet.

**Die Vertrauensgrenze, benannt:** *Contents: write* auf das Tap öffnet **jede Datei und jeden Ref**
des Tap (Festlegung 4); die Formel bestimmt, welche Binaries `brew` auf den Rechnern der Nutzer
installiert, der Schaden eines missbrauchten Tokens ist damit die Kompromittierung des
Verteilwegs — nicht die einer einzelnen Datei. Erreichbar ist das Token für jeden, der ein
`v*`-Tag im Repo `ai-harness-init` pushen kann: der Lauf am Tag führt das Workflow-Skript des
Tag-Baums aus und kann das Token lesen. **Das Umgebungs-Secret schließt Läufe an Branch-Fassungen aus,
nicht Läufe an einem Tag** — wer Tags anlegen darf, ist die Grenze, und wer Schreibrecht im Repo hat,
darf es. Der Scope des Tokens und sein Ablaufdatum begrenzen Umfang und Dauer, nicht das Ziel.

## Fitness Function (falls maschinell prüfbar)

Jede Zusage der Festlegungen steht mit dem Gegenbeispiel, das sie brechen lässt; jeder Fall wird
einmal rot gesehen ([`AGENTS.md`](../../../AGENTS.md) §3.6), die Ausgabe gelesen, nicht nur der
Exit-Code. **Schwächung** heißt: die Zusicherung wird testweise so verändert, dass sie nicht mehr
hält — der benannte Fall muss dann rot werden.

| Zusage | Fall (`bats`, hermetisch; Stubs für Asset, Tap-Stand, `curl`) | Rot unter der Schwächung |
|---|---|---|
| Vergleich: gleich → 0; verschieden → 1 mit beiden Digests und der ersten abweichenden Zeile; nicht lesbar → 2 | drei Fälle, der letzte mit unlesbarem Tap und unlesbarem Asset | jeder Fehler endet als Exit 1 → der Lese-Fall wird rot |
| Idempotenz: bei Gleichheit kein Schreibzugriff | Stub zählt Schreibaufrufe | das Skript schreibt immer → der Fall wird rot |
| Vorwärts-Schutz nach Tap-Stand: Tag-Kern kleiner als der Kern der `version`-Zeile → 2 ohne Schreibzugriff | Tap `0.2.3`, Tag `v0.1.2` — der ältere Stabil-Tag, den `releases/latest` als jüngstes erstelltes Release meldete; Gegenprobe: Tap `0.2.9`, Tag `v0.2.10` schreibt (numerisch je Feld) | Vergleich lexikografisch, oder Schutz entfernt → einer der zwei Fälle wird rot |
| Vorab-Tag: 0 mit *„Vorab-Tag, Tap bleibt"* in **beiden** Modi, ohne Netz-Zugriff; die Regel von Skript und `publish`-Job entscheidet dieselben Tags gleich | Tag-Liste aus dem `publish`-Job gelesen: `v1.0.0-RC`, `v1.0.0-rc.1+x`, stabil `v1.0.0+build-1` | Vorab-Regel nur in `sync` → der `check`-Fall wird rot; Metadatum nicht zuerst abgeschnitten → der `+build-1`-Fall wird rot |
| Tag-Eingabe: eine Form außerhalb der Liste → 2, bevor ein Container oder das Netz berührt wird | Tag `v1.0.0$(touch <marker>)` und `v1.0.0;x`: Exit 2, Marker-Datei fehlt, kein `docker`-Aufruf (Stub zählt); der `run:`-Text des Jobs `tap` enthält kein `${{` | Formprüfung entfernt → Marker/Aufruf-Zähler wird rot; `${{ github.ref_name }}` im `run:` → der Text-Fall wird rot |
| Fehlt-Nachweis: kein `TAP_TOKEN` in `sync` → 2 vor jedem Netz-Zugriff, Meldung nennt `make tap-nachzug` | Stub zählt Aufrufe: 0 | Nachweis entfernt → der Fall wird rot (Aufruf oder anderer Exit) |
| Token nie in einer Kommandozeile und nie in der Ausgabe | Nutzlast läuft mit einem Sentinel-Token und einem `curl`-Stub, der seine Argumentliste aufzeichnet: der Sentinel steht in **keiner** Argumentliste, in **keiner** Ausgabe (Erfolg, Konflikt, Ablehnung), und der Header liegt in einer Datei mit Modus 0600, die nach dem Lauf fehlt | Header als `-H "Authorization: Bearer $TAP_TOKEN"` → der Argument-Fall wird rot; Ausgabe der Antwort samt Header → der Ausgabe-Fall wird rot |
| Schreiben: die geschriebenen Bytes sind die des Assets | Stub dekodiert den Schreib-Inhalt und vergleicht mit `cmp` gegen das Asset (Endzeilenumbruch, Nicht-ASCII-Byte) | Base64 mit Zeilenumbruch oder abgeschnittener Endzeilenumbruch → der Fall wird rot |
| Optimistisch: das Schreiben trägt den Blob-Stand der verglichenen Bytes; ein Konflikt endet mit 2, ohne zweiten Versuch, Tap unverändert | Stub liefert beim Schreiben den Konflikt; er zeichnet den mitgesandten Stand und die Zahl der Schreibaufrufe auf: Stand gleich dem gelesenen, Aufrufe = 1 | Stand weggelassen → der Stand-Fall wird rot; Wiederholung mit frischem Stand → der Zähler-Fall wird rot |
| Nachkontrolle: nach dem Schreiben wird der Kopf erneut gelesen; Ungleich → 1 | Stub bestätigt das Schreiben, liefert beim erneuten Lesen aber den alten Stand | Nachkontrolle entfernt → der Fall endet 0 und wird rot |
| Pin-Prüfung: ein Bild ohne Digest → 2 vor `docker` | Fall wie in `test/traeger-fetch.bats` | Prüfung entfernt → der Fall wird rot |
| Job-Form: `release.yml` trägt einen Job `tap` mit `needs: publish`, gleicher Bedingung wie `publish`, `environment:`, `persist-credentials: false`, `permissions: contents: read`, einem Schritt `make tap-nachzug`; `TAP_TOKEN` steht in keinem Workflow- oder Job-`env`, nur im Step-`env`, und nicht im `publish`-Job | ein Fall je Zeile der Aufzählung | jede Zeile einzeln entfernt bzw. das Secret in Job-`env` oder `publish` gesetzt → der zugehörige Fall wird rot |
| **Rot-Beleg am realen Zustand, kein Gate:** die Kontrolle fängt einen Formel-Unterschied als Exit 1 mit der Meldung des Unterschieds (nicht 2) und meldet Gleichheit als 0 | `make tap-check` gegen das Asset von `v0.2.2` und den Tap-Kopf → Exit 1, die erste abweichende Zeile ist die `version`-Zeile; gegen `v0.2.3` → Exit 0. Das ist das **Gegenstück** des Vorfalls (dort war das Tap älter als das Asset, hier das Asset älter als das Tap): dieselbe Byte-Klasse, umgekehrte Richtung; der Vorfall selbst wird hermetisch nachgestellt, mit dem Asset von `v0.2.3` als Quelle und den Bytes von `v0.2.2` als Tap-Stand | — |
| `make mutate` (kein Gate) | Vorwärts-Schutz, Idempotenz-Zweig, Nachkontrolle, Optimistik-Stand, Tag-Formprüfung und Fehlt-Nachweis entfernt → der jeweilige Wächter fällt (kuratiertes Set) | — |

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
- **Wenn ein Tag-Lauf das Secret liest, obwohl kein Schnitt gewollt war** *(beobachtbar an einem
  `tap`-Lauf zu einem Tag, den der Auftraggeber nicht gesetzt hat)*: die Bindung an `v*`-Tags trägt
  nicht; neu zu wägen sind ein Schutz der Tag-Anlage im Repo oder ein Genehmigungs-Schritt der Umgebung.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde über die
dann geltende Fassung sie gegen
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
| 2026-09-24 | **Proposed** | Architect-Lauf, ausgelöst durch den Befund am Schnitt `v0.2.3` und die Setzung des Auftraggebers vom 2026-09-24 (Variante C: ein Werkzeug zieht die Formel je Release nach). Ausgeformt: ein Skript mit zwei Aufrufern (Release-Job und `make`-Ziel), Token auf ein Repo und `Contents` beschränkt als Umgebungs-Secret an `v*`-Tags, Byte-Kontrolle gegen das veröffentlichte Asset, Vorwärts-Schutz am Tap-Stand, Fehlschlag laut mit wartender Meldung. Der Acceptance-Trigger steht oben |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0064` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
