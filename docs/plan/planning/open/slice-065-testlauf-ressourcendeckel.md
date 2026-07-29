# Slice slice-065: Ressourcen-Deckel für den Go-Testlauf

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Mechanik). Der Anlass fiel in
[welle-09](../welle-09-modul-15-konformitaet.md), der Inhalt gehört nicht dorthin: die
Welle setzt Modul 15 um, dieser Slice härtet den Test-Pfad, an dem **alle** Wellen hängen.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(kein Gate über leerem Prüfbereich — ein Deckel, der nicht greift, ist genau das),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Testumgebung
bleibt gepinnt und hermetisch),
[`ADR-0003`](../../adr/0003-go-native-binaries.md) (Docker-only; der Umbau bleibt innerhalb
dieser Linie), [`AGENTS.md`](../../../../AGENTS.md) §3.6 (die neue Grenze braucht ihren
rot gesehenen Wächter — und die **bestehende** Cache-Zusage darf ihren nicht verlieren).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-29.

---

## 1. Ziel

**Ein Test, der außer Kontrolle gerät, kostet den Testlauf — nicht den Rechner.** Der
Go-Testlauf bekommt einen wirksamen Prozess- und Speicher-Deckel, ohne dass der Container
etwas vom Host gemountet bekommt.

**Der Anlass ist real und nicht hypothetisch** (slice-059, 2026-07-28): ein Test in
`cmd/span-emit/main_test.go` startete sich selbst als Kind-Prozess, um eine
Prozess-Eigenschaft zu messen. Solange die Klemme im Emitter stand, endete das Kind in
`os.Exit(0)`. Mutation 107 nahm die Klemme weg — und damit kehrte `main()` bei gültiger
Payload normal zurück, das Kind lief in den Test-Rumpf weiter und startete das nächste
Kind. Unbegrenzt. Der Mutations-Lauf legte den Arbeitsrechner lahm.

Der Defekt selbst ist behoben (die Abzweigung steht jetzt in `TestMain`, vor dem
Test-Framework). Dieser Slice behandelt die **Klasse**, nicht den Fall:
`make mutate` ist der einzige Sensor dieses Repos, der **absichtlich falschen Code
ausführt** — bei jedem anderen Gate lief der Code vorher durch Review. Sich beim
Containment auf die Wohlerzogenheit des Codes zu verlassen, den man gerade absichtlich
kaputt macht, ist zirkulär. Genau daran ist es gescheitert.

## 2. Definition of Done

- [ ] **(1) Der Testlauf läuft mit wirksamem Prozess- und Speicher-Deckel — und ohne
  Mount.** Der Quellcode kommt wie heute per `COPY` **ins Image**; der Container bekommt
  kein `-v`. Belegt an einer Messung, nicht an einer Flag-Zeile: eine **feste** Last
  (nicht rekursiv, keine Bombe) muss unter dem Deckel scheitern und ohne ihn durchlaufen.
- [ ] **(2) Die Grenze hat einen Wächter, der rot wird, wenn der Deckel fällt.** Ein Test,
  der eine feste Zahl gleichzeitiger Prozesse startet und deren **Scheitern erwartet**:
  mit Deckel grün, ohne Deckel rot. Er ist in beiden Zuständen ungefährlich, weil die Zahl
  fest ist — die Absicherung wird damit selbst bewacht, statt nur eingebaut zu sein
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] **(3) Die bestehende Cache-Zusage überlebt den Umbau — umgeschrieben, nicht
  gelöscht.** Heute gilt sie auf **zwei** Ebenen: `--no-cache-filter test` erzwingt, dass
  die Docker-SCHICHT neu ausgeführt wird, `-count=1`, dass die TESTS neu laufen. Bewacht
  von `test/dockerfile-teststufe.bats` und `test/mutations/98-teststufe-count.sh`. Mit
  `docker run` entfällt die erste Ebene (ein Run wird nie gecacht) — die **Zusage** bleibt
  („jeder Lauf misst wirklich neu"), ihr Beleg muss auf die neue Mechanik zeigen. Ein
  stillschweigend entfallener Wächter wäre hier der eigentliche Schaden.
- [ ] **(4) `make mutate` erbt die Deckel, ohne selbst angefasst zu werden** — er ruft
  `make test-go`. Das ist zu belegen, nicht anzunehmen.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-29, live an diesem Repo) — was greift und was nur so aussieht:**

| # | Weg | feste Last | Ergebnis |
|---|---|---|---|
| 1 | `docker build --resource memory=128m` | 300 MB | **wirkungslos** — Allokation lief durch. Das Flag wird **angenommen**, ohne zu wirken |
| 2 | `docker build --ulimit nproc=64` | 300 Kinder | **wirkungslos** — alle gestartet |
| 3 | `docker build --resource pids-limit=…` | — | `unknown resource` |
| 4 | `docker run --memory 128m` | 300 MB | **greift** — Exit 137 (cgroup-OOM-Killer) |
| 5 | `docker run --pids-limit 64` | 300 Kinder | **greift** — `Cannot fork` |
| 6 | `docker run` ohne `-v`, `--network none`, Deckel gesetzt | `go test ./...` | alle 7 Pakete grün, Exit 0 |
| 7 | Prozess-Abstammung eines Containers | — | `containerd-shim-runc-v2`, cgroup `/system.slice/docker-<id>.scope` |

Zeile 1 ist die wichtigste: ein Deckel, der **wie Schutz aussieht und keiner ist**. Wer ihn
einbaut, hält die Sache für erledigt.

