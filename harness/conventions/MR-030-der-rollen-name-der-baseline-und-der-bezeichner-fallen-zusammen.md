# MR-030 — Der Rollen-Name der Baseline und der Bezeichner fallen zusammen

> **ÜBERHOLT: der Halbsatz *„ohne dass jemand sie richtig beheben kann"* → [`MR-034`](../conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand).** Die übrigen Setzungen dieses Eintrags gelten fort — der Link bleibt tot und wird nicht repariert.

- **Datum:** 2026-08-28
- **Wirksamkeits-Anlass:** slice-081.
- **Geltungsbereich:** Punkt 2 der Liste *„Was als Delta bleibt"* in
  [`MR-021`](../conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  und der Absatz über die kanonischen Agenten-Typ-Namen in
  [`spec/spezifikation.md`](../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5. **Nicht**
  Punkt 1 desselben Eintrags — die vierte Spalte (`Sensor`) weicht weiter von der
  Modul-Vorschrift ab und bindet fort.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  und er setzt keine Abweichung: er **baut eine zurück**, wie
  [`MR-031`](../conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline). Die Abweichung
  *„`implementer` statt Implementation"* hatte ihren Gegenstand in
  [`modul-08-agentenrollen.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-08-agentenrollen.md#rollen-sequenz-für-einen-slice)
  §Rollen-Sequenz für einen Slice; am adoptierten Stand `v5.12.0` steht dort `Implementer`, und
  damit ist sie fort. Was bleibt, ist die **Kleinschreibung** als Bezeichner-Konvention, und die
  tritt an keine Stelle: `grep -rl 'implementer' .harness/baseline/v5.12.0/regelwerk/` ist leer
  (Exit 1) — es gibt keine Modul-Schreibweise, von der sie abwiche. Auch die zwei Nicht-Handlungen
  — [`MR-021`](../conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  bleibt unangefasst, der Markdown-Link bleibt auf dem abgelösten Tag — folgen Entscheidungen
  dieses Repos, nicht einer abgelösten Baseline-Regel.
- **Löst auf:** die Abweichung *„`implementer` statt Implementation"*. Sie hat keinen Gegenstand
  mehr.
- **Ausgelöst durch Baseline-Stand:** `v5.12.0`. Der abgelöste Stand schrieb
  `participant I as Implementation`, der adoptierte schreibt `participant I as Implementer` —
  `grep -c 'participant I as Implementer' .harness/baseline/v5.12.0/regelwerk/modul-08-agentenrollen.md`
  → **1**.
- **Sachstand, gemessen statt behauptet.** Die sechs Rollen-Namen des Moduls sind
  kleingeschrieben Zeichen für Zeichen die sechs Bezeichner des Technik-Stratums — die Ausgabe
  dieses Vergleichs ist **leer**:

  ```sh
  diff <(grep -oE 'participant [A-Za-z]+ as [A-Za-z]+' .harness/baseline/v5.12.0/regelwerk/modul-08-agentenrollen.md | awk '{print tolower($4)}' | sort -u) \
       <(grep -A1 'kanonischen Namen der Agenten-Typen' spec/spezifikation.md | grep -oE '`[a-z]+`' | tr -d '`' | sort -u)
  ```

  Was bleibt, ist die **Kleinschreibung**, und sie trifft alle sechs gleich — eine
  Bezeichner-Konvention, keine Aussage über die dritte Rolle. Der kleingeschriebene Bezeichner
  kommt im Regelwerk selbst nicht vor
  (`grep -rl 'implementer' .harness/baseline/v5.12.0/regelwerk/ | wc -l` → **0**); es gibt also
  auch keine Modul-Schreibweise, von der er abwiche.
- **Der Wert bleibt, wo er steht.** Die Zielort-Setzung aus
  [`MR-021`](../conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben) —
  technische Festlegung ins Stratum — ist unberührt: die sechs kanonischen Namen stehen weiter in
  [`spec/spezifikation.md`](../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5. Was dort
  entfällt, ist allein der **Abweichungs**-Satz; er benannte eine Differenz, die es nicht mehr
  gibt.
- **[`MR-021`](../conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  wird nicht angefasst — und sein Verweis wird nicht nachgezogen.** Der Rumpf bleibt, weil dies
  eine Teil-Aufhebung ist:
  [`ADR-0014`](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (a)
  lässt ihn nur bei **vollständiger** Aufhebung fallen — *„bei Teil-Aufhebung bleibt der Rumpf,
  weil sein Rest bindet"*. Und der Markdown-Link jenes Punktes bleibt auf dem alten Tag stehen:
  der Satz um ihn herum sagt, das Modul nenne die dritte Rolle *Implementation*, und das ist
  **über `v3.5.2` wahr**. Ein Tag-Tausch machte daraus eine Aussage, die die Quelle nicht
  hergibt — bei grünem Gate, also von *laut* nach *stumm*. Genau diese Klasse verwirft
  [`ADR-0016`](../../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 1, und
  [`ADR-0023`](../../docs/plan/adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md) hält den
  Beschluss gegen genau diesen Zielstand neu. Der Verweis ist eine **datierte Aussage**
  (Klasse 2), kein Navigations-Zeiger.
- **Was das kostet, und es wird hier nicht kleingeredet.** Diese eine Zeile bleibt ein
  `target-missing`-Befund von `make docs-check` — in einem **lebenden** Artefakt, dauerhaft, ohne
  dass jemand sie richtig beheben kann. Die Ausnahme aus
  [`ADR-0017`](../../docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) deckt sie
  **nicht**: jene ist extensional auf eine Datei geschlossen, und ein Eintrag für diese Datei
  nähme ihre **254** Link-Vorkommen über **68** eindeutige Ziele mit aus der Prüfung —
  `grep -oE '\]\([^)]+\)' harness/conventions.md | wc -l` und derselbe Strom durch
  `sort -u | wc -l`, **keine Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2), sie
  wachsen mit jedem Verweis. Der Zeilen-Marker deckt sie ebenfalls nicht: `d-check:ignore` wirkt
  auf `ids` und `codepaths`, nicht auf `links`
  ([`MR-029`](../conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  §Auflösungs-Trigger, dort an einer Sonde gemessen).
- **Die strukturelle Ursache ist benannt, nicht behoben: dieser Block läuft in der Inline-Form.**
  Ein akzeptierter Eintrag ist eine **unveränderliche Region in einer änderbaren Datei** — diesen
  Fall kennt [`ADR-0016`](../../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) nicht: dort
  verläuft die Linie *„an der Änderbarkeit der Quelle"*, und `harness/conventions.md` steht
  namentlich auf der änderbaren Seite, deren lokaler Pfad ein *„Navigations-Zeiger"* ist und wo
  *„der Bump zieht ihn nach"* gilt. In der **Verzeichnis-Form**, die der adoptierte Stand zum
  Default macht, gäbe es die Kollision nicht: jeder Eintrag läge in einer eigenen Datei unter
  *harness/conventions/*, und mit dem Eintreten seines Auflösungs-Triggers wanderte er nach
  *conventions/done/* — dieselbe Zeitdokument-Klasse, für die
  [`ADR-0016`](../../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 das Entfallen
  der Adresse bei stehenbleibendem Text bereits regelt. Die Migration ist ein eigener Slice und
  wird hier weder vollzogen noch beschlossen.
- **Kein Wächter, und die Lücke ist die Regel selbst.** Zu welcher Klasse eine Nennung des alten
  Tags gehört, steht im Satz um sie herum und nicht in der Zeichenkette;
  [`ADR-0023`](../../docs/plan/adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 3
  verwirft den nächstliegenden Kandidaten mit gemessener Begründung und gibt die stille Hälfte
  ausdrücklich als **unbewacht** aus. Träger ist der Rollen-Wechsel vor der Änderung.
- **Auflösungs-Trigger:** permanent als Sachstands-Feststellung — eine aufgelöste Abweichung löst
  sich nicht ein zweites Mal auf. Neu zu entscheiden ist der Gegenstand erst, wenn ein künftiger
  Baseline-Stand die dritte Rolle wieder anders schreibt als die übrigen fünf; dann ist die
  Differenz gegen den dann geltenden Tag zu messen und als neuer Eintrag zu führen.
