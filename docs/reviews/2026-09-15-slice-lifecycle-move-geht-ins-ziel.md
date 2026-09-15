# Review-Report: slice-lifecycle-move-geht-ins-ziel — 2026-09-15

**Review-Art:** Code-Review gegen **Plan + ADRs + Hard Rules** (Modul 10 §Drei Review-Arten).
Gegenstand sind drei Commits, die ein Werkzeug in die **emittierte** Ebene legen: eine Vorlage,
die das Werkzeug in ein fremdes Ziel schreibt, ihr Make-Fragment, ein E2E im gebootstrappten
Ziel, ein Test-Paar und drei Mutations-Fälle. **Kein DoD-Review** — DoD-/Spec-Konformität prüft
der Verifier (Modul 11, anderer Eingabe-Kontext).

**Gegenstand:** die drei Commits `6d8401e3` · `89bc30f3` · `9915d99c` (Kopf `9915d99c`), gegen
den Slice-Plan `slice-lifecycle-move-geht-ins-ziel` §1 · §2 · §3 · §5 · §6 · §8.

```sh
git log --oneline 9915d99c..HEAD -- internal/emit harness/tools/full-smoke.sh test/slice-mv.bats test/mutations
#  (keine Ausgabe)   EXIT 0 — kein späterer Commit hat den Gegenstand berührt
git status --porcelain
#  (keine Ausgabe)   EXIT 0 — der Stand dieses Laufs ist der Commit-Kopf
```

Der Slice-Plan selbst ist seit dem Gegenstand **einmal** bewegt (`195ff371`, Rolle Planner:
DoD-Punkt 1 auf seine zwei Lesarten gezogen) — die DoD ist nicht Teil dieses Reports.

**Kein Self-Review:** dieser Lauf hat an dem Gegenstand **nicht** geschrieben — weder an den drei
Commits noch an einer der elf berührten Dateien noch an einer Vorlage daraus. Kein Befund ist
aus einer Commit-Message oder einem Implementer-Bericht übernommen; jede Zahl unten ist in
diesem Lauf gefahren, und wo ein Rot erwartet wurde, ist die Ausgabe gelesen.

**Skill:** `.harness/skills/reviewer.md` @ `0565f274` (2.0.0) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** deepseek-v4.1-flash:cloud[1m] · **Datum:** 2026-09-15

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

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan `slice-lifecycle-move-geht-ins-ziel` — §1 (Ziel und Abgrenzung), §2 (DoD), §3
  (Plan), §5 (Closure-Trigger), §6 (Risiken), §8 (Sub-Area-Prüfungen)
