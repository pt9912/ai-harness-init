# MR-059 — Jede Kennungs-Erkennung trägt die zugelassenen Formen, die Fundliste steht im Vorgang

- **Datum:** 2026-09-15
- **Wirksamkeits-Anlass:** slice-lifecycle-move-geht-ins-ziel — der Architect-Teil. Der Review
  dieses Vorgangs übergab das Feld `Grenze` von
  [`MR-057`](../conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  an die Rolle, die den Norm-Text schreibt ([`AGENTS.md`](../../AGENTS.md) §3.8). Wirksam wird der
  Nachzug mit dem Commit, der diesen Eintrag und seine Index-Zeile aufnimmt.
- **Geltungsbereich:** das Feld `Grenze` von
  [`MR-057`](../conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  — das ist die einzige Stelle, die dieser Eintrag ablöst. **Nicht** seine Setzungen 1 bis 3, sein
  `Geltungsbereich`, sein `Löst auf`, sein `Ersetzt-Baseline-Regel` oder sein `Auflösungs-Trigger`:
  sie binden unverändert fort, und **kein Wort seines Rumpfs wird geändert**. **Nicht**
  `docs/plan/adr/`, wo [`AGENTS.md`](../../AGENTS.md) §3.4 unverändert gilt; **nicht** die
  emittierte Ebene — ihre Einordnung trifft Setzung 4 erneut.
- **Ersetzt-Baseline-Regel:** keine — §Grenze setzt keine Baseline-Regel; sie zieht die Reichweite
  einer Deklaration. Nach dem Wortlaut der Eintrags-Vorlage steht damit ein **Fork**, ausgesprochen
  wie bei
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3. **Das reklassifiziert [`MR-057`](../conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  nicht:** sein Feld trägt seine eigene Einordnung, und sie bindet für ihn fort. Am adoptierten
  Stand `v6.9.0` gemessen, weil
  [`MR-033`](../conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  zu einer Baseline-Aussage den Tag verlangt, gegen den sie gemessen ist:

  ```sh
  B=.harness/baseline/v6.9.0/regelwerk/grundlagen-source-precedence.md
  grep -c 'Der Name trägt das Präfix eines vorhandenen Ankers' "$B"   # 1
  grep -c 'Erkennung' "$B"                                           # 0  (Exit 1)
  grep -c 'Kein Sensor' "$B"                                         # 1
  ```

  **Keine Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — alle drei wandern mit dem Stand. Die zweite trägt die Einordnung: Der Abschnitt, der
  die Form **deklariert**, spricht nicht von ihrer Erkennung. **Welche Wörter die Eigenschaft
  decken, sagt kein `grep`** — dass die Baseline keine Regel über die Erkennungs-Seite führt,
  bleibt ein Urteil ([`AGENTS.md`](../../AGENTS.md) §3.6), und die Treffer desselben Worts in
  anderen Modulen betreffen Injection- und Floskel-Erkennung, nicht eine Kennung.
- **Löst auf:**
  [`MR-057`](../conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  — allein das Feld `Grenze`, keine seiner Setzungen und kein übriges Feld. Das Feld `Ausgelöst
  durch Baseline-Stand` bleibt aus: Ausgelöst hat die Ablösung nicht ein Baseline-Stand, sondern
  die **Werkzeug-Ebene dieses Repos**, die sich seit jenem Eintrag bewegt hat
  ([`MR-038`](../conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte)
  verlangt den Stand für eine baseline-getriebene Ablösung). Die Kopf-Marke setzt dieser Eintrag
  nach [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 1 und 3 an
  [`MR-057`](../conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer);
  seine Verzeichnis-Position bleibt unverändert — die Position ist binär und trägt die
  Teil-Ablösung nicht
  ([`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)).
- **Setzung 1 — die Eigenschaft, und sie ist die ganze Grenze.** Eine Stelle der Dogfood-Werkzeuge,
  die eine Slice- oder Welle-Kennung **erkennt**, trägt **jede** Form, die Setzung 1 und Setzung 2
  zulassen:

  - die **Nummernform** `slice-<NNN>` bzw. `welle-<NN>` — Setzung 2: der Bestand behält seine
    Nummer, die Form bleibt also dauerhaft im Repo;
  - der **freie Slug** in lowercase-Kebab-Case — Setzung 1, etwa `slice-lifecycle-move-geht-ins-ziel`;
  - die Form mit dem **Präfix eines vorhandenen Ankers** — Setzung 1, in der Notation der
    Kennungsklassen `LH-*`, `ADR-*`, `CO-*`, also etwa `slice-<Anker>-<Aspekt-slug>`; das Präfix
    ist in diesem Repo großgeschrieben.

  Eine Erkennung, die eine dieser drei Formen auslässt, trägt die Deklaration nicht. Das ist die
  Grenze; sie ist eine Eigenschaft und keine Aufzählung von Fundorten.
- **Setzung 2 — die Fundliste steht im Vorgang, nicht in diesem Eintrag.** Die Werkzeug-Ebene
  dieses Repos trägt die Formen aus Setzung 1 **nicht durchgehend**. Welche Stellen sie verfehlen,
  ist ein **Befund**, und ein Befund gehört dem Vorgang, der ihn schließt. Er ist benannt als
  **`slice-kennungs-erkennung-traegt-die-zugelassenen-formen`** — dort steht die Aufzählung, dort
  steht ihre Messung, und dort steht der rot gesehene Fall, der die Zusage bricht
  ([`AGENTS.md`](../../AGENTS.md) §3.6). **Kein Satz dieses Eintrags zählt eine Fundmenge
  namentlich auf.** Der Grund ist die Klasse, die der abgelöste Text erzeugt hat und die das
  Beobachtungs-Register führt:
  [`BEO-ALL/lebendes-register-traegt-eine-ueberholte-fundliste`](../../docs/plan/planning/observations/BEO-ALL/lebendes-register-traegt-eine-ueberholte-fundliste/observation.md)
  — eine namentliche Fundmenge ist eine **Bestands-Aussage in einem lebenden Norm-Text**; der Text
  bleibt stehen, während die Menge wandert.
- **Setzung 3 — kein Kommando misst diese Eigenschaft, und darum steht hier keines.** Ein Muster,
  das eine **Ziffernklasse enthält**, ist weder notwendig noch hinreichend dafür, dass eine
  Erkennung die Kennung **an Ziffern bindet**: Eine Alternation kann die Nummernform als *eine von
  mehreren* führen und daneben die Namensform tragen, und eine Zeichenklasse kann die Ziffern neben
  den Buchstaben führen. Umgekehrt bindet ein Muster die Kennung an Ziffern, ohne die Zeichenfolge
  `slice-[0-9]` zu enthalten — der Bezug läuft dann über eine Gruppe, eine Alternative oder eine
  Variable. Beides ist gewöhnliche Regex-Semantik und nicht ein Zustand dieses Repos; die Aussage
  wandert darum nicht mit dem Code. Die Menge zu **lesen** statt sie zu greppen, ist damit keine
  Bequemlichkeit, sondern die einzige Form, die die Eigenschaft trifft — dieselbe Trennung, die
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  zwischen einem Kandidaten-Kommando und dem Urteil zieht.
- **Setzung 4 — die emittierte Ebene bleibt außen vor, und die Einordnung ist bestätigt.** Setzung 1
  bindet die Werkzeuge **dieses** Repos. Was ein Zielrepo an Kennungs-Erkennung bekommt, ist ein
  **Vertrag gegenüber Zielrepos** und wird von dem Vorgang entschieden, der die Tool-Ebene
  entscheidet: Ein Zielrepo führt seinen eigenen Kennungs-Bestand, und die Deklaration dieses Repos
  kann ihn nicht binden. Der abgelöste Text stützte dieselbe Einordnung auf eine Zahl seines
  damaligen Stands; **sie steht hier nicht** — die Einordnung hängt an der Vertrags-Grenze, nicht an
  einem Betrag.
- **Setzung 5 — die Frist des abgelösten Feldes bleibt.** Der Nachzug der Werkzeug-Ebene ist
  fällig, **bevor** die erste Kennung in einer Form aus Setzung 1 vergeben wird — nicht mit diesem
  Eintrag. Bis dahin gilt Setzung 2: Der Vorgang trägt den Befund, und die Vergabe wartet auf ihn.
- **Begründung (gemessen, nicht postuliert).** Eine namentliche Fundmenge und ein Kommando daneben
  sind zwei verschiedene Gegenstände: Die genannten Stellen sind **Dateien**, das Kommando misst
  **Zeichenketten**. Eine Datei trägt mehrere Muster, von denen eines die Seite wechseln kann, ohne
  dass die Datei sie verlässt — und ein Muster kann zifferngebunden sein, ohne die Zeichenfolge zu
  führen, nach der das Kommando sucht. Der abgelöste Text ist damit an beiden Enden gealtert, ohne
  dass sich in ihm ein Wort geändert hätte. **Die Klasse ist registriert, nicht neu:**
  [`BEO-ALL/lebendes-register-traegt-eine-ueberholte-fundliste`](../../docs/plan/planning/observations/BEO-ALL/lebendes-register-traegt-eine-ueberholte-fundliste/observation.md)
  führt sie, mit dem Vorgang aus dem `Wirksamkeits-Anlass` als Beleg. Was dieser Eintrag ändert,
  ist die **Form** der Grenze: Er nimmt die Aufzählung aus dem Norm-Text heraus, statt sie
  nachzuziehen — eine nachgezogene Aufzählung veraltete nach demselben Mechanismus, und der nächste
  Lauf schnitte sein Vorgehen erneut gegen eine Bestands-Aussage.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der
  [`.d-check.yml`](../../.d-check.yml) hält eine Kennungs-Erkennung gegen die Formen-Menge aus
  Setzung 1; `make comment-claims` hat keine Markdown-Datei im Prüfbereich, und `make mutate` kennt
  keine Fehlschlag-Form dafür. **Ein Kommando kann ihn auch nicht tragen** (Setzung 3) — dieselbe
  Lücke, die
  [`MR-057`](../conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  für die Vergabe selbst feststellt. Träger ist der Rollen-Wechsel vor der Vergabe und, für den
  Nachzug, der Vorgang aus Setzung 2.
- **Auflösungs-Trigger:** permanent, solange Setzung 1 und Setzung 2 dieses Blocks gelten. Neu fällig
  wird der Eintrag, wenn Setzung 1 fällt — dann fällt die Formen-Menge mit ihr —, oder wenn
  Setzung 2 fällt — dann trägt die Nummernform nicht mehr den Bestand, und die Menge schrumpft.
  Setzung 4 fällt mit der Vertrags-Grenze gegenüber Zielrepos.
