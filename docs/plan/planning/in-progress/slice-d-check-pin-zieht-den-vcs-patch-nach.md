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

**Verantwortlich:** Implementer (pt9912).

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

- [x] **1 — Der Pin steht auf `v0.76.1`, an beiden gekoppelten Stellen und mit belegtem Digest,
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
      - **Beleg:** Verifikation §1 und §2.1 bis §2.2: Tag und Digest `sha256:1470ecdc…33b3` stehen an beiden Stellen. Das Fragment hat gegen die frische Ausgabe 8 Hunks und wie zuvor 13 Targets, und jeder der fünf Anker steht einmal da. Die Fixture bleibt darum unverändert, und der Gate-Index braucht keinen Eintrag. Das Rot der Kopplung hat die Verifikation mit der behaupteten Ursache gesehen, und jeder Test fällt allein für seine Hälfte. Das Rot der zwei Namensprüfungen haben Review Runde 1 und 2 an Kopien gesehen, auch für einen Namen mit Bindestrich.
- [x] **2 — Die Strenge-Bilanz über `v0.76.0..v0.76.1` ist nach
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
      - **Beleg:** Quell-Differenz, Gegenmessung in drei Stufen (0 = 0, 57 = 57, 74 = 74) und beide `vcs`-Fälle stehen in `ebb76b3d` und [`MR-064`](../../../../harness/conventions.md#mr-064). Review Runde 1 hat die Regeldateien und Stufe 2 nachgefahren, Runde 2 die Quell-Lesung zum VCS-Port und die Verifikation den Code außerhalb von `internal/` (§2.3). Ergebnis: keine Senkung, §4 greift nicht.
        - Den abbrechenden Fall hat Runde 1 an einer Wegwerf-Kopie mit dem **Werkzeug-Exit** gemessen. Der make-Exit ist im Fall *Spitze* unter beiden Digests 2 und trennt dort nichts.
          - *Spitze:* `v0.76.0` Exit 1 (48 × `core-drift-vcs`), `v0.76.1` Exit 2 mit `Range-Spitze … nicht lesbarer Unterbaum "docs/plan/adr": object not found`.
          - *Basis:* `v0.76.0` Exit 0 (`0 Befund(e)`, das stille Grün, das der Patch schließt), `v0.76.1` Exit 2 mit `Range-Basis … nicht lesbarer Unterbaum "docs/plan/adr": object not found`.
        - Der lesbare Fall meldet im umgepackten Arbeitsklon `0 Befund(e)`, make-Exit 0 (Verifikation §2.4).
        - [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Trigger 2 ist nicht eingetreten (§7, Trigger-Audit).
- [x] **3 — Jede Werkzeug-Aussage mit `v0.76.0` als Messstand ist am neuen Stand gemessen oder
      datiert** ([`MR-053`](../../../../harness/conventions.md#mr-053)).
      - Gemeint sind die Treffer des Zählkommandos aus §1, darunter
        [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md),
        [`harness/sensors/commit-msg-check.md`](../../../../harness/sensors/commit-msg-check.md)
        und der Kommentar am `commits`-Block der [`.d-check.yml`](../../../../.d-check.yml).
      - Die Aussagen zum `--range`-Abbruch sind am neuen Stand nachgemessen, denn der Patch
        ändert `vcs`.
      - **Rot:** Das Zählkommando aus §1 nennt eine Zeile, die `v0.76.0` als geltenden Stand
        ausgibt.
      - **Beleg:** Verifikation §1: Das Zählkommando findet keine Zeile, die `v0.76.0` als geltenden Stand ausgibt, und `docs-check.md` nennt `v0.76.1` mit Digest. Die Aussagen zum `--range`-Abbruch sind in `ebb76b3d` und `4db3fcfb` nachgemessen. Eine Stelle ohne Versions-String hat das Zählkommando nicht getroffen (Review F-1). Die Nacharbeit hat sie und eine zweite solche Stelle nachgezogen (Runde 2). Das Gegenstück der Abbruch-Bedingung ist in `045fa9b7` auf das Gemessene eingeschränkt (Verifikation V-1, Review Runde 3 und 4).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: über Liefer-Punkt 3 hinaus keines, solange die Gate-Namen gleich bleiben. Kommt ein Target hinzu, zieht Liefer-Punkt 1 den Gate-Index nach.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

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
   Adaptions-Eintrag zum Sprung. — **Ausgang:** **entfallen.** Eine Wegwerf-Kopie zeigt den Fall an Basis und Spitze ([`MR-064`](../../../../harness/conventions.md#mr-064)), und Review Runde 1 hat ihn mit dem Werkzeug-Exit nachgefahren (DoD 2, Beleg). Den Auslöser aus dem CHANGELOG, Packs unter dem Präfix `loose-`, trug zudem der Arbeitsklon selbst: Dort brach `make adr-immutable` unter `v0.76.1` ab, bis das Repo umgepackt war (Verifikation §3).
2. **Vor dem Start erscheint ein weiterer Release.** *Absehbar:* entfallen, wenn der Slice vorher
   beginnt. Sonst zieht der Planner den Ziel-Tag in Titel und §1 nach, bevor der Slice beginnt;
   die Kennung nennt keinen Tag. — **Ausgang:** **entfallen**, nach dem eigenen Wortlaut. Der Slice begann, bevor ein weiterer Release erschien, und bis zur Closure ist keiner erschienen: Am Klon des Werkzeugs nennt `git -C <Klon> tag -l 'v0.7[6-9]*'` nur `v0.76.0` und `v0.76.1` (Verifikation §2.3, in der Closure wiederholt). Das Lesen von Packs unter fremdem Präfix ist im Werkzeug entschieden, aber nicht released; seine Adresse steht in §7.
3. **Der Adaptions-Eintrag zum Sprung wird mit dem Push unveränderlich, bevor der Review ihn
   liest.** Ein Defekt darin braucht dann einen weiteren Eintrag samt Kopf-Marken
   ([`norm-eintrag-friert-vor-seinem-review-ein`](../observations/BEO-ALL/norm-eintrag-friert-vor-seinem-review-ein/observation.md)).
   *Absehbar:* entfallen, wenn der Review keinen Befund am Eintrag meldet. —
   **Ausgang:** **eingetreten**, im Slice aufgefangen durch
   [`MR-065`](../../../../harness/conventions.md#mr-065).
   - Review Runde 1 und 2 lasen [`MR-064`](../../../../harness/conventions.md#mr-064) vor dem
     Push. Der Nachtrag zu Runde 2, N-1 (`78cf6680`), ging ohne eigene Runde hinaus:
     `git reflog show origin/main` führt ihn als eigene Push-Spitze, vor dem Verifikations-Commit
     `97e71814`.
   - Die Verifikation fand in genau diesem Absatz V-2. Weil der Eintrag eingefroren war, heilt ihn
     ein weiterer Eintrag mit Kopf-Marke. [`MR-065`](../../../../harness/conventions.md#mr-065)
     selbst ging erst nach Runde 3 und 4 hinaus (Push-Spitze `11393a7f`).
   - Kein Carveout und kein Folge-Slice: Der Defekt ist geheilt, nichts bleibt rot. Die Klasse
     trägt das Register weiter (§7,
     [`norm-eintrag-friert-vor-seinem-review-ein`](../observations/BEO-ALL/norm-eintrag-friert-vor-seinem-review-ein/observation.md)).

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

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10), über dem
Stand `11393a7f`. Maßstab sind Baseline-Regelwerk `v6.9.0` · `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln und `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht, dort
die Tabelle der Träger im Repo ohne Wellen.

- **Was hat funktioniert:**
  - Der abbrechende Fall war herstellbar, an Basis und Spitze. Wo der make-Exit unter beiden
    Digests gleich bleibt, trennt der Werkzeug-Exit die zwei Stände (DoD 2, Beleg).
  - Das Rot der Pin-Kopplung hat die behauptete Ursache, und jeder der zwei Tests fällt allein
    für seine Hälfte (Verifikation §2.1).
  - Die Namensprüfung der `--disable`-Listen ersetzt das Zählpaar. Rot wurde sie bei Tausch,
    Umbenennung, Zuwachs und bei einem Namen mit Bindestrich (Review Runde 1 und 2).
  - Die Bilanz *keine Senkung* nennt je Aussage ihren Träger; für den VCS-Port ist das die
    Quell-Lesung (Review F-3, Runde 2).
- **Was ging anders als geplant:**
  - **Der Abbruch hängt am Objektspeicher des Klons, nicht an der Konfiguration allein.**
    - Der Plan wollte die Aussagen zum `--range`-Abbruch nachmessen. Gemessen wurde dabei eine
      andere Ursache: Der Arbeitsklon trug `loose-*.pack`, und `make adr-immutable` brach unter
      `v0.76.1` ab (Verifikation §3).
    - Die Einordnung *unbedienbar* ist an fünf Stellen ersetzt. Eine Rückführung nach §4 folgt
      daraus nicht, denn es gibt weder Senkung noch neuen Handgriff.
    - Auf Entscheidung des Auftraggebers ist das lokale Repo umgepackt (`git repack -a -d`), und
      der Commit-Graph ist neu geschrieben. Seitdem prüft der Range-Lauf im Arbeitsklon wieder
      (Verifikation §2.4).
  - **Zwei Adaptions-Einträge statt einem:**
    - [`MR-064`](../../../../harness/conventions.md#mr-064) trägt den Sprung.
    - [`MR-065`](../../../../harness/conventions.md#mr-065) kam hinzu, weil der Nachtrag
      `78cf6680` ohne eigene Runde gepusht war und die Verifikation darin V-2 fand (§6 Risiko 3).
  - **Vier Review-Runden und eine Verifikation statt einer Runde.** Runde 1 fand drei MEDIUM,
    Runde 2 N-1, die Verifikation V-1 und V-2 (beide MEDIUM) und Runde 3 R3-1. Runde 4 meldete
    keinen Befund, der blockiert.
  - **Über §3 hinaus gebaut** (Verifikation §3):
    - die `KOPPLUNG`-Zeile am Rezept `commit-msg-check`, gedeckt von DoD 1;
    - zwei Sensor-Dateien aus Review F-1.

    DoD, §1, §4 und §6 blieben unverändert.
- **Entscheidungen zu den Übergaben:**
  - **V-3, Vermerk.**
    [`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) führt in
    Alternative E weiter die Einordnung, der Range-Lauf des Moduls sei *„am gepinnten d-check
    unbedienbar"*.
    - [`MR-064`](../../../../harness/conventions.md#mr-064) löst diese Einordnung ab.
    - Die ADR ist angenommen und bleibt ([`AGENTS.md`](../../../../AGENTS.md) §3.4). Ihre
      Entscheidung hängt nicht an der Zeile: Das Hauptargument ist, dass ein Range-Gate erst nach
      dem Commit urteilt.
    - Ein Folge-Artefakt entsteht erst, wenn jemand die Zeile als geltend liest.
    - Dieselbe Einordnung steht unter *Benannt, nicht gezählt* in der `observation.md` von
      [`werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md).
      Die Datei ist ab Anlage unveränderlich und bleibt ebenfalls.
  - **V-4:** DoD 2, Beleg, zitiert für den abbrechenden Fall die Werkzeug-Exits aus Review Runde 1.
  - **N-2** (der Dateiname von [`MR-064`](../../../../harness/conventions.md#mr-064) endet auf
    `…-objekt-ab`): Er bleibt, denn der Dateiname ist eine Adresse und keine Kopie des Titels.
  - **R4-1:** geht als Hinweis an den Architect, ohne Handlungsbedarf.
- **Adressen der zwei Werkzeug-Lücken:**
  - **Packs unter fremdem Präfix.**
    - Im d-check-Repo ist das Lesen solcher Packs entschieden und umgesetzt, laut dessen
      Planungs-Ablage geschlossen, aber nicht released: Die Tags des Klons enden bei `v0.76.1`.
    - **Die Adresse hier ist der permanente Auflösungs-Trigger** von
      [`MR-061`](../../../../harness/conventions.md#mr-061) und
      [`MR-064`](../../../../harness/conventions.md#mr-064).
      - Jeder Release wird gepinnt.
      - [`MR-064`](../../../../harness/conventions.md#mr-064) verlangt, die Grenze neu zu prüfen,
        sobald d-check solche Packs liest.
      - [`MR-065`](../../../../harness/conventions.md#mr-065) nennt denselben Fall als zweiten
        Neu-Prüf-Fall.
      - Den neuen Tag meldet `make freshness-dcheck`, nächtlich über `upstream-drift.yml`.
    - **Urteil: jetzt kein Folge-Slice.**
      - Tag, Digest und Delta gibt es noch nicht. Ein Plan darüber müsste beim Release neu
        geschrieben werden, so wie §6 Risiko 2 es für diesen Slice vorsah.
      - Den Pin-Slice schneidet der Planner, sobald der Tag gemeldet ist, wie bei diesem Slice.
  - **Alternates.**
    - Ein Klon per `git clone --shared` bricht unter `v0.76.1` ab, auch wenn der Alternates-Pfad
      eingehängt ist (Verifikation §2.4, Review Runde 3).
    - Ob ein Nachtrag an d-check geht, entscheidet der Auftraggeber. Bis dahin hat die Lücke im
      Nachbar-Repo keine Adresse.
    - **Die Adresse hier ist das Register:**
      [`werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md)
      (Lese-Schritt unten).
    - Bis eine Regel steht, macht die Angabe aus
      [`MR-065`](../../../../harness/conventions.md#mr-065) Setzung 1 einen solchen Klon vor der
      Bilanz sichtbar.
- **Steering-Loop-Eintrag:** **Geschärfte Regel.**
  [`MR-065`](../../../../harness/conventions.md#mr-065) Setzung 1: Ein history-lesender Lauf, der
  in eine d-check-Bilanz eingeht, nennt zum Laufzeitpunkt, woher sein Klon die Objekte liest, also
  Pack-Namen, Alternates und lose Objekte. Nach Setzung 2 heißt eine Lage außerhalb der gemessenen
  Tabelle *ungemessen*, nicht *frei*. Der nächste Pin-Sprung fährt seine history-lesenden Läufe
  mit dieser Angabe.
  - **Kein `liegt in`-Feld:** Die Regel entstand aus einem Verifikations-Befund, nicht aus der
    3×-Schwelle. Ihre Herkunft steht im Feld `Wirksamkeits-Anlass`.
  - Den Lese-Schritt trägt der Eintrag unten, der zum ersten Mal 3× erreicht.
- **Beobachtungs-Register (`../observations/`):**
  - Der Beleg heißt in jedem Fall `evidence/slice-d-check-pin-zieht-den-vcs-patch-nach.md`.
  - Den Zähler liefert `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`.
  - Die Zahl der Belege aus diesem Vorgang liefert
    `ls docs/plan/planning/observations/BEO-ALL/*/evidence/slice-d-check-pin-zieht-den-vcs-patch-nach.md | wc -l`
    (→ 6).
  - Keine der Zahlen ist ein Erwartungswert.

  | Eintrag | Quelle | Zähler | Stand |
  |---|---|---|---|
  | [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md) | Review F-2 und F-4; Runde 2, N-1; Verifikation V-1 und V-2; Runde 3, R3-1 | 4 | geplant |
  | [`korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge`](../observations/BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge/observation.md) | Review F-1 (die Klasse nennt der Review wörtlich) | 8 | geplant |
  | [`norm-eintrag-friert-vor-seinem-review-ein`](../observations/BEO-ALL/norm-eintrag-friert-vor-seinem-review-ein/observation.md) | §6 Risiko 3: `78cf6680`, V-2, dann [`MR-065`](../../../../harness/conventions.md#mr-065) | 2 | offen |
  | [`werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md) | Alternates (Verifikation §2.4, Runde 3) | 3, zum ersten Mal | geplant |
  | [`praesens-aussage-in-einzufrierendem-artefakt-ohne-form`](../observations/BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form/observation.md) | Verifikation V-3 | 4 | geplant |
  | [`beleg-faehrt-den-behaupteten-pfad-nicht`](../observations/BEO-ALL/beleg-faehrt-den-behaupteten-pfad-nicht/observation.md) | Review F-3 (die Klasse nennt der Review wörtlich) | 1, neu | offen |

  **Lese-Schritt.** `werkzeug-luecke-im-nachbar-repo-ohne-adresse` erreicht mit diesem Slice zum
  ersten Mal 3×. Die Belege sind `slice-217`, `slice-stilllegungs-kanten-sind-gemessen` und dieser
  Slice.

  - **Ausgang: geplant**, Kennung `slice-werkzeug-luecke-im-nachbar-repo-bekommt-eine-adresse`
    (in `open/`).
  - **Warum geplant:** Keine Quelle dieses Repos sagt, welche Adresse eine gemessene Lücke im
    gepinnten Nachbar-Werkzeug bekommt und wer darüber entscheidet.
    - Für das Pack-Präfix gab es in diesem Slice zwei Stücke: einen eingehenden Änderungswunsch
      im Nachbar-Repo, den der Auftraggeber freigab, und einen Neu-Prüf-Satz im
      Auflösungs-Trigger des Pin-Eintrags. Das ist Praxis, keine Norm.
    - Für die Alternates steht die Freigabe aus.
  - **Warum nicht verkörpert:** Die Neu-Prüf-Sätze in
    [`MR-064`](../../../../harness/conventions.md#mr-064) und
    [`MR-065`](../../../../harness/conventions.md#mr-065) gelten je für einen Fall, nicht für die
    Klasse.
  - **Wer entscheidet:** Zielort und schreibende Rolle bestätigt der Architect
    (Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle, Schritt 3b).
    Dieses Verdikt holt jener Slice ein, nicht diese Closure.
  - **Die übrigen berührten Einträge über der Schwelle behalten ihren Ausgang:**
    `stellen-messung-als-eigenschaft-ausgegeben`,
    `korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge` und
    `praesens-aussage-in-einzufrierendem-artefakt-ohne-form`. Jeder Fall liegt in dem, was der
    genannte Slice laut `state.md` schreibt.

  **Nicht getragen, mit Urteil:**

  - **V-2 unter `zusage-nennt-sensor-der-form-nicht-sieht`**, wie die Verifikation vorschlägt:
    - Der Eintrag beschreibt eine Zusage im Kopf eines Skripts oder einer Funktion. Sein geplanter
      Slice schreibt eine Regel für Wächter über einer Quelldatei.
    - V-2 steht dagegen in einem Adaptions-Eintrag, und der Diagnose-Schritt ist kein Wächter.
    - V-2 ist darum unter `stellen-messung-als-eigenschaft-ausgegeben` gezählt:
      `ls .git/objects/pack/` ist eine Stelle, *frei* ist die Eigenschaft.
  - **F-4** (*Bedingung weiter gefasst als gemessen*): dieselbe Klasse wie F-2, im selben Vorgang
    einmal gezählt. Die Präfix-Regel steht seitdem überall als Vermutung.
  - **F-5** (ein Zeiger, der nicht auflöst): Der Zeiger war Bestand und ist in `4db3fcfb` ersetzt.
    Kein Eintrag beschreibt die Klasse, und der Review nennt keine Wiederholung.
  - **F-6, F-7, F-8, N-2, R4-1:** INFO oder behoben; der Review nennt für keinen eine Klasse.
  - `naechste-rolle-uebernimmt-vor-dem-schluss-der-vorigen-runde`: Die Verifikation übernahm erst,
    nachdem Runde 2 *„bereit für Verifier"* gemeldet hatte. Runde 3 und 4 prüften die Nacharbeit
    danach.
  - `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`: Die Closure setzt den Ruhe-Marker in
    einem eigenen Commit nach dem Move.
- **Trigger-Audit** (wellenlos, bei der Slice-Closure):
  - **Carveout:**
    - `CO-001` steht auf *Auflösung fällig*; seine Adresse ist `slice-113-co-001-ist-faellig` in
      `open/`.
    - `CO-002` steht auf *permanent*.
    - Dieser Slice berührt keine ihrer Bedingungen.
  - **Bootstrap-aware Gate:** keines
    (`grep -n -i 'bootstrap-aware' Makefile *.mk harness/mk/*.mk` → kein Treffer).
  - **ADR:**
    - [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md), Trigger 2
      (*„Wenn ein Modul des Doku-Gates Status und Adress-Form zusammenhält."*): **nicht
      eingetreten, gemessen.**
      - `--print-config` ist unverändert, und es gibt kein neues Modul.
      - `vcs` hält Status und Pfad-Menge, nicht die Adress-Form eines Verweises (`ebb76b3d`).
      - Der Port dient `vcs`, `commits` und `tracked`, und keines davon hält eine Adress-Form
        (Review Runde 1, Negativbefund).
      - Am nächsten Stand prüft den Trigger der nächste Pin-Sprung.
    - [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md), Trigger 1, 3 und
      4: nicht berührt. Der Slice bewegt weder die Baseline noch `make slice-mv`.
    - [`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md): Keiner
      der vier Trigger ist eingetreten. Der Slice ändert weder `core.hooksPath` noch die Kennungs-Menge
      oder die emittierte Ebene, und den Werkzeug-Kandidaten arbeitet er nicht. V-3 steht oben.
    - [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md): nicht berührt, denn
      dieser Slice führt keinen Baseline-Sprung aus.
  - **Adaptions-Einträge:**
    - [`MR-061`](../../../../harness/conventions.md#mr-061), permanent (*bei jedem
      d-check-Release*): ausgelöst durch `v0.76.1` und von diesem Slice getragen. Der nächste
      Release löst ihn wieder aus.
    - [`MR-063`](../../../../harness/conventions.md#mr-063), permanent (*bei jedem
      d-check-Sprung*): in DoD 2 ausgeführt. Keiner der zwei Neu-Entscheidungs-Fälle ist
      eingetreten.
      - Kein Werkzeug dieses Repos fährt die Messung.
      - d-check gibt je Befund kein Modul aus: Der Vergleich der vollen Befundzeilen beider
        Digests ist leer (Review Runde 1).
    - [`MR-064`](../../../../harness/conventions.md#mr-064), permanent (*bei jedem
      d-check-Release*): Der Neu-Prüf-Fall ist nicht eingetreten, denn der Release, der Packs
      unter fremdem Präfix liest, fehlt. Die Adresse steht oben.
    - [`MR-065`](../../../../harness/conventions.md#mr-065), permanent: Keiner der zwei
      Neu-Prüf-Fälle ist eingetreten.
      - Kein `make`-Ziel gibt die Angabe selbst aus.
      - d-check liest Alternates und Packs unter fremdem Präfix nicht nachweislich (Verifikation
        §2.4, Runde 3).
    - Die permanenten Trigger von [`MR-010`](../../../../harness/conventions.md#mr-010),
      [`MR-027`](../../../../harness/conventions.md#mr-027) und
      [`MR-052`](../../../../harness/conventions.md#mr-052) hängen am selben Release. DoD 1 hat
      sie getragen, zusammen mit den Handgriffen aus
      [`MR-062`](../../../../harness/conventions.md#mr-062) (Verifikation §2.2).
- **Folge-Slices:**
  - `slice-werkzeug-luecke-im-nachbar-repo-bekommt-eine-adresse` (neu, in `open/`): aus dem
    Lese-Schritt.
  - `slice-stilllegungs-form-hat-einen-waechter` (vorhanden, in `open/`): die Aktivierung, die §1
    ausschließt.
  - Kein Pin-Slice für den nächsten d-check-Release; das Urteil steht unter *Adressen*.
- **Risiken aus §6:** Jedes hat genau einen Ausgang. 1 und 2 sind entfallen, 3 ist eingetreten
  und im Slice aufgefangen.
- **Archiv:** keines. Dieses Repo archiviert bei einer Slice-Closure nicht.
- **Drei Paarungen** (§2):
  - **(a) kein Gegenstand**, denn diese Notiz führt kein `liegt in`-Feld.
  - **(b) getragen.** Jede genannte Slice-Kennung liegt als Datei im Lifecycle
    (`ls docs/plan/planning/*/<kennung>.md`): der neue Folge-Slice,
    `slice-stilllegungs-form-hat-einen-waechter`, `slice-113-co-001-ist-faellig` und die Slices
    aus den `state.md` der Tabelle.
  - **(c) getragen.** Jede genannte Beobachtung existiert als Verzeichnis und trägt mindestens
    einen Beleg (Tabelle oben).
    - Repo-weit führt ein Eintrag keinen Beleg: `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`.
    - Seine `state.md` benennt das und nennt als Adresse
      `slice-beleglose-register-eintraege-bekommen-eine-lesart`. Aus diesem Slice stammt der Fall
      nicht.

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
