# MR-031 — Die Kommentar-Regel steht in der adoptierten Baseline

- **Datum:** 2026-08-29
- **Wirksamkeits-Anlass:** slice-081 — der Baum-Tausch, mit dem der Auflösungs-Trigger von
  [`MR-022`](../conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline) feuerte. slice-082 §3
  weist den Vollzug einem Architect-Lauf zu ([`AGENTS.md`](../../AGENTS.md) §3.8); dieser Eintrag
  ist sein Ergebnis.
- **Geltungsbereich:** [`MR-022`](../conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)
  und [`MR-023`](../conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung) je
  **vollständig**, dazu [`AGENTS.md`](../../AGENTS.md) §3.7. **Nicht** die emittierte Ebene: was ein
  Zielrepo an Kommentar-Regeln bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet.
- **Ersetzt-Baseline-Regel:** keine. Dieser Eintrag setzt **keine** Abweichung, er baut zwei
  zurück. Nach dem Wortlaut der Eintrags-Vorlage — *„Ein Eintrag, der keine benannte Regel
  ersetzt, ist ein **Fork**, keine Adaption"* — ist er damit ein Fork; die Einordnung wird hier
  ausgesprochen, nicht bestritten. Was daraus für den Block folgt — ob ein Rückbau-Eintrag hier
  stehen darf oder anderswohin gehört —, entscheidet slice-083 §2 für den ganzen Block und nicht
  dieser Eintrag für sich.
- **Adaption:** [`AGENTS.md`](../../AGENTS.md) §3.7 ist keine Abweichung mehr, sondern die
  repo-lokale Fassung einer Baseline-Regel: die Vorlage des adoptierten Standes führt sie unter
  derselben Nummer und demselben Titel, der Grundlagen-Abschnitt schreibt sie aus, und §3.7 zeigt
  seit diesem Eintrag dorthin. Die zwei Einträge, die sie als *Vorgriff* und als
  *Platzierungs-Abweichung* führten, sind vollständig aufgehoben.
- **Begründung:** Ein Vorgriff hört auf, einer zu sein, sobald der Stand da ist, auf den er
  vorgriff. Bliebe er stehen, führte der Block eine Abweichung, die es nicht gibt — dieselbe
  Klasse von Schaden, gegen die
  [`MR-023`](../conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung) entstand, nur mit
  umgekehrtem Vorzeichen.
- **Löst auf:** beide Einträge, vollständig.
  [`MR-022`](../conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline) deklarierte die Regel
  als **Vorgriff** auf einen Kurs-Stand, den die adoptierte Baseline nicht führte;
  [`MR-023`](../conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung) hob dessen Punkt 2
  auf und ließ eine Textprüfung offen. Beide Gegenstände sind fort. Nach
  [`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) behalten sie Nummer,
  Überschrift wörtlich, `Datum` und eine Zeiger-Zeile; den Rumpf trägt `git`. **Das ist die heute
  geltende Form**, und sie bleibt richtig, falls der Adaptions-Durchgang
  [`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) selbst ablöst: der
  Rumpf liegt in `git`, gleich welche Form danach gilt.
- **Ausgelöst durch Baseline-Stand:** `v5.12.0`. Die AGENTS-Vorlage führt die Regel als Hard Rule
  mit derselben Nummer und demselben Titel
  (`grep -c '^### 3\.7 Ein Kommentar beschreibt, was da ist$' .harness/baseline/v5.12.0/templates/AGENTS.template.md`
  → **1**), ausgeschrieben trägt sie der Grundlagen-Abschnitt
  (`grep -c '^### Was ein Kommentar trägt — Code, Konfiguration, Skripte$' .harness/baseline/v5.12.0/regelwerk/grundlagen-harness-dateien.md`
  → **1**). Damit ist der Trigger aus
  [`MR-022`](../conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline) in seinem **ersten**
  Zweig eingetreten — *deckt sie sich* —, und zwar gemessen am adoptierten Baum, nicht vorab.
