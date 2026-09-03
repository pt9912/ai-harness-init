# MR-034 — Das geteilte Referenz-Ventil trägt am gepinnten Stand

- **Datum:** 2026-08-30
- **Wirksamkeits-Anlass:** slice-132.
- **Geltungsbereich:** die **Werkzeug-Aussage** über das Doku-Gate in zwei Einträgen dieses
  Blocks — der Satz *„Am heutigen Pin gibt es ihn nicht"* im Auflösungs-Trigger von
  [`MR-029`](../conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  und der Halbsatz *„ohne dass jemand sie richtig beheben kann"* in
  [`MR-030`](../conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen). **Nicht**
  deren übrige Setzungen: der `scan.ignore`-Zensus samt seiner Klassifikation
  und seiner Aufnahme-Grenze gilt fort, ebenso die Feststellung, dass die Abweichung
  *„`implementer` statt Implementation"* keinen Gegenstand mehr hat, und ebenso beider Aussage,
  dass der Zeilen-Marker `d-check:ignore` das Modul `links` nicht deckt.
- **Löst auf:** genau die zwei Sätze oben. Jene Einträge bleiben unangetastet; ihr Rumpf ist die
  richtige Aussage über den Tag ihres Datums, und **hier** steht der geltende Stand.
- **Ausgelöst durch Baseline-Stand:** keiner. Die Ablösung hat keinen Baseline-Anlass — ausgelöst
  hat sie eine Messung gegen den gepinnten d-check. Die Eintrags-Vorlage
  (`.harness/baseline/v5.12.0/templates/harness/conventions/MR-NNN-titel.template.md`) kennt zu
  `Löst auf` nur den Baseline-Stand als Auslöser; dass eine Aussage über ein **Werkzeug** ihren
  Auslöser im Werkzeug-Pin hat, steht deshalb hier ausgeschrieben statt in einem Feld, das ihn
  nicht vorsieht.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**.
  Dieselbe Einordnung und dieselbe offene Folge wie bei
  [`MR-031`](../conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline) und
  [`MR-033`](../conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist):
  was daraus für den Block folgt, entscheidet slice-083 §2.
- **Adaption — der Sachstand, mit den Kommandos, die ihn ausgeben.** Der gepinnte d-check ist
  `ghcr.io/pt9912/d-check:v0.65.0` unter dem Digest in `d-check.mk`. Er führt `ignore-refs` als
  **Top-Level**-Schlüssel, den `links`, `anchors` und `codepaths` gemeinsam honorieren, mit `in`
  (Glob auf die Quelldatei), `refs` (Globs auf das aufgelöste Ziel) und `keep`; der modul-lokale
  `codepaths.ignore-refs` aus [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) ist
  sein Alias. Der Schlüssel ist **älter als der Pin** und wurde zwischen seiner Einführung und
  ihm nicht entfernt — beide Zeilen gegen den lokalen Klon des Werkzeug-Repos:

  ```sh
  grep -c '^## \[0\.49\.0\] — 2026-07-18' /Development/d-check/CHANGELOG.md                             # 1
  awk '/^## \[0\.65\.0\]/,/^## \[0\.49\.0\]/' /Development/d-check/CHANGELOG.md | grep -c '^### Removed' # 0
  ```

  **Gemessen am eigenen Baum, mit beiden Skopen an einer roten Gegenprobe:** eine Sonde in
  `.d-check.yml` mit `in: "harness/conventions.md"` und
  `refs: [".harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md"]` liefert
  `469 Datei(en) geprüft, 0 Befund(e)` bei **unveränderter** Datei-Zahl; mit `in: "AGENTS.md"`
  und mit `refs` auf eine Nachbardatei desselben Baums kehrt der Befund je zurück. Das Ventil
  sitzt auf der **Referenz-Achse**: es nimmt keine Datei aus dem Prüfbereich, sondern die
  Referenzen, die `in` und `refs` gemeinsam treffen.
- **Der Name, unter dem man ihn sucht, ist nicht der, unter dem er steht.** Wer unter `links:`
  nach `ignore-refs` sucht, findet nichts und schließt aus der Abwesenheit auf die fehlende
  Fähigkeit. `d-check --print-config` gibt eine kommentierte **Beispiel**-Config aus, keine
  Schema-Liste; Abwesenheit darin ist keine Abwesenheit der Option. Dieselbe Klasse wie eine
  Trefferliste, die als Vollständigkeitsaussage gelesen wird.
- **Was daraus folgt — und was ausdrücklich nicht.** Der Link in
  [`MR-021`](../conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  Punkt 2 bleibt tot und wird nicht repariert: die Setzung aus
  [`MR-030`](../conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen) ist
  unberührt, und das Ventil ändert an jenem Eintrag kein Zeichen. Was nicht mehr trägt, ist
  allein die Folgerung, der **Befund** sei unvermeidbar. Ihn stummzuschalten ist eine Senkung
  nach [`AGENTS.md`](../../AGENTS.md) §3.5 — der Prüfumfang kürzt sich um eine Referenz, die dieses
  Repo autoritativ schreibt — und wird darum nicht hier autorisiert, sondern in
  [`ADR-0026`](../../docs/plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md).
- **Warum ein neuer Eintrag und keine Korrektur an den zwei Sätzen.** Der Block läuft
  append-only: *„Einträge werden nie überschrieben"*
  ([`grundlagen-harness-dateien.md`](../../.harness/baseline/v5.18.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher)
  §harness/conventions.md als Konventionsspeicher). Ein Satz, der zu seinem Datum richtig war,
  bleibt stehen; dass er es nicht mehr ist, sagt die Kopf-Marke daneben
  ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzungen 1 und 3, mit diesem Eintrag gesetzt).
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der `.d-check.yml` hält eine
  Aussage über ein Werkzeug gegen den Stand, unter dem das Werkzeug läuft — `links` prüft
  Link-Ziele, `ids` drei Kennungs-Muster —, und `make comment-claims` hat keine Markdown-Datei in
  seinem Prüfbereich. Ob ein Satz über ein Werkzeug spricht, ist überdies ein **Urteil, kein
  Muster** ([`AGENTS.md`](../../AGENTS.md) §3.6). Träger ist der Rollen-Wechsel vor der Änderung.
- **Auflösungs-Trigger:** Der Sachstand wandert mit dem Pin. Verlöre ein künftiger d-check das
  geteilte `ignore-refs`, wäre die Aussage neu zu erheben und als neuer Eintrag zu führen; ein
  Re-Pin prüft das mit dem Trockenlauf, der ohnehin fällig ist. Die **Ablösung** der zwei Sätze
  ist davon unabhängig und permanent. Beide Sätze sprechen über den Stand, unter dem sie
  geschrieben wurden, und trafen ihn schon dort nicht: der gepinnte d-check war an ihrem Datum
  derselbe wie heute ([`MR-027`](../conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt)),
  und der Schlüssel steht seit einem Release, das dieser Pin überholt (`0.49.0` gegen `v0.65.0`).
  Ihre Ablösung fällt darum nicht mit einem künftigen Pin weg.
