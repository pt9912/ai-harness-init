# Verifikation `slice-d-check-pin-bringt-die-stilllegungs-bedingung`: DoD 1 bis 3 erfüllt, drei Übergaben an den Planner vor der Closure

**Rolle:** Verifier · **Datum:** 2026-09-17 · **Geprüfter Stand:** `c7a5417d` (= `HEAD` vor diesem
Bericht, `git log --oneline c7a5417d..HEAD | wc -l` → `0`). Geprüft ist die Kette
`d46a7123..c7a5417d` (`git log --oneline d46a7123..c7a5417d | wc -l` → `12`).
**Verifikations-Art:** DoD- und ADR-Konformität gegen den tatsächlichen Baum
(`v6.9.0` · `regelwerk/modul-11-verification.md`). Das ist kein Review.

**Eingang:**

- der Slice-Plan `slice-d-check-pin-bringt-die-stilllegungs-bedingung` §1 bis §8, Stand im Pfad
  `in-progress/`;
- die Umsetzung: Implementer-Commits `0fbefa46`, `675d1f03`, `b6219b1c`, `9f6484a9`, `5b4356e6`,
  `ba727601`; Architect-Commits `966458a5` (`MR-061`), `87ef3941` (`MR-062`), `8ec29665`
  (`MR-063`), `c7a5417d` (§Baseline);
- beide Review-Reports vom 2026-09-17 (Runde 1: 1 HIGH, behoben; Runde 2: bereit, N-1 in
  `c7a5417d` behoben). Ihre Messungen sind gelesen und **nicht** wiederholt: Registry-Digest,
  `numstat` am d-check-Klon, Gegenmessung 379/379, Gegenmessung je Modul 61/61, bats-Wächter der
  Marke;
- `ADR-0042` §Re-Evaluierungs-Trigger 2;
- Fremdquelle, nur lesend: der lokale Klon des d-check-Repos.

---

## 1. Ergebnis je DoD-Punkt

| DoD-Punkt | Status | Beleg |
|---|---|---|
| **1** — Pin an beiden Stellen, Digest belegt, Fragment re-adaptiert, Kopf, Rot | **erfüllt** | `d-check.mk:74-75` und `internal/emit/emit.go:32-33` tragen `v0.76.0` und `sha256:f0b55fde…945396`. Das lokale Bild: `RepoDigests` = derselbe Wert, Label `org.opencontainers.image.version` = `0.76.0`. Die Registry hat Runde 1 belegt, die Kommandos stehen in `0fbefa46`. Fragment gegen eine frische `--print-mk`-Ausgabe (§2.2): 8 Hunks, 13 Targets mit gleichen Namen, jeder der fünf Anker aus `MR-010` §Auflösungs-Trigger genau einmal in der Ausgabe und in der Fixture. Die Fixture bleibt zu Recht unverändert. Kein neues Target, also kein Eintrag im Gate-Index nötig. Das Rot ist in diesem Lauf selbst gesehen (§2.1). Zum Kopf: V-4. |
| **2** — Strenge-Bilanz `v0.74.1..v0.76.0` mit Richtung, `ADR-0042` Trigger 2 | **erfüllt** | Quell-Differenz, gelesenes `rules/run.go`, Trockenlauf und Gegenmessung stehen in `0fbefa46`. Die Gegenmessung deckte dort nur drei der acht Module (Runde 1, F-2). Vollständig ist sie in `MR-063`, in Runde 2 mit eigenen Sonden reproduziert (61 = 61, `diff` leer). Ergebnis: **keine Senkung**, §4 greift nicht. `ADR-0042` Trigger 2 ist in `0fbefa46` mit „nicht eingetreten" beantwortet. Nachgefahren (§2.3): Der `--print-config`-`diff` beider Digests enthält nur die Verfügbar-Zeile (`+ mentions`) und zwölf Kommentarzeilen zu `open-tasks-require-marker(-section)`. Keine davon verbindet Status und Adress-Form. |
| **3** — Werkzeug-Aussagen am alten Digest neu gemessen oder datiert | **erfüllt** | `grep -n 'e31a372b' harness/sensors/docs-check.md` → kein Treffer (vorher 1: `git show d46a7123:harness/sensors/docs-check.md \| grep -c e31a372b` → `1`). Die Stilllegungs-Tabelle nennt jetzt `v0.76.0` mit Digest. Eine Stichprobe von zwei der acht Lagen ist am neuen Digest nachgefahren und stimmt zeilengleich (§2.4). `.d-check.yml:372-373` und `commit-msg-check.md` datieren den `--range`-Abbruch, das Stellenpaar hat Runde 1 nachgemessen. Zur Reichweite des Rot-Kommandos: §6. |
| `make gates` grün | **erfüllt** | §7 |
| Review durchgeführt, Report liegt vor | **erfüllt** | zwei Reports vom 2026-09-17 unter `docs/reviews/`, beide aus einem Reviewer-Kontext |
| Doku-Update über Liefer-Punkt 3 hinaus keines | **erfüllt** | Kein Target ist hinzugekommen (13/13/13, §2.2), `harness/README.md` bleibt unberührt (`git diff --stat d46a7123..c7a5417d` nennt die Datei nicht). |
| Closure-Notiz, Register, Risiko-Ausgänge, Paarungen | **offen, Planner** | Das sind Closure-Pflichten (`AGENTS.md` §3.10). §7 des Plans steht auf „offen bis zur Closure". |
| Reconciliation-Register | entfällt | wie im Plan begründet |