- **Die Textprüfung, die [`MR-023`](../conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung)
  offenließ — gefahren, mit Ausgang.** Ihre Frage: *trägt der hiesige Wortlaut die
  Upstream-Semantik?* Die Antwort ist **nein an drei Posten** (die Liste unten zählt sie auf), und
  alle drei sind **übernommen**; keiner bleibt als Abweichung stehen. Ein Kommando misst beide
  Seiten:

  ```sh
  for p in 'Zustandsfeld' 'seit welle-' 'grundlagen-harness-dateien'; do
    printf '%-28s AGENTS.md=%s Vorlage=%s\n' "$p" \
      "$(grep -c "$p" AGENTS.md)" \
      "$(grep -c "$p" .harness/baseline/v5.12.0/templates/AGENTS.template.md)"
  done
  ```

  **Keine Erwartungswerte** ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — die Zahlen wandern mit beiden Texten; tragend ist, dass keine der drei Zeilen links
  auf **0** steht.
  1. **Die Zustandsfeld-Hälfte.** Die Vorlage bindet dieselbe Regel auf `Stand`-/`Status`-Zellen
     und nennt sie schon in der Geltungszeile. §3.7 trägt sie jetzt als eigenen Absatz, mit den
     Orten dieses Repos (Roadmap-Faden, Meilenstein-Tabelle, ADR-Index) und der Trennung
     Drift-Log ↔ Closure-Log.
  2. **Der dritte Herkunfts-Anker `· seit welle-<NN>`.** Er fehlte in der Aufzählung der
     Begründung. Dieses Repo fährt Wellen-Betrieb
     ([`MR-016`](../conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)), also greift er.
  3. **Der Zeiger auf den Grundlagen-Abschnitt.** Die Vorlage nennt ihn; §3.7 nannte ihn nicht und
     war damit die einzige Fassung der Regel im Repo — genau die zweite Fassung, die driftet.
