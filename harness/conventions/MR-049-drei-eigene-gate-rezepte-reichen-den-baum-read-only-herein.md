# MR-049 — Drei eigene Gate-Rezepte reichen den Baum read-only herein, statt ihn per COPY ins Bild zu nehmen

- **Datum:** 2026-09-03
- **Wirksamkeits-Anlass:** slice-160 — die Docker-Form dieses Repos gegen die Ziel-Fassung.
- **Geltungsbereich:** die drei Rezepte `test-bats`, `shell-lint` und `ci-lint` im `Makefile`.
  **Nicht** `docs-check` und die `doc-*`-Rezepte in `d-check.mk`: deren Mount-Form ist
  tool-generiert und von der Baseline selbst freigestellt, entschieden in
  [slice-157](../../docs/plan/planning/done/slice-157-adaptions-durchgang-v5180.md) gegen den
  neuen Absatz *§Und das Fragment mountet*. **Nicht** die emittierte Ebene: dort mountet kein
  eigenes Rezept (`grep -c 'docker run' internal/gen/golang.go internal/gen/cpp.go` → **0** in
  beiden), die emittierten Gates sind ausschließlich `docker build --target`.
- **Ersetzt-Baseline-Regel:**
  [`modul-14-docker-harness.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-14-docker-harness.md#der-prüflauf-ist-hermetisch--kein-mount)
  §Der Prüflauf ist hermetisch — kein Mount, Satz *„Die Quellen wandern beim Build ins Image, die
  Ergebnisse kommen über `stdout` heraus."*
- **Adaption.** Wo das Werkzeug in einem fremden, digest-gepinnten Bild liegt und der Prüfbereich
  der ganze Baum ist, kommt der Baum per `-v "$(CURDIR)":<pfad>:ro` herein. Das ist der
  `:ro`-Zweig, den
  [`modul-14-docker-harness.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-14-docker-harness.md#besitz-der-belege-eines-containerisierten-gates)
  §Besitz der Belege eines containerisierten Gates als einen von zwei Preisen nennt — *„`:ro`
  plus Umleitung alles Schreibenden (trägt nur, solange die Prüfung nichts in den Baum schreiben
  **muss**)"*. Der Rest des Gate-Wegs ist hermetisch: `test-go`, `lint`, `build`, `host-bin`,
  `compile` und `release-artifacts` nehmen die Quellen per `COPY` ins Bild.
- **Der Preis ist bezahlt, gemessen an drei Stellen.**
  1. **Kein Mount ist schreibbar.** Über beide Dateien:
     `grep -oE '\-v "?\$\(CURDIR\)"?[:/][^ ]*' Makefile d-check.mk | grep -vc ':ro'` → **0**.
  2. **Die Belege gehören dem Aufrufer, nicht `root`.** Der schreibende Prozess ist der Host —
     [`harness/tools/artifact-copy.sh`](../tools/artifact-copy.sh) legt das Zielverzeichnis
     host-seitig an und holt die Datei per `docker cp` heraus; der Gate-Stempel entsteht in
     [`harness/tools/record-gates.sh`](../tools/record-gates.sh). Der Testfall, den die Baseline
     selbst nennt, ist `ls -l` auf den Beleg-Bereich nach dem Gate-Lauf:
     `ls -l .harness/state/bin/` → Eigentümer ist der aufrufende Nutzer, nicht `root`.
  3. **Und die Sperre trägt wirklich.** Derselbe Aufruf wie `make test-bats`, nur mit einem
     Schreibversuch, läuft als `uid=0` und scheitert an der Sperre:
     `docker run --rm --network none -v "$(pwd)":/code:ro -w /code --entrypoint sh $(grep -m1 '^BATS_IMAGE' Makefile | cut -d' ' -f3) -c 'id -u; touch /code/PROBE'`
     → `uid=0`, `touch: /code/PROBE: Read-only file system`, Exit **1**, und der Baum bleibt
     unverändert. Ohne `:ro` schreibt derselbe Aufruf eine Datei, die `root:root` gehört — das
     ist der Schaden, den der Abschnitt beschreibt.
- **Was der Mount kostet, und was den Verlust auffängt.** Der Abschnitt nennt drei Kosten. Zwei
  entfallen hier: ein Gate *kann* nicht schreiben (Messung 1 und 3), und ein Mountpunkt entsteht
  host-seitig nicht, weil `$(CURDIR)` immer existiert. Die dritte bleibt — **kein Digest sagt,
  was geprüft wurde**. Aufgefangen ist sie außerhalb des Bildes: `make record-gates` stempelt
  einen inhaltsbasierten Hash über alle getrackten und untrackten Dateien
  ([`harness/tools/working-tree-hash.sh`](../tools/working-tree-hash.sh),
  [`MR-003`](../conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)),
  und der Stop-Hook lässt keinen Abschluss über einem Baum zu, den dieser Stempel nicht deckt.
  Das ist **eine andere Antwort auf dieselbe Frage**, kein Ersatz für den Digest: Der Stempel
  bindet den Gate-Lauf an den Baum, nicht an das Bild.
- **Warum nicht hermetisch.** Für jedes der drei Werkzeuge entstünde eine eigene Stage
  `FROM <werkzeug-bild>` + `COPY . .` samt Rebuild je Quelländerung — für Prüfungen, die
  ausschließlich lesen und deren Prüfbereich der ganze Baum ist. Der Umbau berührt den Build-Weg
  und ist damit ein eigener Schnitt, nicht die Fracht des Laufs, der ihn gemessen hat.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der
  [`.d-check.yml`](../../.d-check.yml) liest ein Make-Rezept (`grep -m1 '^modules:' .d-check.yml`
  führt `links, anchors, ids, matrix, codepaths, spans`), und `make mutate` kennt keine
  Fehlschlag-Form, in der ein fehlendes `:ro` rot wird. Träger ist dieser Eintrag und der
  Rezept-Satz, den er benennt.
- **Auflösungs-Trigger:** sobald eine Prüfung dieses Rezept-Satzes in den Baum **schreiben muss**
  — dann trägt der `:ro`-Preis nicht mehr und die Wahl steht neu zwischen `--user` und der
  hermetischen Form. Ebenfalls fällig, sobald eines der drei Werkzeuge seine Abhängigkeiten beim
  Build zieht: dann ist nach demselben Abschnitt die **Gate-Stage selbst** das Gate, und der
  Mount entfällt ohnehin.
