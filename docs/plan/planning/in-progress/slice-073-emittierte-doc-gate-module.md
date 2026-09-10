# Slice slice-073: Welche Doc-Gate-Module ein frisch gebootstrapptes Ziel bekommt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle. Begründet gegen die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird):
(1) **Bündel?** Nein — eine Modul-Liste und ihre Zähne landen zusammen oder gar nicht.
(2) **Gemeinsames Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift der DoD.
(3) **Reaktiv oder gewollt?** **Reaktiv:** Auslöser ist eine Messung an der vorhandenen
Emissions-Vorlage, nicht der Wunsch nach einer Fähigkeit. Damit **nicht** in der Roadmap geführt
([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2).

**Nicht welle-09.** Deren Ziel-Satz ist auf die vier Regelblöcke von
`modul-15-observability.md` gescopt; die Referenz-Richtung ist keiner davon — sie kommt aus
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
und [`AGENTS.md`](../../../../AGENTS.md) §3.4. Der Slice teilt mit welle-09 **die Ebene**, nicht
die Regel-Familie.

**Bezug:** [`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)
(die emittierte Doc-Gate-Baseline und ihre Bedingung „`ids`/`codepaths` nur mit existierenden
Targets/roots aktivieren"),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (der
emittierte Stand ist out-of-the-box gate-sicher — die Schranke, an der jedes Kandidaten-Modul
gemessen wird),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein
Gate über leerem Prüfbereich — die Gegenkraft),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Default-Regel für emittierte Prüfbereiche: laut falsch schlägt leise falsch — hier als
Bezug, nicht als Analogie, denn ihr Geltungsbereich **ist** diese Datei),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* → Steering-Loop),
[`ADR-0007`](../../adr/0007-bootstrap-phasen.md) (die Idempotenz-Klasse *skip-if-present*, aus der
die Reichweiten-Grenze dieses Slice folgt),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel).

**Verantwortlich:** Implementer (pt9912).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-31.

---

## 1. Ziel

**Das emittierte Doc-Gate bekommt die Module, die es tragen kann — entschieden nach einer
Regel, nicht nach Geschmack, und je Modul im Ziel rot gesehen.**

Die emittierte Konfiguration führt heute zwei Module. Der Dogfood führt sieben. Ein
gebootstrapptes Ziel bekommt damit dieselbe Doku-Struktur und dieselbe Regelwerk-Kopie wie wir —
und ein Gate, das die Referenz-Richtung nicht prüfen **kann**. Es ist nicht rot und nicht grün;
es hat zu der Frage nichts zu sagen.

**Die Entscheidungsregel, die dieser Slice setzt.** Ein Modul geht ins Ziel, wenn **alle drei**
gelten:

1. **Der Dogfood fährt es selbst.** Was wir emittieren, haben wir hier erprobt — ein Modul, das
   dieses Repo nie unter sich hatte, ist im Ziel eine Behauptung.
2. **Es ist über dem frisch emittierten Bestand grün.** Ein Ziel, das am ersten Tag rot startet,
   verliert die Zusage aus
   [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3).
3. **Sein Gegenbeispiel wird im Ziel rot.** Grün allein ist von „prüft nichts" nicht zu
   unterscheiden ([`AGENTS.md`](../../../../AGENTS.md) §3.6).

Kriterium 2 und 3 zusammen sind die Fassung von
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
für diesen Prüfbereich: streng, aber nicht lauter als der emittierte Bestand aushält.

**Ist-Messung** (frisch gebootstrapptes tmp-Ziel, je Variante ein netzloser d-check-Lauf gegen
das gepinnte Image; beide Bootstrap-Formen — `--lang go` und sprachlos — liefern **identisch**
12 geprüfte Dateien und identische Befunde):

| Kandidat | out-of-the-box | Gegenbeispiel im Ziel | Verdikt |
|---|---|---|---|
| `matrix` (vier Klassen, Lifecycle-Klassen im `token:`-Modus) | 0 Befunde | 2 × `matrix-forbidden` | **emittieren** |
| `spans` | 0 Befunde | 1 × `span-unclosed` | **emittieren** |
| `ids`, nur ADR-Muster | 0 Befunde | 1 × `id-unlinked` | **emittieren** |
| `ids` + Requirement-Muster | **2 Befunde** | — | **nicht** emittieren |
| `codepaths` (roots spec/docs/harness) | **2 Befunde** | — | **nicht** emittieren |

Die beiden `codepath-missing`-Befunde stammen **aus der emittierten Vorlagen-Prosa selbst** —
eine Platzhalter-Zeile der emittierten AGENTS-Datei und ein Form-Verweis in der emittierten
Konventions-Datei. Kein Adopter-Fehler, sondern unser Emissions-Bestand; darum ist `codepaths`
ein anderer Schnitt und keine Zeile in diesem hier.

**Die Ziel-Form ist vorgegeben, nicht zu erfinden.** Die Startkonfiguration des Werkzeugs führt
die Regel `{from: adr, to: slice}` samt `token:`-Erkennung für bare Kennungen und dem
Zeilen-Marker `<!-- d-check:status-provenance -->` auskommentiert mit. Was der Marker im Ziel
trägt, entscheidet DoD (1).

**Warum die Regel richtig ist**, steht in
[slice-072](../open/slice-072-adr-verweist-nicht-auf-lifecycle.md) §1 und wird hier **nicht** wiederholt.
Dieser Slice entscheidet nur, was davon ein fremdes Repo bekommt.

## 2. Definition of Done

- [ ] **(1) Die emittierte Konfiguration führt die entschiedene Modul-Liste, und ein frisches Ziel
  ist grün.** `internal/emit/templates/d-check.yml` bekommt
  `modules: [links, anchors, ids, matrix, spans]`. `ids` trägt **nur** das ADR-Muster mit
  `link-policy: always`; das Requirement-Muster bleibt auskommentiert (das Präfix gehört dem
  Adopter, und mit dem Beispiel-Präfix gemessen: 2 Befunde). `matrix` trägt vier Klassen — die
  Spec-Straten über **drei** emittierte Dateien, **mit `order:` und `direction: no-downward`**,
  dazu `adr`, `slice` und `welle`, die beiden Lifecycle-Klassen im `token:`-Modus — und neben den
  Spec-Straten-Regeln die beiden neuen `{from: adr, to: slice}` und `{from: adr, to: welle}`, dazu
  `status.forbidden` und `exclude-sections`. Der Kommentar nennt den Zeilen-Marker als den
  vorgesehenen Ausweg. `make full-smoke` grün — **beide** Bootstrap-Formen.

  **Die Autorität ist für alle Positionen dieses Blocks dieselbe: die Ziel-Form.** Der
  auskommentierte `matrix`-Block der Baseline-Vorlage führt `order:` und
  `direction: no-downward` genauso wie `token:` auf `slice` und die Regel `{from: adr, to: slice}`
  — und die `welle`-Positionen gar nicht:

  ```sh
  T=.harness/baseline/v6.5.0/templates/.d-check.yml
  grep -cF 'order:' "$T"; grep -cF 'direction: no-downward' "$T"   # 1 · 1
  grep -cF "token: 'slice" "$T"; grep -cF 'from: adr, to: slice' "$T"  # 1 · 1
  grep -cF 'welle' "$T"                                            # 0
  ```

  **Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — sie wandern mit dem vendored Stand. Tragend ist das Verhältnis: Eine Position, die
  die Vorlage führt, wird nicht zurückgehalten, während zwei ohne Vorlagen-Deckung mitgehen.
  Kriterium 1 aus §1 (*der Dogfood fährt es selbst*) bindet auf **Modul**-Ebene — die Zeilen der
  §1-Tabelle sind Module —, und das Modul `matrix` fährt der Dogfood. Für die Positionen
  *innerhalb* von `matrix` ist die Ziel-Form die Autorität, und sie gilt für alle gleich.
- [ ] **(2) Jedes neu aktivierte Modul wird im Ziel rot gesehen, und mit der heutigen
  Konfiguration grün.** Je Modul ein Gegenbeispiel im gebootstrappten Ziel, in
  `harness/tools/full-smoke.sh` nach der dort etablierten Zahn-Form (Verletzung einschmuggeln →
  Gate muss rot **mit der benannten Befund-Art** → zurücknehmen): `matrix-forbidden` ·
  `matrix-downward` · `id-unlinked` · `span-unclosed`. **Vier Befund-Arten, nicht drei** —
  `matrix` trägt seit DoD (1) zwei, und eine Regel ohne eigenes Gegenbeispiel ist
  gelistet-aber-unbewacht ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Für `matrix-downward` ist
  der Zahn am frisch gebootstrappten Ziel bereits gemessen (§3, *Übergabe an den Architect*):
  Abwärtslink Vertrag → Technik/Sicht → `2 Befund(e)`, ohne die Regel `0`.
  Die zweite Richtung gehört dazu und ist heute schon wahr:
  dasselbe Gegenbeispiel bleibt unter `modules: [links, anchors]` grün — ohne sie behauptet der
  Beleg, das Modul habe die Verletzung gefunden, statt: **erst** das Modul findet sie. Dazu der
  netzlose Wächter, weil `full-smoke` Docker braucht: ein Go-Test bindet die **entschiedene**
  Liste an den eingebetteten Vorlagen-Inhalt (nicht „mindestens zwei Module"), und ein
  `test/mutations/`-Fall nimmt ein Modul aus der Vorlage und muss ihn rot färben.
- [ ] **(3) Was das Ziel NICHT bekommt und wie weit die Entscheidung reicht, steht mit
  Auflösungs-Trigger in [`harness/conventions.md`](../../../../harness/conventions.md).** Die
  Entscheidungsregel aus §1; die **zwei** begründeten Nicht-Emissionen (`codepaths` — Trigger: die
  zwei Vorlagen-Stellen sind emit-seitig neutralisiert oder upstream gefallen; das
  Requirement-Muster von `ids` — Trigger: das Tool erfährt das Präfix); und die **Reichweite**:
  `.d-check.yml` ist *skip-if-present*
  ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)), ein **bestehendes** Ziel bekommt also
  nichts davon. Das ist die Idempotenz-Klasse, kein Versehen — aber es heißt, dass die Lücke bei
  jedem heute schon gebootstrappten Repo **offen bleibt**, und das gehört benannt statt
  vorausgesetzt.

  **Es sind zwei, nicht drei.** Die dritte Position — die Richtungs-Prüfung *innerhalb* der
  Spec-Straten — ist keine Nicht-Emission mehr, sondern Teil von DoD (1). Ein Eintrag über sie
  trüge einen Auflösungs-Trigger, der bei seiner Anlage schon gilt, und die Einträge dieses Blocks
  sind append-only
  ([`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf))
  — der Rumpf wird nachträglich nicht korrigiert. Die Entscheidung dazu steht in §3 unter
  *Übergabe an den Architect*, mit ihrer Messung.