## 2. Eigene Messungen

Alle Läufe über `docker`/`make`/`git`, netzlos. Die Kopien liegen außerhalb des Repos.

### 2.1 Bewusstes Brechen (DoD 1)

`git archive HEAD` in eine Wegwerf-Kopie. Darin sind **nur** in `internal/emit/emit.go` `DefaultImage`
und `DefaultDigest` auf `v0.74.1` bzw. `sha256:e31a372b…6d4641` zurückgesetzt. Der `diff` gegen das
Repo zeigt genau die Zeilen 32 und 33, `d-check.mk` bleibt unverändert. Danach lief
`make -C <kopie> test-go`:

```text
--- FAIL: TestDefaultDigest_MatchesCanonical (0.00s)
    emit_test.go:73: emit.DefaultDigest "sha256:e31a372b…6d4641" != kanonische Pin-Quelle "sha256:f0b55fde…945396" (Drift)
--- FAIL: TestDefaultImage_MatchesCanonical (0.00s)
    emit_test.go:82: emit.DefaultImage "ghcr.io/pt9912/d-check:v0.74.1" != kanonische Quelle "ghcr.io/pt9912/d-check:v0.76.0" (Tag-Drift)
FAIL	github.com/pt9912/ai-harness-init/internal/emit
make-Exit 2
```

**Die Ursache ist richtig.** Nur das Paket `internal/emit` fällt, und nur mit diesen zwei Tests.
Beide Meldungen nennen den abweichenden Wert neben dem kanonischen aus `d-check.mk`. Die
DoD-Formulierung *„wer nur `d-check.mk` bewegt"* ist die Gegenrichtung derselben Ungleichung, und
beide Tests vergleichen genau dieses Paar. Der unveränderte Stand ist grün, denn `make test`
gehört zum `make gates`-Lauf in §7.

### 2.2 Fragment gegen frische `--print-mk`-Ausgabe (DoD 1)

| Messung | Ergebnis |
|---|---|
| Zeilen der Ausgabe `v0.76.0` / `v0.74.1` | 76 / 76 |
| `diff <(… f0b55fde… --print-mk) d-check.mk \| grep -c '^[0-9]'` | **8** (`1,13c1,73 15c75 26,27c86,87 59c119 60a121 67c128 68a130 75,76c137,138`), der Wert im Kopf von `d-check.mk` |
| alte gegen neue Ausgabe | 7 Hunks: die Zeile `DCHECK_IMAGE` und sechsmal `--disable mentions`. Beides übernimmt das Fragment wörtlich, der Sprung braucht **keinen** neuen Handgriff |
| `grep -cE '^docs?-[a-z-]+:'` alt / neu / `d-check.mk` | 13 / 13 / 13; die Namen sind gleich (`doc-check` ↔ `docs-check` abgebildet) |
| Anker `DCHECK_IMAGE ?=`, `^\.PHONY: doc-check$`, `^doc-check:`, `^DCHECK_DIGEST ?=$`, wörtlich `'^doc-[a-z-]+:` | je `1` in der neuen Ausgabe **und** in `internal/emit/testdata/raw-print-mk.txt` |

