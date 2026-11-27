# MR-098 — Die Umgebungs-Zusage trägt Mischform, die Dogfood-Gates und Lab-Läufer fahren am Host

- **Datum:** 2026-11-27
- **Wirksamkeits-Anlass:** slice-adr-gates-laeufen-host-native (Architect-Rolle,
  [`AGENTS.md`](../../AGENTS.md) §3.8 — eigener Commit, nur Architect-Artefakte).
- **Geltungsbereich:** die Soll-Herkunft **je Werkzeug** und der **Ausführungsort**
  des Tool-/Versions-Checks der Dogfood-Gates — die Begriffe trägt
  [`ADR-0109`](../../docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md)
  (docker-los als Pflicht-Weg, Image-Weg opt-in, Mischform, `pinsync`, erster
  Check). **Ziel-Bild, nicht Bestand:** die Inventar-Datei, das Check-Skript mit
  seinem Break-Test, die Host-Rezepte der Läufer und die Sensoren-Datei
  `harness/sensors/environment-check.md` mit ihrer Sensors-Zeile im
  [`harness/README.md`](../../harness/README.md) §Sensors — sie entstehen mit der
  Implementations-Fassung des Umbaus; die Bindung der Sensor-Zeile verweist
  dieser Eintrag, angelegt wird sie vom Implementier-Slice. **Nicht** der
  Release-Bau (er bleibt docker-getrieben, [ADR-0003](../../docs/plan/adr/0003-go-native-binaries.md)),
  **nicht** der d-check-Pin und seine Form
  ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)),
  **nicht** die Rezept-Texte des Makefiles.
- **Ersetzt-Baseline-Regel:** keine — das Baseline-Regelwerk
  [`modul-14-docker-harness.md`](../../.harness/baseline/v7.0.0/regelwerk/modul-14-docker-harness.md)
  stellt die Träger-Wahl ausdrücklich frei („Die Wahl trifft das Repo … Die Wahl
  ist eine Adaption der Baseline und steht als `MR-<NNN>`"); die Setzungen sind
  Adaption, keine Ersetzung.
- **Adaption — drei Setzungen:**
  1. **Soll-Herkunft: Mischform.** Das Inventar leitet das Soll **ab, wo eine
     maschinen-lesbare Pin-Stelle existiert** — die `GO_VERSION`-Stelle des
     Dockerfile/Makefile und die Image-Digests; sie trägt es **im Manifest je
     Werkzeug ohne Pin-Stelle** — bats, shellcheck, actionlint, das
     d-check-Binary, die GNU-Werkzeuge, `git`, `bash`, GNU `make` — je Eintrag
     mit einem Grund (Prüfform *exakt* / *Mindestversion* / *Fähigkeit* /
     *Anwesenheit*, Baseline-Regelwerk `modul-14-docker-harness.md` §Prüfform je
     Werkzeug; eine Pauschale „Coreutils ungeprüft" gibt es dort nicht).
     `pin legt fest, Check belegt` — wo Docker nicht trägt, ist der Check selbst
     der Träger; er steht als erster Check der Gates.
  2. **Ausführungsort: Host und CI-Runner.** Der Check prüft, was dort läuft,
     wo es läuft — der docker-los Weg führt keinen zweiten Kontext-Lauf im
     Image mit; die im Image adressierten Werkzeuge (der docker-getriebene
     Tool-Bau) bleiben über den Digest **adressiert, nicht verglichen** — die
     Lücke der Zeile „nur Host" aus
     [`modul-14-docker-harness.md`](../../.harness/baseline/v7.0.0/regelwerk/modul-14-docker-harness.md) §Inventar, Stufen, Kontext, hier ausdrücklich benannt.
  3. **Grenze: die GNU-Werkzeuge-Annahme am Host ist Linux.** Für macOS bleibt
     die bestehende Nicht-Tragung der Host-Läufer — [`AGENTS.md`](../../AGENTS.md)
     §3.9 nennt den Umfang — mit ihrem Auflösungs-Trigger; wo Varianten
     auftreten, trägt die Prüfform *Fähigkeit* (die Probe misst, was das
     Skript braucht, nicht die Nummer).
- **Begründung.** Die drei Kriterien der Soll-Form-Wahl (Baseline-Regelwerk
  `modul-14-docker-harness.md` §Woher das Soll kommt) liegen alle vor: Es gibt
  maschinen-lesbare **Pin-Stellen** (`GO_VERSION`, Image-Digests, `DCHECK_DIGEST`),
  ein Teil der Umgebung **läuft am Host** (GNU-Werkzeuge, `git`, `bash`,
  `make` — ohne Pin-Stelle), und ein **Stellen-Abgleich** steht zur Verfügung
  (d-check-Modul `pinsync`, am Dogfood aktiv — [`MR-097`](../conventions.md#mr-097--pinsync-ist-im-dogfood-aktiv-die-emittierte-vorlage-hält-den-kommentar-block)).
  Nur-Ableiten versagt an den Host-Werkzeugen, nur-Manifest macht jede
  Pin-Stelle zur zweiten Quelle; die Mischform hält die Eine-Quelle-Disziplin
  je Werkzeug. **Plan-Form, ausdrücklich benannt:** der Anlass-Plan §3 sah
  zwei Einträge „je Adaption" (Soll-Form, Ausführungsort) vor; zusammengelegt
  ist **eine** Eintrags-Datei, weil das Baseline-Regelwerk die
  Ausführungsort-Wahl in dieselbe `MR-<NNN>` bindet („das Repo deklariert
  seine Wahl in derselben `MR-<NNN>`").
- **Auflösungs-Trigger:** permanent bis ein Werkzeug ohne Pin-Stelle eine
  bekommt (Versions-Manager oder Lock je GNU-Werkzeug) — dann wandert sein
  Soll ins Ableiten, und die Manifest-Zeile der Setzung 1 wird je Werkzeug
  zurückgenommen; und/oder eine macOS-CI hält die Host-Läufer — dann entfällt
  die Grenz-Zeile der Setzung 3. Die Weg-Form selbst ist keine Setzung dieses
  Eintrags — sie trägt [`ADR-0109`](../../docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md)
  und folgt deren Re-Evaluierungs-Triggern.
