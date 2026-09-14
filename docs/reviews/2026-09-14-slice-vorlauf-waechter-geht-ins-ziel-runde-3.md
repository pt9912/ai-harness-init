# Review-Report: slice-vorlauf-waechter-geht-ins-ziel — Runde 3 — 2026-09-14

**Review-Art:** Code-Review gegen **Plan + Hard Rules** (Modul 10 §Drei Review-Arten). **Dritter
Lauf** am selben Gegenstand, geprüft ist das **Delta seit Runde 2**. **Kein DoD-Review** —
DoD-/Spec-Konformität prüft der Verifier (Modul 11, anderer Eingabe-Kontext).

**Gegenstand:** `ee350f6d` („fail-closed Bedingung des Fragments — Ziel-Definition mit Rezept,
Runde 3“) — die Behebung der zwei blockierenden Runde-2-Befunde. Der Commit davor, `e76b3962`
(`.claude/commands/implement-slice.md`, der Anweisungssatz der **ausführenden** Rolle, nach
[`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)), ist
**nicht** Gegenstand; er ist nur insoweit angesehen, wie er diesen Prüfstand berührt (§11).
**Geprüfter Stand:** `ee350f6d`; `main` trägt seither keinen Commit (`git rev-parse --short HEAD`
→ `ee350f6d`, `git status --porcelain` → leer). Runde-2-Report:
`docs/reviews/2026-09-14-slice-vorlauf-waechter-geht-ins-ziel-runde-2.md` — **sein Urteil ist
nicht übernommen**: jeder Befund ist in diesem Lauf einzeln nachgemessen (§1–§10), keiner
abgeschrieben.

**Kein Self-Review (Negativ-Aussage):** dieser Lauf hat an `ee350f6d`, an `e76b3962` und an den
drei Vorgänger-Commits dieses Gegenstands **nicht geschrieben** — kein Kommentar, kein Test, kein
Fragment, keine Mutations-Datei, kein Sensor-Dokument dieses Deltas stammt aus diesem Kontext.
Aus der Commit-Message und aus dem Implementer-Bericht ist **nichts** als Befund oder als
Negativbefund übernommen; die dort behaupteten Rot-Belege sind einzeln nachgefahren (§5, §6), und
zwei dort behauptete Aussagen sind **nachgemessen statt geglaubt** (§4, §6).

**Skill:** `.harness/skills/reviewer.md` (2.0.0) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** deepseek-v4.1-flash:cloud[1m] · **Datum:** 2026-09-14

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan `slice-vorlauf-waechter-geht-ins-ziel` (§1 Ziel und Abgrenzung, §2 DoD, §3 Plan)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.6, §3.7, §3.9)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) ·
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
- [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed) ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- Baseline `v6.8.0` · `regelwerk/grundlagen-harness-dateien.md` §Was ein Kommentar trägt
  (Zeitform-Test, die drei herausfallenden Klassen) — die Quelle, auf die §3.7 verweist
- Vorherige Findings am **selben Gegenstand**: Runde 1 (1 HIGH · 3 MEDIUM · 1 LOW · 2 INFO),
  Runde 2 (2 MEDIUM · 1 LOW · 1 INFO); am **selben Modul**:
  `2026-08-27-slice-106-review.md`, `2026-09-10-slice-073-emittierte-doc-gate-module-runde-5.md`

---

## Eigene Messungen

Jedes Kommando dieses Abschnitts ist in diesem Lauf gefahren. Wo eine Zahl steht, steht das
Kommando daneben, das sie liefert; **keine Erwartungswerte**
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
Die Docker-Sonden (`make gates`, `make full-smoke`) liefen über `make`; die isolierten
Make-/awk-Sonden in `/tmp` sind Wegwerf-Dateien und **nicht** im Repo.

### 1. Das neue Fragment verbatim, aus der Quelle gezogen

```sh
awk '/^const docGateMk = `/{sub(/^.*`/,"");print;f=1;next} f&&/^`$/{exit} f{print}' internal/emit/emit.go > /tmp/r3/probe/frag.mk
# 43 Zeilen; die zwei Bedingungen auf Zeile 27 (doc-immutable) und 35 (doc-commits)
grep -n 'ifeq' /tmp/r3/probe/frag.mk
```

Geprüft wurde damit **die emittierte Form**, nicht der Go-Text: das Fragment liegt in einem
Wegwerf-Verzeichnis als `harness/mk/doc-gate.mk`, daneben ein Root-Makefile mit
`include harness/mk/doc-gate.mk` und ein `d-check.mk`.

### 2. Die vier Ausgänge, an denen die Bedingung entscheidet — gemessen am Fragment

| Lage (`make -n doc-immutable RANGE=HEAD~1..HEAD`) | Ausgang | Verdikt |
|---|---|---|
| `d-check.mk` unverfälscht (aus diesem Repo, tool-abgeleitet) | Kette `history-range-guard` → Modul-Rezept | **bindet**, EXIT 0 |
| Ziel-Zeilen umbenannt (`doc-ohne-definition-…`) | Meldung + `exit 2` | **Abbruch** |
| dasselbe **ohne `awk` im PATH** (`env PATH=/nonexistent "$(command -v make)" …`) | dieselbe Meldung + `exit 2` | **Abbruch** |
| Ziel-Zeile bleibt, Rezept-Zeile gelöscht (`sed '/^doc-immutable:/{n;d}'`), **echter Lauf** ohne `-n` | Meldung, `make: *** [harness/mk/doc-gate.mk:32: doc-immutable] Fehler 2`, **RC=2** | **Abbruch** |
| `d-check.mk` leer | Meldung + `exit 2` | **Abbruch** |

**N-1 und N-2 sind damit an der Quelle nachgefahren, nicht geglaubt:** der unbekannte Ausgang
(kein Probe-Werkzeug) und der rezeptlose Nachweis wählen je den Abbruch, und der unverfälschte
Fall bindet weiter.

### 3. Die neue `awk`-Probe gegen einen Katalog von `d-check.mk`-Formen

Die Bedingung wurde isoliert nachgebaut (dieselbe `awk`-Zeile, `doc-x` als Ziel) und gegen **zwölf
Datei-Formen** gefahren (dreizehn Läufe, zwei davon dieselbe Form) — je mit GNU Awk, BusyBox-awk
und (Stichprobe) mawk; je Form zweimal gemessen: `awk '…' d-check.mk` (die Ausgabe des
Probe-Werkzeugs) und `make -f mk.tmpl all` (der daraus gewählte Zweig):

| Form | gawk 5.2.1 | busybox awk | mawk 1.3.4 | Zweig |
|---|---|---|---|---|
| Ziel + TAB-Rezept | `da` | `da` | `da` | bindet |
| Ziel + Leerzeilen + TAB-Rezept | `da` | `da` | — | bindet |
| Ziel + Kommentarzeile + TAB-Rezept | `rezeptlos` | `rezeptlos` | `rezeptlos` | Abbruch |
| Ziel mit `;`-Inline-Rezept | leer | leer | leer | Abbruch |
| Ziel allein, EOF | leer | leer | leer | Abbruch |
| Ziel + Leerzeile, dann EOF | leer | leer | — | Abbruch |
| Ziel + leere TAB-Zeile | leer | leer | — | Abbruch |
| Ziel + SPACE-eingerücktes „Rezept“ | `rezeptlos` | `rezeptlos` | — | Abbruch |
| `doc-x: ## help` + TAB-Rezept (die echte Form) | `da` | `da` | `da` | bindet |
| zwei Ziel-Zeilen, die zweite mit Rezept | `da` | `da` | — | bindet |
| Zielname mit Präfix (`x-doc-x:`) | leer | leer | — | Abbruch |
| nur `.PHONY: doc-x` | leer | leer | — | Abbruch |

**Portabilität: kein gawk-Spezial gefunden.** `substr`, der Ternär im `print`, `next`, `exit`,
`/regex/` und `[[:space:]]` sind POSIX; die drei Implementierungen stimmen über alle geprüften
Formen überein (`awk --version` → GNU Awk 5.2.1; `busybox awk`; `mawk -W version` → mawk 1.3.4).
**Grenze der Messung:** drei Host-Implementierungen, kein BSD-awk und kein POSIX-strikter Lauf
(`PATH`-Wechsel mit `POSIXLY_CORRECT` wurde nicht gefahren).

**Die Leerzeilen-Toleranz ist keine Lücke, sie deckt sich mit `make`.** Am Host gemessen
(`make -f`), wie `make` ein Rezept an eine Ziel-Zeile bindet:

```text
doc-x:            → RECIPE_RAN   (Ziel, Leerzeile, TAB-Rezept)
doc-x:            → RECIPE_RAN   (Ziel, # Kommentar, TAB-Rezept)
doc-x: ; rezept   → RECIPE_RAN   (Inline-Rezept)
```

`make` hängt das Rezept auch über eine Leerzeile **und** über eine Kommentarzeile hinweg an.
Die zwei Formen, in denen die Probe **strenger als `make`** ist (Kommentarzeile, `;`-Rezept),
enden **laut** (Abbruch) — kein stiller Pfad in der anderen Richtung. Die Leerzeilen-Form, in
der die Probe **schwächer** ist, ist keine: `make` bindet dort tatsächlich. Für die
**tool-generierte** Datei sind beide strengen Formen ohnehin unerreichbar (§4), und eine künftige
Form-Änderung des Werkzeugs färbt `make full-smoke` rot, weil dessen grüne Richtung den
Modul-Lauf verlangt (§6).

### 4. Die grüne Richtung am **emittierten** Fragment — der blinde Pfad „in der anderen Richtung“

Die naheliegende neue Kante nach der N-2-Behebung wäre, dass die **verschärfte** Probe eine
Ziel-Zeile **mit** Rezept nicht mehr als `da` erkennt — dann stünde der Abbruch über einem
gesunden Ziel. Gemessen über der **tool-generierten** Datei (nicht der Repo-Kopie):

```text
make full-smoke   # EXIT 0
full-smoke: Zieldefinition (golang): make doc-immutable bricht ueber einem d-check.mk ohne Ziel-Definition LAUT ab, ohne ein Modul zu fahren.
full-smoke: Zieldefinition (golang): make doc-commits bricht ueber einem d-check.mk ohne Ziel-Definition LAUT ab, ohne ein Modul zu fahren.
full-smoke: Zieldefinition (golang): make doc-immutable bricht ueber einem d-check.mk ohne Ziel-Definition LAUT ab, ohne ein Modul zu fahren.
full-smoke: Zieldefinition (golang): ohne das Probe-Werkzeug bricht make doc-immutable LAUT ab, statt zu binden.
full-smoke: Zieldefinition (golang): derselbe Aufruf ueber dem unverfaelschten d-check.mk bleibt gruen (doc-commits), der Modul-Lauf fand statt.
```

Die letzte Zeile ist der Beleg: `vorbindung_mit_zieldefinition` verlangt `rc = 0` **und**
`Datei(en) geprüft` im Output — ein Fehlurteil der Probe über einem gesunden `d-check.mk` des
Ziels wäre hier rot (Rezept gelesen, `harness/tools/full-smoke.sh`). Derselbe Befund an der Quelle
(§2, Zeile 1).

### 5. Die drei neuen bzw. geänderten Fälle — **einzeln** gefahren (kein voller `make mutate`)

Je Fall: Operand von Hand angewandt (`bash test/mutations/<fall>.sh`), `make full-smoke` gefahren,
die Ausgabe gelesen, dann `cp` aus der Sicherung zurück, `git status --porcelain` danach leer.

| Fall | Operand trifft | `make full-smoke` | gefallene Zusicherung (gelesen) |
|---|---|---|---|
| `329-doc-gate-fragment-ohne-fail-closed` | 2× (eine `ifeq`-Zeile je Ziel; `grep -c rezeptlos` nach dem Operand: 2 → 0) | **EXIT 2** | `make doc-immutable blieb ueber einem d-check.mk OHNE die Ziel-Definition GRUEN (Exit 0)` |
| `330-ziel-zeile-ohne-rezept-bindet` | 2× | **EXIT 2** | die ersten zwei Zusicherungen tragen, die dritte fällt, dieselbe Zeile |
| `331-unbekannter-probe-ausgang-bindet` | 2× (Diff gelesen: beide `ifeq`-Zeilen tragen jetzt `2>/dev/null \|\| echo da`) | **EXIT 2** | die ersten drei tragen, die vierte fällt: `der Aufruf waehlte trotz fehlenden Probe-Werkzeugs die Bindung …` |

**Jeder Fall trifft genau seinen Wächter und fällt aus dem richtigen Grund** (die `# expect:`-Zeile
steht in der Fehlschlag-Ausgabe) — die Stufe ist die richtige (`# verify: full-smoke` ist ein
geführter Modus des Treibers, `harness/tools/mutate.sh`), und `# files: internal/emit/emit.go`
löst auf genau eine Datei auf. **Kein voller `make mutate`** — die Weisung stellt den Satz auf die
Post-integration-Stufe, und die drei Einzel-Belege treten an seine Stelle.

### 6. Der eine Fall, den keiner der neuen Auslöser fährt — **selbst gemessen**

Die Probe steht **zweimal** (Zeile 27 und 35 des Fragments), und der Auslöser „Ziel-Zeile **ohne
Rezept**“ läuft in Abschnitt (f) nur für **`doc-immutable`** (`harness/tools/full-smoke.sh:553`;
`:548` und `:558` fahren dasselbe Ziel bzw. die andere Randlage). Die Gegenprobe — dieselbe
Mutation **einseitig** auf die `doc-commits`-Probe (`"rezeptlos"` → `"da"`), alles andere
unverändert:

```text
$ sed -i '100s@"rezeptlos"@"da"@' internal/emit/emit.go     # nur die doc-commits-Zeile
$ make full-smoke
FULLSMOKE_EXIT=0          # die Sektion (f) druckt alle vier Zusicherungen + die grüne Richtung
```

**Nichts wird rot.** Und der Defekt ist keiner der Theorie — am gedrifteten Fragment über einem
`d-check.mk`, dessen `doc-commits:` kein Rezept führt:

```text
$ make -n doc-commits RANGE=HEAD~1..HEAD     # gedriftetes Fragment
bash tools/harness/history-range-guard.sh "HEAD~1..HEAD"
$ make -n doc-commits RANGE=HEAD~1..HEAD     # unverfälscht, dieselbe Datei
echo "harness/mk/doc-gate.mk: d-check.mk fuehrt 'doc-commits' nicht als Ziel mit Rezept …" >&2 ; exit 2
```

Der gedriftete Zweig **bindet** — der Wächter läuft, das Modul nicht, der Aufruf endet ohne den
Modul-Lauf. Genau der stille Erfolg, gegen den die Bedingung steht, nur an einem der zwei Ziele.
Kein Textanker fängt das: der einzige Go-Test über das Fragment prüft die zwei **Bindungs**-Zeilen
(`internal/emit/emit_test.go`), keine Datei nennt die `awk`-Zeile außer den zwei Mutations-Operanden
— und die treffen **beide** Zeilen gleichzeitig (Fall `330`/`331`, §5). **Neu entstanden** mit
diesem Delta: die Rezept-Unterscheidung gibt es erst seit `ee350f6d`, und mit ihr den einseitig
unsichtbaren Zweig. **N-5.**

### 7. N-4 — die Befund-Kennungen, am Baum gezählt

```sh
grep -rn 'F-2\|f2_\|Review-Befund' harness/sensors/history-range-guard.md harness/tools/full-smoke.sh \
        internal/emit/emit.go test/mutations/329-*.sh test/mutations/330-*.sh test/mutations/331-*.sh
```

**4 Treffer (6 mit den `F-1`-Nennungen derselben Herkunft), alle außerhalb des Deltas** — `harness/tools/full-smoke.sh:1505`, `:1519`, `:1525`,
`:1541`, `:1547`, `:1738` (`slice-046 (Review F-2)`, `Review F-1/F-2`). Herkunft nachgemessen:

```sh
git blame -L 1505,1505 -L 1525,1525 -L 1738,1738 --date=short -- harness/tools/full-smoke.sh
# c868f0821 (pt9912 2026-07-25)  — alle drei
```

`c868f0821` ist der Slice-046-Stand, **nicht** Bestandteil dieses Deltas; der Cutoff des §3.7
(„der Bestand ist kein Arbeitsauftrag“) greift. In den **vom Delta angefaßten** Bereichen: **0
Treffer** — `f2_ohne_rezept_def`/`f2_mit_rezept_def`, die Sektion `(f) DER F-2-FALL` und die
zugehörigen Ausgabezeilen sind verschwunden, `test/mutations/329` zitiert statt der Befund-Kennung
jetzt `AGENTS.md §3.6`. Die neuen Namen beschreiben die Sache (`vorbindung_ohne_zieldefinition`,
`Zieldefinition`, `vorbindung_ohne_probewerkzeug`) und sind an den Adressaten gerichtet („wer diese
Zeile ändert“), nicht an den, der die Entscheidung traf.

### 8. Die zwei `ifeq`-Zeilen — driften sie gegeneinander?

Nach Zeichenvergleich sind sie bis auf den Zielnamen identisch:

```sh
sed -n '92p' internal/emit/emit.go | sed 's/doc-immutable/doc-X/g' > /tmp/r3/a.txt
sed -n '100p' internal/emit/emit.go | sed 's/doc-commits/doc-X/g'  > /tmp/r3/b.txt
diff /tmp/r3/a.txt /tmp/r3/b.txt      # leer
```

**Strukturell sind sie zwei Kopien ohne Ableitung.** Gezählt (ausführbare Nennungen je Ziel in
`internal/emit/emit.go`): `grep -c 'doc-immutable'` → **10** Zeilen (mit Prosa), `grep -c
'doc-commits'` → **7**; davon strukturell: `awk`-Muster, Bindungs-Zeile, Abbruch-Ziel-Zeile,
Meldung, `vorbindungsTargets()` — **fünf** je Ziel gegen **drei** im Runde-2-Stand (Bindungs-Zeile,
`grep`-Bedingung, `vorbindungsTargets()`). Die Menge ist gewachsen; ob sie eine Ableitung bekommt,
ist die offen gebliebene Struktur-Frage (§10).

### 9. Der Host-Werkzeug-Zuwachs — und was DoD (3) verlangt

Die Probe liest mit `awk` statt mit `grep`. **Keine neue Werkzeug-Klasse**, aber die
**Richtung** des Fehlt-Falls hat gewechselt: ohne `grep` **band** die alte Bedingung still, ohne
`awk` **bricht** die neue ab (§2). DoD (3) verlangt „keine neue Host-Abhängigkeit“ und „der
Fehlt-Fall sagt etwas, statt still zu bleiben“ — die zweite Hälfte ist damit belegt, die erste
ist unberührt: `awk` ist POSIX-Basis und wird von diesem Repo ohnehin vorausgesetzt
(`.claude/hooks/pretooluse-command-guard.sh`: „Reines bash + awk“; `harness/tools/extract-command.awk`
im Hook-Pfad). Der Abbruchtext nennt den Grund im zweiten Halbsatz („oder awk fehlt“) — der erste
Halbsatz („d-check.mk fuehrt … nicht als Ziel mit Rezept“) ist im Fehlt-Fall des Werkzeugs
irreführend, und `2>/dev/null` verbirgt die Ursache so weit wie vorher.

### 10. `make gates` und `make full-smoke` dieses Laufs

| Lauf | Ergebnis |
|---|---|
| `make gates` | **EXIT 0**; entscheidende Zeilen `baseline-verify: v6.8.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)`, `d-check: 1390 Datei(en) geprüft, 0 Befund(e)` (derselbe Lauf mit **diesem Report** im Baum: **1391**, `grep -n "^d-check:" /tmp/r3/gates2.log`), `comment-claims: 58 Datei(en) geprueft, 0 Befund(e)`; bats `ok`-Zeilen **280**; `golangci-lint`-Stufe und Go-Tests grün |
| `make full-smoke` (unverfälscht) | **EXIT 0** (§4) |
| `make full-smoke` je Einzelfall `329`/`330`/`331` | **EXIT 2** je, aus dem benannten Grund (§5) |
| `make full-smoke` über der einseitigen Drift (§6) | **EXIT 0** — der Befund N-5 |
| `make mutate` | **nicht gefahren** — Weisung: Post-integration, getragen von `.github/workflows/mutate.yml`; an seine Stelle treten die drei Einzel-Belege (§5) |

*Keine Erwartungswerte* — Datei- und Testzahlen wandern mit dem Baum.

### 11. `e76b3962` — nur, soweit es diesen Prüfstand berührt

Der Satz steht in `.claude/commands/implement-slice.md` (dem Anweisungssatz der ausführenden
Rolle) und stellt die Runde auf **Einzel-Belege** um; den repo-weiten Satz trägt
`.github/workflows/mutate.yml`. Er zitiert dafür den adoptierten Stand:
`v6.8.0` · `regelwerk/grundlagen-klassifikation.md` §Klassifikation und Steering Loop
› Lifecycle-Verteilung — **verbatim nachgesehen** (`grep -n 'nach Merge : Mutation Tests' …` →
eine Zeile, „nach Merge : Mutation Tests : vollständige Verifikation : Validator-Agent“). Er
deckt sich mit der Weisung dieses Laufs (§5) und berührt keinen geprüften Pfad. `258ab942`
(Planner, `.claude/agents/implementer.md`) liegt außerhalb dieses Gegenstands.

---

## Runde 2 — je Befund ein Verdikt

| Runde-2-ID | Verdikt | Kommando / Beleg |
|---|---|---|
| **N-1** (MEDIUM) | **behoben** | Der unbekannte Ausgang wählt den Abbruch: `env PATH=/nonexistent "$(command -v make)" -n doc-immutable` über einem `d-check.mk` **ohne** Ziel-Zeile → Meldung + `exit 2` (§2); ohne `awk` und mit **leerem** `d-check.mk` ebenso (§2); Fall `331` fällt rot mit der behaupteten Meldung (§5) |
| **N-2** (LOW) | **behoben**, und die Gegenrichtung ist gemessen | Ziel-Zeile ohne Rezept: echter Lauf `RC=2` + Meldung (§2); die grüne Richtung bleibt intakt — `make full-smoke` verlangt den Modul-Lauf über der **tool-generierten** Datei und ist EXIT 0 (§4) |
| **N-3** (INFO) | **nicht angefaßt** (war an den Architect übergeben) — **und die Menge ist gewachsen** | Die zwei `ifeq`-Zeilen sind identisch bis auf den Zielnamen (Zeichenvergleich, §8); strukturelle Nennungen je Ziel: **5** gegen 3 (§8). Der Runde-2-Satz „beide Drift-Richtungen enden laut, kein stiller Pfad“ **trägt für die neue Probe nicht mehr** — einseitige Drift endet still (§6, **N-5**) |
| **N-4** (MEDIUM) | **behoben** | `grep -rn 'F-2\|f2_\|Review-Befund'` über die Delta-Dateien → 0 Treffer in den angefaßten Bereichen; die verbleibenden liegen in `slice-046`-Bestand (`git blame` → `c868f0821`, 2026-07-25) (§7) |

**Neu entstanden ist durch die Behebung N-5** (einseitig unsichtbare Rezept-Unterscheidung, §6)
und die umgeschriebene Konjunktiv-Klausel **N-6** (§8/Findings). Beides verdankt sich der Behebung,
nicht dem Vorgängerstand.

## Findings (neu in diesem Lauf)

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der verbindlichen Single Source of
Truth. Die Spalten sind nur **gespiegelt**, nicht neu definiert; bei Abweichung gilt der Skill bzw.
dessen Quelle `v6.8.0` · `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| N-5 | **MEDIUM** | Die fail-closed Probe steht **zweimal** (je Ziel), der neue Auslöser „Ziel-Zeile **ohne Rezept**“ wird aber nur für `doc-immutable` gefahren (`harness/tools/full-smoke.sh:553`, während `:548` und `:558` andere Kombinationen fahren). Gemessen: eine **einseitige** Drift der `doc-commits`-Probe (`"rezeptlos"` → `"da"`) läßt `make full-smoke` **EXIT 0**, und das gedriftete Fragment **bindet** über einem `doc-commits:` ohne Rezept — nur der Wächter läuft, das Modul nicht; kein Textanker (Go-Test, Mutations-Operand) prüft diese Zeile allein, und der Sensor-Text liest die Abdeckung als beide Auslöser an beiden Zielen. | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed) · [`AGENTS.md`](../../AGENTS.md) §3.6 | `harness/tools/full-smoke.sh:547-558` · `internal/emit/emit.go:92,100` · `harness/sensors/history-range-guard.md:73-88` | ja — einseitige Drift auf `internal/emit/emit.go` setzen, `make full-smoke` (§6) | **doppelte-probe-ohne-zweiseitigen-negativtest** |
| N-6 | **LOW** | Die in diesem Delta **umgeschriebene** Begründungsklausel der fail-closed-Zusage steht im Konjunktiv über die verworfene Alternative: „Sonst stuende die Vorbindung ueber einem Ziel ohne Rezept, und der Aufruf endete mit Erfolg (Exit 0), statt zu fallen.“ Sie folgt einer indikativen Zusage („jeder andere … faellt in den Abbruch mit Exit 2“). Dieselbe Form trägt der umgeschriebene Kommentar der Sektion (f) („endet der Aufruf des Ziels sonst mit Erfolg“). Die Grenze der Regel ist im Repo unentschieden — im **selben** Skript stehen dutzende solcher Klauseln vorbestehend. | [`AGENTS.md`](../../AGENTS.md) §3.7 · `v6.8.0` · `regelwerk/grundlagen-harness-dateien.md` §Was ein Kommentar trägt („Drei Klassen fallen heraus: Deliberation — der Konjunktiv über die verworfene Alternative“) | `internal/emit/emit.go:81-82` · `harness/tools/full-smoke.sh:539` | nein — kein Gate liest die Zeitform eines Kommentars | **konjunktiv-ueber-die-verworfene-alternative-in-umgeschriebener-klausel** |

### Messung zu N-5 (weil daran das Verdikt hängt)

```text
$ sed -i '100s@"rezeptlos"@"da"@' internal/emit/emit.go      # nur die doc-commits-Zeile
$ git diff -- internal/emit/emit.go | grep '^[+-]ifeq'
-ifeq ($(shell awk '/^doc-commits:/… ? "da" : "rezeptlos");exit}' d-check.mk 2>/dev/null),da)
+ifeq ($(shell awk '/^doc-commits:/… ? "da" : "da");exit}' d-check.mk 2>/dev/null),da)
$ make full-smoke
FULLSMOKE_EXIT=0
$ grep -nE 'FEHLER' /tmp/r3/fs-drift.log | head
(keine Zeile — der Lauf druckt vier Zieldefinition-Zusicherungen und die grüne Richtung)
# danach zurückgenommen (cp aus der Sicherung), git status --porcelain -> leer
```

### Messung zu N-6 (die Grenze, statt eines Verdikts)

```sh
MUSTER='#.*(stuende|waere|waeren|entstuende|liefe|koennte|belegte|abbraeche|traege|muesste|kaeme|endete|erzeugte|behauptete)'
grep -nE "$MUSTER" internal/emit/emit.go harness/tools/full-smoke.sh | wc -l             # 30
git grep -cE "$MUSTER" ee350f6d^ -- harness/tools/full-smoke.sh internal/emit/emit.go    # 26 + 1 → 27
git diff ee350f6d^ ee350f6d -- internal/emit/emit.go harness/tools/full-smoke.sh \
  | grep -cE '^\+.*(#|//).*(stuende|waere|liefe|endete|belegte|entstuende)'                # 4
```

**Das Muster ist eine Obergrenze, kein Konjunktiv-Zähler** — es trifft auch Präteritum-Formen
(`endete`, `erzeugte`). Es zeigt die Größe des Bestands derselben Form: **vor** diesem Delta **27**
Treffer (26 in `harness/tools/full-smoke.sh`, 1 in `internal/emit/emit.go`), jetzt **30**, davon
**4** durch dieses Delta hinzugefügte Zeilen (die Netto-Differenz ist eine ersetzte Zeile). Eine
einzelne umgeschriebene Klausel zu verurteilen, während der Bestand derselben Form im Bestand
bleibt, wäre inkonsistent — dieselbe Abwägung, die
`docs/reviews/2026-08-09-slice-066-verdikt-runde.md` für dieselbe Klasse als **LOW, nicht
blockierend** ausgesprochen hat. **Kein Blockiergrund**, aber benannt: die Klausel ist in diesem
Delta **neu geschrieben**, und die Vorfassung war indikativisch („… endet dann mit Erfolg (Exit 0),
statt zu fallen“).

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Die neue `awk`-Probe (Portabilität)** | geprüft, ohne Befund: kein gawk-Spezial; zwölf Datei-Formen × GNU Awk 5.2.1 und BusyBox-awk stimmen überein, die mawk-Stichprobe ebenfalls (§3). **Grenze:** drei Host-Implementierungen, kein BSD-awk, kein `POSIXLY_CORRECT`-Lauf |
| **Leerzeilen-Toleranz der Probe** | geprüft, ohne Befund: `make` hängt das Rezept über Leerzeilen hinweg an (am Host gemessen) — die Probe ist dort **nicht** schwächer als `make` (§3) |
| **Die zwei Formen, in denen die Probe strenger als `make` ist** (Kommentarzeile, `;`-Inline-Rezept) | geprüft, ohne Befund: beide enden **laut** (Abbruch), kein stiller Pfad; für die tool-generierte Datei unerreichbar, und eine Form-Änderung des Werkzeugs färbt `make full-smoke` über dessen grüne Richtung rot (§3, §4) |
| **Fail-closed bei leerem `d-check.mk`, EOF nach der Ziel-Zeile, fehlendem Probe-Werkzeug, `.PHONY`-Marke allein, Namens-Präfix** | geprüft, ohne Befund: alle fünf Formen wählen den Abbruch (§2, §3) |
| **Der stille Erfolg über einer leeren TAB-Zeile** | geprüft, mit Grenze: die Probe wählt dort den Abbruch (leere Ausgabe), `make` hätte eine leere Rezept-Zeile — die konservative Richtung; die Form ist in einer tool-generierten Datei nicht zu erwarten (§3) |
| **DoD (3) „keine neue Host-Abhängigkeit“** | geprüft, ohne Befund: `awk` ist POSIX-Basis und wird von diesem Repo ohnehin vorausgesetzt; die **Richtung** des Fehlt-Falls ist von still auf laut gewechselt (Verbesserung) — der Abbruchtext nennt „oder awk fehlt“ (§9) |
| **Der Rot-Beleg je Fall (`# expect:`)** | geprüft, ohne Befund: alle drei `expect`-Zeilen stehen in der Fehlschlag-Ausgabe der je gefahrenen Mutation (§5); `# verify: full-smoke` ist ein geführter Modus des Treibers, `# files:` löst eindeutig auf |
| **Die zwei Mutations-Operanden** | geprüft, ohne Befund: `330` trifft `? "da" : "rezeptlos"` **2×** (nach dem Operand: `grep -c rezeptlos` → 0), `331` trifft beide `ifeq`-Zeilen (Diff gelesen); keiner trifft außerhalb der Probe (§5) |
| **Der E2E-Sensor selbst (Stilles-Grün)** | geprüft, **mit Befund N-5**: die drei Helfer prüfen je beide Richtungen (Exit, Meldung, „kein Modul-Lauf“) und beenden sich im Zweifel mit `exit 1`; **aber** der zweite und dritte Auslöser laufen nur an einem der zwei Ziele, und die Probe steht zweimal |
| **`AGENTS.md` §3.2 (Lint-Suppression)** | geprüft, ohne Befund: kein `//nolint`, kein `# shellcheck disable` im Delta |
| **`AGENTS.md` §3.9 (Docker-only)** | geprüft, ohne Befund: kein Rezept ruft ein Host-Werkzeug in der Befehlsposition; das Fragment arbeitet mit `bash`, `git`, `awk`, das Bild kommt aus `d-check.mk` |
| **`AGENTS.md` §3.7 über allen neuen Texten (außer N-6)** | geprüft, mit Befund N-6 und sonst ohne: keine Befund-Kennung, keine Slice-Nummer als Erzählung, kein Lauf-Protokoll, kein abwesender Text, kein abgebrochener Satz; „davor war 'Keine Regel'“ in der Sektion (f) ist **Bestand** aus der Vorfassung und im selben Zug nur umgebrochen |
| **`AGENTS.md` §3.11 (Adresse in einfrierendem Artefakt)** | geprüft, ohne Befund: die neuen Texte nennen kein Artefakt bei seinem Pfad, das der Prozeß bewegt; Kennungen (LH-QA-01, §3.6) stehen als Inline-Code |
| **`MR-025` (Zahl neben Kommando)** | geprüft, ohne Befund: die neuen Texte führen keine Zahl als Erwartungswert; `20 Datei(en)`/`0 Befund(e)` sind zitierte Programm-Ausgaben |
| **Gate-Lockerung ohne ADR (§3.5)** | geprüft, ohne Befund: das Delta nimmt einen stillen Erfolgspfad weg und fügt keinen hinzu (N-5 ist eine **Abdeckungs**-Lücke, keine Senkung); keine Schwelle, kein Modul, keine Strenge gesenkt |
| **Layout/Reichweite der emittierten Fassung** | geprüft, mit Grenze: geprüft ist das Fragment **verbatim** aus `docGateMk` (§1) und im gebootstrappten Klon über `make full-smoke` (§4); die zwei `--decide`-Zweige und die `enforce`-Vorlage des Wächters liegen außerhalb dieses Deltas |
| **Traceability der Commit-Messages** | geprüft, ohne Befund: `ee350f6d` nennt `LH-FA-06`/`LH-QA-01` und trägt die Rolle im Betreff; der Rot-Beleg ist im Rumpf benannt, mit Bedingung und gelesener Meldung |
| **Rollentrennung (§3.8/§3.10/ADR-0028)** | geprüft, ohne Befund: kein Commit dieses Deltas berührt Hard Rule, Adaptions-Eintrag, ADR oder Closure-Artefakt; `e76b3962` schreibt den Anweisungssatz **seiner** ausführenden Rolle (ADR-0028), `258ab942` ist Planner-Arbeit an `.claude/agents/implementer.md` und liegt außerhalb dieses Gegenstands (§11) |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 (N-5) |
| LOW | 1 (N-6) |
| INFO | 0 neu (N-3 aus Runde 2 bleibt offen, s. Verdikt-Tabelle) |

**Finding-Klassen dieses Laufs:** doppelte-probe-ohne-zweiseitigen-negativtest ·
konjunktiv-ueber-die-verworfene-alternative-in-umgeschriebener-klausel

Die zwei Runde-2-Klassen `fail-closed-bedingung-waehlt-bei-unbekanntem-ausgang-den-permissiven-zweig`
und `befund-kennung-als-name-in-neuem-skript` sind **geschlossen**;
`ziel-definition-ohne-rezept-unterlaeuft-die-fail-closed-pruefung` ist in ihrer benannten Form
geschlossen (beide Ziele, am emittierten Fragment) und lebt als **einseitige** Randlage in N-5
weiter; `dieselbe-menge-in-drei-literalen-nennungen-ohne-ableitung` ist **offen und größer
geworden** (5 je Ziel, §8). Ob das den Zähler bewegt, entscheidet die Slice-Closure §7 — dieser
Report zählt nicht.

## Verdikt

**Merge-blockierend: ja** (HIGH und MEDIUM blockieren, Vorlage §Verdikt) — **ein MEDIUM (N-5)**.
**Kein HIGH:** die Klasse dieses Slice (stiller Erfolg über leerem Prüfbereich) ist an allen in
Runde 1 und 2 benannten Stellen geschlossen und je einzeln rot gesehen; N-5 ist **kein** Defekt des
heutigen Codes, sondern eine **Abdeckungs**-Lücke: der neue Auslöser läuft an einem von zwei
Zielen, und die Probe steht zweimal.

**Klassifikations-Grenze, benannt statt still entschieden:** N-5 wäre unter dem Skill-Punkt
„Stilles-Grün-Pfad in einem Gate“ auch als HIGH lesbar — der Lauf meldet grün (§6). Er ist es
**nicht**, weil kein Sensor eine Abdeckung über der einseitigen Drift **behauptet**: die
Commit-Message nennt „(beide Targets)“ ausdrücklich nur für den ersten Auslöser, und der
Test-Kommentar spricht von den zwei Auslösern des einen Ziels. Die **Doc**-Zeile in
`harness/sensors/history-range-guard.md` liest die Abdeckung dagegen über beide Ziele und ist der
Grund, warum die Lücke nicht als INFO durchgeht. Der Unterschied zwischen LOW und MEDIUM bleibt
eine Architect-Frage: wer den Abdeckungs-Satz der Sensoren-Doku an das Kriterium binden will („welche
Ziel-×-Auslöser-Zelle ist gefahren?“), hat hier einen schärferen Satz und damit ein HIGH.

**Was dieser Lauf zu den drei Auftrags-Fragen sagt.** (1) **N-1 und N-4 sind behoben**, N-2 ist
behoben und die von der Aufgabe verlangte **Gegenrichtung** ist gemessen: die verschärfte Probe
erkennt die Ziel-Zeile mit Rezept weiter als `da` — an der tool-generierten Datei, nicht nur an der
Repo-Kopie (§4). (2) Die zwei behaupteten Rot-Belege **tragen**: alle drei Fälle sind einzeln
gefahren, jeder fällt mit der in seiner `# expect:`-Zeile benannten Zusicherung (§5). (3)
**Neu entstanden ist etwas**: N-5 hat dieselbe Bauart wie die zwei vorigen Runden-Funde — eine
Behebung, die eine Kopie mehr erzeugt hat als ihr Auslöser abdeckt (§6), und N-6 eine
umgeschriebene Klausel in der Form, die §3.7 ausschließt (§8).

**Offen geblieben in diesem Lauf** (was dieser Report **nicht** geprüft hat): (a) ein **eigener**
voller `make mutate` — Weisung: Post-integration-Stufe (`.github/workflows/mutate.yml`); an seine
Stelle treten die drei Einzel-Belege (§5); (b) die **N-3**-Struktur-Frage (Ableitung der zwei
Zielnamen) — sie ist unverändert offen und gehört dem Architect; (c) `258ab942`
(`.claude/agents/implementer.md`) und der Inhalt von `e76b3962` über den Prüfstand hinaus; (d) die
Frage, ob die leere Range oder die unkonfigurierte Sektion der emittierten `.d-check.yml` die
Ursache der „blind grün“-Hälfte ist (Runde-2-Grenze, unverändert); (e) die span-/Telemetrie-Achse.

**Übergabe:** **N-5** und **N-6** gehen an den **Implementer**. Die **N-3**-Struktur-Frage bleibt
beim **Architect** — und sie ist durch N-5 nicht mehr reine Form: die Drift, die sie beschreibt,
hat jetzt einen gemessenen stillen Ausgang. Die Finding-Klassen gehen in die Slice-Closure §7 und
von dort in das Beobachtungs-Register.

Dieser Report ist ein **Lauf-Beleg** (Audit: dieses Delta, dieser Skill, dieses Modell, dieses
Verdikt) — er wird über Läufe hinweg nicht wieder gelesen und muss es nicht. Er ersetzt keine
Verifikation: DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).
