# Verifikations-Report: slice-tap-nachzug-ist-schritt-der-release-prozedur — 2026-09-25

**Rolle:** Verifier (Modul 11), frischer Kontext. Frage: *Bauen wir es richtig?* — gegen DoD, Plan und die
normativen Quellen, **nicht** gegen den Reviewer-Maßstab. Kein Selbst-Verifizieren: der Lauf schrieb weder
`docs/user/releasing.md` noch den Review-Report.

**Gegenstand:** Slice `slice-tap-nachzug-ist-schritt-der-release-prozedur` (Kennung, nicht Pfad — der Plan
wandert mit dem Lifecycle, `AGENTS.md` §3.11). Stand HEAD `7f6c1f8d`, Baum sauber
(`git status --short | wc -l` → `0`). Diff-Basis `57287b64..HEAD`: sechs Commits, davon zwei `make slice-mv`
(Move, ein nachgezogener Verweis), `dce20611` (Ruhe-Marker), `8441a755` (Schritt 7/8), `ac70005f`
(Review-Report), `7f6c1f8d` (Findings R1-1 bis R1-5).

**Norm:** `LH-QA-02`, `ADR-0064` (`Accepted`; Festlegung 2, 3 c, 3 d, 6, Folgepflicht 3 und 6), `ADR-0066`
(`Accepted`; Festlegung 1), `AGENTS.md` §3.6, §3.7, §3.10, §3.11, Setzung *„die Nutzerdoku trägt nur den
Ist-Zustand"*.

**Eingang:** DoD-Bestätigung des Implementers (Commit-Messages `8441a755`, `7f6c1f8d`) und der Review-Report
`docs/reviews/2026-09-25-slice-tap-nachzug-ist-schritt-der-release-prozedur.md`. Beides war **Behauptung**;
jede Aussage unten ist selbst gefahren oder als *nur gelesen* gekennzeichnet.

---

## 1. Ist der Sensor gelaufen? — eigene Läufe dieses Laufs

Lesend; kein Schreibzugriff auf das Tap, kein Nachzug, kein Push, kein `make mutate`, keine Host-Toolchain.
Mutationen ausschließlich auf Kopien im Scratchpad, nie im Repo-Baum.

| Aufruf | Ergebnis |
|---|---|
| `make tap-check TAG=v0.2.4` | Prozess-Exit 0, `tap-check: gleich — Tag v0.2.4, Tap-Kopf Formula/ai-harness-init.rb, sha256 ccc0a3db…536c`, 1 s, keine Exit-Zeile |
| `make tap-check TAG=v0.2.3` (Tap-Kopf `0.2.4`) | **66 s**; stderr `tap-check: Formel-Unterschied — Tag v0.2.3, Asset sha256 a5a1c165…a1f2, Tap-Kopf sha256 ccc0a3db…536c; erste abweichende Zeile (zweites Lesen) Zeile 11: Asset [  version "0.2.3"] \| Tap [  version "0.2.4"]`, dann `tap-check: Exit 1` (**genau einmal**, `grep -c`), dann `make: *** [Makefile:493: tap-check] Fehler 1`; Prozess-Exit von `make` **2** |
| `TAP_WAIT=3 make tap-check TAG=v0.2.3` (Gegenprobe zur 65 s) | 4 s, sonst gleiche Klasse: die 66 s stammen aus dem Default `TAP_WAIT=65`, nicht aus dem Netz |
| `make tap-check TAG=v0.3.0-rc.1`, `TAG=v1.0.0-rc.1+x` | Exit 0, `tap-check: Vorab-Tag, Tap bleibt (<tag>)`, 0 s (vor jedem docker-Aufruf), keine Exit-Zeile |
| `make tap-check TAG=v1.0.0+build-1` | Exit 2, `Asset nicht auffindbar … (HTTP 404)`, `tap-check: Exit 2` — **kein** Vorab-Tag |
| `make tap-check TAG=v9.9.9` (Klasse-2-Fall) | Prozess-Exit 2, `Asset nicht auffindbar: … (HTTP 404) — es wurde nichts verglichen`, `tap-check: Exit 2` einmal |
| `make tap-check TAG=v0.2` / `TAG=v01.0.0` | Exit 2, `Tag-Form falsch` bzw. `Feldform falsch`, je `tap-check: Exit 2` |
| `DOCKER_HOST=tcp://127.0.0.1:1 make tap-check TAG=v0.2.4` | Exit 2, Docker-Client: *Cannot connect to the Docker daemon*, Skript: `der Transport im Bild endete ohne Ergebnis der Nutzlast (docker Exit 1) — das Ergebnis des Vergleichs ist unbekannt`, `tap-check: Exit 2` |
| `grep -nE '^[a-z-]*tap[a-z-]*:' Makefile` | genau eine Zeile: `492:tap-check:` |
| `grep -ci version harness/tools/tap-nachzug.sh harness/tools/tap-nachzug-nutzlast.sh` | `:0` je Datei |
| `gh api -H 'Accept: application/vnd.github.raw' repos/pt9912/homebrew-ai-harness-init/contents/Formula/ai-harness-init.rb \| grep -n version` | genau eine Zeile: `11:  version "0.2.4"` |
| `gh release download v0.2.4 --pattern ai-harness-init.rb` (nach Scratchpad) | Datei geladen, `sha256sum` = `ccc0a3db…536c`, gleich dem Digest der Zeile von `tap-check` |
| `gh release view v0.2.4 --json assets --jq '.assets \| length'` | `8` |
| `gh release list --json tagName,isPrerelease` | `v0.1.0` … `v0.2.4` (sieben), alle `false` |
| `grep -nE '^  [a-z0-9-]+:$' .github/workflows/release.yml` | `artifacts`, `start-smoke`, `publish` (kein Tap-Job) |
| `grep -rn 'releasing.md#' docs harness README.md` (ohne den Slice) | kein Treffer |
| `grep -rnE 'Schritt(e)? [0-9]' docs/user harness README.md` | lebende Nennungen der Prozedur: `releasing.md` `(Schritt 1)`, `(Schritt 8)`, `Schritt 3`, `(Schritt 7)`, `Schritt 5`, `Schritte 4 und 6`; alle anderen Treffer (`MR-*`, `harness/README.md:241`, `smoke.sh`, Handbuch Weg B) meinen andere Vorgänge |

