# Review — slice-waechter-umgebungs-robustheit (welle-ohne-docker)

**Reviewer-Lauf:** frisch, frischer Kontext (kein Vorbericht am Slice)
**Diff:** `e3c4cfd2..ba3394c1` — 4 Implementer-Commits nach dem Claim-Commit
(`e3c4cfd2` = `git mv` nach `in-progress/`, `ba3394c1` = HEAD des Laufs)
**Umfang:** 5 Dateien, +76/−5 — `test/traeger-fetch.bats` und
`test/traeger-fetch-host.bats` (Setup-Ausmerz der `TRAEGER_*`-Stellen),
`test/targets-modul-wiring.bats` (Kollations-Festlegung `LC_ALL=C` an den
`sort`-/`comm`-Stellen), `test/dockerfile-teststufe.bats` (Grenz-Zeile im
Kopf, nur Kommentar) und die Plan-Datei (§3 Ist-Stand, Drift-Nachzug,
Mess-Protokoll).
**Gegenstand laut Plan §3:** die Wächter-Laufformen des `make test`-Weges tragen
ihre Umgebung je Setup selbst (PIN-Erbe, Locale, `BATS_*`), sodass Einzellauf und
voller Sweep dieselbe Rot-Menge liefern (Beobachtung
`BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante`).

**Abgrenzung dieses Reviews:** Code gegen Plan §1/§3/§6 und ADR-0109/LH-QA-01.
DoD-Abhakung (Liefer-Punkte 2/3 als Messungen), CI-Kausalität und Closure sind
nicht Teil dieses Berichts (Modul 10 Grenze).

---

## Findings

### F-1 — LOW

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.6, Skill-Zeile „Mehrteilige Regel-Zusage im Kommentar
  ohne Mutations-Deckung je Teil"; Maintainability