- [ ] `make gates` grün; `make full-smoke` grün; `make mutate` grün über die CI
  (`.github/workflows/ci.yml`, frischer Runner).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/d-check.yml` | update | die entschiedene Modul-Liste samt `ids`- und `matrix`-Block; die zwei Nicht-Emissionen bleiben als begründete Kommentar-Blöcke stehen, nicht als Leerstelle |
| `internal/emit/emit_test.go` | update | der Wächter behauptet heute „genau `[links, anchors]`" — das ist nach der Änderung falsch **und** wäre als „irgendeine Liste" zahnlos; er bindet die entschiedene Liste |
| `harness/tools/full-smoke.sh` | update | die drei Zähne aus DoD (2), je Modul einer, nach der dort etablierten Form |
| `test/mutations/` | neu | der Mutations-Fall zum netzlosen Wächter |
| [`harness/conventions.md`](../../../../harness/conventions.md) + [`harness/conventions/`](../../../../harness/conventions/) | update | der Eintrag aus DoD (3) — **Architect-Arbeit** ([`AGENTS.md`](../../../../AGENTS.md) §3.8), eigener Commit, nicht im Implementations-Kontext |

### Übergabe an den Architect — der Eintrag aus DoD (3)

**Diese Übergabe liegt hier, weil der Slice-Plan ihr Artefakt ist.** Das Baseline-Regelwerk führt
für die Kante Planner→Architect genau eines
(`modul-08-agentenrollen.md` §Die neun Übergaben und ihre Artefakte: *„Planner→Architect:
Slice-Plan mit LH-Bezug"*), und beide Rollen werden über die Artefaktklasse **Template** geführt,
nicht über einen Skill und nicht über ein Zeitdokument (§Welche Rolle braucht welche
Artefaktklasse). Eine zweite Datei daneben wäre ein zweiter Ort für dieselbe Aussage.

Der Eintrag bekommt die nächste freie Kennung nach der höchsten vergebenen; vergeben wird sie im
Architect-Lauf, nicht hier:

```sh
ls harness/conventions/ | grep -oE 'MR-[0-9]{3}' | sort -u | tail -1
```

**Kein Erwartungswert** — die Antwort wandert mit dem Block. Der Eintrag hält fest:

1. **Die Entscheidungsregel aus §1** — drei Kriterien, und dass Kriterium 1 auf Modul-Ebene bindet.
2. **Zwei Nicht-Emissionen mit Auflösungs-Trigger** — `codepaths` und das Requirement-Muster von
   `ids`, mit den Triggern aus DoD (3). **Keine dritte.**
3. **Die Reichweite** — `.d-check.yml` ist *skip-if-present*
   ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)); ein bereits gebootstrapptes Ziel bekommt
   nichts davon, und die Lücke bleibt dort offen.

**Warum keine dritte — die Messung, an der die Entscheidung hängt** (2026-09-10, gegen eine Kopie
außerhalb des Repos, netzlos, Mount `:ro`, über dem in [`d-check.mk`](../../../../d-check.mk)
gepinnten Digest; das Ziel frisch gebootstrappt mit dem Träger aus `make host-bin`):

| Messung | Prüfgegenstand | Ergebnis |
|---|---|---|
| Kriterium 2 | frisches Ziel, `order:`/`direction:` aktiv, unverändert | `19 Datei(en) geprüft, 0 Befund(e)` — gleich dem Stand ohne die zwei Zeilen |
| Kriterium 3 | dasselbe Ziel, Abwärtslink Vertrag → Technik/Sicht | `2 Befund(e)`, beide `matrix-downward` (Rang 0 → 1, Rang 0 → 2) |
| Kausalität | dasselbe Gegenbeispiel, `order:`/`direction:` entfernt | `0 Befund(e)` — der Fund kommt aus dieser Regel, nicht aus einer anderen |
| Erprobung | Dogfood-Baum, `order:`/`direction:` aktiv | `1064 Datei(en) geprüft, 0 Befund(e)`; Gegenbeispiel `2 Befund(e)` `matrix-downward` |

**Keine Erwartungswerte** — die Datei-Zahlen wandern mit beiden Bäumen. Tragend sind die drei
zusammen — *grün ohne Verletzung · rot mit Verletzung · grün ohne Regel*: Erst die dritte trennt
„prüft" von „prüft nichts" ([`AGENTS.md`](../../../../AGENTS.md) §3.6), denn Grün allein hätte
auch ein stillschweigend ignoriertes Feld erzeugt. Der Prüfbereich im Ziel ist **nicht leer** —
der Bootstrap legt alle drei Spec-Straten als echte `.md` an (`ls <ziel>/spec/` → drei Dateien),
also greift auch [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
nicht als Grund.

**Kein Change Request nötig — und das ist gemessen, nicht angenommen.**
[`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) nennt
zu den Modulen genau **eine** Bedingung: `ids`/`codepaths` nur mit existierenden Targets/roots.
Die wird hier **erfüllt**, nicht geändert — das ADR-Verzeichnis existiert im emittierten Ziel
(es wird per Halte-Datei getragen), und `codepaths` bleibt aus. Zu `matrix` und `spans` sagt das
Lastenheft nichts. Damit ist das eine **Anhebung** im Sinne von
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Steering-Loop, kein ADR) und keine Vertragsänderung nach
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler).
**Folge für die Umsetzung:** `spec/lastenheft.md` bleibt unberührt, belegt per `git diff --stat`.