Der Sensor, den DoD und Plan benennen — Läufe von `make tap-check` gegen einen Tag mit anderer Formel und
gegen den Tag des Tap-Standes —, ist **gelaufen**, und die Ausgabe ist gelesen, nicht der Exit-Code allein.

---

## 2. Deckt der Sensor die Zusage? — Rot-Belege (`AGENTS.md` §3.6)

Zu jeder Zusage mit Rot-Bedingung: was brechen müsste, und ob es einmal rot gesehen wurde.

| Zusage in `releasing.md` | Rot-Bedingung | Rot gesehen (Scratchpad-Kopie) | Was deckt sonst |
|---|---|---|---|
| Die Skripte des Vergleichs enthalten das Wort `version` nicht (`grep -ci` → `0` je Datei) | ein Kommentar oder Code mit dem Wort | Kopie von `tap-nachzug.sh` mit einem Kommentar `# … version-Zeile …`: das Kommando liefert `tap-nachzug.sh:1` statt `0` — **rot** | siehe F-2: das Kommando bindet das *Wort*, nicht die Eigenschaft *„liest keine Version"* |
| Vorab ist, was vor `+<Build>` ein `-` trägt; `v1.0.0+build-1` ist nicht Vorab | die Regel schneidet das Metadatum nicht zuerst ab | Kopie mit `case "${tag}" in` statt `case "${tag%%+*}" in`: `TAG=v1.0.0+build-1` endet mit `Vorab-Tag, Tap bleibt`, das Original mit `Asset nicht auffindbar` — der Text wäre falsch, die Läufe zeigen den Unterschied — **rot** | bats-Fall *„die Regel des Skripts entscheidet dieselben Tags wie die Regel des publish-Jobs"* (Review-Report; nicht von mir gefahren) |
| `tap-check` läuft in keiner Gate-Kette | `tap-check` als Prerequisite von `record-gates`/`gates` | Kopie des Makefile mit `record-gates: tap-check baseline-verify …`: `make -n record-gates \| grep -c tap-nachzug` → Original `0`, mutiert `1` — **rot** | bats-Fall `kein gate: tap-check steht weder in gates noch in record-gates` (gelesen, `[[ "$zeilen" != *tap-check* ]]`; bindet die direkten Prerequisites) |
| Bei Ungleichheit wartet der Aufruf einmal 65 s, bei Gleichheit nicht | anderer Default; Wartezeit auch bei Gleichheit | `TAP_WAIT=3` → 4 s statt 66 s (Default treibt die Zeit); Gleichheit `v0.2.4` → 1 s — beide Seiten **gesehen** | bats-Fälle *„die Wartezeit ohne Vorgabe sind 65 Sekunden"*, *„sofort gleich liest einmal und wartet nicht"* (nicht von mir gefahren) |
| Klasse 1 nennt beide Digests und die erste abweichende Zeile; `tap-check: Exit 1` genau einmal | Nutzlast verliert Digest oder Zeile; zweite Exit-Zeile | Läufe `v0.2.3` (Exit 1, beide Digests, Zeile 11, eine Exit-Zeile) und `v0.2.4` (Exit 0) — Paar **gesehen**; die Mutation selbst nicht gefahren | bats-Fall *„vorfall nachgestellt: …"* (`Zeile 11: …`) |
| Die Nennung `(Schritt 8)` in Schritt 5 | die Nennung bliebe `(Schritt 7)` | `git show 57287b64:docs/user/releasing.md`: dort steht `(Schritt 7)` auf Zeile 80, und Schritt 7 war die Meldung. Unverändert übernommen zeigte sie heute auf den Nachzug — die Gegenprobe des Plans ist am Diff **ablesbar** (Handlungs-Unterschied: `(Schritt 7)` → `(Schritt 8)`) | kein Sensor (Plan benennt es; Klasse `BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor`) |

