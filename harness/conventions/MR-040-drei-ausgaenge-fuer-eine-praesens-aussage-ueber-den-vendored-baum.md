# MR-040 — Drei Ausgänge für eine Präsens-Aussage über den vendored Baum

- **Datum:** 2026-09-02
- **Wirksamkeits-Anlass:** slice-131.
- **Geltungsbereich:** die **lebenden**, repo-eigenen Markdown-Artefakte — derselbe Ausschnitt, den
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §Geltungsbereich
  über vier Kommandos definiert und den
  [`MR-033`](../conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  bereits übernimmt; er steht hier nicht ein drittes Mal, weil zwei Fassungen desselben Ausschnitts
  driften. **Nicht** `docs/plan/adr/` — dort gilt [`AGENTS.md`](../../AGENTS.md) §3.4, und die
  Verweis-Form regelt [`ADR-0016`](../../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md)
  Festlegung 1.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**, der
  nach [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 hier steht und sein Verdikt im Feld trägt. Das
  [Freshness-Audit](../../.harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md#freshness-audit-der-vendored-baseline-schritt-2)
  führt am adoptierten Stand `v5.12.0` Ausgänge für **Adaptions-Einträge** und einen Durchgang über
  die **Form** der Artefakte; für die sagt es *„Für **wiederkehrende** Templates (ADR, Slice, Welle,
  Carveout, Review-Report) gilt die Append-only-Logik: Neue Instanzen folgen der neuen Form,
  bestehende werden nicht rückwirkend umgeschrieben."* Das bindet die **Form** einer Instanz —
  Sektionen und Felder —, nicht eine **Aussage über den vendored Baum**, die in ihr steht. Für die
  führt das Audit keinen Ausgang; diese Setzung füllt die Lücke und tritt an keine Stelle.
- **Adaption:** Wandert der vendored Baum (Re-Baseline), bekommt **jede** Präsens-Aussage über ihn
  in einem lebenden Artefakt genau **einen** von drei Ausgängen, und einen vierten gibt es nicht:
  1. **nachgemessen** — der Pfad ist auf den neuen Tag gezogen **und** das Kommando neu gefahren; im
     Text steht das Ergebnis dieses Laufs. Trägt es eine andere Folgerung als das alte, wird die
     Folgerung gezogen und nicht die Zahl gerundet.
  2. **Tree-Operand** — der Satz spricht über die Vor-Tausch-Seite (`git show
     <ref>:.harness/baseline/<alt>/…`, ein Vergleich alt gegen neu, das Zitat einer eingefrorenen
     Zeile). Die Adresse bleibt auf dem alten Tag stehen, und der Grund steht daneben; ein Nachzug
     zerstörte hier die Aussage.
  3. **entfallen** — die Aussage hat ihren Gegenstand verloren und wird **mit Begründung**
     aufgehoben, nicht stillschweigend gestrichen.

  Die alte Zahl unter neuem Pfad ist keiner der drei, sondern der Fehler, gegen den sie stehen: der
  Sprung zerreißt genau die Kopplung, die
  [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 1 verlangt.
- **Begründung (gemessen, nicht postuliert):** Der Sprung auf `v5.12.0` hat in lebenden Plandateien
  Nennungen des abgelösten Tags hinterlassen, deren Mehrzahl Operand eines Kommandos mit zitiertem
  Ergebnis war; beim Nachfahren bewegten sich mehrere Ergebnisse. Der größte Sprung ist nachprüfbar:
  `grep -rh '^### Ziel-Form' .harness/baseline/v5.12.0/regelwerk/ | wc -l` → **11**, während
  dieselbe Zählung über den abgelösten Baum **7** gibt
  (`git grep -h '^### Ziel-Form' b902b60^ -- '.harness/baseline/v3.5.2/regelwerk/' | wc -l`,
  Tree-Operand nach Ausgang 2) — im Text stand **7** neben einem Pfad, der nach dem Tausch weiter
  auflöste. **Keine Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2): die
  erste Zahl wandert mit dem Baum, die zweite ist am eingefrorenen Stand fest. Tragend ist nicht der
  Betrag, sondern dass kein Gate ihn sah — keine dieser Zahlen stand in einem Markdown-Link, und
  `make docs-check` war über alle grün, weil Datei und Anker auflösten und allein der Satz daneben
  falsch war. Ein mechanischer Tag-Tausch hätte sie durchgelassen und dabei einen lauten Fehler in
  einen stummen verwandelt — genau die Verwandlung, die
  [`ADR-0016`](../../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) in ihrer Option C verwirft,
  dort aber nur für das **unveränderlich werdende** Artefakt entscheidet. Für das lebende sagt ihre
  Festlegung 2 *„der Bump zieht ihn nach"* und setzt damit voraus, dass der Pfad ein reiner
  Navigations-Zeiger ist. Für die Fälle, in denen er ein **Operand** ist, steht diese Setzung.
- **Warum hier und nicht als ADR.** Der Gegenstand ist die Prozedur eines Re-Baseline-Durchgangs an
  repo-eigenen Artefakten — dieselbe Klasse wie
  [`MR-038`](../conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte)
  und [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines),
  die denselben Durchgang für den Block selbst regeln. Eine ADR trüge sie in beide Richtungen
  schlecht: Sie ist ab *Accepted* immutabel, während die Ausgangs-Menge mit einer künftigen Fassung
  des Freshness-Audits neu zu prüfen ist; und ein Folge-ADR mit `supersedes` hätte kein Objekt —
  [`ADR-0016`](../../docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md) wird nicht abgelöst, ihre offen
  gelassene Hälfte wird gefüllt.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der `.d-check.yml` prüft, was ein
  Satz neben einem auflösenden Pfad behauptet — `links` prüft Auflösbarkeit, `anchors` Anker, `ids`
  drei Kennungs-Muster —, und `make comment-claims` hat keine Markdown-Datei im Prüfbereich. Genau
  deshalb lagen die bewegten Zahlen bei grünem Gate falsch da. Träger ist der Durchgang beim Sprung,
  nicht ein Gate danach.
- **Auflösungs-Trigger:** permanent. **Kein Cutoff, und der Grund ist die Fläche:** der Bestand ist
  beim Sprung auf `v5.12.0` sortiert (slice-131, Erhebungs-Kommando in dessen §1), die Setzung
  bindet ab dem nächsten Sprung. Ändert ein künftiger Baseline-Stand das Freshness-Audit an dieser
  Stelle, ist sie gegen den dann geltenden Tag neu zu prüfen.