**Was die Umsetzung zuerst nachmisst** (Modul 9 §4): die Tabelle in §1 gegen ein **frisch**
gebootstrapptes Ziel neu fahren, bevor die Modul-Liste geschrieben wird. Die Zahlen hängen am
emittierten Vorlagen-Bestand, und der wandert mit jeder Baseline. Insbesondere kann ein
Baseline-Bump die zwei `codepath-missing`-Stellen auflösen — dann ist `codepaths` kein
Nicht-Emissions-Eintrag mehr, sondern ein vierter Zahn.

## 4. Trigger

**`open` → `next`:** keine Abhängigkeit von
[slice-072](../open/slice-072-adr-verweist-nicht-auf-lifecycle.md) — der berührt `.d-check.yml`, dieser
die Emissions-Vorlage; beide Reihenfolgen tragen. Die Konfliktfläche liegt bei slice-063 —
**falls** slice-062 für das `targets`-Modul entscheidet, fasst er dieselbe Vorlagen-Datei an;
beide sind benannt, nicht geschnitten. Grund für die Reihung ist damit WIP-Limit und
Konfliktfläche, nicht Reihenfolge-Zwang.

**`next` → `in-progress`:** WIP-Limit.

**Reihenfolge innerhalb von `next/`: nach
[slice-140](../done/slice-140-emittierter-stand-ohne-vorlagen-hilfen.md) — Ökonomie, kein Zwang.** Die
zwei `codepath-missing`-Befunde aus §1 stammen aus der Prosa der emittierten AGENTS- und
Konventions-Datei. Genau diese zwei Vorlagen tragen Kommentar-Hilfen des vendored Satzes, und
jener Slice entfernt sie; ob die zwei Befunde damit fallen und `codepaths` ein vierter Zahn wird,
entscheidet die Nachmessung aus §3. Läuft dieser Slice zuerst, ist sie nach jenem Merge ein
zweites Mal zu fahren.

