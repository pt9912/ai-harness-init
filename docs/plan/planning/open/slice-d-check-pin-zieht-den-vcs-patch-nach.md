# Slice slice-d-check-pin-zieht-den-vcs-patch-nach: Der d-check-Pin zieht den Patch nach, und der Abbruchfall von `vcs` ist gemessen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit
eine Welle braucht beobachtet keine Closure-Bedingung mehr als diese DoD.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der
Digest-Pin ist die Reproduzierbarkeits-Zusage),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (das
Modul `targets` hält den Gate-Index gegen die Targets des Fragments),
[`MR-061`](../../../../harness/conventions.md#mr-061) (sein Auflösungs-Trigger nennt jeden
d-check-Release und führt den abbrechenden Fall von `vcs` als ungemessen),
[`MR-063`](../../../../harness/conventions.md#mr-063) (die Gegenmessung),
[`MR-010`](../../../../harness/conventions.md#mr-010) und
[`MR-062`](../../../../harness/conventions.md#mr-062) (die Handgriffe am Fragment),
[`MR-053`](../../../../harness/conventions.md#mr-053) (ein Eintrag datiert seine Werkzeug-Aussage),
[`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (Re-Evaluierungs-Trigger 2
hängt am Pin).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-17.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der gepinnte d-check steht auf `v0.76.1`, an beiden gekoppelten Stellen und mit belegtem
Digest. Das Fragment ist re-adaptiert, die Strenge-Bilanz über `v0.76.0..v0.76.1` ist nach
[`MR-063`](../../../../harness/conventions.md#mr-063) gezogen, und der abbrechende Fall von `vcs`,
den [`MR-061`](../../../../harness/conventions.md#mr-061) als ungemessen führt, ist gemessen.

**Warum jetzt.** Der Auflösungs-Trigger von [`MR-061`](../../../../harness/conventions.md#mr-061)
ist permanent und greift bei jedem d-check-Release. Der Patch ändert, wann `vcs` abbricht, und
`vcs` fährt hier in `make adr-immutable` und `make doc-immutable`; beide sind kein Gate.

### Das Delta, gelesen

Gelesen im Planungslauf am 2026-09-17, nur lesend, am lokalen Klon des Werkzeugs
(`<Klon des d-check-Repos>`, eine Fremdquelle). Keine Zahl ist ein Erwartungswert.

1. **Die Spanne umfasst einen Release.**
   `git -C <Klon> for-each-ref --format='%(refname:short) %(creatordate:short)' 'refs/tags/v0.76*'`
   gibt `v0.76.0 2026-09-17` und `v0.76.1 2026-09-17` aus.
2. **Der CHANGELOG nennt einen Eintrag unter *Fixed*, und er betrifft `vcs`**
   (`awk '/^## \[0\.76\.1\]/,/^## \[0\.76\.0\]/' CHANGELOG.md`):
   - `vcs` löst die geschützte Pfad-Menge direkt gegen beide git-Tree-Stände auf.
   - Ein Unterbaum, dessen Objekt nicht lesbar ist, bricht den Lauf mit Exit 2 ab. Laut Eintrag
     meldete derselbe Fall bisher `0 Befund(e)` mit Exit 0.
   - Ein unlesbarer HEAD-Tree meldet einen Umgebungsfehler. Laut Eintrag meldete er bisher
     `core-drift-vcs` mit Exit 1.
   - Laut Eintrag gibt es keinen Konfigurations-Bruch und keine Änderung am Grund-Code.

   Die Aufzählung bestätigt nur. Tragend sind die Messungen aus DoD 2.

**Nicht gemessen im Planungslauf** sind die Quell-Differenz
(`git -C <Klon> diff --numstat v0.76.0..v0.76.1 -- internal/`), der Digest, die frische
`--print-mk`-Ausgabe, der Trockenlauf und die Gegenmessung. Sie brauchen das Bild und zum Teil
Netz; der Umsetzungs-Lauf trägt sie (§2).

### Was bei uns rot werden kann

- **`make adr-immutable` und `make doc-immutable`.** Ein Lauf, der bisher `0 Befund(e)` meldete,
  kann mit Exit 2 abbrechen. Kein Gate hängt daran; wer die Ziele fährt, liest die Meldung.
- **Ein neues Target im Fragment.** Das Modul `targets` ist aktiv
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Die Anker der Fixture** `internal/emit/testdata/raw-print-mk.txt`
  ([`MR-010`](../../../../harness/conventions.md#mr-010) §Auflösungs-Trigger).
- **Aussagen mit `v0.76.0` als Messstand** in lebenden Artefakten außerhalb des Adaptions-Blocks.
  Sie zählt
  `git grep -n 'v0\.76\.0\|f0b55fde' -- ':!.harness' ':!docs/reviews' ':!docs/plan/planning/done' ':!docs/plan/adr' ':!harness/conventions'`.
- **[`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md),
  Re-Evaluierungs-Trigger 2:** *„Wenn ein Modul des Doku-Gates Status und Adress-Form
  zusammenhält."* Ob `v0.76.1` ein solches Modul liefert, prüft DoD 2.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **`structure` und `open-tasks-require-marker` werden nicht aktiviert.** *Ein Folge-Slice
  übernimmt es:* `slice-stilllegungs-form-hat-einen-waechter`. Die Aktivierung ist ein Anheben
  mit eigener Konfiguration und eigenem roten Gegenbeispiel
  ([`MR-001`](../../../../harness/conventions.md#mr-001)).
- **`vcs` kommt nicht in `modules:`, und `make adr-immutable` wird kein Gate.** *Anderer
  Vorgang:* Ein neues Gate ist ein Anheben mit eigener Konfiguration und eigenem grünen Start.
- **Kein Adaptions-Eintrag in diesem Slice.** *Anderer Vorgang:* Der Adaptions-Block gehört dem
  Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8); §6 führt die Übergabe.
- **Offene Pläne mit einer Messung an einem früheren Pin werden nicht nachgezogen.** *Bestand
  bleibt bewusst stehen:* Jeder nennt seinen Messstand und misst in seinem eigenen Lauf am dann
  gepinnten Stand neu.
- **Kein Scan des gepinnten Bildes auf Schwachstellen.** *Anderer Vorgang:* Die Lücke führt das
  Register als
  [`gepinntes-bild-ohne-schwachstellen-scan`](../observations/BEO-ALL/gepinntes-bild-ohne-schwachstellen-scan/observation.md).

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Drei Liefer-Punkte, jeder mit dem Kommando, das ihn rot färbt
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **1 — Der Pin steht auf `v0.76.1`, an beiden gekoppelten Stellen und mit belegtem Digest,
      und das Fragment ist re-adaptiert.**
      - `DCHECK_IMAGE` und `DCHECK_DIGEST` in [`d-check.mk`](../../../../d-check.mk) sowie
        `DefaultImage` und `DefaultDigest` in
        [`internal/emit/emit.go`](../../../../internal/emit/emit.go) tragen denselben Tag und
        denselben Digest. Der Digest ist aus der Registry und aus dem lokalen Bild belegt, mit
        Kommando im Umsetzungs-Commit.
      - Die Handgriffe aus [`MR-010`](../../../../harness/conventions.md#mr-010) Setzung 1 und
        [`MR-062`](../../../../harness/conventions.md#mr-062) laufen gegen eine frische
        `--print-mk`-Ausgabe, und die fünf Anker der Fixture sind gezählt.
      - Die zwei handgeschriebenen `--disable`-Listen im [`Makefile`](../../../../Makefile)
        (`commit-msg-check`, `regelwerk-check`) sind **nach Namen** gegen das Fragment bzw. die
        `modules:`-Zeile gehalten. Der Kommentar an `regelwerk-check` nennt den Namensvergleich
        statt des Zählpaars, denn gleiche Zahlen sind keine gleichen Namen:

        ```sh
        diff <(grep -m1 '^modules:' .d-check.yml | sed 's/^modules:[[:space:]]*//; s/[][]//g' | tr ',' '\n' | tr -d ' ' | sort) \
             <(sed -n '/^regelwerk-check:/{n;p}' Makefile | grep -oE -- '--disable [a-z]+' | awk '{print $2}' | sort)
        ```

      - Der Kopf von `d-check.mk` spricht über den neuen Stand
        ([`AGENTS.md`](../../../../AGENTS.md) §3.7), und der Absatz zur Marker-Tabelle nennt
        **einen** Messstand.
      - **Rot:** Wer nur `d-check.mk` bewegt, bringt `make test` an
        `TestDefaultImage_MatchesCanonical` und `TestDefaultDigest_MatchesCanonical` zu Fall. Wer
        im Rezept `regelwerk-check` ein `--disable` gegen ein nicht aktives Modul tauscht, bekommt
        vom Kommando im Kommentar eine Zeile je Seite. Beide Meldungen sind gelesen.
- [ ] **2 — Die Strenge-Bilanz über `v0.76.0..v0.76.1` ist nach
      [`MR-063`](../../../../harness/conventions.md#mr-063) gezogen, und der abbrechende Fall von
      `vcs` ist gemessen.**
      - Die Quell-Differenz umfasst die Regeldateien der aktiven Module und die der Module, die
        ein Werkzeug dieses Repos außerhalb von `modules:` fährt
        ([`MR-061`](../../../../harness/conventions.md#mr-061) §Auflösungs-Trigger).
      - Die Gegenmessung läuft nach [`MR-063`](../../../../harness/conventions.md#mr-063)
        Setzung 2: je aktivem Modul eine Sonde, beide Digests je mit dem Fragment ihres Standes,
        Vergleich je Zeile und je Grund-Code.
      - `vcs`, lesbarer Fall: `make adr-immutable RANGE=8ae647cc~1..8ae647cc` meldet unter
        `v0.76.1` weiter `0 Befund(e)`.
      - `vcs`, abbrechender Fall: An einer Wegwerf-Kopie mit einem nicht lesbaren Unterbaum
        liefert `v0.76.1` Exit 2 mit gelesener Meldung. Daneben steht, was `v0.76.0` an
        derselben Kopie meldet. Ist der Fall nicht herstellbar, steht das mit Grund da.
      - Die Antwort auf [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
        Trigger 2 steht mit Beleg im Umsetzungs-Commit.
      - Fällt die Bilanz auf **Senkung**, greift §4.
      - **Rot:** Die zwei Befundmengen weichen ab, oder der abbrechende Fall meldet unter
        `v0.76.1` Exit 0.
- [ ] **3 — Jede Werkzeug-Aussage mit `v0.76.0` als Messstand ist am neuen Stand gemessen oder
      datiert** ([`MR-053`](../../../../harness/conventions.md#mr-053)).
      - Gemeint sind die Treffer des Zählkommandos aus §1, darunter
        [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md),
        [`harness/sensors/commit-msg-check.md`](../../../../harness/sensors/commit-msg-check.md)
        und der Kommentar am `commits`-Block der [`.d-check.yml`](../../../../.d-check.yml).
      - Die Aussagen zum `--range`-Abbruch sind am neuen Stand nachgemessen, denn der Patch
        ändert `vcs`.
      - **Rot:** Das Zählkommando aus §1 nennt eine Zeile, die `v0.76.0` als geltenden Stand
        ausgibt.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: über Liefer-Punkt 3 hinaus keines, solange die Gate-Namen gleich bleiben. Kommt ein Target hinzu, zieht Liefer-Punkt 1 den Gate-Index nach.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`d-check.mk`](../../../../d-check.mk) | update | Pin, Kopf, Re-Adaption (DoD 1) |
| [`internal/emit/emit.go`](../../../../internal/emit/emit.go) | update | emittierter Default, per go-Test gekoppelt (DoD 1) |
| `internal/emit/testdata/raw-print-mk.txt` | update, falls ein Anker fehlt | [`MR-010`](../../../../harness/conventions.md#mr-010) §Auflösungs-Trigger |
| [`Makefile`](../../../../Makefile) | update | Kommentar an `regelwerk-check` (DoD 1); die `--disable`-Listen nur, wenn das Fragment ein Modul hinzubringt |
| [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md), [`harness/sensors/commit-msg-check.md`](../../../../harness/sensors/commit-msg-check.md), [`.d-check.yml`](../../../../.d-check.yml) (Kommentar am `commits`-Block) | update | DoD 3 |
| [`harness/README.md`](../../../../harness/README.md) oder [`.d-check.yml`](../../../../.d-check.yml) | update, falls ein Target hinzukommt | [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (DoD 1) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit ist frei. Keine Abhängigkeit hält den Start;
`slice-d-check-pin-bringt-die-stilllegungs-bedingung` liegt in `done/`.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Bilanz fällt auf Senkung und
  braucht eine ADR ([`AGENTS.md`](../../../../AGENTS.md) §3.5), oder **der Sprung** erzeugt einen
  Handgriff am Fragment, den weder [`MR-010`](../../../../harness/conventions.md#mr-010)
  Setzung 1 noch [`MR-062`](../../../../harness/conventions.md#mr-062) führt. Ein Handgriff, der
  schon am `v0.76.0`-Fragment steht, löst die Rückführung nicht aus.
- `in-progress` → `open` (blockiert — Carveout?): Der Digest von `v0.76.1` ist in der Registry
  nicht belegbar.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. Unter dem neuen Pin meldet `make docs-check` keinen Befund, und `make test` hält die Kopplung.
2. Die Gegenmessung zeigt identische Befundmengen, der abbrechende Fall von `vcs` ist gemessen oder
   mit Grund als nicht herstellbar benannt, und `make gates` ist grün.

Dazu kommt ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Der abbrechende Fall ist an einer Kopie nicht herstellbar.** Der CHANGELOG nennt als
   Auslöser unkanonisch benannte Packs nach einer git-Wartung. *Absehbar:* entfallen, wenn eine
   Wegwerf-Kopie den Fall zeigt; sonst eingetreten, und die Grenze steht datiert im
   Adaptions-Eintrag zum Sprung. — **Ausgang:** <offen>
2. **Vor dem Start erscheint ein weiterer Release.** *Absehbar:* entfallen, wenn der Slice vorher
   beginnt. Sonst zieht der Planner den Ziel-Tag in Titel und §1 nach, bevor der Slice beginnt;
   die Kennung nennt keinen Tag. — **Ausgang:** <offen>
3. **Der Adaptions-Eintrag zum Sprung wird mit dem Push unveränderlich, bevor der Review ihn
   liest.** Ein Defekt darin braucht dann einen weiteren Eintrag samt Kopf-Marken
   ([`norm-eintrag-friert-vor-seinem-review-ein`](../observations/BEO-ALL/norm-eintrag-friert-vor-seinem-review-ein/observation.md)).
   *Absehbar:* entfallen, wenn der Review keinen Befund am Eintrag meldet. —
   **Ausgang:** <offen>

### Übergabe an den Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8)

Ein Adaptions-Eintrag zum Sprung `v0.76.0` → `v0.76.1` nach dem Muster von
[`MR-061`](../../../../harness/conventions.md#mr-061), in der Form aus
[`MR-053`](../../../../harness/conventions.md#mr-053) und mit der Gegenmessung aus
[`MR-063`](../../../../harness/conventions.md#mr-063). Er trägt die Messung des abbrechenden
`vcs`-Falls oder die datierte Grenze, falls der Fall nicht herstellbar ist.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** offen bis zur Closure.
- **Was ging anders als geplant:** offen bis zur Closure.
- **Steering-Loop-Eintrag:** offen bis zur Closure.
- **Beobachtungs-Register (`../observations/`):** offen bis zur Closure.
- **Folge-Slices:** offen bis zur Closure.
- **Risiken aus §6:** offen bis zur Closure, jedes mit genau einem Ausgang.
- **Drei Paarungen:** offen bis zur Closure.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `d-check.mk`, `Makefile`, `.d-check.yml`,
`internal/emit/` und `harness/sensors/`; alle liegen in `*`. `harness/tools/` (`TOOLS`) und
`.codex/` (`CODEX`) sind nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge führen die Sub-Area `*`; gesichtet
ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die erste Zeile
der `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`](../observations/BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten/observation.md) | 3 | geplant | DoD 1 und 3: der Kopf von `d-check.mk` und die Sensor-Dateien nennen ihren Messstand |
| [`aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md) | 3 | geplant | §1: das Delta ist nur aus dem CHANGELOG gelesen; DoD 2 misst am Quellstand |
| [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md) | 3 | geplant | DoD 2: der abbrechende Fall ist eine Stelle, keine Eigenschaft von `vcs` |
| [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md) | 17 | geplant | DoD 1: der Kommentar an `regelwerk-check` |
| [`norm-eintrag-friert-vor-seinem-review-ein`](../observations/BEO-ALL/norm-eintrag-friert-vor-seinem-review-ein/observation.md) | 1 | offen | §6 Risiko 3 |
| [`gepinntes-bild-ohne-schwachstellen-scan`](../observations/BEO-ALL/gepinntes-bild-ohne-schwachstellen-scan/observation.md) | 1 | offen | §1, Ausschluss |

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