### 2.3 `ADR-0042` Trigger 2 (DoD 2)

`diff <(… e31a372b… --print-config) <(… f0b55fde… --print-config)` → `13c13` (in der
Verfügbar-Liste kommt `mentions` hinzu) und `182a183,194` (zwölf Kommentarzeilen zu
`open-tasks-require-marker` und `open-tasks-require-marker-section`). Die Bedingung koppelt
offene Task-Items an eine Marke. Keine der Zeilen hält eine Status-Zeile mit der Form eines
Verweises zusammen. **Nicht eingetreten** ist damit bestätigt.

### 2.4 Stichprobe der Stilllegungs-Tabelle (DoD 3)

Ein Wegwerf-Klon (`git clone --local --no-hardlinks`) mit lokaler git-Identität, sein `d-check.mk`
ist der Stand `c7a5417d`, also Digest `f0b55fde…`. Kante `open → done` wie beim Implementer:
§7 von `slice-067` in die Ziel-Form gebracht (`Gegenstand:` mit Kennung, zwei weitere
Zeilen, jedes der drei Risiken mit Ausgang, Liefer-Punkte leer) und committet. Danach
`make slice-mv SLICE=slice-067 TO=done`: 2 eingehende Verweise nachgezogen.

| Lage | Tabelle sagt | gemessen |
|---|---|---|
| Ziel-Form vollständig | keine Meldung | `d-check: 1570 Datei(en) geprüft, 0 Befund(e)`, make-Exit 0, kein Treffer auf `slice-067` |
| §7 auf einen Satz gekürzt | `closure-note-thin` auf der §7-Überschrift | `…/slice-067-pretooluse-ausgabeform.md:109 … closure-note-thin …` (Z. 109 ist `## 7. Closure-Notiz`), `1 Befund(e)`, make-Exit 2 |

Die übrigen sechs Lagen sind nicht nachgefahren. Sie hängen an `planning`, und die Regeldateien
dieses Moduls sind über die Spanne unverändert (Runde 1).

### 2.5 F-5 aus Runde 1 (offen an mich)

Heute sind die Namensmengen gleich: der `diff` der `modules:`-Liste gegen die `--disable`-Namen
im Rezept `regelwerk-check` ist leer. **Das Gegenbeispiel ist rot gesehen:** Wird im Rezept
`--disable targets` gegen `--disable structure` getauscht, liefert das Zählpaar im Kommentar
`8 = 8`, der Namens-`diff` dagegen `< targets` / `> structure`. Der Kommentar sagt *„genau die
Module"*, das beigestellte Kommando prüft aber nur die Anzahl. Die Zusage ist damit breiter als
ihr Sensor (`AGENTS.md` §3.6). Ein Namensvergleich deckt sie:

```sh
diff <(grep -m1 '^modules:' .d-check.yml | sed 's/^modules:[[:space:]]*//; s/[][]//g' | tr ',' '\n' | tr -d ' ' | sort) \
     <(sed -n '/^regelwerk-check:/{n;p}' Makefile | grep -oE -- '--disable [a-z]+' | awk '{print $2}' | sort)
```

Kein DoD-Punkt beruft sich auf den Kommentar, und `regelwerk-check` ist kein Gate. **Nicht
blockierend.**

## 3. Plan-vs-Code-Diff

**Gebaut und geplant** (§3 des Plans): `d-check.mk`, `internal/emit/emit.go`,
`harness/sensors/docs-check.md`, `.d-check.yml` (Kommentar), `harness/sensors/commit-msg-check.md`,
`Makefile`. Die letzten drei Zeilen sind während der Umsetzung nachgetragen worden: `0fbefa46`
und `5b4356e6`, nach Runde 1 F-4. Die Übergabe an den Architect (§6) ist eingelöst: `MR-061` nennt
`mentions` und `open-tasks-require-marker` als verfügbar und nicht aktiv.