Rückführungen:

- `in-progress` → `next`: falls die Nachmessung zeigt, dass ein Modul der Liste im Ziel doch rot
  startet. Dann trennt ein Re-Schnitt das grüne Teilstück von dem, das erst eine
  Vorlagen-Korrektur braucht — nicht die Liste stillschweigend kürzen.
- `in-progress` → `open`: falls sich zeigt, dass die Zähne im Ziel eine Änderung an
  `harness/tools/full-smoke.sh` verlangen, die über das Einschmuggeln-und-Zurücknehmen
  hinausgeht (etwa ein sechstes tmp-Ziel). Dann ist erst zu klären, was der Smoke tragen soll,
  bevor er wächst.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates` und
`make full-smoke` grün und ein CI-Vollauf `make mutate` mit `0 Befund(e)`; `git mv` nach `done/`
(eigener Move-Commit); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Beleg deckt das frische Ziel, nicht das gealterte.** Alle drei Zähne laufen über einem
  Ziel, das gerade erst entstanden ist und **null** ADRs, **null** Slices und **null**
  Welle-Pläne führt. Ein Adopter, der ein Jahr gearbeitet hat, hat einen Bestand — und für den
  gilt die Messung nicht. Er bekommt die Module ohnehin nicht (skip-if-present); wer sie
  nachträglich einschaltet, misst neu. Das ist die ehrliche Grenze, nicht ein Restrisiko.
- **`token:` sieht die Kennung überall, auch in Inline-Code.** Im frischen Ziel ist das gemessen
  unschädlich (0 Befunde). Über einem gewachsenen Adopter-Bestand ist es ungeprüft — und es ist
  genau die Stelle, an der ein Adopter den Zeilen-Marker braucht. Der Kommentar in der Vorlage
  muss ihn deshalb nennen, sonst ist die Regel scharf und ihr Ventil unsichtbar.
- **Drei Module in einem Schnitt sind drei Zähne.** Sie sind eine Arbeit, weil sie eine Datei,
  eine Messreihe und eine Entscheidungsregel teilen — aber wenn die Umsetzung merkt, dass sie
  drei Belege statt einer führt, ist die Rückführung nach `next` der richtige Zug und nicht die
  stille Kürzung der Liste.
- **Abgrenzung zu slice-062/063 (welle-09).** slice-062 entscheidet, welche **Modul-15**-Regeln
  ins Ziel gehören — darunter ausdrücklich, ob die emittierte Konfiguration das `targets`-Modul
  nachzieht, und ob ein Span-Emitter mitgeht; slice-063 emittiert das Entschiedene. Beide
  brauchen einen Change Request, weil sie eine neue Artefakt-Klasse in den Adopter-Vertrag
  legen. **Dieser Slice nimmt `targets` ausdrücklich nicht** und legt keine neue Artefakt-Klasse
  an; er füllt nur eine bestehende Konfiguration. Die Überschneidung ist die **Datei**, nicht die
  Entscheidung — wer nach diesem Slice läuft, ergänzt die Modul-Liste, statt sie zu ersetzen.
- **Der Plan misst gegen einen überholten Stand.** Er entstand am 2026-07-31; die Modul-Liste des
  Dogfood ist seither um `planning` gewachsen (`grep -m1 '^modules:' .d-check.yml`), und die
  Ist-Messung in §1 führt dafür keine Zeile. Kriterium 1 aus §1 — *der Dogfood fährt es selbst* —
  lässt damit einen Kandidaten zu, den die Tabelle nie geprüft hat; die Nachmessung aus §3 deckt
  die vorhandenen Zeilen, nicht die gewachsene Kandidaten-Menge. Daneben zeigen zwei Verweise auf
  [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
  auf einen aufgelösten Eintrag, abgelöst von
  [`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst),
  und die Lifecycle-Zeile nennt eine Kurs-URL auf einen abgelösten Tag. — **Ausgang:** <entfallen:
  die Nachmessung nimmt die gewachsene Kandidaten-Menge mit auf | eingetreten: slice-NNN |
  weiter offen: → Beobachtungs-Register>