- [`ADR-0042`](../../docs/plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (Festlegung 1
  und 2 — die zwei Pfad-Ausnahmen; §Was diese Entscheidung nicht tut, *emittiertes Repo*) ·
  [`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) ·
  [`ADR-0053`](../../docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
  (Proposed — Festlegung 4 und ihr Kandidat `slice-werkzeug-commits-tragen-eine-kennung`) ·
  `ADR-0007` (Idempotenz-Klassen, im Gegenstand zitiert) ·
  [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules; tragend hier §3.1, §3.2, §3.5, §3.6, §3.7, §3.9) · §2
- `LH-FA-08` · `LH-FA-02` · `LH-QA-01` (die drei, die der Slice in seinem Bezug führt)
- [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  (Setzung 1 und §Grenze) ·
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) ·
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
- Baseline `v6.8.0` · `regelwerk/grundlagen-traceability.md` §Herkunfts-Anker für
  Steering-Loop-Regeln · `regelwerk/grundlagen-source-precedence.md` §Vergabe ·
  `regelwerk/modul-04-adrs.md` §Hard Rule für Accepted-ADRs ·
  `regelwerk/modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin)
- Beobachtungen, die der Plan in §8 sichtet:
  `BEO-ALL/verweise-brechen-beim-ortswechsel` (6×, offen) ·
  `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen` (24×, offen); aus dem Auftrag
  zusätzlich `BEO-ALL/adaptions-marker-nennt-eine-stelle-die-emissions-klasse-nicht-haelt` und
  `BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`
- Vorherige Findings am Schwester-Gegenstand `slice-174-archivierung-emittieren` (dieselbe Welle,
  dieselbe Bauart: Fragment + Werkzeug + E2E)

---

## Eigene Messungen

Jedes Kommando dieses Abschnitts ist in diesem Lauf gefahren. Wo eine Zahl steht, steht das
Kommando daneben, das sie liefert; **keine Erwartungswerte**
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

### 1. Der Happy Path — `make full-smoke` und `make gates`

```sh
make full-smoke   # EXIT 0
# full-smoke: Lifecycle-Wechsel im Ziel (golang): make slice-mv bewegt slice-smoke-move.md nach
#   next/, legt den reinen Move als eigenen Commit an (0 insertions/0 deletions) und zieht den
#   Verweis-Nachzug getrennt davon nach — eingehend die Nachbar-Datei, ausgehend das praefixlose
#   Geschwister; die ADR bleibt nach der Repo-Politik des Fragments unberuehrt.
# full-smoke: Voraussetzung (golang): make slice-mv bricht ueber einem unsauberen Arbeitsbaum ab …
# full-smoke:   slice-mv: Arbeitsbaum nicht sauber — erst committen oder stashen …
# full-smoke: ohne Verweise (golang): make slice-mv bewegt slice-smoke-einsam.md und laesst es
#   beim einen Move-Commit — kein zweiter Commit ohne Inhaltsaenderung.
make gates        # EXIT 0 — d-check: 1435 Datei(en) geprueft, 0 Befund(e) · comment-claims: 62 Datei(en) geprueft, 0 Befund(e)
```

**Der E2E trägt, was er zugesagt hat** — er ist gefahren, nicht gelesen: die beiden Richtungen,
der reine Move-Commit (`git show --numstat → 0 0`), die Ausnahme gegen eine ADR, der Abbruch über
einem unsauberen Baum und der Zweig ohne Verweise. Der Nicht-Gate-Zahn hat seine Vorbedingung
(`record-gates.sh`/`baseline-verify.sh`/`docker run` in der gelesenen Kette) — die Kette ist
damit nicht leer und die Aussage *„slice-mv steht nicht darin"* prüft einen Inhalt.

### 2. Frage 4 — vergleicht `test/slice-mv.bats` die zwei Fassungen wirklich?

Reproduziert in einer **eigenen Baum-Attrappe** (`/tmp`, außerhalb des Repos: `test/slice-mv.bats`
plus je eine Kopie der zwei Skripte an ihren relativen Orten), damit der Prüfbaum unberührt
bleibt:

```sh
docker run --rm --network none -v /tmp/review-mvtest:/code:ro -w /code bats/bats@sha256:e8f18… test/
#  1..11   alle ok                                     ← unmutierter Ausgangsstand

sed -i 's/0-9a-z/0-9/g' internal/emit/templates/enforce/slice-mv.sh   # NUR das emittierte Exemplar
#  not ok 7 … [ "$output" = "1" ] failed
#  not ok 8 … [ "$output" = "2" ] failed

cp <unmutiert> … ; sed -i 's/#g" "$file"$/#" "$file"/' internal/emit/templates/enforce/slice-mv.sh
#  1..11   (kein "not ok")                             ← NUR das emittierte Exemplar
```

**Im Prüfbereich rot, außerhalb grün.** Die erste Sonde färbt (der Ausgehend-Nachzug erkennt eine
benannte Kennung in *einer* Fassung nicht mehr) — die Vergleichs-Hälfte trägt dort. Die zweite
Sonde ist eine einseitige **Entscheidung** ohne Fall: das `/g`-Flag des Eingehend-`sed` entfernt
nur im emittierten Exemplar. Danach ersetzt die eine Fassung je Zeile **ein** Vorkommen, die
andere alle — und **beide** Suiten bleiben grün. Die Klasse ist damit eingeengt, nicht
geschlossen. → **F-2**.

### 3. Der Zahn des neuen Test-Paares — Mutation 343 einzeln gefahren

```sh
cp -a <Arbeitsbaum ohne .git> /tmp/review-mvmut
bash /tmp/review-mvmut/test/mutations/343-lifecycle-kommando-haengt-an-gate-checks.sh
docker build --no-cache-filter test --build-arg GO_VERSION=1.27.0 --target test .
#  --- FAIL: TestSliceMvFragment_LiegtImZielUndHaengtNichtAnDerGatesKette
#      slicemv_test.go:50: harness/mk/slice-mv.mk haengt [slice-mv] an GATE_CHECKS — es traegt ein Kommando, kein Gate
#      slicemv_test.go:53: "slice-mv" haengt in der gates-Kette des Ziels …: [baseline-verify build docs-check gates lint record-gates slice-mv test]
#  EXIT 1
```

**Rot, und die Meldung trägt die behauptete Ursache** (beide Zweige der Zusage, nicht „irgendwie
rot"). 344 und 345 sind **nicht** gefahren — die Weisung dieses Laufs schließt den vollen
`make mutate` aus; beide zielen auf dieselbe Go-Stufe, deren Ansteuerung mit 343 belegt ist.
→ §Was dieser Lauf nicht prüfen konnte.

### 4. Frage 3 — ist die Ausnahmeliste wirklich *setzbar*?

```sh
printf 'show:\n\t@printf "%%s\\n" "$${SLICE_MV_AUSGENOMMENE_PFADE:-LEER}"\n' > Makefile && make show
#  LEER
SLICE_MV_AUSGENOMMENE_PFADE=':!x :!y' make show      #  :!x :!y      ← Umgebung
make SLICE_MV_AUSGENOMMENE_PFADE=':!z' show          #  :!z          ← Kommandozeile
printf 'SLICE_MV_AUSGENOMMENE_PFADE = :!aus_makefile\n…' > Makefile && make show
#  LEER                                                ← Zuweisung IM Makefile, ohne export
printf 'export SLICE_MV_AUSGENOMMENE_PFADE = :!mit_export\n…' > Makefile && make show
#  :!mit_export
```

**Zwei der drei benannten Orte nehmen die Zuweisung an, der dritte nur mit `export`.** Die
Umgebung und die Kommandozeile reichen durch; eine bloße Zuweisung in einer Make-Quelle tut es
nicht. Der Skriptkopf nennt „im Aufruf **oder in seinem eigenen Make-Fragment**". → **F-3**.

### 5. Frage 1 — die Kennungs-Frage, in beide Richtungen gemessen

```sh
RE='ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+'
git log --format='%s' | grep -c  '^slice-mv:'          # 417
git log --format='%s' | grep '^slice-mv:' | grep -vcE "$RE"   #  48
grep -n -A 6 '^commits:' .d-check.yml                  # id-patterns: ADR-\d{4} · LH-[A-Z]{2}-\d{2} · MR-\d{3} · slice-\d+
grep -rn 'Die Kennung \*\*ist\*\* der Dateiname' .harness/baseline/v6.8.0/regelwerk/grundlagen-traceability.md
#  :88
git grep -lE 'slice-(\[0-9\]|\\d)' -- internal/emit    # 3 Dateien, keine davon das neue slice-mv.sh
```

**Die Umkehrung trägt an ihrem Kern.** Die Baseline sagt wörtlich, die Kennung **sei** der
Dateiname (`v6.8.0` · `regelwerk/grundlagen-traceability.md` §Herkunfts-Anker für
Steering-Loop-Regeln, Zeile 88), [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 setzt den Namen als Form, und die Message des Werkzeugs führt `slice-<Kennung>.md`
wörtlich. Was die 48 der 417 nicht trifft, ist `slice-\d+` in `.d-check.yml` —
**Konfiguration**. Und die Konfigurations-Seite ist heute die **letzte** Stelle dieser Bindung:
`git grep -nlE 'slice-(\[0-9\]|\\d)' -- harness/tools internal cmd Makefile d-check.mk ':!internal/emit'`
nennt nur noch `harness/tools/commit-msg-traceability.sh` — die zwei Stellen, die
[`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) §Grenze namentlich führt, binden die Kennung nicht mehr an Ziffern. Der
Kandidat wird damit nicht kleinredet, sondern **bestätigt**: die Form-Frage bleibt bei ihm, und
die Menge ist das, was fällt. Sein offener Rest ist F-6.

### 6. §3.6 — ein Test-Name, gegen den *falschen* Grund gefahren

```sh
cp -a <Arbeitsbaum ohne .git> /tmp/review-mvmut2
# Schritt 9 der Vorlage auf die Handarbeit zurückgeholt (die Stelle nennt `make slice-mv` nicht
# mehr) UND einen Ersatz-Nennung im ANPASSEN-Block daneben gestellt:
grep -c 'make slice-mv' internal/emit/templates/commands/implement-slice.md   # 2   ← unverändert
docker build --no-cache-filter test --build-arg GO_VERSION=1.27.0 --target test .
#  ok  github.com/pt9912/ai-harness-init/internal/emit     ← grün, alle Pakete ok   EXIT 0
```

**Der Wächter des Lieferpunkts bleibt grün, während der Lieferpunkt fällt.** → **F-1**.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | `TestSliceMvAnleitung_NenntDasWerkzeugAnDenZweiStellen` behauptet in Name und Doc-Kommentar, das Werkzeug sei **an den zwei Stellen** (Eintritt nach `in-progress`, Closure nach `done`) benannt; gemessen wird `strings.Count(anleitung, "make slice-mv") >= 2` — ein Vorkommen irgendwo im Dokument. Im Beleg-Lauf bleibt der Wächter grün, während Schritt 9 wieder `git mv` von Hand vorschreibt und die zweite Nennung in einem Kommentar daneben steht. | `AGENTS.md` §3.6 (Hard Rule) · `v6.8.0` · `regelwerk/modul-11-verification.md` §Bewusstes Brechen für DoD-Testbehauptungen | internal/emit/slicemv_test.go:157-176 (Zählung :162) | ja — `make test-go` mit der Mutation aus §6 der Messungen färbt nicht rot, das ist der Befund | `test-name-behauptet-stelle-gemessen-wird-ein-zaehler` |
| F-2 | MEDIUM | Der Kopf von `test/slice-mv.bats` (und die Message von `6d8401e3`) sagt, eine **einseitige** Änderung färbe rot; die zwei Fassungen werden über denselben Fall-Satz gefahren, also nur über die Entscheidungen, die ein Fall trifft. Gemessen bleibt eine einseitig entfernte Entscheidung (das `/g`-Flag des Eingehend-`sed` in einem der zwei Exemplare) über **allen elf** Fällen grün. | `BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor` · `AGENTS.md` §3.6 | test/slice-mv.bats:15-21 | ja — die zwei Sonden aus §2 der Messungen, in einer Baum-Attrappe gefahren | `vergleichs-zusage-weiter-als-der-fall-satz` |
| F-3 | MEDIUM | Der REPO-POLITIK-Kommentar des Werkzeugs nennt als Ort für `SLICE_MV_AUSGENOMMENE_PFADE` „im Aufruf **oder in seinem eigenen Make-Fragment**". Eine Zuweisung in einer Make-Quelle erreicht das Rezept nicht (gemessen `LEER`); nur Umgebung, Kommandozeile oder `export` tun es. Ein Adopter, der die zwei Ausnahmen dort setzt, glaubt sie gesetzt — der Nachzug schreibt dann in den vendored Baum hinein. | `AGENTS.md` §3.7 · `LH-FA-02` (der Marker trägt die Adaption) | internal/emit/templates/enforce/slice-mv.sh:65-71 (Zuweisung :72) | ja — die drei Sonden aus §4 der Messungen | `adaptions-ort-der-die-aenderung-nicht-annimmt` |
| F-4 | MEDIUM | `TestSliceMvFragment_MeldetEinFehlendesWerkzeug` behauptet in Name und Kommentar ein **Verhalten** („fehlt das Werkzeug, bricht das Ziel mit einer eigenen Meldung ab") und misst zwei Teilstrings des Fragments. Der Zweig ist an keiner Stelle gefahren: der E2E verlangt umgekehrt, daß das Werkzeug **liegt**, und bricht ab, wenn nicht. | `AGENTS.md` §3.6 · Schwester-Bauart `TestArchivierungFragment_TraegtPreisUndMeldung` (`v6.8.0` · `regelwerk/modul-11-verification.md` §Fitness Function ohne Standard-Tool) | internal/emit/slicemv_test.go:128-145 | ja — die Meldung hinter ein `@bash`-Rezept gezogen läßt beide Teilstrings stehen und den Wächter grün | `fail-closed-zweig-ohne-negativtest` |
| F-5 | LOW | Der Kennungs-Absatz des Skriptkopfs widerlegt sich zwei Sätze später selbst: erst „beide Messages tragen sie damit verbatim", dann „committet hier also kennungsfrei im Sinne seiner eigenen Konfiguration". Ein Leser kann dem Absatz nicht entnehmen, ob die Message eine Kennung trägt. | `AGENTS.md` §3.7 (Kommentar beschreibt, was da ist) | internal/emit/templates/enforce/slice-mv.sh:16-22 | nein — kein Gate liest Prosa eines Skriptkopfs | `kommentar-widerlegt-sich-im-selben-absatz` |
| F-6 | INFO | Die Message-Form der zwei Commits ist im Ziel **nicht** setzbar, während die Pfad-Ausnahmen es sind. Ein Ziel, das die mitemittierte Traceability-Zusage am Commit durchsetzt, trifft damit genau die Folge aus `ADR-0053` §Kontext (Abbruch **nach** dem `git mv`, gestagter Rename ohne Commit) und hat keinen Knopf. Der Kopf benennt die Bedingung ausdrücklich — benannt, nicht geschlossen. | `ADR-0053` Festlegung 4 + Kandidat `slice-werkzeug-commits-tragen-eine-kennung` (Planner/Architect) | internal/emit/templates/enforce/slice-mv.sh:16-22 · :184 · :213 | nein — kein Sensor auf der Message-Form im Ziel | `benannte-grenze-ohne-setzbaren-traeger` |
| F-7 | LOW | **Außerhalb des Gegenstands, beim Messen aufgefallen:** [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) §Grenze nennt namentlich zwei Dogfood-Stellen, die die Slice-Kennung an Ziffern binden; die daneben stehende Messung liefert keine davon mehr (nur `harness/tools/commit-msg-traceability.sh`), und `internal/archive/stub.go:225` führt inzwischen eine namensfähige Regex. | `AGENTS.md` §3.8 (der Norm-Text entsteht im Architect-Lauf) · `MR-032`/`MR-020` (Korrektur als Nachfolger) | `MR-057` §Grenze (Zeilen 90-96 des Eintrags) | ja — das Kommando des Eintrags liefert heute die andere Menge | `lebendes-register-traegt-eine-ueberholte-fundliste` |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `internal/emit/templates/enforce/slice-mv.sh` — Ersetzungs-Regeln, Wortgrenzen-Anker, `re_escape`, Ausnahmeliste als reine Funktion, Abbruch über dem unsauberen Baum | geprüft, ohne Befund (die Kommentar-Hälfte siehe F-3/F-5) |
| `internal/emit/templates/enforce/slice-mv.mk` — Kommando, kein Gate; fail-closed-Abbruch; Hilfetext trägt `KEIN Gate` in der Zeile selbst | geprüft, ohne Befund; die Go-Kante ist mit Mutation 343 **rot gelesen**, die E2E-Kante (`make -n gates` nennt `slice-mv` nicht) im Smoke gefahren |
| `harness/tools/full-smoke.sh` — der neue Abschnitt, seine sechs zugesagten Aussagen (a)–(f) und der Nachtrag (g) | gefahren, ohne Befund: `make full-smoke` EXIT 0 mit allen Einzelzeilen; die Vorbedingung des Nicht-Gate-Zahns ist selbst geprüft |
| `internal/emit/slicemv.go` · `internal/emit/enforce.go` — Zielorte, Modus `0755`, Idempotenz-Klasse convergent, Einordnung neben den Fragmenten der Erfassungs- und Archivierungs-Schicht | geprüft, ohne Befund |
| Die zwei Pfad-Ausnahmen gegen `ADR-0042` Festlegung 2 und ihre Ableitung im Ziel | geprüft, ohne Befund: beide Pfade existieren im gebootstrappten Ziel (`.harness/baseline/v6.8.0/` ist dort durch `make baseline-verify` gate-gedeckt — im Smoke-Lauf grün), beide Ableitungen stehen im mitemittierten Regelwerk |
| Grenze 4 — die Anker-Präfix-Kennung (`slice-ADR-…`) bleibt in der Ausgehend-Ersetzung unerkannt | geprüft, ohne Befund: im Werkzeugkopf **benannt**, nicht still geerbt — und die Zeichenklasse des Musters trägt die Aussage |
| Die drei Commits gegen §3.3 (Move und Inhalt getrennt) und §3.4 (Accepted-ADRs unangetastet) | geprüft, ohne Befund: kein `git mv` in der Range, keine ADR berührt |
| §3.2 (Suppression-Verbot) und §3.9 (Docker-only) in den neuen Dateien | geprüft, ohne Befund: `shell-lint` und `comment-claims` grün in `make gates`, keine Inline-Suppression |
| §3.7-Klassen der neuen Kommentare (Kopplung, Abgrenzung, Grenze, Rang-Zeiger) in Fragment, Werkzeug, Go-Code und den Mutations-Fällen | geprüft, ohne Befund — außer F-5; die Mutations-Fälle verweisen auf lebende Nachbar-Fälle (334, 337, 180), keine Befund-Kennung, kein Lauf-Protokoll |

## Die vier Fragen des Auftrags

1. **Die Message-Form — trägt die Umkehrung?** Ja: „die Kennung ist der Dateiname" steht wörtlich
   in `v6.8.0` · `regelwerk/grundlagen-traceability.md` §Herkunfts-Anker, `MR-057` Setzung 1 setzt
   die Namens-Form, und was die 48 von 417 nicht trifft, ist `slice-\d+` in der
   `.d-check.yml`-Konfiguration — deren letzte gebundene Stelle heute die des Commit-Wächters
   ist (gemessen); der Kandidat aus `ADR-0053` Festlegung 4 wird nicht kleinredet, sondern
   bestätigt, mit dem offenen Rest F-6.
2. **Die Ausnahmen — trägt das, und braucht es eine eigene ADR?** Ja, sie tragen: beide Pfade
   sind im Ziel vorhanden, beide Ableitungen stehen im mitemittierten Regelwerk, und
   `.harness/baseline` ist dort sogar durch `make baseline-verify` gate-gedeckt; eine eigene ADR
   ist **nicht** nötig, weil `ADR-0042` ausdrücklich nur dieses Repo bindet, den Werkzeug-Level
   einem Vorgang überläßt, und keine Schwelle gesenkt wird (§3.5) — der Preis ist die
   pfad-förmige (statt status-förmige) Ausnahme, deren `Proposed`-Differenz im Ziel nur über
   dessen eigenes `docs-check` auffällt.
3. **Der Marker nennt den Mechanismus, nicht die Stelle — trägt die Auflösung?** Ja, mit einem
   Abzug: die zwei Pfade stehen als **setzbare** Variable (in diesem Lauf über Umgebung und
   Kommandozeile verifiziert) und damit nicht festgeschrieben in der kanonisch überschriebenen
   Datei — aber der zweite benannte Ort, „sein eigenes Make-Fragment", nimmt die Zuweisung nur
   mit `export` an (gemessen) → F-3.
4. **Fährt `test/slice-mv.bats` beide Fassungen wirklich vergleichend?** In seinem Prüfbereich ja,
   darüber hinaus nein: eine einseitige Änderung an einer **getroffenen** Entscheidung färbt rot
   (Fall 7 und 8), eine einseitige Änderung an einer **ungetroffenen** bleibt über allen elf
   Fällen grün — die `BEO-ALL/zwei-fassungen-…`-Klasse ist damit eingeengt, nicht geschlossen
   → F-2.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 3 |
| LOW | 2 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:**
`test-name-behauptet-stelle-gemessen-wird-ein-zaehler` ·
`vergleichs-zusage-weiter-als-der-fall-satz` ·
`adaptions-ort-der-die-aenderung-nicht-annimmt` ·
`fail-closed-zweig-ohne-negativtest` ·
`kommentar-widerlegt-sich-im-selben-absatz` ·
`benannte-grenze-ohne-setzbaren-traeger` ·
`lebendes-register-traegt-eine-ueberholte-fundliste`

## Was dieser Lauf nicht prüfen konnte

- **Kein voller `make mutate`** (Weisung dieses Auftrags, Post-Integration). Gefahren ist **ein**
  Rot-Fall des neuen Paares — 343, mit gelesener Meldung und getragener Ursache. **344 und 345
  sind nicht gefahren**: beide zielen auf dieselbe Go-Stufe, deren Ansteuerung mit 343 belegt
  ist; ihre `# expect:`-Wächter sind gegen den Code gelesen, nicht gegen ihr Rot.
- **Kein `make hooks-install`** in diesem Klon (Weisung) — die Träger-Aktivierung aus `ADR-0053`
  ist nicht Teil dieses Laufs, und ein gesetzter `core.hooksPath` hätte die zwei
  `slice-mv`-Commits dieses Werkzeugs an ihrem Commit-Kanal berührt.
- **Die emittierte Ebene ist an einer Variante gemessen.** Der E2E fährt das `--lang-go`-Ziel;
  die sprachlose Variante ist über die Go-Stufe (Emit ohne Sprache) gedeckt, nicht über einen
  zweiten Bootstrapp.
- **`test/mutations/344`/`345` gegen ihr eigenes Rot** — siehe erster Punkt.
- **Der Kandidat `slice-werkzeug-commits-tragen-eine-kennung` ist nicht Gegenstand** dieses
  Laufs; `ADR-0053` ist `Proposed` und damit nicht normativ — F-6 ist ein Zeiger auf ihn, kein
  Befund gegen die Range.

## Verdikt

**Merge-blockierend: ja** — F-1 ist ein Verstoß gegen `AGENTS.md` §3.6 und blockiert; F-2, F-3
und F-4 sind vor dem Merge zu klären. Der Gegenstand selbst (Werkzeug, Fragment, E2E) trägt in
diesem Lauf: `make full-smoke` und `make gates` sind grün gefahren, der Move-Commit ist ein
reiner Rename, der Abbruch über dem unsauberen Baum ist mit seiner Meldung rot gelesen.

**Übergabe:** Findings gehen an den Implementer (Rückkante Review → Plan bei Plan-Defekt, hier
nicht gegeben — alle sieben sitzen im Diff); F-7 geht an den **Architect** als Nachfolger-Eintrag
zu [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
und ist keine Arbeit dieses Slice. Die **Finding-Klassen** gehen zusätzlich in die Slice-Closure
§7 und von dort in den Zähler. Dieser Report ist ein **Lauf-Beleg** — er wird über Läufe hinweg
nicht wieder gelesen. Der Report ersetzt keine Verifikation: DoD-/Spec-Konformität prüft der
Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