Zeile 7 erledigt den naheliegenden Gegenvorschlag: `make mutate` in eine cgroup zu stecken
(`systemd-run --scope`, `ulimit -u`) wirkt **nicht** — Container-Prozesse hängen unter dem
Docker-Daemon, nicht unter dem Aufrufer. Der Deckel muss an den Container.

**Nicht gewählt und warum:** ein **Zeit**-Deckel je Mutationsfall (`timeout`). Er war der
erste Vorschlag und wurde vom Auftraggeber verworfen — beim aufgetretenen Absturz hätte er
nicht geholfen, weil die Ressourcenerschöpfung schneller eintritt als jede vertretbare
Zeitgrenze. Er bleibt eine mögliche Ergänzung gegen **Hänger**, ist aber gegen diese Klasse
wirkungslos und darf sie nicht scheinbar abdecken.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Dockerfile` | update | Eine Stage mit Quellcode, aber **ohne** `RUN go test`. Der Testlauf verlässt den Build |
| `Makefile` (`test-go`) | update | `docker run --rm --network none --pids-limit … --memory … <image> go test -count=1 ./...`. Kein `-v`: der Quellcode ist im Image. `--network none` ist eine Zugabe — der heutige Build läuft **mit** Netz |
| Wächter für die Grenze | neu | DoD (2). Ob er die Prozesse wirklich startet oder `/sys/fs/cgroup/pids.max` liest, entscheidet der Implementer **mit Messung**: das Lesen prüft die Konfiguration, das Starten die Wirkung — und §3.6 verlangt die Wirkung |
| `test/dockerfile-teststufe.bats` | update | DoD (3): die Cache-Zusage auf die neue Mechanik umschreiben |
| `test/mutations/98-teststufe-count.sh` | update | dito — die Mutation muss weiter den Wächter röten, der die Zusage trägt |
| `harness/tools/agent-watch.sh` | **vorhanden, einzubinden** | Der Melder existiert seit dem 2026-07-29 (entstanden in slice-059, dort als ungeplantes Artefakt benannt): er beobachtet die Werkzeugschicht und meldet ab einer Schwelle. **Unbewacht, kein Makefile-Ziel, kein `MR`-Eintrag.** Hier gehört er verankert — und er ist die zweite Hälfte des Themas: der Deckel begrenzt, der Melder sieht zu. Basislinie gemessen: ~3 GB im Normalbetrieb, ein serieller Agenten-Lauf kostet 0,15 GB |
| Zahlenwahl (`pids-limit`, `memory`) | Entscheidung | Kein Ratewert: aus dem realen Bedarf des Testlaufs messen und mit Abstand darüber setzen. Ein zu enger Deckel macht den Gate flatterig, ein zu weiter schützt nicht |

## 4. Trigger

**`open` → `next`:** wenn slice-059 geschlossen ist (er hält das WIP-Limit) **und** der
Zahlen-Bedarf aus Zeile „Zahlenwahl" gemessen vorliegt. Der Slice ist nicht dringend —
der auslösende Defekt ist behoben; offen ist die Klasse.

Rückführungen:

- `in-progress` → `next`: falls der Umbau von `test-go` die Cache-Zusage nicht sauber
  trägt. Dann trennt ein Re-Slice den Deckel (neu) von der Zusage (bestehend) — zwei
  verschiedene Verträge, zwei verschiedene Wächter.
- `in-progress` → `open`: falls sich zeigt, dass der Deckel den Testlauf in der CI anders
  trifft als lokal (andere cgroup-Version, andere Limits). Dann ist erst die Umgebung zu
  klären, nicht der Wert zu drehen.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt die DoD (Modul 11);
`make gates` und `make mutate` grün; `git mv` nach `done/` (eigener Move-Commit);
Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Ein Deckel, der nicht greift, ist schlimmer als keiner** — er behauptet Schutz. Zeile 1
  der Ist-Messung ist der Beleg, dass das hier kein theoretisches Risiko ist. Deshalb
  verlangt DoD (1) die Messung und nicht die Flag-Zeile.
- **Der zu enge Deckel.** Der Go-Testlauf startet selbst Prozesse (Compiler, Testbinaries,
  der Kind-Prozess in `cmd/span-emit/main_test.go`). Ein knapper Wert macht den Gate
  flatterig — und ein flatteriger Gate wird abgeschaltet.
- **Die Cache-Zusage ist der eigentliche Arbeitsanteil**, nicht der Deckel. Sie ist heute
  zweistufig belegt; wer nur die Flags umstellt, lässt einen Wächter still ins Leere
  zeigen.
- **Der Wächter aus DoD (2) misst eine Umgebungs-Eigenschaft**, keine Code-Eigenschaft: er
  ist grün, weil der Aufrufer den Deckel setzt. Läuft der Testlauf je anders (ohne
  `make test-go`), schlägt er fehl — das ist beabsichtigt, gehört aber ausgesprochen.
- **Nicht in diesem Slice:** eine Regel, die die gefährliche **Form** verbietet (ein
  `_test.go`, das sich selbst re-exec't, muss in `TestMain` abzweigen). Das wäre ein
  hermetischer Gate neben `make comment-claims` und trifft den Anlass direkter als jeder
  Deckel — aber es ist eine eigene Zusage mit eigenem Wächter. Kandidat für einen
  Folge-Slice; hier bewusst **nicht** mitgenommen, damit der Deckel nicht mit einer
  Konventions-Prüfung vermischt wird.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `Makefile`,
`Dockerfile` und `test/` gehören zum Greenfield-Bestand dieses Repos, der Modus steht in
der Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
