# `make environment-check` — prüft, ob die Umgebung die deklarierte ist

> **Template-Hinweis.** Kopiert aus
> `.harness/baseline/v7.0.0/templates/harness/sensors/environment-check.template.md`;
> alle Platzhalter ausgefüllt, der Vorlagen-Block entfernt.

## Vertrag

Rot heißt: Die Umgebung trägt die Umgebungs-Zusage nicht — ein Werkzeug des
Inventars fehlt, weicht vom Soll ab oder hat die Fähigkeit nicht, die ein
Skript braucht. Ein **Umgebungs-Befund**, kein Befund über den Code. Der Check
läuft als **erster** in `make gates`
(`record-gates: environment-check …` — ein Umgebungs-Befund endet dem
Gate-Lauf an der Kante, bevor ein Gate gegen fehlendes Werkzeug falsch färbt).

Festlegung: [`SPEC-099`](../../spec/spezifikation.md#7-festlegungen-der-harness-werkzeuge)
in der Spezifikation — welche Prüfformen, wie verglichen wird, was rot ist und
was Warnung. Bindung der Anforderung:
[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die
Umgebungs-Zusage — der Check ist ihre Messmethode docker-los) und
[`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(docker ist Weg, keine Pflicht — der erste Gate-Check fährt nur mit
Host-Werkzeugen). Träger der Soll-Form ist
[`ADR-0109`](../../docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md)
(docker-los Pflicht-Weg, Image-Weg opt-in, Mischform, erster Check).

## Inventar und Soll

**Inventar:** [`harness/tools/environment-inventory.txt`](../tools/environment-inventory.txt)
— je Eintrag Werkzeug · Prüfform · Pflichtgrad · Soll · Kontext · Grund
(zeilenweise, `|`-getrennt; die Form liest das Skript nach
[`SPEC-099`](../../spec/spezifikation.md#7-festlegungen-der-harness-werkzeuge)).
Die Prüfformen: *Anwesenheit*, *Mindestversion*, *Fähigkeit* (die Probe misst
die genutzte Aufrufform, nicht die Distribution), *exakt*.

**Woher das Soll kommt:** die Mischform des Adaptions-Blocks —
[`MR-098`](../conventions.md#mr-098--die-umgebungs-zusage-trägt-mischform-die-dogfood-gates-und-lab-läufer-fahren-am-host):
das Inventar leitet das Soll ab, wo eine maschinen-lesbare Pin-Stelle existiert
(Go über die `GO_VERSION`-Stelle im [`Makefile`](../../Makefile) — der Wert
steht als `abgeleitet:` und der Stellen-Abgleich hält ihn byte-genau gegen den
Pin), und trägt es selbst, wo keine Pin-Stelle trägt (`manifest:` — git, bash,
make, die GNU-Werkzeuge, bats, shellcheck, actionlint, das d-check-Binary).
Der Stellen-Abgleich steht im
[`pinsync`-Block](../../.d-check.yml) der
Doku-Gate-Konfiguration (Pin `go`: Inventar-Zeile gegen `GO_VERSION ?=`; die
Config-Form hält
[`test/pinsync-modul-wiring.bats`](../../test/pinsync-modul-wiring.bats)).

**Ausführungsort:** Host und CI-Runner — der docker-lose Pflicht-Weg führt
keinen zweiten Kontext-Lauf im Image mit; die im gepinnten Image adressierten
Werkzeuge des Tool-Baus bleiben über den Digest **adressiert, nicht
verglichen** (die Lücke benannt im Adaptions-Eintrag). Deklariert in
derselben [`MR-098`](../conventions.md#mr-098--die-umgebungs-zusage-trägt-mischform-die-dogfood-gates-und-lab-läufer-fahren-am-host).

## Grenze — was das Grün nicht abdeckt

1. **Drift zwischen zwei Läufen.** Der Check stellt die Umgebung zum Zeitpunkt
   des Laufs fest — permanent.
2. **Werkzeuge außerhalb des Inventars.** Was nicht im Inventar steht, prüft
   der Check nicht: absolute Pfade (`/bin/sh` als Rezept-Shell), Builtins,
   Aufrufe in nicht ausgeführten Zweigen der Rezepte · Probe über
   [`test/environment-check.bats`](../../test/environment-check.bats)
   hermetisch (Stubs und Fixtures); die reale Rot-vor/Gruen-nach-Beobachtung
   der Inventar-Zeilen am Host trägt `make gates` selbst — das Protokoll der
   lokalen Beobachtungen steht im Kopf des Skripts
   ([`harness/tools/environment-check.sh`](../tools/environment-check.sh),
   §Protokoll der Break-Tests).
3. **Kontexte, in denen er nicht läuft** — der gepinnte Image-Weg (opt-in): der
   Image-Digest adressiert sein Inneres, der Check vergleicht nicht.
4. **Zusätzlich Vorhandenes.** Der Check prüft, was das Soll nennt; globale
   Pakete und weitere Werkzeuge am Host bleiben unbemerkt. Er isoliert nicht.
5. **Versions-Zusagen fehlen an bats, shellcheck, actionlint und d-check**
   (Prüfform *Anwesenheit*): keine Pin-Stelle trägt ihre Versions-Fassung —
   eine exakte Behauptung über sie wäre unbelegt; sie steht bewusst nicht.
6. **Die Fähigkeits-Proben messen die Aufrufform, nicht die Distribution** —
   `mktemp -p` und der feste sha256-Digest tragen uutils-Varianten ebenso;
   GNU-ness ist kein Gegenstand der Proben.

## Ausgabe und Ausgänge

| Exit | Bedeutung |
|---|---|
| 0 | jedes Pflicht-Werkzeug trägt sein Soll — kein Befund; fehlt ein `optional`-Eintrag, steht eine Warnzeile, die sagt, was ausfällt (eine Warnung ist kein Rot) |
| 1 | Umgebungs-Befund: je Werkzeug eine Zeile `umgebung: Werkzeug · Soll · Ist`, dazu die Pflicht-Befund-Anzahl |
| 2 | Aufruf- oder Inventar-Aufform (unlesbares oder leeres Inventar, Zeile mit anderer Spaltenzahl, unbekannte Prüfform, unbekannter Pflichtgrad, Soll ohne Quelle, unstimmige Probe-ID) — fail-closed; auch der bash-Guard unterhalb der Inventar-Mindestversion |

## Sperren

- **Bash zu alt** — der Guard steht als erster Top-Level-Befehl, vor jeder
  Funktionsdefinition und außerhalb jeder Funktion, nur mit Builtins
  (`BASH_VERSINFO`): Unterhalb der Mindestversion 4.0 endet der Lauf mit einer
  Diagnose statt mit einem Syntaxfehler → eine neuere Bash in den `PATH`
  stellen. Strukturell gehalten durch
  [`test/environment-check.bats`](../../test/environment-check.bats) (erster
  Top-Level-Befehl); die Unter-Version-Auslösung selbst braucht ein älteres
  bash, das kein Test-Image trägt — bewusste Grenze.

## Bindung

[`SPEC-099`](../../spec/spezifikation.md#7-festlegungen-der-harness-werkzeuge) ·
[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ·
[`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) ·
Inventar: [`harness/tools/environment-inventory.txt`](../tools/environment-inventory.txt) ·
Soll-Quelle und Ausführungsort:
[`MR-098`](../conventions.md#mr-098--die-umgebungs-zusage-trägt-mischform-die-dogfood-gates-und-lab-läufer-fahren-am-host) —
Weg-Form: [`ADR-0109`](../../docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md) ·
seit slice-environment-check-fuehrt-die-gates
