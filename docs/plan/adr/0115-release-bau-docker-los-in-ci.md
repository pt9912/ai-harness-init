# ADR-0115: Docker entfällt insgesamt — der Release-Bau cross-kompiliert host-nativ in CI

**Status:** Accepted

**Datum:** 2026-11-28

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Revidiert (Teil-Supersede):** den Build-Satz des Entscheidungs-Abschnitts von
[ADR-0003](0003-go-native-binaries.md)
(*„Der **Build** erfolgt **Docker-only**: Cross-Compile im gepinnten Build-Image, **kein
Host-`go`**"*) samt seiner Fitness-Zeile (*`make build` — Cross-Compile je Plattform im Image,
kein Host-`go`*). Die übrigen Festlegungen von [ADR-0003](0003-go-native-binaries.md) bleiben
**Accepted** und unberührt: Go als Implementierungssprache, native Binaries je
`GOOS`/`GOARCH` als Auslieferungsform, die Verwerfung des Docker-in-Docker-Weges, der Supersede
von [ADR-0002](0002-test-tooling-grenze.md)
<!-- d-check:ignore (Lineage-Verweis auf superseded ADR) -->. Genau der Trigger von ADR-0003
(*„Wenn ein air-gapped/registry-freier Vertrieb zur Pflicht wird — kein Docker-Pull beim Build —
→ Build-Model neu bewerten"*) greift hier: die Neubewertung ist diese ADR.
[ADR-0109](0109-gates-lauefer-docker-los-image-weg-opt-in.md) wird nicht revidiert, sondern
**geschlossen an seiner letzten offenen Kante**: der Release-Bau war dort als einziger Pflicht-
Rest beim gepinnten Bild stehen geblieben (*„bis sie liegt, fahren die gepinnten Image-Rezepte
weiter"*) — die Ausnahme entfällt mit Festlegung 2; der opt-in Weg bleibt opt-in (gepinnt,
ungestrichen). §3.5 bindet auch diese Entscheidung: der Tool-Bau ist ein Gate-Getriebener Weg,
seine Umstellung ist diese ADR, kein PR-Kommentar.

**Bezug:**
[`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (die Matrix
linux · macos · windows × amd64 · arm64 — sechs Binaries; die Messmethode mit Start-Smoke auf den
nicht-Linux-Plattformen bleibt unverändert),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Repro-Träger wandert
vom Image-Pin zum Inventar-Pin — Festlegung 3),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (docker ist Weg, keine
Pflicht — mit dieser Entscheidung wörtlich für jeden Pflicht-Pfad),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), (kein
Target nennen, das nicht existiert — `release-artifacts-host` entsteht im Implementations-Slice),
[ADR-0109](0109-gates-lauefer-docker-los-image-weg-opt-in.md) (Pflicht-Weg docker-los, Image-Weg
opt-in — hier geschlossen an der Release-Kante),
[ADR-0003](0003-go-native-binaries.md) (der revidierte Bau-Weg),
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 4 (der
Runner-Rest — hier um die Toolchain-Fassung der Runner-Umgebung erweitert, am Pin geprüft, nicht
gepinselt),
[ADR-0063](0063-das-werkzeug-sagt-seine-fassung.md) (die ldflags-Fassungs-
Injektion — unverändert übernommen),
[ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
(Folgepflicht 1: die SHA256SUMS entsteht am selben Ort wie die Assets),
[`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (Setzung 1:
ein Check lebt versioniert im Repo, der Step ruft ihn nur — der Release-Job ruft
ausschließlich make-Ziele),
[`MR-098`](../../../harness/conventions.md#mr-098--die-umgebungs-zusage-trägt-mischform-die-dogfood-gates-und-lab-läufer-fahren-am-host)
(der Umgebungs-Zusage Mischform: abgeleitete Pin-Stelle, Manifest je übriges Werkzeug),
[`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
(Anlage-Disziplin der Mutations-Fälle)

**Schärft:**
[`spec/architecture.md §3 Externe Abhängigkeiten`](../../../spec/architecture.md#3-externe-abhängigkeiten)
— `ARC-012` (docker) und `ARC-013` (Go-Toolchain) tragen dort den Docker-only-Bau; die
Fortschreibung ist ohne Vertragsänderung zulässig und gehört in denselben Zug (Festlegung 5).
Das Lastenheft bleibt unverändert: [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
verspricht docker als Weg, keine Pflicht — jetzt wörtlich.

---

## Kontext

[ADR-0109](0109-gates-lauefer-docker-los-image-weg-opt-in.md) stellte Checks, Lab-Läufer und
Smokes docker-los; der Release-Bau blieb bewusst beim gepinnten Bild — die letzte Stelle, an der
ein Lauf einen Daemon braucht. Der Auftraggeber hat entschieden, Docker **ingesamt** entfallen zu
lassen, auch dort: die six-Plattform-Matrix der Release-Artifacts wird auf einem Linux-Runner
host-nativ cross-kompiliert. Die Form liegt bereits neben dem Weg: [`make
host-bin`](../../../harness/sensors/host-bin.md) baut den Traeger am Host je
`CGO_ENABLED=0`/`GOOS`/`GOARCH`/`-trimpath` (ADR-0109-Fassung); der Release-Bau generalisiert
dieselbe Form auf die Plattform-Matrix.

## Entscheidung

Wir wählen: **Der Release-Bau ist ein make-Ziel am Host, CI ruft es auf einem Linux-Runner; die
gepinnten Docker-Rezepte des Werkzeug-Baus wandern vollständig in die opt-in-Klasse; der
Repro-Träger ist der Inventar-Pin statt des Image-Digests.** Sechs Festlegungen:

**1. Der Release-Bau host-nativ in CI.** Neues make-Ziel
`release-artifacts-host` (Form des Rezepts [`make host-bin`](../../../harness/sensors/host-bin.md),
generalisiert auf die Matrix): je `RELEASE_PLATFORMS`-Eintrag (Linux/AMD64, Linux/ARM64,
Darwin/AMD64, Darwin/ARM64, Windows/AMD64, Windows/ARM64) ein Cross-Compile je
`CGO_ENABLED=0`, `GOOS`/`GOARCH`, `-trimpath`, ldflags-Fassungs-Injektion je
[ADR-0063](0063-das-werkzeug-sagt-seine-fassung.md) Festlegung 1 je
`TRAEGER_VERSION`, danach `release-sums.sh generate` und `homebrew-formula-fill.sh` am selben
Ort ([ADR-0059](0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
Folgepflicht 1; [LH-QA-04](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)). Der
`artifacts`-Job der [release.yml](../../../.github/workflows/release.yml) ruft nur dieses Target
([`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) Setzung
1 — kein Check in der YAML, dieselbe Form wie die Gates- und Mutations-Jobs je
[ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) Festlegung 2: CI führt
ausschließlich make-Ziele aus); der Runner-Daemon ist dort kein Weg mehr. Die Plattform-Runner
bauen weiter nichts — sie starten (`start-smoke.sh`, unverändert; kein make, kein docker dort,
das war schon die alte Grenze).

**2. Die Docker-Stufen des Werkzeug-Baus liegen vollständig in der opt-in-Klasse**
([ADR-0109](0109-gates-lauefer-docker-los-image-weg-opt-in.md)-Fassung). `release-artifacts`,
`artifact`, `artifact-host`, `build`, `build-image`, `host-bin-image`, `compile` bleiben als
gepinnte Image-Rezepte stehen — byte-genau dieselben Pins, ungestrichen (ADR-0109-Festlegung:
kein Rückbau des opt-in Weges); kein Lauf der Pflicht-Kette ruft sie mehr, und die
release.yml-Grenze an den gepinnten Bild (*der Runner-Daemon ist hier Weg*) wird mit der
Umstellung entfallen. Die Pflicht-Kette dieses Repos trägt nach dieser Entscheidung kein
daemon-gebundenes Zug mehr.

**3. Der Reproduzierbarkeits-Träger wandert vom Image-Pin zum Inventar-Pin**
([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
Die Docker-Form hielt die Bau-Reproduzierbarkeit über den gepinnten Image-Digest; die host-Form
trägt sie über die abgeleitete Pin-Stelle
([`MR-098`](../../../harness/conventions.md#mr-098--die-umgebungs-zusage-trägt-mischform-die-dogfood-gates-und-lab-läufer-fahren-am-host)-Mischform):
die CI-Install-Konfiguration richtet die Go-Toolchain aus dem `GO_VERSION`-Pin-Ort des
Makefiles ein — ein Wert, keine zweite Version-Stelle, und der Tool-/Versions-Check
(erster Check der Gates) belegt am Host die Fassung desselben Pins. Statisch und
plattform-frei (`CGO_ENABLED=0`) bleibt der Bau plattform-übergreifend vom Linux-Runner aus;
zwei Läufe desselben Baums mit derselbe Pin-Fassung liefern byte-identische
SHA256SUMS ([LH-QA-02](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), geprüft je
Fitness). Der Runner-Rest
([ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 4) wächst um
die Runner-Umgebung der Toolchain — am Pin geprüft, außerhalb eines Pins gepinselt nicht;
die SKIP-Belehnform der CI behauptet kein Runner-Verdikt.

**4. Der Release-Schnitt und die Pin-Züge bleiben, wie sie sind.**
[traeger-pins-check](../../../harness/sensors/traeger-pins-check.md) (Pin gegen Publikation),
[tap-check](../../../harness/sensors/tap-check.md)/[tap-nachzug](../../../harness/sensors/tap-check.md)
(Formel gegen Asset) messen Bau-unabhängig — der Bau-Wechsel berührt ihre Zusage nicht, sie
halten weiter nicht die Bau-Vs-Bau-Kante (whether ein Neubau die Digests des opt-in Wegs trifft,
und die Asset-Menge, hält kein Sensor, das trägt der Release-Schnitt selbst). Die Grenze aus
[ADR-0109](0109-gates-lauefer-docker-los-image-weg-opt-in.md) §3.9-Verwandtschaft bleibt:
macOS ist für die Host-Läufer dieses Repos nicht getragen — die Einzelfahrt dort bleibt
Hilfe ohne Anspruch; der Release-Bau ist Linux-Runner-Sache und wird es bleiben (der
Start-Smoke ist der Plattform-Nachweis, nicht der Bau).

**5. Die Spec-Fortschreibung gehört in denselben Zug.**
[`spec/architecture.md §3`](../../../spec/architecture.md#3-externe-abhängigkeiten) trägt den
Bau-Weg im dritten Stratum (Rang 3); ADR-0115 rangiert darunter, und ein stehender
Widerspruch zwischen Rang 3 und Rang 4 wäre eine zweite Quelle derselben Aussage, die drifft.
Die Fortschreibung ist ohne Vertragsänderung zulässig (Sicht, meilensteinfrei) und minimal:
`ARC-012` (docker) wird zur opt-in-Bild-Rezept-Klasse (Substituierbar: ja — der Pflicht-Weg
ist docker-los), `ARC-013` (Go-Toolchain) wird zur Host-Toolchain am Inventar-Pin
(Tool-Bau/Cross-Compile host-nativ), der Blockquote-Satz folgt. Das Lastenheft (Rang 1)
bleibt unberührt — es verlangte nie Docker
([LH-QA-03](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).

**6. Implementations-Slice-Skizze, Kennung `slice-release-bau-dockerlos-v1`.**
Drei Liefer-Punkte, je zwei Schichten (Build-Mechanik + CI-Form): (a) das make-Ziel
`release-artifacts-host` (Tafel über `RELEASE_PLATFORMS`, Cross-Compile je Plattform,
SHA256SUMS + Formel am selben Ort) samt der Wächter-Klasse (Matrix-Vollständigkeit je
LH-QA-04 — eine gestrichene Plattform-Zeile färbt rot; Fehlt-Fall der Fassungs-Injektion am
`--version` je [ADR-0063](0063-das-werkzeug-sagt-seine-fassung.md)
Festlegung 2, rot-vor am realen Bau); (b) die CI-Fassung: `artifacts`-Job ruft das Host-Target,
die Toolchain-Install aus dem Pin, die Entfallen-Grenze der gepinnten Bild-Ausnahme in der
release.yml-Kopfkommentar-Fassung; der reale Tag-/Dispatch-Lauf belegt die Kette (die CI ist
dort das Netz, [`MR-003`](../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Form);
(c) die Spec-Fortschreibung (Festlegung 5) samt der README-/Sensor-Zellen, die den release-Bau
docker-getrieben nennen — sie nennen nach der Umstellung der host-Form, der opt-in Weg je
ADR-0109-Form. Mutations-Fälle je
[`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit):
(a-1) die Matrix-Tafel verliert still eine Plattform-Zeile → Wächter rot; (a-2) die
ldflags-Injektion fällt still weg → Wächter rot am `--version`-Fehlt-Fall; (b-1) der CI-Step
ruft das Docker-Target oder ein Inline-Compile statt des make-Ziels → Wächter rot (die
MR-014-Setzung-1-Form: die YAML nennt nur make-Ziele).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — Status quo (Docker-only Bau, [ADR-0003](0003-go-native-binaries.md)) | ein Digest-Pin trägt die Reproduzierbarkeit, erprobt | der Daemon bleibt an der einzigen Stelle Pflicht, an der kein Gate ihn braucht; LH-QA-03 wörtlich unerfüllt am Release-Pfad |
| B — GoReleaser als Bau-Werkzeug | Standard-Form für Cross-Compiles | ein drittes Werkzeug im Inventar mit eigener Pin-Kante; dieselbe Form, die `RELEASE_PLATFORMS`-Tafel und `host-bin` bereits tragen, entstünde doppelt |
| C — nativer Bau je Plattform-Runner | die Binaries wachsen auf ihrer Ziel-Plattform | keine Tool-Pin-Kante auf macOS/Windows (Host-Läufer dieser Repos sind Linux, §3.9-Form); sechs Toolchain-Umgebungen statt einer; der Runner-Rest wächst um sechs |
| D — daemon-loses OCI-Pull der Toolchain (dcheck-fetch-Form) | pin-getragene Reproduzierbarkeit ohne Daemon | ein OCI-Zug je Bau für ein Werkzeug, das der Inventar-Pin schon trägt — Mechanik statt Form-Einfachheit; der Pull braucht Netz an genau diesem Aufruf |
| **E — host-nativer Cross-Compile via make-Ziel am Inventar-Pin (gewählt)** | dieselbe Form wie `host-bin`, ein Runner, keine Daemon-Pflicht, Pin-Träger am Inventar | der Runner-Rest (Toolchain-Umgebung außerhalb des Pins) bleibt — am Pin geprüft, nicht gepinselt (Festlegung 3) |

## Konsequenzen

- Positiv: [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) wörtlich —
  kein Pflicht-Pfad dieses Repos braucht docker; der Release-Schnitt läuft daemon-los; der
  gepinnte opt-in Weg bleibt gepinnt (kein Rückbau, ADR-0109-Fassung).
- Negativ: der Runner-Rest wächst um die Toolchain-Umgebung des Runners — am Pin geprüft
  (Festlegung 3), aber die Runner-Image-Fassung liegt außerhalb jedes Repo-Pins; die
  Re-Evaluierungs-Trigger 1/2 tragen ihn.
- Negativ: zwei Bau-Wege nebeneinander (Host opt-in-Pflicht, Docker opt-in) — dieselbe Zwei-Weg-
  Lage wie an jeder ADR-0109-Kante; die Pflicht-Form ist die Host-Form, und die opt-in-Rezepte
  tragen ihre Pins weiter.
- Folgepflicht (Implementations-Zug): die README- und Sensor-Zellen, die den Release-Bau
  docker-getrieben nennen ([`sensors/artifact-host.md`](../../../harness/sensors/artifact-host.md),
  §Sensors-Zeilen zu `build`/`build-image`, `host-bin`, AGENTS.md §3.9-Textzüge), nennen die
  host-Form; die Spec-Züge stehen in Festlegung 5.

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| bats, `test/release-host-bau.bats` (neu) | **Happy:** `make release-artifacts-host DEST=<tmp>` erzeugt sechs Binaries + SHA256SUMS; der zweite Lauf desselben Baums liefert byte-identische SUMS ([LH-QA-02](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); ohne `TRAEGER_VERSION` meldet `--version` den Fehlt-Fall laut ([ADR-0063](0063-das-werkzeug-sagt-seine-fassung.md) Festlegung 2). **Negative:** eine Plattform-Zeile gestrichen → Matrix-Wächter rot; ein Binary fehlt im DEST → rot. **Boundary:** die Tafel hält die Sechs-Satz-Anforderung von LH-QA-04 gegen die `RELEASE_PLATFORMS`-Zeile | `make test` (in `make gates`) |
| Mutations-Fälle, `test/mutations/` (drei, Festlegung 6) | je [`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit) | `make mutate` (`MUTATE_CASES`) |

**Was hier nicht behauptet wird:** der Rot-Beleg entsteht im Implementations-Zug, nicht in dieser
ADR ([AGENTS.md](../../../AGENTS.md) §3.6-Form); der reale Tag-Lauf belegt die CI-Kette, nicht
ein lokaler Wächter. **Was kein Wächter hält:** die Toolchain-Fassung der Runner-Images gegen
künftige Runner-Stände (der Runner-Rest der Festlegung 3) und die Bau-Vs-Bau-Kante zum opt-in
Weg — Träger sind der Release-Schnitt und die Re-Evaluierungs-Trigger.

## Re-Evaluierungs-Trigger

Nicht permanent. Vier beobachtbare Bedingungen, jede einzeln auslösend:

1. **Zwei Läufe desselben Baums mit derselben Pin-Fassung liefern abweichende SHA256SUMS** —
   dann trägt der Inventar-Pin die Reproduzierbarkeit nicht; die Pin-Form ist neu zu wägen, im
   Extremfall per Folge-ADR mit `Supersedes ADR-0115` (Option D ist die nächstliegende
   Rückfall-Form).
2. **Ein Runner-Image-Stand ändert die Übersetzung sichtbar** (Go-Toolchain-Pin unverändert, die
   Binaries oder ihre SUMS verändern sich) — dieselbe Neubewägung, dieselbe Rückfall-Form.
3. **Eine Plattform tritt in die Matrix** ([LH-QA-04](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)-Wachstum)
   — Tafel-Zelle vor dem ersten Schnitt, sonst behauptet das Target eine Matrix, die kein Lauf
   fuhr.
4. **Der gepinnte opt-in Weg wird abgewählt** (Image-Klasse des Werkzeug-Baus entfernen) — eigene
   Entscheidung, ADR-0109-Fassung; diese ADR beschließt ihn nicht.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-28 | **Accepted** | Architektur-Übergabe-Artefakt auf die Auftraggeber-Entscheidung (*„Docker entfällt insgesamt, auch für den Release-Bau"*); Annahme am 2026-11-28. Der Form-Aufruf folgt dem Revidiert-Satz von [ADR-0003](0003-go-native-binaries.md) — dessen eigener Trigger (*air-gapped/registry-freier Vertrieb*) trägt die Neubewertung |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0115` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