**Bedingt geplant und zu Recht nicht gebaut:** `internal/emit/testdata/raw-print-mk.txt`, weil
kein Anker fehlt (§2.2), und `harness/README.md`, weil kein Target hinzukam.

**Gebaut, aber nicht geplant:**

- `MR-062` samt Kopf-Marke an `MR-010`. Er deklariert den fünften Handgriff (Marke an
  `doc-tracked`/`doc-structure`). Der Handgriff ist Bestand seit `slice-217` (`497564d7`), der
  Sprung hat ihn nicht erzeugt. Dazu V-1.
- `MR-063` samt Kopf-Marken an `MR-061` und `MR-052`: die vollständige Gegenmessung, ausgelöst
  von Runde 1 F-2. Die Übergabe in §6 nannte **einen** Eintrag, gebaut sind drei.
- `harness/conventions.md` §Baseline (`c7a5417d`, Runde 2 N-1).
- Der Lücken-Absatz in `docs-check.md` unter §Ein stillgelegter Slice in `done/`: Die Lücke liegt
  jetzt nicht mehr im Werkzeug, sondern in der Konfiguration, mit der Adresse
  `slice-stilllegungs-form-hat-einen-waechter`. Die Aussage über die Bedingung deckt sich mit
  `--print-config` (§2.3), `grep -n '^modules:' .d-check.yml` führt kein `structure`. DoD 3 deckt
  das.

**Geplant, aber fehlt:** nichts in den drei Liefer-Punkten.

## 4. Befunde und Übergaben

| ID | Adressat | Befund | vor der Closure? |
|---|---|---|---|
| V-1 | Planner | **Die Rückführungs-Bedingung aus §4 ist dem Wortlaut nach erfüllt, und der Slice lief weiter.** §4 nennt `in-progress → next`, wenn *„das Fragment mehr als die Handgriffe aus `MR-010` Setzung 1 braucht"*. `MR-010` Setzung 1 nannte vier, das Fragment trägt fünf; so steht es in der Kopf-Marke an `MR-010` (Z. 3) und in `MR-062`. Der fünfte ist Bestand (`slice-217`), der Sprung selbst brauchte keinen neuen (§2.2). Das spricht dafür, die Bedingung als *„durch den Sprung neu"* zu lesen. Dem Plan ist das aber nicht zu entnehmen. | **ja** — §7 *Was ging anders als geplant* nennt die Lesart und warum der Slice nicht zurückging |
| V-2 | Planner | **`v0.76.1` ist getaggt.** Im lokalen d-check-Klon trägt `v0.76.0` den Stand `2026-09-17 08:33` und `v0.76.1` den Stand `2026-09-17 10:23`. Der Slice startete um `09:40` (`0fb8aeef`). Risiko 2 entfällt damit nach seinem eigenen Wortlaut. Der Pin liegt aber einen Patch zurück. Laut CHANGELOG `[0.76.1]` bricht `vcs` jetzt fail-closed ab, wo es bisher still grün meldete oder falsch diagnostizierte. `vcs` fährt hier in `doc-immutable` und `make adr-immutable`, beide kein Gate. Ob das Bild in der Registry liegt, ist nicht geprüft (Netz). | **ja** — der Ausgang von Risiko 2 nennt die Tatsache. Ob `v0.76.1` eine Adresse bekommt (Folge-Slice oder Register), entscheidet der Planner |
| V-3 | Planner | **Die Nachmess-Übergabe aus §1 hat keinen Träger beim Empfänger.** Die fünf genannten Slices liegen alle in `open/`. `slice-192-…` und `slice-213-…` nennen den alten Digest wörtlich. `slice-spec-straten-zeigen-nicht-nach-aussen` (Z. 53) nennt `v0.74.1` als Stand von `d-check.mk`, und das ist jetzt falsch. `slice-mv-kanten-nach-done-sind-bewacht` und `slice-risiko-ausgang-hat-einen-sensor` nennen weder den Pin noch diesen Slice (`grep -cE 'v0\.74\|e31a372b\|d-check-pin-bringt'` → `0`). Ihre Basis, die Stilllegungs-Tabelle, ist neu gemessen (DoD 3, §2.4). Für sie ist nichts zu tun. `slice-stilllegungs-form-hat-einen-waechter` (Z. 49) sagt *„Am gepinnten `v0.74.1`"*. Nach der Closure steht die Adressliste nur noch in `done/`. | **ja** — Folge-Zeile in §7 oder ein Vermerk in den drei betroffenen Plänen (Artefakte des Planners); der Planner wählt |
| V-4 | Implementer | Im Kopf von `d-check.mk` nennen Z. 26 und Z. 29 (*„VERENGTES MARKER-VERHALTEN seit v0.74.1"*, *„unter v0.74.1"*) die Vier-Lagen-Tabelle am alten Tag. Diese Zeilen sind seit `2999156f` unverändert. Der in diesem Slice geschriebene Zeiger in Z. 38-39 verweist für Messung und Stand auf `MR-027`, dessen Pin `v0.65.0` ist und der dieselbe Tabelle trägt (`MR-027` Z. 42). Ein Absatz nennt damit zwei Messstände für dieselbe Tabelle. **Kein DoD-Verstoß:** Die Zeilen sind datiert und unverändert, der Cutoff aus `AGENTS.md` §3.7 bindet sie nicht. | nein |
| F-5 | Implementer | wie §2.5, Gegenbeispiel rot gesehen | nein |