- `pfad`: `test/targets-modul-wiring.bats:44-46` (Kommentar „LC_ALL=C an den sort- und
  comm-Stellen", Stellen 49/61/70 `sort` · 97/107 `comm`)
- `befund`: Der Kommentar trägt die Kollations-Zusage je Teil („an den sort- und
  comm-Stellen"), aber der Zahn sitzt an den `sort`-Löschungen allein — Bruchprobe
  entfernt `LC_ALL=C ` nur an den zwei `comm`-Stellen: beide Fälle bleiben grün,
  unter `LC_ALL=en_US.utf8` wie ohne Locale-Variable. Löst die `sort`-Stellen:
  rot („comm: input is not in sorted order"). Die Teil-Zusage an `comm` ist
  nicht einzeln gebunden, und die Grenze (Zahn sitzt an `sort`) trägt sie
  nirgends im Bestand — kein Mutations-Fall für die vier Stellen
  (`test/mutations/` hat keinen Fall gegen `targets-modul-wiring.bats`), keine
  benannte Grenze im Kommentar oder Plan §3; die Messung steht nur im
  Implementer-Lauf selbst. Richtung des ungebundenen Teils: eine spätere Löschung
  der `comm`-Präfixe verfälscht die Zusage des Kommentars nicht (die
  Locale-Invarianz bleibt), öffnet aber die spurious-rote Seite — eine
  Host-Kollation, deren `comm`-Ordnungsprobe gegen die C-sortierte Eingabe
  meckert, bricht einen grünen Fall laut, bevor die `sort`-Stelle sie trägt.
  Lücken-Befund, nicht Verstoß: das Verhalten ist belastbar gemessen, die
  Grenze ist nur nicht dokumentiert.
- `verifizierbar`: ja, beide Richtungen gefahren (Protokoll unten); ein
  Mutations-Fall würde die `comm`-Löschung binden.
- `klasse`: „Mehrteilige Kollations-Zusage im Kommentar ohne Mutations-Deckung
  je Teil — Zahn sitzt an `sort`, Grenze unbenannt"

### F-2 — LOW

- `quelle`: `AGENTS.md` §3.7 (Herkunft als **ein** auflöbares Feld) ·
  Maintainability
- `pfad`: `docs/plan/planning/in-progress/slice-waechter-umgebungs-robustheit.md:124-128`
  (Abschnitt „Ist-Stand gegen die Tabelle")
- `befund`: Der Ist-Stand trägt drei Plan-Zeilen dem „Vorgänger-Commit
  `be63da5d`" zu; zwei davon trägt git dem Commit `9c788a9c` zu — die
  `BATS_ROOT`/`BATS_LIBDIR`-Restauration in `harness/tools/bats-lint.sh` (F-1)
  (`git log --oneline -S BATS_ROOT -- harness/tools/bats-lint.sh` → `9c788a9c`)
  und die docs-check-Carrier-Prosa (`git blame -L 14,20 harness/sensors/docs-check.md`
  → `9c788a9c`). `be63da5d` trägt stattdessen die Rezept-Grep-Form
  (`rezept-host.bats`, `dockerfile-teststufe.bats`), die F-3-Zellen
  (`harness/README.md` traeger-fetch-Zeile, `harness/sensors/traeger-fetch.md`,
  `spec/spezifikation.md` SPEC-099) und den Mutations-Beleg 810. Die Schluss-
  folgerung der Notiz — die drei Zeilen sind vor diesem Lauf erfüllt — bleibt
  wahr; nur die Herkunfts-Adresse der zwei Zeilen löst ins Leere, und ein
  späterer Leselauf prüft die falsche Stelle nach `git show be63da5d` hin.
- `verifizierbar`: ja — die zwei git-Kommandos oben.
- `klasse`: „Herkunfts-Anker im Plan löst auf den falschen Commit auf"

---

## Kommando-Protokoll (alle Läufe am Reviewer-Host, docker-los)

```
# Sensoren an HEAD (ba3394c1)
make -s test-bats BATS_TARGET=test/traeger-fetch.bats        → GRÜN
make -s test-bats BATS_TARGET=test/traeger-fetch-host.bats   → GRÜN
make -s test-bats BATS_TARGET=test/targets-modul-wiring.bats → GRÜN
make -s test-bats BATS_TARGET=test/dockerfile-teststufe.bats → GRÜN
make -s test-bats BATS_TARGET=test/ignore-refs-restbreite.bats → ROT (1 Fall)
   not ok 2 … jede Top-Level-ignore-refs-Ausnahme deckt genau die … deklarierte …
   (= der in Plan §3 benannte Vorlauf-Befund, hier Fall 273-Klasse: ein rot
   gebliebener Fall, der vor `e3c4cfd2` bestand)

# Bruchprobe 1 — Kollation, Kopie /tmp/rev-swr-a (geklont, nach dem Lauf geräumt)
sed 's/LC_ALL=C sort/sort/g'   → env LC_ALL=en_US.utf8 make test-bats … → ROT
   ("comm: input is not in sorted order")
git checkout -- ; sed 's/LC_ALL=C comm/comm/g'              → GRÜN unter en_US.utf8,
   GRÜN auch unter env -u LC_ALL -u LANG

# Bruchprobe 2 — Setup-Ausmerz, Kopie /tmp/rev-swr-b (geklont, geräumt)
for-Schleife aus beiden Setups entfernt, Lauf über das make-Rezept (die reale
Quelle: Makefile:61 `export TRAEGER_TAG … TRAEGER_CARRIER` exportiert den Pin-Satz):
test/traeger-fetch.bats      → 4 rot (Plan §3: {3,5,7,9} vor dem Fix)
test/traeger-fetch-host.bats → 5 rot (Plan §3: {603,605,606,607,608})

# make gates an HEAD → rot an docs-check-host (erster roter Gate; 102 Befunde)
# Vergleich am Claim-Commit (Klon von e3c4cfd2 + kopiertes d-check-Binary):
d-check: 3075 Datei(en) geprüft, 102 Befund(e)  — auf beiden Ständen identische
Befundliste, einzig Zeilenschübe im Plan-Diff (140→174, 213→247); die diff-neuen
Plan-Texte tragen keinen neuen Befund. Der Doku-Gate-Rot-Bestand ist vollständig
vorbestehend (Plan-Posten, nicht Implementer-Diff).

# make test-bats BATS_TARGET=test/ (voller Sweep an HEAD)
exakt ein rot: Fall 273 (ignore-refs-restbreite) — dieselbe Vorlauf-Rot.
```

---

## Geprüft, ohne Befund

- **Plan §1 Ziel/Abgrenzung gegen den Diff:** die zwei geplanten Wächter-Zeilen
  (`traeger-fetch`, `targets-modul-wiring`) trägt der Diff; `dockerfile-teststufe`
  bekommt die Grenz-Zeile des Plan-Tabelle-Eintrags (Kopf-Kommentar); der
  über Plan hinaus berührte Wächter (`traeger-fetch-host`) ist die im Plan §3
  nachgezogene zweite Instanz und die Rückführungs-Schwelle („mehr als drei
  berührte Wächter-Dateien") ist nicht gerissen — berührt werden drei Wächter-
  Setups plus eine Kommentar-Zeile.
- **Grenz-Zeile im dockerfile-teststufe-Kopf gegen den Bestand:** der Körper
  ruft nach `be63da5d` kein `make`/`git`/`docker` mehr an der Laufzeit (keine
  `run make`/`run git`-Stelle; die Assertion-Zeilen lesen grep-Formen); die
  Zusage „denselben Exit-Vertrag an beiden Wegen" ist eine Form-Zusage mit
  Grenze, nicht ein halluziniertes Urteil; ihr Messbeleg reist dem Verifier.
- **F-3-Nachzieh-Konsistenz:** die README-Zelle `make traeger-fetch`
  (`be63da5d`) und die docs-check-Prosa (`$(DCHECK_CARRIER)`,
  `harness/sensors/docs-check.md:14-20`, hergebracht `9c788a9c`) nennen
  denselben gefetchten Carrier-Träger — konsistent, kein Zwickel.
- **Gate-Senkung (§3.5):** keine — die `LC_ALL=C`-Festlegung hält die Invariante
  der Wächter (die gemessene Menge der Fall 6-Formen ist lokal-unabhängig
  identisch, der vorgehende rote Fall bestand an der Locale-Abhängigkeit), der
  Sweep am HEAD liefert dieselbe Vorlauf-Rot und keinen geänderten Fall-Satz;
  die Schwellen bleiben. Kein ADR nötig, keine Senkung.
- **`# shellcheck disable` / Inline-Suppression (§3.2):** keine im Diff.
- **Kommentar-Klassen und Zustandsfelder (§3.7):** alle neu angelegten
  Kommentare tragen Zusage/Grenze mit `seit`-Anker oder Kopplung (Rezept-Weg
  exportiert Pin-Satz, belegt am `Makefile:61`); kein Vorgangs-Protokoll, kein
  Konjunktiv über die verworfene Alternative, kein Datums-/Befund-Protokoll in
  den Kommentarfeldern; das Plan-Protokoll liegt (richtig) im Plan, nicht im
  Code-Kommentar.
- **Plan §6 Risiken:** die zwei benannten Risiken (Ursache im Läufer-Werkzeug;
  Symptom-Dreh am Host-Profil) sind durch die Mess-Belege nicht eingetreten —
  die Setups tragen die Rot-Menge (Bruchprobe 2 bestätigt die geerbten
  Pin-Mengen als Auslöser, nicht den Läufer) —, den Ausgang trägt die Closure
  (nicht dieses Review).
- **Zwillings-Asymmetrie der Unset-Listen (INFO-Prüfung, kein Befund):**
  `traeger-fetch.bats` unset-zusätzlich `TRAEGER_IMAGE/OS/ARCH`, der Host-Zwilling
  nicht — kein Fehlszenario: der Host-Skript-Zweig liest `TRAEGER_OS/ARCH/TRAEGER_CARRIER`,
  jeder Host-Fall bindet `TRAEGER_OS`/`TRAEGER_ARCH` je Fall per `env`, kein Fall
  misst den `uname`-Fallback, und der Rezept-Weg exportiert nur die geschlossene
  Menge der `Makefile:61`-Zeile (kein TRAEGER_OS/ARCH-Kanal in die Suite).
- **Die anderen TRAEGER-lesenden Wächter** (`test/traeger-pins-check.bats`,
  `test/release-warten.bats`) tragen dieselbe Klasse nicht — ihre Setups
  setzen die Pins/Tag je Setup selbst (überschreiben etwaigen Ambiente
  deterministisch), der Ambient-Kanal kann die Fälle nicht schwenken.
- **Die 5 vorbestehenden Gates-Rot-Klassen:** keine durch den Diff eingeführt
  und keine vertieft — `make gates` bricht an `docs-check-host`, dessen 102
  Befunde am Claim-Stand identisch sind (Protokoll oben); der volle bats-Sweep
  zeigt nur den vorbestehenden Fall 273; Go-Code, Makefile-Rezepte und
  Lint-Konfiguration berührt der Diff nicht.

---

## An den Verifier (nächste Prüfung)

1. **Liefer-Punkt 2:** Einzellauf gegen vollen Sweep je berührter Wächter-Datei
   (beide Formen, dokumentiert im Verifikations-Bericht) — an HEAD ist der
   Sweep-Bestand {Fall 273} und alle vier geänderten Wächter grün; die
   Einzellauf-Hälfte je Datei trägt der Verifier.
2. **Liefer-Punkt 3:** der opt-in `test-bats-image`-Weg (docker-getrieben) gegen
   denselben Exit-Vertrag — docker trug am Reviewer-Host nicht; gelesen, nicht
   gefahren.
3. **Die Grenze aus F-1** in der Closure benannt tragen (Kommentar oder
   Mutations-Fall) — die Messung steht im Implementer-Bericht, im Bestand nirgends.
4. Der Plan §3 benannte Vorlauf-Befund (Fall 273) ist an HEAD reproduziert rot;
   sein Präzedenz-Nachzug ist Planner-Posten, kein Verifier-Mangel.

**Rollen-Widerspruch der Klasse HIGH:** nein — alle Findings sind LOW, die
Implementer-Ausführungen gegen den Plan tragen.