- **Nicht in diesem Slice:** `codepaths` im Ziel (misst rot, s. §1), das Requirement-Muster von
  `ids` (Präfix unbekannt) und jeder Migrationspfad für bereits gebootstrappte Repos.
  Ebenfalls **nicht** hier: die **Dogfood-Seite** des `matrix`-Blocks — sie ist
  [slice-072](../open/slice-072-adr-verweist-nicht-auf-lifecycle.md), und ihre Begründung wird nicht
  zweimal aufgeschrieben. Das gilt für **drei** Positionen: die zwei
  Lifecycle-Klassen im `token:`-Modus, die zwei Regeln `{from: adr, to: …}` **und** die
  Richtungs-Prüfung innerhalb der Spec-Straten. Für diese drei nimmt die Adresse die Sendung an —
  ihre DoD (1) hebt genau diesen Block, sie schließt keine der drei aus, und sie liegt in `open/`,
  schließt also nach diesem Slice.
- **Die vierte Position ist `exclude-sections`, und sie geht an eine andere Adresse:**
  [slice-208](../open/slice-208-dogfood-wert-von-exclude-sections.md). Die emittierte Vorlage trägt
  `[Geschichte]`, der Dogfood `[Historie, "7. Historie", Geschichte]`
  (`grep -n 'exclude-sections' internal/emit/templates/d-check.yml` gegen `sed -n '194p' .d-check.yml`).
  slice-072 kann diese Sendung nicht annehmen, und das ist gemessen statt vermutet: Der Schlüssel
  steht nicht in seiner DoD (1), **und** seine eigene Ist-Messung setzt den weiten Wert voraus
  (§1 dort: *„sechs Nennungen liegen unter `Historie`/`Geschichte`, das `exclude-sections` schon
  heute ausnimmt"*) — der engere Wert würde jene Messung falsch machen, statt sie zu erfüllen.
  Dazu kommt die Regel-Familie: Verengt man den Dogfood-Wert probeweise (Kopie außerhalb des Repos,
  netzlos, Mount `:ro`, gepinnter Digest aus [`d-check.mk`](../../../../d-check.mk)), meldet der
  Lauf `1071 Datei(en) geprüft, 16 Befund(e)` — **alle** in
  [`spec/lastenheft.md`](../../../../spec/lastenheft.md) unter `## 7. Historie`, davon 14
  `matrix-forbidden` der Richtung `spec-straten → adr` und 2 `matrix-inactive`. slice-072 handelt
  von `{from: adr, to: …}`, also der Gegenrichtung; die Position an ihn zu hängen hieße, ihm eine
  fremde Regel-Familie anzuhängen. **Keine Erwartungswerte** — die Zahlen wandern mit der
  Historie-Tabelle; tragend ist, dass sie sämtlich aus der CR-Historie stammen, die nach
  [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  die ADR nennen **muss**, die den Vertrag änderte.
- **Der emittierte Stand läuft dem Dogfood an vier Positionen voraus, und das ist die benannte
  Grenze.** Ein frisch gebootstrapptes Ziel fährt eine `matrix`-Form, die dieses Repo selbst nicht
  fährt. Erprobt ist sie hier trotzdem — beide Richtungen über beiden Bäumen (§3, *Übergabe an den
  Architect*); was fehlt, ist die Dauerhaftigkeit im eigenen Gate, nicht der Beleg. **Die vier
  laufen unterschiedlich ein:** Drei holt slice-072 ein, und danach ist der Vorlauf weg. Bei der
  vierten ist offen, **ob** er je eingeholt wird — ein frisches Ziel hat keine CR-Historie, die auf
  ADRs zeigt, dieses Repo hat sie; die Abweichung kann darum die richtige Dauerform sein.
  Entschieden wird das in [slice-208](../open/slice-208-dogfood-wert-von-exclude-sections.md),
  nicht hier. — **Ausgang:** <entfallen: slice-072 und slice-208 schließen vor der Closure |
  eingetreten: slice-NNN | weiter offen: → Beobachtungs-Register>

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): der Emitter
(`internal/emit/`), `harness/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