**Nicht gefahren, nur gelesen:** die HTTP-Fälle 401/403/429/404 des **Tap** (Nutzlast `lese_tap`); der Fall
*„nach dem Nachzug eines älteren Tags endet die Kontrolle gegen genau diesen Tag mit Exit 0"* (ein Nachzug ist
Schreibzugriff, verboten; das Ergebnis folgt deterministisch aus `cmp` und dem Fehlen jeder Versionslogik im
Vergleich, und der Lauf `v0.2.3` gegen Tap `0.2.4` zeigt, dass ein älterer Tag **nicht** am Alter, sondern an
den Bytes scheitert); `v1.0.0+build-1` gegen einen *existierenden* Tag (es gibt keinen — nur der 404-Pfad und
der Code zeigen, dass die Vorab-Regel nicht greift); die Klasse *„Ende durch Signal"* und *„stderr nicht
beschreibbar"*. Die DoD verlangt keinen dieser Läufe, aber die Formulierung *„genau einmal bei Exit 1 und 2"*
(Liefer-Punkt 2) ist breiter als die Zusage in `ADR-0066` (F-3).

---

## 3. Verdikt je DoD-Punkt

| DoD-Punkt | Verdikt | Beleg / Vorbehalt |
|---|---|---|
| **Liefer-Punkt 1** — Schritt 7 (Nachzug) nach der Wartestelle (Schritt 6), Schritt 8 (Meldung); Quelle, Handlung, Voraussetzung, Vorwärts-Schutz-Vorbedingung, keine Rolle, kein Klon-Pfad, Schritt 8 hängt an `tap-check` Exit 0 samt Ausgabezeile | **bestätigt** | Überschriften 1 bis 8 (`grep -nE '^[0-9]+\. \*\*' docs/user/releasing.md`); Quelle `gh release download <tag> --pattern ai-harness-init.rb` läuft und liefert die Bytes, die `tap-check` als Tap-Kopf findet; Handlung, Voraussetzung, Vorbedingung nach `ADR-0064` Festlegung 3 d, 3 f und 6; `grep -niE` auf Rolle, `Klon`, `../` über Schritt 7/8: kein Treffer (das Repo `pt9912/homebrew-ai-harness-init` steht als Ziel, kein Pfad); Schritt 8: *„Die Meldung geht erst, wenn `make tap-check TAG=<tag>` (Schritt 7) mit Exit 0 endet, und sie trägt dessen Ausgabezeile als Beleg"*. Alle lebenden Nennungen einer Schritt-Nummer stimmen (§1). **Grenze, benannt:** die Zusage ist auf *die Prozedur nennt den Schritt* eingeschränkt, nicht *der Nachzug geschieht* — kein Sensor hält die Folge. |
| **Liefer-Punkt 2** — der Beleg trägt Wortlaut und Grenze der Kontrolle | **bestätigt mit Vorbehalt** | Wortlaut und Klassen 0, 1 und 2 stimmen mit den Läufen (§1) und dem Code überein; 65 s, Prozess-Exit 2 über `make`, Zeile `tap-check: Exit <N>` genau einmal bei den gefahrenen Fällen, fehlend bei Exit 0: **bestätigt**. Rot-Beleg vor Übernahme (Tag mit fremder Formel → Exit 1, Meldung, Zeile; Tag des Tap-Standes → Exit 0): **gesehen**. **Vorbehalt** — F-1: die Klasse-2-Definition *„es wurde nichts verglichen"* deckt einen der eigenen Beispiele nicht (Docker-Ausfall: das Skript sagt *„das Ergebnis des Vergleichs ist unbekannt"*). F-2: das Kommando `grep -ci version` bindet nur das Wort. F-3: *„genau einmal bei Exit 1 und 2"* nennt die Ausnahmen der `ADR-0066` nicht. Keiner der drei bricht eine DoD-Zeile; alle drei machen den Text breiter als sein Sensor. |
| `make gates` grün | **bestätigt** (im Anschluss an diesen Bericht gefahren, siehe Ende) | Stempel gedeckt, Baum sauber |
| Review durchgeführt, Report unter `docs/reviews/` | **bestätigt mit Vorbehalt** | Report vorhanden (0 HIGH, 0 MEDIUM, 5 LOW, 2 INFO). **Vorbehalt:** der Review las `8441a755`; die Findings R1-1 bis R1-5 zog `7f6c1f8d` **danach**, und dieser Commit führt neue Aussagen (`grep -ci version …`, das `gh api`-Kommando, die Vorab-Beispiele, die Klasse-2-Aufzählung), die kein Reviewer gelesen hat. Ich habe jede dieser Aussagen gefahren (§1, §2); eine Nachrunde des Reviews verlangt die DoD nicht. |
| Doku-Update: Handbuch Weg C gegen den Schritt geprüft, nur bei Abweichung nachgezogen | **bestätigt mit Vorbehalt** | Kein Diff an `docs/user/benutzerhandbuch.md`. Gemessen: alle sieben veröffentlichten Releases sind stabil, Schritt 7 nimmt nur Vorab-Tags aus — *„je Release-Schnitt … nachgezogen"* ist am Bestand wahr. **Vorbehalt:** das Urteil steht in **keinem** Artefakt des Implementers, allein in Review R1-6 und in der Commit-Message (*„R1-6 … nicht gezogen"*); die Closure sollte es in §7 festhalten. Es kippt mit dem ersten veröffentlichten Vorab-Tag (INFO R1-6). |
| Closure-Notiz, Register, Risiko-Ausgänge, drei Paarungen, Reconciliation | **offen — Planner** | `AGENTS.md` §3.10: §7 des Slice ist unbeschrieben (*„—"*), kein DoD-Häkchen gesetzt, und der Implementer hat den Abschluss **nicht** vorweggenommen. Kein Befund, Übergabe (§6). |

---

## 4. Plan-vs-Code-Diff (Auftrag 3, beide Richtungen)

**`git diff 57287b64..HEAD --name-status -M`:** `M roadmap.md` (Ruhe-Marker, −3), `R099` Slice `next/` →
`in-progress/` (eine Zeile: der Verweis im §4-Kommando, `make slice-mv`), `A` Review-Report, `M`
`docs/user/releasing.md` (+76/−7). Keine Berührung von `harness/`, `Makefile`, `.github/`, `spec/`, Handbuch,
Baseline. `git diff 57287b64..HEAD -- docs/plan/adr | wc -c` → `0`: **keine ADR angefasst** (`AGENTS.md` §3.4).
Kein eingefrorenes Zeitdokument umgeschrieben (der einzige Nachzug in einem Artefakt ist die eine Zeile in
der Slice-Datei selbst, vom Werkzeug).

**Geplant und gebaut:** Schritt 7 (Quelle, Handlung, Voraussetzung, Vorbedingung, keine Rolle), Schritt 8 mit
Beleg-Abhängigkeit, `(Schritt 7)` → `(Schritt 8)` in Schritt 5, Wortlaut und Grenze der Kontrolle,
Handbuch unberührt (*„nur bei Abweichung"*).

**Geplant, nicht gebaut:** nichts. `harness/README.md` bekommt planmäßig keinen Eintrag; die Zeile
`make tap-check` (Zeile 84) besteht und nennt dieselben Klassen wie die Prozedur.

**Gebaut, nicht (so) geplant:**

- Die **Vorab-Regel im Wortlaut des Skripts** samt Beispielen (`v0.3.0-rc.1`, `v1.0.0-rc.1+x`,
  `v1.0.0+build-1`) — Folge von R1-2; der Plan nennt Vorab nur als Ausnahme (Liefer-Punkt 2). Gedeckt durch
  `ADR-0064` Festlegung 3 c; Lauf-belegt (§1).
- **Ort des Tap-Stands** (`gh api … | grep -n version`) und *„setzt auf dem aktuellen Kopf auf"* — Folge von
  R1-4; der Plan verlangt die Vorbedingung, nicht den Ort. Kommando gefahren, liefert genau die behauptete
  Zeile.
- Das **Kommando `grep -ci version …`** in der Grenze (R1-3-Umbau) — nicht im Plan; siehe F-2.
- **`roadmap.md`** fehlt in der §3-Tabelle. Die Änderung (Ruhe-Marker entfällt bei beanspruchtem
  `in-progress/`) folgt aus `modul-06-roadmap.md` §Roadmap-Struktur und ist Prozess, kein Lieferumfang; die
  Liste der offenen Wellen bleibt unberührt.
- Die Abwesenheits-Aussagen des ersten Standes (*„Workflow schreibt nicht ins Tap"*, *„Ziel besteht nicht"*)
  sind auf die eine mit Kommando reduziert; `ADR-0064` Folgepflicht 3 (Nachzug-Ergebnis **des Jobs**, lokaler
  Ausfallweg) ist bewusst nicht gebaut — Plan §1 schließt es aus, der Folge-Schnitt trägt es (R1-7).

**Rollen und Eigentum (`AGENTS.md` §3.8, §3.10):** Hard Rules, `harness/conventions*` und ADRs unberührt;
Closure-Artefakte (§7, Häkchen, Register) unberührt. Commits tragen `Rolle Implementer` / `Rolle Reviewer`.

**Kommentar-Regel (§3.7) auf die Prozedur-Prosa:** `grep -niE 'würde|wäre|hätte|könnte|noch nicht|früher|künftig|bald'`
über Schritt 7 und 8: kein Treffer; der Text beschreibt den Zustand im Indikativ. **§3.11:** kein Pfad auf ein
bewegliches Artefakt in `releasing.md`; Anker `releasing.md#…` in keinem lebenden Artefakt.

---

## 5. Größe (Auftrag 7)

Liefer-Punkte: **2** (≤ 3). Schichten: **1** (Nutzer-Doku; kein Code, kein Skript, kein `make`-Ziel,
kein Workflow). Eine Review-Sitzung genügte (ein Report). Die Größenregel ist gehalten.

---

## 6. Befunde

Kein HIGH, kein MEDIUM. Drei LOW, zwei INFO. **Klasse** ist die Verifier-Klasse (Zusage breiter als Sensor
oder Quelle), nicht die Review-Klasse.

**F-1 — LOW · Klasse: Definition breiter als das Werkzeug, das sie zitiert.**
`docs/user/releasing.md` Schritt 7, Klasse 2: *„nicht ausführbar: es wurde nichts verglichen, die Ausgabe nennt
die Ursache"*. Das Skript unterscheidet: die Meldung des Docker-Ausfalls (im Text selbst als Beispiel *„ein nicht
erreichbarer Docker-Daemon"* genannt) lautet `… (docker Exit 1) — das Ergebnis des Vergleichs ist unbekannt`
(gemessen, §1), und der Kopf von `harness/tools/tap-nachzug.sh` sagt *„ob der Vergleich dabei gelaufen ist, ist
unbekannt"*. Für die Klasse als Ganzes ist *„nichts verglichen"* zu stark; wahr ist *„es wurde keine Gleichheit
festgestellt"*. DoD Liefer-Punkt 2 verlangt die Klassen *„so, wie das Skript sie liefert"*. Kein Fehlhandeln
folgt (Klasse 2 blockiert Schritt 8 ebenso), aber die Prozedur behauptet über die eigene Beispiel-Zeile
hinaus. *Verifizierbar:* ja — `DOCKER_HOST=tcp://127.0.0.1:1 make tap-check TAG=v0.2.4`. *Übergabe:* Implementer
(eine Wortlaut-Korrektur), nicht in diesem Lauf.

**F-2 — LOW · Klasse: Kommando bindet das Wort, die Zusage nennt die Eigenschaft.**
Der Satz *„Sie vergleicht Bytes, keine Versionen: die Skripte des Vergleichs enthalten das Wort `version`
nicht"* trägt sein Kommando (`→ 0 je Datei`, gemessen, Rot mit Kommentar gesehen, §2). Das Kommando fällt
aber auch bei einem Kommentar, der das Wort trägt, und bleibt `0`, wenn ein Versions-Vergleich ohne das Wort
gebaut wird (`vers`, `Fassung`, `awk '/^  ver/'`). Die Eigenschaft *„check liest keine Version"* tragen
tatsächlich die bats-Fälle (`version-zeile: in check kein Gegenstand …`, `vorfall nachgestellt: …`), nicht das
`grep`. Der Text nennt das Wort, nicht die Eigenschaft — als Wortlaut-Zusage ist er wahr; als Beleg für
*„keine Versionen"* ist er schwächer, als er klingt. **Zeitbombe, die der Folge-Schnitt entschärfen muss:**
`ADR-0064` Festlegung 3 d verlangt von `sync` das Lesen der `version`-Zeile — das Wort erscheint dann im Skript,
das Kommando liefert `> 0`, und der Satz ist falsch. Das ist kein Mangel dieses Slice, aber der Slice für
`sync` muss diesen Satz mit umbauen (Übergabe §7).

**F-3 — LOW · Klasse: Zusage in der Prozedur breiter als ihre Quelle.**
*„Bei Exit 1 und 2 steht sie [die Zeile `tap-check: Exit <N>`] genau einmal"* (Schritt 7) übernimmt die
Zusage aus `ADR-0066` Festlegung 1 ohne deren Ausnahmen: nicht zugesagt bei einem Signal, bei nicht
beschreibbarer stderr, bei fehlendem oder unbekanntem Modus; die Zeile in `harness/README.md` (84) und der
Kommentar am Makefile-Ziel nennen sie. Für den menschlichen Aufrufer der Prozedur praktisch unerheblich
(alle drei liegen außerhalb der Fälle Tag-Form, Asset, Tap, Docker) — als Aussage über *„jeden"* Exit 1/2 ist
der Satz breiter als die Zusage, die ihn deckt. *Verifizierbar:* gemessen sind Exit 1 (`v0.2.3`) und Exit 2
(fünf Fälle), je genau eine Zeile; die Ausnahmen sind nur aus dem Code gelesen.

**F-4 — INFO · Prüfung, die der Reviewer nicht führen konnte.**
Der Review-Report bindet Zeilennummern von `8441a755` (`releasing.md:124`, `:109`, …); nach `7f6c1f8d` sind sie
verschoben. Der Report ist Lauf-Beleg des Zeitpunkts; die Befunde sind in `7f6c1f8d` gezogen (R1-1: Klasse 2
nach Wesen; R1-2: Vorab nach der Regel des Skripts; R1-3: Abwesenheits-Aussagen auf die eine mit Kommando;
R1-4: Ort des Tap-Stands; R1-5: Stand-Form-Zuordnung). Ich habe jede gezogene Zeile gegen einen Lauf gehalten;
R1-1, R1-2, R1-4 stimmen (§1), R1-3 stimmt bis auf F-2, R1-5 ist Wortlaut (Schritt 8, gelesen: Release-Text
trägt Belege *„zum Zeitpunkt seiner Fassung"*, die Zeile von `tap-check` steht in der Meldung).

**F-5 — INFO (= R1-6, nicht gezogen).** Handbuch Weg C stimmt am Bestand (sieben stabile Releases); kippt mit
dem ersten veröffentlichten Vorab-Tag. Ein Träger für diese Bedingung besteht nicht (das Handbuch-Update gehört
zum Release-Schnitt, Plan §1). R1-7 (Job-Ergebnis und Ausfallweg der ADR-Folgepflicht 3) ist eine
**Grenze des Umfangs**, keine Abweichung: der Plan schließt sie aus, und die Prozedur behauptet sie nicht.

---

## 7. Übergaben an den Planner

1. **Closure (`AGENTS.md` §3.10):** die §7-Felder, Häkchen, Risiko-Ausgänge und drei Paarungen sind Planner-Arbeit
   in frischem Kontext. Der Verifier hat den Slice nicht geändert. Liefer-Punkte 1 und 2 sind nach diesem
   Bericht belegt (Vorbehalt F-1 bis F-3); DoD-Punkt *Doku-Update* trägt das Urteil *„Weg C stimmt am Bestand"*
   — im §7 festhalten.
2. **Findings F-1 bis F-3 → Implementer (Wortlaut in `docs/user/releasing.md`)**, falls der Planner sie
   vor der Closure ziehen lässt; sie blockieren nicht. Wird keines gezogen, gehören sie in §7 als *Was ging
   anders* und die Klassen (F-1 Definition breiter als Werkzeug, F-2 Wort-Sensor für eine Eigenschaft, F-3
   Zusage ohne die Ausnahmen der Quelle) als Zähler-Kandidaten.
3. **`sync`-Träger für R1-3 (und F-2):** der Slice für den Modus `sync` (Kennung noch nicht vergeben, Plan §1)
   trägt den Umbau von Schritt 7. Vier Aussagen altern mit ihm und sollten in seiner DoD **ausdrücklich**
   stehen: (a) *„der Nachzug ist ein Handgriff dieses Schritts"*, (b) *„das einzige Tap-Ziel im Makefile ist
   `tap-check`"* (mit Kommando — wird `> 1` Zeilen), (c) *„Ein Nachzug von Hand hat diesen Schutz nicht"*,
   (d) **das `grep -ci version`-Kommando samt Satz** (wird falsch, sobald `sync` die `version`-Zeile liest;
   `ADR-0064` Festlegung 3 d). Ein Sensor für die Alterung besteht nicht.
4. **Register-Belege (die vier Einträge aus §8 des Slice) — Fakten, das Urteil *„dieselbe Beobachtung?"* fällt
   beim Schreiben des Belegs, nicht hier:**
   - `BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor` (Stand 1×): Schritt 7 und Schritt 8 sind weitere
     Prozedur-Zeilen ohne Sensor — bestätigt (kein Test, kein Gate hält die Schritt-Folge; der Review-Report
     und §2 nennen es). Beleg-Kandidat.
   - `BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut` (2×): der Nachzug ist Handarbeit
     gegen ein Werkzeug, dessen Modus `sync` als Stub endet (`Exit 2 … nicht implementiert`, Kopf des Skripts).
     Nahe, nicht deckungsgleich (Füllung als Code, Einstieg nicht). Erreicht der Eintrag mit diesem Beleg 3×,
     ist der Folge-Slice der `sync`-Schnitt.
   - `BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet` (2×): der Vorwärts-Schutz steht als Satz der
     Prozedur; im lesenden Lauf ist die einzige Sicherung der Handarbeit ein Kommando (`gh api … | grep -n
     version`) und Text, kein Träger. F-2 ist eine zweite Ausprägung (ein Wort-Sensor für die Eigenschaft).
   - `BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet` (6×, Ausgang *geplant*,
     `ADR-0062`): §6 Frage 1 wurde in diesem Lauf **nicht** beantwortet — die Prozedur nennt keine Rolle
     (`grep` über Schritt 7/8), der Nachzug wurde von keinem Lauf ausgeführt (`git log` zeigt keinen Tap-Bezug
     außer dieser Prozedur). Kein neuer Beleg, keine Bewegung des Ausgangs.
5. **INFO R1-6 / F-5 → Planner und Auftraggeber:** Handbuch Weg C erst mit dem ersten Vorab-Tag nachziehen;
   der Träger dafür ist das Handbuch-Update des Release-Schnitts.
6. **Nachlauf-Review:** `7f6c1f8d` wurde nicht erneut reviewt; ob der Planner eine Kurzrunde will oder
   diesen Bericht als Deckung nimmt, ist seine Entscheidung (die DoD verlangt keine).

---

## Ende des Laufs

`make gates` und `make record-gates` liefen nach dem Commit dieses Berichts; Ergebnis in der Meldung des
Aufrufers. Der Lauf schrieb allein diese Datei; keine Korrektur an `docs/user/releasing.md`, am Slice, an
ADR, Hard Rule oder `harness/conventions*`.
