# Review-Report: ADR-0058 — Glättungs-Nachrunde 2026-09-18

**Review-Art:** Nachrunde derselben prüfenden Rolle zu ADR-0058 vor ihrem Accept-Übergang
([ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 2) — geprüft wird allein der Glättungs-Commit, kein Neu-Review.

**Gegenstand:** Commit `6353aa1a` (Architect: F-3/F-5 aus der Runde
`2026-09-18-slice-traeger-per-fetch-aus-dem-release-runde-1` im `Proposed`-Fenster
behalten — 1 Datei, +16/−12).

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 · **Modell:** claude glm-5.3-flash ·
**Datum:** 2026-09-18

> **Zitier-Form:** Kennung statt Adresse —
> `slice-traeger-per-fetch-aus-dem-release` statt seines Lifecycle-Pfads,
> ADR-0058 als `ADR-0058`, Runde-1-Report als Datei-Kennung.

**Eingangs-Kontext:** die Runde-1-Findings (F-3, F-5 zur Debatte) · ADR-0058
(Proposed) · ADR-0033 Festlegung 4 (Verbatim-Quelle) · ADR-0040 Festlegung 2 ·
`AGENTS.md` §3.7 · `cmd/ai-harness-init/main.go` (Messgegenstand der Festlegung 2).

---

## Prüfung der zwei Glättungen

**F-3 (MEDIUM, Runde 1) — getragen, mit einer Evidenz- und einer Struktur-Reste.**

- **(a) Messangabe stimmt.** `grep -c 'case "' cmd/ai-harness-init/main.go` → **4**
  (selbst gefahren). Der switch an `main.go:559` führt genau die vier string-cases
  (`span-emit`, `span-report`, `archive-welle`, `vendor-baseline`) und **keinen
  Default** — ein Aufruf mit fremdem `os.Args[1]` fällt zum Init-Pfad durch
  (`run(…)` an `main.go:575`). Die geglättete Festlegung 2 beschreibt damit den
  gepinnten Stand wahr.
- **(b) Alle Wiederholungen tragen die Korrektur.** `grep -n 'laut\|still'` über die
  ADR: keine Präsens-Stelle setzt den laut-Bruch am gepinnten Stand mehr voraus —
  Festlegung 2 („bricht der Aufruf am gepinnten Stand nicht laut"; der laut-Bruch
  als Zusage an den Release-Schnitt, „erst ab ihm"), Contra-Zelle F („still startend
  am gepinnten Stand"), Konsequenz („bis zum Release-Schnitt fällt der Bruch still")
  und Re-Evaluierungs-Trigger 2 („bricht der Aufruf am gepinnten Stand still") tragen
  dieselbe Umstellung. Die „still ändern"-Treffer (Zeilen 170, 202) betreffen die
  Fehlt-Fall-Zusage des Prerequisite-Verbots und stehen unberührt richtig.
- **(c) Trigger 2 setzt den Vorbehalt.** Er leitet aus dem stillen Bruch ab und
  konditioniert den laut-Bruch auf den Release-Schnitt („Trägt der laut-Bruch nach
  dem Release-Schnitt nicht …") — vorausgesetzt wird nichts mehr.

**F-5 (LOW, Runde 1) — getragen.** Die Paraphrase trägt jetzt „hält als
Wiederherstellungs-Weg den erneuten Tool-Lauf fest" ohne „allein"; gegen das
Verbatim in ADR-0033 Festlegung 4 („und wiederhergestellt wird er durch einen
erneuten Tool-Lauf") Wort für Wort deckungsgleich, keine Exklusivität mehr
behauptet. Festlegung 5 (Schärfung, kein `Supersedes`) ist vom Diff unberührt und
steht unverändert.

**Geschichte-Zeile.** Die ergänzte Zeile nennt Zustand („Überarbeitet, weiter
**Proposed**") und Beleg als auflösbare Anker (Report-Kennung, Commit `2a7b6aae`).
Die Befund-Darstellung im Verweis-Feld beschreibt den Korrektur-Vorgang in der
Form des Musters ADR-0033 (dessen Überarbeitet-Zeile denselben Detailgrad trägt);
der Zustand steht im Ereignis-Feld, die Herkunft in den zwei Ankern — kein
Zustandsfeld, das Chronik statt Beleg führt. Geprüft, ohne Befund.

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| N-1 | MEDIUM | Der Glättungs-Commit hat in Zeile 261 das Zeilenende von Trigger 2 mit dem Bullet-Anfang von Trigger 3 verschmolzen: „… konstruktiv zu bauen.- **Wenn das Release keinen Signier-Schritt bekommt …". Die Re-Evaluierungs-Trigger-Liste zählt **3** Bullets statt vier (`sed -n '/^## Re-Evaluierungs-Trigger/,/^## Geschichte/p' … \| grep -c '^- \*\*Wenn'` → 3; die Runde-1-Negativbefund-Zeile zählte vier); Trigger 3 (Signier-Schritt/Digest-Angriff) ist sein eigenes List-Item los und liest sich als Absatz-Halbsatz von Trigger 2. Ein Gate fängt das nicht (`make docs-check` 1705/0 über dem Defekt). Die Datei wird mit dem Accept unveränderlich — nach ihm kostet die Korrektur eine `Supersedes`-ADR. Ein Zeilenwechsel vor `- **Wenn das Release` behebt es. | Maintainability · `AGENTS.md` §3.4 (Immutabilität ab `Accepted`) | docs/plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md:261 | ja — die Bullet-Zählung daneben | Korrektur-Zug verliert ein Strukturzeichen in einem einfrierenden Artefakt |
| N-2 | LOW | Trigger 2 trug vor der Glättung zwei Ausgänge („Release-Schnitt verschärfen **oder** der Fassungs-Fit konstruktiv zu bauen") und trägt jetzt nur noch den zweiten. Das ist mehr als der geforderte Vorbehalt: eine zweite Setzung im selben Zug. Trägt der laut-Bruch nicht, weil der gepinnte Stand die Sperren fehlen lässt, wäre das Nachschieben einer Release-Fassung mit Sperren der leichtere Weg vor dem konstruktiven Bau — der Trigger nennt ihn nicht mehr. Entwurfshafte Verengung oder Versehen ist hier nicht ablesbar; vor dem Accept klären oder die zweite Option zurückstellen. | Maintainability | docs/plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md:257-261 | nein — Urteil über die Ausgangs-Menge, kein Gate | Rewrite eines Triggers trägt eine zweite Setzung mit, die keine Korrektur war |
| N-3 | INFO | Festlegung 2 belegt „vier Fälle und keinen Default" allein mit dem case-Grep — er trägt die Fälle-Hälfte, die Default-Abwesenheit trägt nur die Quellen-Lektüre (`grep -n default cmd/ai-harness-init/main.go` → Zeile 236, ein `default:` im Flag-Loop-`switch`, nicht im Unterkommando-`switch`; die Aussage ist gescoped wahr). Ein Kommando, das die zweite Hälfte trägt, fehlt. | `MR-025` | docs/plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md:152-153 | ja — die Evidenz-Lücke ist an der Stelle ablesbar | Evidenz-Paar trägt nur eine Hälfte der dualen Aussage |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Festlegung 2 gegen den gepinnten Stand | geprüft, ohne Befund — switch `main.go:559` liest `os.Args[1]`, vier string-cases, kein `default`, Fall-through zu `run(…)`; der Init-Pfad-Claim trägt |
| Übrige laut-Bruch-Claims der ADR | geprüft, ohne Befund — keine Präsens-Stelle über dem gepinnten Stand; alle vier Korrekturstellen konsistent (siehe (b)) |
| F-5 Verbatim | geprüft, ohne Befund — „allein" entfernt, Paraphrase gegen ADR-0033 Festlegung 4 wörtlich deckungsgleich |
| Festlegung 5 (Nicht-`Supersedes`-Schluss) | geprüft, ohne Befund — vom Diff unberührt |
| Geschichte-Zeile gegen §3.7 | geprüft, ohne Befund — Zustand + zwei auflösbare Anker, Muster ADR-0033, keine Chronik im Zustandsfeld |
| Commit-Zuschnitt `6353aa1a` | geprüft, ohne Befund — nur die ADR-Datei, Rolle und Kennung in der Message, Beleg (`make docs-check`) genannt |

**Nicht gefahren:** `make gates`/`make docs-check` — vom Architect über den Stand
gefahren und im Auftrag als grün gemeldet (1705/0); dieser Lauf prüft Text, kein
Gate-Rerun.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Korrektur-Zug verliert ein Strukturzeichen in
einem einfrierenden Artefakt · Rewrite eines Triggers trägt eine zweite Setzung
mit, die keine Korrektur war · Evidenz-Paar trägt nur eine Hälfte der dualen
Aussage.

## Verdikt

**Ready for Accept: noch nicht — der Rest ist ein Zeilenwechsel.** Beide
geforderten Glättungen tragen: Festlegung 2 beschreibt den gepinnten Stand wahr und
stellt den laut-Bruch als Zusage an den Release-Schnitt um; die Messangabe ist
selbst gefahren und stimmt; alle Wiederholungsstellen, Trigger 2 und die
F-5-Paraphrase stehen korrigiert, Festlegung 5 unverändert. Die ADR trägt damit
die Messung.

**Blockierend für den Accept ist allein N-1** — der vom Glättungs-Commit selbst
eingeführte verschmolzene Zeilenwechsel, der Trigger 3 sein List-Item kostet. Der
Acceptance-Trigger verlangt einen Report ohne blockierenden Befund; dieser hier
blockiert, bis der Zeilenwechsel gezogen ist. Nach dem Zug genügt eine kurze
Bestätigungs-Runde derselben Rolle (nur die Bullet-Zählung und die zwei
Reste-N-2/N-3 im Blick) — dann ist der Accept-Übergang ein kleiner
Architect-Zug. N-2 ist vor dem Accept vom Architect zu klären (zurückstellen oder
zweite Option nachtragen); N-3 ist ein INFO-Anhang ohne Blockwirkung.

**Übergabe:** N-1/N-2 an den **Architect** (ein Zeilenwechsel, eine
Ausgangs-Entscheidung — beides im `Proposed`-Fenster gratis). Die Finding-Klassen
gehen in die Slice-Closure §7 und von dort in den Zähler.

---

# Bestätigungsrunde — 2026-09-18, nach Commit `1b722b71`

**Gegenstand:** `1b722b71` (Architect: N-1/N-2/N-3 gezogen — nur die ADR-Datei,
+3/−3, `make docs-check` 1706/0 als Beleg in der Message). Die drei Prüfungen der
Bestätigungsrunde, alle selbst gefahren:

1. **Bullet-Zählung:** `sed -n '/## Re-Evaluierungs-Trigger/,/## Geschichte/p' … |
   grep -c '^- \*\*Wenn'` → **4**. Die verschmolzene Zeile ist getrennt, Trigger 3
   (Signier-Schritt/Digest-Angriff) führt sein List-Item wieder. N-1 getragen.
2. **Trigger 2 trägt beide Ausgänge wörtlich:** „ist der Release-Schnitt zu
   verschärfen oder der Fassungs-Fit konstruktiv zu bauen" — die Zweiteilung der
   Fassung vor der Glättung, restauriert. Die Klärung von N-2 („keine beabsichtigte
   Setzung; die ursprüngliche Zweiteilung gilt unverändert") steht in der
   Commit-Message, nicht im ADR-Text: das Artefakt trägt nur den Zustand (beide
   Ausgänge), den Vorgang der Restauration hält `git`. Kein Chronik-Text im
   Artefakt — §3.7 geprüft, ohne Befund. N-2 getragen.
3. **N-3 trägt die Lektüre-Kennzeichnung:** Festlegung 2 nennt jetzt „daß kein
   Default-Zweig folgt, trägt die Lektüre des Switches — Zeilen 558–570 — und kein
   Muster-Grep". Die Evidenz ist als Lektüre gekennzeichnet statt als belegte
   Messung ausgegeben; die Lektüre stimmt mit meiner eigenen
   (`main.go:559`, vier string-cases, kein `default`, Fall-through zum Init-Pfad).
   N-3 getragen. Das „daß" ist keine Orthographie-Abweichung mit Anker — der
   Bestand führt es auch in zwölf weiteren ADR-Stellen (`grep -rn 'daß' … docs/plan/adr |
   grep -v 0058 | wc -l` → 12); nach dem Stil-Polizist-Ausschluss des Skills kein
   Finding.

**Negativbefunde:** Commit-Zuschnitt `1b722b71` geprüft, ohne Befund — nur die
ADR-Datei, Rolle und Kennung in der Message, Beleg (`make docs-check` 1706/0)
genannt. Keine weitere Stelle der ADR vom Diff berührt; die Festlegungen 1–5, die
Konsequenzen und die Geschichte-Zeile stehen unverändert. **Nicht gefahren:**
`make gates`/`make docs-check` — vom Architect gefahren und in der Message belegt.

## Verdikt der Bestätigungsrunde

**READY FOR ACCEPT.** Kein blockierender Befund: N-1 ist behoben (vier Trigger-Bullets,
selbst gezählt), N-2 ist geklärt und als Zustand im Artefakt formuliert, N-3 trägt
die Lektüre-Kennzeichnung ohne Messungs-Behauptung. Die ADR-0058 trägt die Messung
am gepinnten Stand (F-3), die Verbatim-Paraphrase (F-5) und die
Korrektur-Geschichte als auflösbare Anker. Der Accept-Übergang — Status-Setzung
`Proposed` → `Accepted` samt Accept-Zeile in §Geschichte — ist der kleine
Architect-Zug, den der Acceptance-Trigger der ADR freigibt; Beleg dieser Runde nach
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 2 ist diese Datei.