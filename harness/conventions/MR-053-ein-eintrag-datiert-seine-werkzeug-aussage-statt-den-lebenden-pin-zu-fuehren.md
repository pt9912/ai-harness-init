# MR-053 — Ein Eintrag datiert seine Werkzeug-Aussage, statt den lebenden Pin zu führen

- **Datum:** 2026-09-05
- **Wirksamkeits-Anlass:** slice-187.
- **Geltungsbereich:** die **Werkzeug-Aussage** über den gepinnten d-check in den Einträgen dieses
  Blocks; namentlich zwei Stellen in
  [`MR-034`](../conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand) — der
  Satz *„Der gepinnte d-check ist `ghcr.io/pt9912/d-check:v0.65.0` unter dem Digest in
  `d-check.mk`"* und der Halbsatz *„ihr Rumpf ist die richtige Aussage über den Tag ihres Datums,
  und **hier** steht der geltende Stand"*. **Nicht** die übrigen Aussagen jenes Eintrags: die
  Ablösung der zwei Sätze aus
  [`MR-029`](../conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
  und [`MR-030`](../conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
  gilt fort, ebenso die Ventil-Aussage samt ihrer roten Gegenprobe und die Feststellung, dass
  `d-check --print-config` eine Beispiel-Config und keine Schema-Liste ist. **Nicht**
  `docs/plan/adr/`, wo [`AGENTS.md`](../../AGENTS.md) §3.4 unverändert gilt; **nicht** die
  emittierte Ebene.
- **Löst auf:** [`MR-034`](../conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand)
  — genau die zwei Stellen oben.
- **Ausgelöst durch Baseline-Stand:** keiner. Ausgelöst hat die Ablösung ein **Werkzeug**-Pin, der
  d-check-Sprung aus
  [`MR-052`](../conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte).
  [`MR-038`](../conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte)
  verlangt den Stand, der den Trigger gefeuert hat; die Vorlage kennt zu `Löst auf` nur den
  Baseline-Stand als Auslöser. Dass hier ein Werkzeug-Pin an seiner Stelle steht, ist dieselbe
  Lage, die
  [`MR-034`](../conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand) für
  seine eigene Ablösung ausgeschrieben hat — und derselbe Grund trägt sie zweimal.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  der nach
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 hier steht und sein Verdikt im Feld trägt. Die Baseline führt für eine Aussage über ein
  **Werkzeug** keinen Ausgang: das
  [Freshness-Audit](../../.harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md#freshness-audit-der-vendored-baseline-schritt-2)
  kennt Ausgänge für Adaptions-Einträge gegenüber der **Baseline**, und
  [`grundlagen-harness-dateien.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher)
  §harness/conventions.md als Konventionsspeicher sagt *„Einträge werden nie überschrieben"*, ohne
  zu sagen, wohin eine überholte Werkzeug-Aussage geht. Diese Setzung füllt die Lücke und tritt an
  keine Stelle.
- **Setzung 1 — der lebende Pin hat einen Ort, und kein Eintrag dieses Blocks ist er.** §Baseline
  nennt ihn und sagt den Grund gleich mit: *„der lebende Pin steht in `d-check.mk`
  (`DCHECK_IMAGE`/`DCHECK_DIGEST`) und, per go-Test daran gekoppelt, in `internal/emit/emit.go` —
  hier steht keine zweite Fassung davon"*. Ein Eintrag, der ihn im Indikativ als geltenden Stand
  nennt, **ist** diese zweite Fassung. Er darf den Pin als **Mess-Operand** führen (*„über
  `v0.65.0` gemessen"*, *„der Sprung `v0.65.0` → `v0.74.1`"*) — das bleibt wahr, wenn der Pin
  weiterzieht. Er darf ihn nicht als **Geltungs-Aussage** führen (*„der gepinnte d-check ist …"*,
  *„hier steht der geltende Stand"*) — das wird mit dem nächsten Re-Pin falsch, und der Rumpf ist
  append-only eingefroren.
- **Setzung 2 — eine Werkzeug-Aussage nennt den Stand, gegen den sie gemessen ist.** Dieselbe
  Setzung, die
  [`MR-033`](../conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  für die Baseline trägt, für das zweite Ding, das unter dem Repo wegwandert: den gepinnten
  d-check. Wer schreibt, das Werkzeug führe eine Fähigkeit oder führe sie nicht, nennt den Tag, an
  dem er nachgesehen hat — im selben Absatz und nicht implizit über den gerade gepinnten Stand.
  Ein Kommando, dessen Argument den Tag oder den Digest enthält, erfüllt die Setzung; ein Satz
  ohne beides erfüllt sie nicht. **Die zwei Setzungen greifen ineinander:** Setzung 2 macht die
  Aussage prüfbar, Setzung 1 hält sie davon ab, sich als die lebende auszugeben.
- **Setzung 3 — die Kopf-Marke steht am abgelösten Eintrag.** Nach
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 1 und 3 setzt der ablösende Eintrag sie in derselben Änderung, in der er entsteht; der
  Rumpf von [`MR-034`](../conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand)
  bleibt wörtlich, und seine Datei bleibt nach
  [`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)
  in [`conventions/`](../conventions/): die Verzeichnis-Position ist binär und trägt die
  Teil-Ablösung nicht. **Der Fall ist die erste Hälfte von
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 4, nicht die zweite:** deren Ausnahme für die d-check-Pin-Kette gilt einem **Pin**-Eintrag,
  der einen Sprung datiert und keine Aussage ablöst — hier löst ein Eintrag eine Aussage
  **namentlich** ab, und damit ist die Marke fällig.
- **Begründung (gemessen, nicht postuliert):** Der Pin-Sprung aus
  [`MR-052`](../conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte)
  hat die zwei Stellen falsch gemacht, und kein Lauf dieses Repos meldet es. Die Kandidaten nennt
  `git grep -ln 'v0\.65\.0\|5ea03abe' -- ':!docs/reviews' ':!docs/plan/planning/done' ':!.harness/baseline'`;
  **eine Zahl steht hier nicht**, denn sie wäre keine Zahl von Verstößen: die meisten Nennungen
  sind Mess-Operanden und bleiben wahr. Falsch wird allein, was im Indikativ über den
  **geltenden** Stand spricht — und welche Nennung das ist, ist ein Urteil und kein Muster
  ([`AGENTS.md`](../../AGENTS.md) §3.6). Genau darum trägt die Setzung eine Form-Regel und keinen
  Zensus.
- **Warum ein eigener Eintrag und nicht ein Satz in
  [`MR-052`](../conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte).**
  Jener Eintrag ist eine **datierte Momentaufnahme** — er datiert einen Sprung. Eine Form-Setzung,
  die in ihm stünde, wäre beim nächsten Sprung in einem Eintrag zu suchen, den niemand mehr liest,
  und teilte das Schicksal der Aussage, gegen die sie steht. Eine Aussage hat einen Ort
  ([`MR-033`](../conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  §Warum ein eigener Eintrag).
- **Was diese Setzung nicht ist.** Sie ist **nicht** die Antwort auf die allgemeine Klasse *eine
  Zusage steht neben einer geänderten Ableitung*: die führt das Beobachtungs-Register als
  [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../../docs/plan/planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md),
  ihr Ausgang steht dort auf `geplant` mit der Kennung `slice-153`, und ihr `state.md` weist die
  Unterklasse *Präsens-Satz* ausdrücklich als offen aus. Diese Setzung deckt davon **einen**
  Ausschnitt — die Werkzeug-Aussage in den Einträgen dieses Blocks — und nimmt jenem Ausgang
  nichts ab.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der `.d-check.yml` hält eine
  Aussage über ein Werkzeug gegen den Stand, unter dem das Werkzeug läuft — `links` prüft
  Link-Ziele, `ids` drei Kennungs-Muster —, und `make comment-claims` hat keine Markdown-Datei in
  seinem Prüfbereich. Das Modul mit genau diesem Vertrag existiert im gepinnten Bild und ist nicht
  adoptiert (`versions`, `DC-FA-VER-001` —
  [`MR-027`](../conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt)
  §Kein Wächter über einer Versions-Nennung in Prosa). Träger ist der Rollen-Wechsel vor der
  Änderung.
- **Cutoff — ab diesem Eintrag, kein Nachrüsten.** Gebunden ist die Werkzeug-Aussage, die
  geschrieben oder geändert wird; der **Bestand ist kein Arbeitsauftrag**, und er ist ohnehin
  append-only eingefroren. Ein Maßstab über ihn wäre dauerhaft rot und entwertete die Setzung,
  statt sie zu tragen — dieselbe Begründung trägt den Cutoff in
  [`MR-033`](../conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  und in [`AGENTS.md`](../../AGENTS.md) §3.7.
- **Auflösungs-Trigger:** permanent. Der lebende Pin wandert weiter, und ein Eintrag, der ihn
  datiert statt zu führen, bleibt bei jedem Sprung wahr. Fällt die Setzung, dann durch ein
  adoptiertes `versions`-Modul, das die zwei Fassungen zusammenhält: dann trägt ein Sensor, was
  heute der Rollen-Wechsel trägt, und diese Zeile ist gegen ihn neu zu prüfen.
