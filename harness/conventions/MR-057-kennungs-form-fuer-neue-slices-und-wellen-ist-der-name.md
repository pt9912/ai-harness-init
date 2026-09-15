# MR-057 — Die Kennungs-Form für neue Slices und Wellen ist der Name, nicht die Nummer

> **ÜBERHOLT: die Zahl neben dem `grep -c 'slice-NNN'`-Kommando im Feld `Löst auf` → [`MR-058`](../conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen).** Das Kommando, die Aussage daneben und alle drei Setzungen dieses Eintrags gelten fort; gestrichen ist allein der Betrag.
> **ÜBERHOLT: die namentliche Fundmenge samt ihrem Kommando im Feld `Grenze` → [`MR-059`](../conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang).** Die Eigenschaft, die jene Stelle setzt, gilt fort und steht dort ausgeschrieben; die Setzungen 1 bis 3, der Geltungsbereich und der Auflösungs-Trigger dieses Eintrags bleiben unberührt.

- **Datum:** 2026-09-13
- **Wirksamkeits-Anlass:** slice-225 — der Architect-Teil. Wirksam wird die Deklaration mit dem
  Commit, der diesen Eintrag und seine Index-Zeile aufnimmt.
- **Geltungsbereich:** die **Form** jeder ab diesem Eintrag **neu vergebenen** Slice- und
  Welle-Kennung dieses Repos, und die Platzhalter-Notation dort, wo eine lebende Regel diese Form
  **vorschreibt** (Setzung 3). **Nicht** der Bestand (Setzung 2). **Nicht** die übrigen
  Kennungsklassen — `LH-*`, `ADR-*`, `CO-*`, `MR-*`, `BEO-*` behalten die Form, die
  [`MR-000`](../conventions.md#mr-000--baseline-aussage) und
  [`ADR-0034`](../../docs/plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  für sie setzen. **Nicht** die emittierte Ebene: Was ein Zielrepo an Kennungs-Form bekommt,
  entscheidet der Slice, der die Tool-Ebene entscheidet.
- **Ersetzt-Baseline-Regel:** keine — und nach dem Wortlaut der Eintrags-Vorlage trotzdem **kein
  Fork**, aus demselben Grund wie bei [`MR-000`](../conventions.md#mr-000--baseline-aussage):
  Dieser Eintrag ist die **Deklaration, die die Baseline selbst verlangt**, nicht eine Adaption
  neben anderen.
  [`grundlagen-source-precedence.md`](../../.harness/baseline/v6.8.0/regelwerk/grundlagen-source-precedence.md#vergabe-woher-die-nächste-kennung-kommt)
  §Vergabe setzt *„Welle- und Slice-Kennungen sind Namen, nicht Nummern — unabhängig von der
  Schreiberzahl"* und verlangt daneben ausdrücklich *„Welche Form gilt, deklariert das Repo — in
  `harness/conventions.md`"*. Gemessen am adoptierten Stand `v6.8.0`, weil
  [`MR-033`](../conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  zu einer Baseline-Aussage den Tag verlangt, gegen den sie gemessen ist:

  ```sh
  B=.harness/baseline/v6.8.0/regelwerk/grundlagen-source-precedence.md
  grep -c 'Welle- und Slice-Kennungen sind Namen, nicht Nummern' "$B"   # 1
  grep -c 'Welche Form gilt, deklariert das Repo' "$B"                  # 1
  grep -c 'dichte Nummern' "$B"                                         # 0  (Exit 1)
  ```

  **Keine Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — alle drei wandern mit dem Stand. Die dritte trägt die Fälligkeit: Der Absatz, der
  dichte Nummern für Repos mit einem Schreiber lizenzierte, steht am adoptierten Stand nicht mehr.
  Damit ist die Form **deklarationspflichtig statt voreingestellt**, und das Fehlen einer
  Deklaration wäre keine stille Fortgeltung, sondern eine Lücke.
- **Löst auf:** [`MR-000`](../conventions.md#mr-000--baseline-aussage) — allein das Token
  `slice-NNN` in seiner `Adaption:`-Zeile, keine seiner übrigen Setzungen. Eine Welle-Form hat
  jener Eintrag nie geführt; für sie ist dieser Eintrag die **erste** Deklaration, keine Ablösung:

  ```sh
  grep -c 'slice-NNN' harness/conventions/MR-000-baseline-aussage.md   # 1
  grep -c 'welle-NN'  harness/conventions/MR-000-baseline-aussage.md   # 0  (Exit 1)
  ```

  Der Rumpf von [`MR-000`](../conventions.md#mr-000--baseline-aussage) bleibt wörtlich; dass das
  Token abgelöst ist, sagt seine Kopf-Marke
  ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)),
  und seine Verzeichnis-Position bleibt unverändert
  ([`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)):
  Die Position ist binär und trägt die Teil-Ablösung nicht.
- **Ausgelöst durch Baseline-Stand:** `v6.7.2`.
- **Setzung 1 — die Form, und sie ist übernommen, nicht erfunden.** Eine neu vergebene Slice- oder
  Welle-Kennung ist ein **Name**: das Präfix eines vorhandenen Ankers (`LH-*`, `ADR-*`, `CO-*`)
  oder ein freier Slug in lowercase-Kebab-Case. Ein Slice, der während einer Welle entsteht, trägt
  die Welle als Namensraum-Präfix (`slice-<welle-name>-<aspekt-slug>`). Das ist wörtlich die Form
  aus §Vergabe; dieser Eintrag **wählt** sie, er setzt ihr nichts hinzu.
- **Setzung 2 — der Cutoff beginnt mit diesem Eintrag, und der Bestand ist kein Arbeitsauftrag.**
  Gebunden ist die Kennung, die **vergeben** wird. Bestehende `slice-<NNN>` und `welle-<NN>`
  behalten ihre Nummer; aus dieser Setzung folgt **kein** Umbenennungs-Auftrag, und eine Kennung,
  die vor diesem Eintrag vergeben wurde, ist nicht falsch — namentlich `slice-226` und
  `slice-227`, am Tag davor geschnitten. Der Bestand ist gemessen, nicht geschätzt:

  ```sh
  ls docs/plan/planning/*/slice-*.md | wc -l                                    # 224
  ls docs/plan/planning/welle-*.md docs/plan/planning/done/welle-*.md | wc -l    #  27
  ```

  **Keine Erwartungswerte** — beide wandern mit dem Lifecycle. Der Grund für den Cutoff ist
  derselbe, den [`AGENTS.md`](../../AGENTS.md) §3.7 und §3.8 für ihre eigenen nennen: Ein Maßstab
  über den Bestand wäre dauerhaft rot und entwertete die Regel, statt sie zu tragen. Dazu kommt
  ein Grund, den nur diese Kennungsklasse hat — eine Slice-Kennung steht in Commit-Messages, in
  Closure-Notizen, in Beleg-Dateien des Beobachtungs-Registers und in `Accepted`-ADRs; ein
  Umbenennungs-Durchgang bräuchte an jeder dieser Stellen eine Antwort, und für die eingefrorenen
  gäbe es keine ([`AGENTS.md`](../../AGENTS.md) §3.4, §3.11).
- **Setzung 3 — was der Cutoff für die Platzhalter-Notation heißt, und wo er endet.** Wo eine
  **lebende** Regel die Form **vorschreibt**, steht ab hier `<Kennung>` statt `<NNN>`/`<NN>` —
  heute ist das die Aufzählung der Herkunfts-Anker-Formen in
  [`AGENTS.md`](../../AGENTS.md) §3.7. Wo eine Stelle dagegen eine **Messung zitiert**, bleibt das
  Muster wörtlich stehen: Ein geändertes Suchmuster liefert eine andere Zahl, und die Zahl wäre
  dann nicht mehr die, neben der das Kommando steht
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
  Vorschreiben oder zitieren ist ein **Urteil je Stelle**, kein Muster — ein `grep` über
  `<NNN>` trifft beide Klassen gleich
  ([`AGENTS.md`](../../AGENTS.md) §3.6). Eingefrorene Artefakte ziehen ohnehin nicht nach:
  `Accepted`-ADRs und die angenommenen Einträge dieses Blocks behalten ihren Wortlaut.
- **Grenze — die Werkzeug-Ebene trägt die neue Form heute nicht, und das ist gemessen.** Zwei
  Dogfood-Stellen binden die Slice-Kennung an Ziffern:

  ```sh
  git grep -lE 'slice-(\[0-9\]|\\d)' -- harness/tools internal cmd Makefile d-check.mk ':!internal/emit'
  # harness/tools/slice-mv.sh   — der Verweis-Nachzug beim Lifecycle-Wechsel
  # internal/archive/stub.go    — die Kennungs-Erkennung im Archiv-Stub
  ```

  **Kein Erwartungswert** — die Menge wandert mit dem Code. Solange sie so steht, findet
  [`make slice-mv`](../sensors/slice-mv.md) die Verweise auf einen **benannten** Slice nicht und
  der Archiv-Stub übernimmt seine Kennung nicht. Das ist **benannt, nicht geschlossen**: Der
  Nachzug ist Implementer-Arbeit an Produkt-Code und Skript, nicht Architect-Arbeit am
  Adaptions-Block ([`AGENTS.md`](../../AGENTS.md) §3.8), und er ist fällig, **bevor** die erste
  benannte Kennung vergeben wird — nicht mit diesem Eintrag. Die emittierte Ebene ist von dieser
  Grenze getrennt und bleibt außen vor: Dort steht dasselbe Muster als Vorlage
  (`git grep -lE 'slice-(\[0-9\]|\\d)' -- internal/emit | wc -l` → **3**), und wer es bewegt,
  ändert einen Vertrag gegenüber Zielrepos.
- **Kein Wächter, und die Baseline sagt es selbst.** §Vergabe schließt mit *„Kein Sensor.
  Doppelvergabe ist heute ein Review-Griff, kein Gate"*
  (`grep -c 'Doppelvergabe ist heute ein Review-Griff' .harness/baseline/v6.8.0/regelwerk/grundlagen-source-precedence.md`
  → **1**). Hier ist es enger: Das Modul `ids` der [`.d-check.yml`](../../.d-check.yml) führt drei
  Muster — `ADR-\d{4}`, `LH-[A-Z]{2}-\d{2}`, `MR-\d{3}` —, keines davon eine Slice- oder
  Welle-Kennung (`grep -c 'regex:' .d-check.yml` → **3**), und das Modul `planning` liest
  Roadmap-Abschnitt, Marker und Closure-Verzeichnis, keine Dateinamens-Form. Ein Verstoß gegen
  Setzung 1 färbt damit nichts rot. Träger ist der Rollen-Wechsel vor der Vergabe.
- **Auflösungs-Trigger:** permanent für Setzung 1 und Setzung 2 — eine Deklaration, die die
  Baseline verlangt, wird nicht mit einem Tag gegenstandslos, und ein Cutoff gilt ab seinem Datum
  fort. **Neu fällig** wird dieser Eintrag, wenn ein künftiger Baseline-Stand §Vergabe die
  Namens-Form wieder nimmt oder die Deklarations-Pflicht streicht: Dann ist nicht der Eintrag zu
  korrigieren, sondern ein Nachfolger zu schreiben, der ihn auflöst und den Stand nennt
  ([`MR-038`](../conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte)).