## 5. Risiken aus §6: Belege für die Closure

Die Ausgänge weist der Planner zu. Hier stehen nur die Belege.

| Risiko | Beleg | naheliegender Ausgang |
|---|---|---|
| 1 — leere Quell-Differenz als Freispruch | Die Gegenmessung je Modul in `MR-063`, in Runde 2 reproduziert, liefert identische Mengen | entfallen |
| 2 — weiterer Release vor dem Start | `v0.76.1` wurde nach dem Start getaggt (V-2) | entfallen nach Wortlaut, mit der Tatsache aus V-2 |
| 3 — kein Sensor scannt das Bild | unverändert, kein Slice nimmt die Frage | weiter offen, also ins Register |
| 4 — Kopf nennt den Eintrag erst nach dem Architect-Lauf | `966458a5` (`MR-061`) liegt vor `675d1f03` (Kopf nennt `MR-061`), `87ef3941` (`MR-062`) vor `9f6484a9` | entfallen |

## 6. Offengelegt

- **Reichweite des Rot-Kommandos in DoD 3.** Der Titel sagt *„jede Werkzeug-Aussage mit dem alten
  Digest als Messstand"*. Die Unterzeile *„Gemeint sind die Stellen in `docs-check.md`, die
  `e31a372b` nennen"* verengt ihn, und genau diese Menge deckt das `grep`. Daneben nennt
  `docs-check.md:283` den alten **Tag** (*„v0.74.1 zum Zeitpunkt dieser Messung"*). Die Stelle ist
  datiert, also `MR-053`-konform, und seit `d46a7123` unverändert.
- **Nicht wiederholt**, weil ein anderer Lauf sie schon gefahren hat: Registry-Digest, `numstat`
  und `run.go` am Klon, beide Gegenmessungen, das `--range`-Stellenpaar, der bats-Wächter der
  Marke.
- **Nicht gefahren:** die sechs übrigen Lagen der Stilllegungs-Tabelle, `make full-smoke`,
  `make mutate`.

## 7. Gate-Lauf

`make docs-check` und `make gates` laufen über dem Baum mit diesem Bericht. Das Ergebnis steht in
der Commit-Message dieses Berichts.

## 8. Verdikt

**DoD 1 bis 3 erfüllt, `make gates` grün. Bereit für die Closure**, sobald der Planner V-1, V-2
und V-3 in §7 bzw. im Risiko-Ausgang beantwortet hat. V-4 und F-5 gehen an den Implementer und
blockieren nicht.