- **Was über die Vorlage hinaus stehen bleibt, und warum es keine Abweichung ist.** Vier Stücke:
  der **Geltungsbereich** (`.harness/baseline/` ausgenommen, ein Zeitdokument ist kein lebendes
  Register, die emittierte Ebene entscheidet ein anderer Slice), der **Cutoff**, die
  **Quellen-Klausel** (*„Beschrieben wird die Stelle, nicht der Vorgang, der sie erzeugt hat"* —
  ein Kommentar sitzt in keinem Rang der Source Precedence und trägt darum nicht den Grund einer
  Entscheidung) und die **Wächter-Aussage** *„`make comment-claims` prüft, ob ein genannter Sensor
  existiert, nicht, worüber ein Kommentar spricht"*. Keines schränkt die Baseline-Regel ein — die
  Baseline sagt über den Bestand nichts, verlangt also kein Nachrüsten; einen Sensor behauptet
  keine der beiden Fassungen; und die Quellen-Klausel wendet die Baseline-Hard-Rule *„Wer Herkunft
  nennt, nennt sie als **ein** auflösbares Feld … und nie als Absatz"* an, statt sie zu verengen:
  Sie nimmt keine der fünf Klassen weg und keine der dort genannten Anker-Formen — `· seit
  welle-<NN>` und, für wellenlos verkörperte Regeln, `· seit slice-<NNN>` bleiben zulässig.

  ```sh
  grep -c 'nennt sie als \*\*ein\*\* auflösbares Feld' .harness/baseline/v5.12.0/regelwerk/grundlagen-harness-dateien.md   # Hard-Rule-Satz, den die Klausel anwendet
  grep -c 'seit slice-<NNN>'                           .harness/baseline/v5.12.0/regelwerk/grundlagen-traceability.md      # die Anker-Form, die erhalten bleibt
  grep -c 'Rang-Zeiger'                                AGENTS.md                                                          # die Klasse, die nicht wegfällt
  ```

  **Keine Erwartungswerte** ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — tragend ist, dass keine der drei Zeilen auf **0** steht. Eine Ergänzung ohne
  Einschränkung ist keine Adaption; [`MR-000`](../conventions.md#mr-000--baseline-aussage) wird für diesen Punkt
  nicht ausgenommen.
- **Was hinter der Vorlage zurückbleibt: der zweite Träger fehlt — eine Lücke, keine Adaption.**
  Der Grundlagen-Abschnitt nennt für **beide** Hälften zwei Träger: *„Träger aller drei ist das
  Briefing … plus der HIGH-Eintrag Kommentar trägt keine der fünf Klassen im Reviewer-Skill …"*
  — die zwei ausgelassenen Klammern nennen die Ziel-Form-Pfade der Vorlagen — und, für
  Zustandsfelder, *„ist das eine Chronik?" ist ein Urteil — Träger sind das Briefing (§3.7) und
  der HIGH-Eintrag Zustandsfeld trägt Chronik im Reviewer-Skill."* Der zweite existiert im Repo
  für **keine** der beiden Hälften:

  ```sh
  grep -c 'Kommentar trägt keine' .harness/skills/reviewer.md                                                      # 0
  grep -c 'Zustandsfeld' .harness/skills/reviewer.md                                                               # 0
  grep -c 'Kommentar trägt keine' .harness/baseline/v5.12.0/templates/.harness/skills/reviewer.template.md          # 1
  grep -c 'Zustandsfeld trägt Chronik' .harness/baseline/v5.12.0/templates/.harness/skills/reviewer.template.md     # 1
  ```

  **Keine Erwartungswerte** ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — alle vier wandern; tragend ist, dass die zwei oberen **0** sind. §3.7 trägt die
  Regel im Repo damit **allein**, und dieser Eintrag beansprucht für den fehlenden zweiten Träger
  **keine** Deckung. Geschlossen wird die Lücke am Reviewer-Skill; den führt slice-083 §2
  namentlich, samt der Feststellung, dass für ihn keine Quelle eine schreibende Rolle benennt.
- **Zwei allgemeine Sätze aus dem Rumpf von
  [`MR-023`](../conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung) binden weiter —
  hier steht, wo.** [`ADR-0014`](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)
  Festlegung 2 (b) lässt einen Rumpf nur fallen, wenn jede bindende Aussage einen bindenden Ort
  hat oder als *ersatzlos* mit Grund verzeichnet ist. Zwei Sätze jenes Rumpfs galten über seinen
  Gegenstand hinaus:
  1. *„Ein Sachfehler ist dabei kein eigener Vorgang und braucht keine eigene Regel: entweder kann
     der Punkt ersatzlos entfallen … oder an seiner Stelle muss etwas Richtiges binden — dann
     trägt es der aufhebende Eintrag. In beiden Fällen bleibt der Rumpf unangetastet."*
     **Bindender Ort:** [`ADR-0014`](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)
     Festlegung 2 (a) und (b) — dieselbe Regel eine Ebene höher, als aktive ADR und damit stärker
     gebunden als hier.
  2. *„Eine Aussage über die Baseline nennt darum den Tag, gegen den sie gemessen ist."*
     **Bindender Ort:** [`MR-033`](../conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
     wo der Satz wörtlich als Setzung 1 steht. Ein bestehender Ort trägt ihn nicht:
     [`ADR-0016`](../../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 bindet die
     Beleg-Form in Artefakten, *die unveränderlich werden*, und stellt
     [`AGENTS.md`](../../AGENTS.md) und diese Datei ausdrücklich auf die änderbare Seite; das
     Pflichtfeld `Ausgelöst durch Baseline-Stand` der Eintrags-Vorlage greift nur zusammen mit
     `Löst auf`. Übrig bliebe genau die Klasse, in der der Fehler entstand — eine
     Baseline-Aussage in einem lebenden Artefakt.

  **Ersatzlos entfällt nichts.** Der übrige Rumpf hatte seinen Gegenstand in
  [`MR-022`](../conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline) Punkt 2 und in einer
  Vorab-Messung gegen einen Tag, der nie adoptiert wurde; er fällt mit dem Gegenstand, nicht gegen
  eine fortbestehende Bindung.
- **Die Vorab-Messung ist ersetzt, nicht fortgeschrieben.**
  [`MR-023`](../conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung) maß den ersten
  Zweig gegen `v5.3.0` und erklärte ihn für `v5.3.1`; adoptiert wurde `v5.12.0`. Die zwei
  Kommandos oben laufen gegen den Baum, der im Repo liegt — eine Messung gegen einen Tag, der nie
  adoptiert wurde, trägt hier nichts.
- **Kein Wächter, und das gehört dazu.** Kein Sensor dieses Repos hält [`AGENTS.md`](../../AGENTS.md)
  §3.7 gegen die Vorlage: kein Modul aus `modules:` der `.d-check.yml` vergleicht zwei
  Markdown-Abschnitte, und `.harness/baseline/**` steht ohnehin in `scan.ignore`
  ([`MR-029`](../conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)).
  `make comment-claims` hat keine Markdown-Datei im Prüfbereich. Auch der fehlende zweite Träger
  ist unbewacht: kein Ziel liest den Reviewer-Skill gegen seine Vorlage. Die Kommandos oben sind
  reproduzierbar, gefahren werden sie von keinem Gate. Träger ist der Form-Vergleich der
  Re-Baseline (slice-083 für die Singleton-Form und für den Skill) und der Rollen-Wechsel vor der
  Änderung.
- **Auflösungs-Trigger:** permanent als Sachstands-Feststellung — ein eingeholter Vorgriff wird
  nicht ein zweites Mal eingeholt. Neu anzufassen ist der Gegenstand erst, wenn ein künftiger
  Baseline-Stand §3.7 ändert; dann ist gegen den dann geltenden Tag zu messen und als neuer
  Eintrag zu führen.
