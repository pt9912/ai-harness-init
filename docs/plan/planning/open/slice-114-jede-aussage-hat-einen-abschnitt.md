# Slice slice-114: Jede Aussage des Harness-Einstiegs hat einen Abschnitt — und wo die Pflichtgliederung keinen vorsieht, steht sie beim Werkzeug

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — ein Durchgang über **eine** Datei; er ist
einzeln lieferbar und wartet auf keinen zweiten Slice. Der zweite Gegenstand, den derselbe Befund
sichtbar macht, ist ausdrücklich **nicht** hier gebündelt, sondern abgegeben (§1 *Was dieser Slice
abgibt*) — er hat einen anderen Eigentümer und eine andere Ziel-Form. **(2) Gemeinsames
Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift der eigenen DoD. **(3) Auslöser
reaktiv oder gewollt?** Reaktiv: ein Norm-Artefakt ist gemessen von seiner Ziel-Form abgedriftet
(§1). Kein Fähigkeits-Sprung — das Werkzeug lernt nichts Neues. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist die `harness/README.md` **dieses** Repos. Die
`harness/README.md` eines emittierten Repos entsteht aus der vendored Vorlage: `singletonTarget`
bildet `templates/harness/README.template.md` auf `harness/README.md` im Ziel ab, indem es die
Endung tauscht (`internal/emit/templates.go:291-299`;
`grep -c 'TrimSuffix(rel, ".template.md")' internal/emit/templates.go` → **1**). Ein Adopter
bekommt damit **7 322** Zeichen
(`wc -c < .harness/baseline/v5.12.0/templates/harness/README.template.md`), abzüglich des
gestrippten Hinweis-Blocks — nicht die **16 161** dieses Repos (`wc -c < harness/README.md`). Was
hier bewegt wird, geht **nicht** mit; die emittierte Ebene ist von diesem Befund nicht betroffen,
und genau das ist der Grund, aus dem er hier so lange unbemerkt bleiben konnte.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Grenze, an der dieser Slice haltmacht: für die **Masse** gibt es kein trennscharfes Kriterium, also
baut er keinen Wächter über sie — §1 *Drei Kandidaten, gemessen und verworfen*),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (die
Vorlage, aus der die emittierte Fassung entsteht und gegen die die hiesige gemessen wird),
[`AGENTS.md`](../../../../AGENTS.md) §3.8 und
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 (Hard Rules und
Adaptions-Block schreibt der Architect — dieser Slice fasst beide **nicht** an und gibt ab, was
dorthin gehört),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (jede Zusage dieses Plans nennt, was sie rot färbt, oder
sagt, dass nichts es tut),
[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
(Ausfüll-Templates werden referenziert und kopiert, nicht nachgebaut — der Anlege-Commit dieser
Datei hat das nicht getan, und die fehlende Pflicht-Sektion ist die Spur davon),
[`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar)
(`structure` liegt im Pin und ist nicht aktiviert — der einzige Wächter-Kandidat für die
**Gliederung**, seine Eignung ist ungeprüft),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(*„Gate-Anheben → Steering-Loop"* — falls der Kandidat trägt, ist seine Aktivierung ein
Steering-Loop und kein ADR),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das genau sie ausgibt; die Ziel-Werte in §2 sind
ausdrücklich **keine** Erwartungswerte über den Bestand),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung).

**Autor:** Planner. **Datum:** 2026-08-27.

---

## 1. Ziel

**Der Harness-Einstieg trägt die acht Abschnitte, die seine Pflichtgliederung vorsieht, und je
Werkzeug eine Zeile — die Grenzen eines Werkzeugs stehen im Kopf des Werkzeugs, nicht im Einstieg.**

### Der gemessene Anlass: dreißig Änderungen, kein neuer Abschnitt

`harness/README.md` entstand am 2026-06-13 im Bootstrap-Commit `d30db38` mit **2 058** Zeichen
(`git show d30db38:harness/README.md | wc -c`) und misst am 2026-08-28 **16 161**
(`wc -c < harness/README.md`) — fast das **Achtfache** über **34** Commits
(`git log --format=%H -- harness/README.md | wc -l`). **Beide Zahlen wandern mit der Datei und
sind keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); sie datieren den Anlass, sie messen ihn nicht ab. Was **nicht** wandert: in derselben
Zeit hat sich die Liste der Abschnitte **nicht um eine Zeile** bewegt —
`diff <(git show d30db38:harness/README.md | grep '^## ') <(grep '^## ' harness/README.md) | wc -l`
→ **0**. Jede Änderung seit dem Anlege-Commit ist in einen bestehenden Abschnitt gegangen, und die
meisten in denselben: `## Sensors (Feedback-Gates)` misst **14 083** Zeichen
(`awk '/^## Sensors/{f=1} /^## Traceability/{f=0} f' harness/README.md | wc -c`) — **87 %** der
Datei.

Die Ziel-Form ist kleiner und hat **mehr** Zeilen: die Vorlage misst **7 322** Zeichen auf **154**
Zeilen (`wc -l -c .harness/baseline/v5.12.0/templates/harness/README.template.md`), unsere Fassung
**16 161** auf **86** (`wc -l -c harness/README.md`). Der Unterschied liegt nicht in der Tabelle,
sondern in der Prosa daneben. Im Abschnitt `## Sensors` steht bei uns eine Tabelle von **1 874**
Zeichen neben **11 983** Zeichen Prosa, in der Vorlage **458** neben **1 158** — je ein Kommando
für beide Hälften:

```
sec() { awk '/^## Sensors/{f=1} /^## Traceability/{f=0} f' "$1"; }
vor=.harness/baseline/v5.12.0/templates/harness/README.template.md
tp() { awk '/^[[:space:]]*\|/{t+=length+1;next}{p+=length+1}END{print t,p}'; }
sec harness/README.md | tp        # -> 1874 11983   (Tabelle, Prosa)
sec "$vor"            | tp        # ->  458  1158
sec harness/README.md | grep -c '^| `make'   # -> 11   (Ziele in der Tabelle)
sec "$vor"            | grep -c '^| `make'   # ->  8
```

**Die Tabelle ist um Zeilen gewachsen, die Prosa um Absätze.** Die Tabelle trägt heute **11**
Ziele statt der **8** der Vorlage (die zwei letzten Zeilen des Blocks oben) und bleibt dabei die
Form, die sie war: eine Zeile, ein Werkzeug, ein Vertrag. Die Prosa ist auf das **Zehnfache**
gewachsen und hat dafür keine Struktur bekommen — sie hat **eine Zeile**:
`awk '{if(length>m)m=length}END{print m}' harness/README.md` →
**6 047** Zeichen, gegenüber **311** als längster Zeile der Vorlage (dasselbe Kommando über die
Vorlage). In diesem einen Absatz stehen **sieben** verschiedene `make`-Aufrufe
(`sed -n '70p' harness/README.md | grep -o 'make [a-z-]*' | sort -u | wc -l`): vier beschriebene
Nicht-Gate-Werkzeuge und drei Erwähnungen innerhalb der Beschreibung.

**Der Mechanismus ist das Anhängen.** Ein Werkzeug bekam eine Grenze, ein Sensor eine Ausnahme,
ein Lauf eine zweite Ausgangsform — und jedes Mal wurde der Satz an den Absatz gehängt, in dem das
Werkzeug schon vorkam, statt daneben gestellt oder ersetzt. Das ist keine Vermutung über die
Vergangenheit, sondern die Erklärung, die zu den zwei Messungen oben passt: Masse wächst, Struktur
nicht.

### Die fehlende Sektion ist kein zweiter Befund, sondern derselbe

Die Pflichtgliederung des Einstiegs steht im vendored Regelwerk und nennt **acht** Abschnitte
([`grundlagen-harness-dateien.md` §harness/README.md als Einstiegspunkt](../../../../.harness/baseline/v5.12.0/regelwerk/grundlagen-harness-dateien.md#harnessreadmemd-als-einstiegspunkt)).
Unsere Datei führt **sechs**; **zwei** fehlen, und sie sind verschiedener Art:
`## Safety and scope boundaries` ist ein **Ort für vorhandene Sätze**, `## Leseordnung` ist
**neuer Text** — die Baseline nennt sie *„die Menschen-Hälfte des Einstiegs"* und deckelt sie bei
*„drei bis fünf geordnete Zeiger"*.

```
for s in "Purpose" "Source precedence" "Guides" "Sensors" "Traceability" \
         "Safety and scope boundaries" "Minimal agent workflow" "Leseordnung"; do
  grep -q "^## $s" harness/README.md || echo "fehlt: $s"
done
```

→ zwei Zeilen Ausgabe. Dasselbe Kommando über
`.harness/baseline/v5.12.0/templates/harness/README.template.md` gibt **nichts** aus — die Vorlage
des gepinnten Stands trägt alle acht.

Der Abschnitt war **nie** da: `git log -S'Safety and scope boundaries' -- harness/README.md` ist
leer, und `git grep -c 'Safety and scope' -- '*.md' ':!.harness/baseline/**'` findet im lebenden
Bestand **keinen** Treffer (Exit 1). Die Datei wurde also nicht aus der Vorlage kopiert, sondern
nachgebaut — das ist die Klasse, die
[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
adressiert.

**`## Leseordnung` fehlt aus einem anderen Grund: den Abschnitt gibt es in der adoptierten
Fassung erst seit dem Sprung.** Er kam mit dem Baum, den
[slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) getauscht hat, und ist damit
**keine** Drift dieses Repos, sondern eine neue Pflicht. Der Nachweis steht neben der Pflicht
selbst: `diff <(git show <Tausch-Commit>^:.harness/baseline/v3.5.2/templates/harness/README.template.md | grep '^## ') <(grep '^## ' .harness/baseline/v5.12.0/templates/harness/README.template.md)`
→ genau eine Zeile `> ## Leseordnung`. Für die Arbeit dieses Slice ändert das nichts an der
Ziel-Form und alles an der Herkunft der zwei Punkte: einer ist Rückbau, einer ist Nachzug.

**Und die Aussagen, die dort stehen müssten, sind nicht verloren — sie stehen im falschen
Abschnitt.** Der `## Sensors`-Block trägt heute mindestens drei Sätze, die Reichweite abgrenzen
statt einen Gate zu beschreiben: dass ein grüner CI-Lauf keine Aussage über ungetestete Flächen
ist; dass der Dogfood flach ist und das Architektur-Gate hier einen leeren Prüfbereich hätte; dass
zwei Nicht-Gate-Läufe bewusst nicht in `make gates` stehen. Das sind *scope boundaries*. Sie sind
in den Sensors-Absatz gewandert, weil es den Abschnitt nicht gab, in den sie gehören — die
fehlende Sektion **ist** ein Teil der Masse im Nachbarabschnitt.

### Drei Kandidaten für eine bewachbare Eigenschaft — gemessen und verworfen

Der Auftrag war, zu prüfen, ob die **Masse** eine trennscharfe Eigenschaft hat, die ein Wächter
halten kann. Sie hat keine. Alle drei Kandidaten sind gemessen, keiner trägt:

- **(a) Eine Obergrenze für die Zeichenzahl einer Zeile.** Sie färbt legitime Fälle rot und
  übersieht den Befund. Über die **96** lebenden Markdown-Dateien — die Datei-Liste heißt unten
  `$md` — liegen bei einer Schranke von 600 Zeichen **151** Tabellenzeilen darüber und **19**
  Zeilen, die keine Tabellenzeile sind:

  ```
  md=$(git ls-files '*.md' ':!docs/reviews/**' ':!docs/plan/planning/done/**' \
                    ':!.harness/baseline/**' ':!**/*.template.md')
  echo "$md" | wc -l                                       # -> 96
  awk 'length>600 &&  /^[[:space:]]*\|/' $md | wc -l       # -> 151  (Tabellenzeilen)
  awk 'length>600 && !/^[[:space:]]*\|/' $md | wc -l       # ->  19
  ```

  Eine Markdown-Tabellenzeile lässt sich nicht umbrechen — die Schranke verlangte dort, den
  Vertrag zu kürzen, und würde abgeschaltet. Umgekehrt ist sie mit **einer Enter-Taste** erfüllt:
  der 6 047-Zeichen-Absatz unterschreitet jede Schranke, sobald ihn jemand umbricht, ohne dass
  sich ein Wort ändert. Dass das kein Gedankenspiel ist, misst dieselbe Klasse an einer
  umgebrochenen Datei — `AGENTS.md` hat als längste Zeile **716** Zeichen
  (`awk '{if(length>m)m=length}END{print m}' AGENTS.md`) und trägt trotzdem einen Prosa-Block von
  **1 276** Zeichen. Die umbruch-unabhängige Größe misst sie so (`blocks` heißt sie unten wieder):

  ````
  blocks() { awk 'function f(){if(n>0)printf "%d\t%s:%d\n",n,FILENAME,s;n=0}
       FNR==1{f();fence=0}
       /^```/{f();fence=!fence;next}
       fence{next}
       /^[[:space:]]*$/{f();next}
       /^[[:space:]]*[|]/{f();next}
       /^[[:space:]]*([-*+]|[0-9]+\.)[[:space:]]/{f();s=FNR;n=length($0);next}
       {if(n==0)s=FNR; n+=length($0)+1}
       END{f()}' "$@"; }
  blocks AGENTS.md        | sort -rn | head -1    # -> 1276  AGENTS.md:142
  blocks harness/README.md | sort -rn | head -1   # -> 4594  harness/README.md:70
  ````

  Sie **misst** also, was die Zeilen-Schranke verfehlt — nur ist auch sie mit einer Leerzeile in
  der Mitte erfüllt, ohne dass ein Gedanke einen Ort bekommt. Ein Wächter darüber sagte
  *„eine Aussage hat einen eigenen Absatz"* zu und prüfte *„kein Block über N Zeichen"*: eine
  Zusage weiter als ihre Abdeckung ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- **(b) Das Verhältnis unserer Fassung zu ihrer Vorlage.** Nicht trennscharf, und der
  Gegenbeleg ist der wichtigste Konventionsspeicher selbst: `harness/conventions.md` misst am
  2026-08-28 **148 721** Zeichen gegen **8 785** der Vorlage
  (`wc -c harness/conventions.md .harness/baseline/v5.12.0/templates/harness/conventions.template.md`)
  — **mehr als das Sechzehnfache**, und zwar **konstruktionsbedingt**: die Vorlage liefert den Adaptions-Block
  leer, und jede Adaption ist ein Eintrag. **Der Faktor wandert mit jedem Eintrag und ist kein
  Erwartungswert** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2); was das Kriterium verwirft, ist die Bauart, nicht die Ziffer — der Nenner ist
  `grep -c '^### MR-' harness/conventions.md`.
  Ein Kriterium, das das Abweichungs-Register für seine Abweichungen rot färbt, wird abgeschaltet.
  Dazu kommt: Artefakte ohne Vorlage — die Nutzer-Doku unter `docs/user/` — haben gar keinen
  Nenner.
- **(c) Eine Aussage über Dopplung zwischen zwei Dateien.** Messbar, aber sie trifft eine
  **gewollte** Dopplung. `AGENTS.md` §4 und `harness/README.md` §Sensors nennen heute dieselben
  **11** Ziele, und zwar **alle**:

  ```
  a=$(awk '/^## 4\./{f=1} /^## 5\./{f=0} f' AGENTS.md | grep -o 'make [a-z-]*' | sort -u)
  b=$(awk '/^## Sensors/{f=1} /^## Traceability/{f=0} f' harness/README.md | grep -o 'make [a-z-]*' | sort -u)
  comm -12 <(echo "$a") <(echo "$b") | wc -l
  ```

  → **11** bei **11** Zielen in §4. Das ist keine Drift, sondern die Arbeitsteilung, die
  [`AGENTS.md`](../../../../AGENTS.md) §4 in seinem Schlusssatz selbst ausspricht: die Liste dort,
  die Beschreibung hier, *„eine Aussage hat einen Ort"*. Ein Wächter über Dopplung färbte genau
  diesen Satz rot.

**Also kein Wächter über die Masse, und kein erfundener Gate**
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

### Was bewacht werden kann, ist die Gliederung — der Kandidat ist ungeprüft

Trennscharf ist die **Pflichtgliederung**, und zwar aus einem Grund, den keiner der drei
Kandidaten hat: die Liste der sieben Abschnitte ist **nicht erfunden**, sie steht kanonisch im
Regelwerk. Sie ist umbruch-fest, sie kennt keinen legitimen Gegenfall, und sie färbt heute genau
eine Sache rot — die fehlende Sektion. Was sie **nicht** kann: die Masse begrenzen. Ein Abschnitt
mehr macht keinen Absatz kürzer.

Der Wächter-Kandidat dafür ist `structure` aus dem d-check-Pin: verfügbar seit
[`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar),
nicht aktiviert (`grep -c 'structure' .d-check.yml` → **0**, Exit 1), und seine Eignung ist an
diesem Repo **nicht erprobt** — das sagt
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
über denselben Kandidaten ausdrücklich. **Dieser Slice aktiviert ihn nicht und sagt ihn nicht zu.**
Er stellt die Gliederung her und schreibt in §7 auf, ob `structure` sie halten könnte — geprüft an
einem Trockenlauf, nicht an einer Modul-Beschreibung. Trägt er, ist seine Aktivierung ein eigener
Schnitt und ein Steering-Loop nach
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids),
kein ADR.

**Die Abgrenzung zu
[`MR-026`](../../../../harness/conventions.md#mr-026--die-hard-rule-nummer-ist-eine-adresse-keine-baseline-entsprechung),
weil sie naheliegt und nicht gilt:** Jener Eintrag sagt, dass die **Nummer** einer Hard Rule in
`AGENTS.md` §3 keine Entsprechung in der Vorlage zusagt. Hier geht es nicht um Nummern und nicht um
§3, sondern um den **Satz der Abschnitte** einer anderen Datei, den das Regelwerk als
Pflichtgliederung führt. Der Einstieg darf Abschnitte anders benennen und ergänzen — er darf keinen
der sieben weglassen.

### Regel für Neues oder Migration: eine Migration, über genau ein Artefakt

**Migration.** Eine Regel, die nur Künftiges bindet, ließe 16 161 Zeichen stehen — und diese
Zeichen werden nicht einmal bezahlt, sondern bei **jedem** Lauf: `harness/README.md` ist Schritt 1
des Minimal Agent Workflow in [`AGENTS.md`](../../../../AGENTS.md) §6 **und** in der Datei selbst.
Dazu kommt der Beleg aus dem Anlass: die Datei ist unter allen Regeln gewachsen, die dieses Repo
sich bisher gegeben hat.

**Über genau ein Artefakt, und nicht mehr.** Ein Bestands-Auftrag über die lebende Doku wäre
dauerhaft rot: **613** Prosa-Blöcke über 600 Zeichen in **69** der 96 lebenden Dateien — mit
`blocks` und `$md` aus §1 (a):

```
blocks $md | awk '$1>600' | wc -l                                  # -> 613
blocks $md | awk '$1>600' | cut -f2 | cut -d: -f1 | sort -u | wc -l  # ->  69
```

Ein Maßstab darüber entwertete die Setzung, statt sie zu tragen
— dieselbe Begründung trägt den Cutoff in
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
in
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
und in [`AGENTS.md`](../../../../AGENTS.md) §3.7.

**Die Regel-Hälfte gehört nicht in diesen Slice, sondern in den Adaptions-Block** — und den
schreibt der Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8,
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1). Dieser Slice
bewegt das Artefakt und liefert die Messreihe; er formuliert keine Setzung.

### Was dieser Slice abgibt und warum er es nicht selbst schreibt

Derselbe Befund hat einen zweiten Gegenstand, und er ist **nicht** derselbe Slice.
`harness/conventions.md` misst am 2026-08-28 **1 635** Zeilen und **132 869** Zeichen
(`wc -l -c harness/conventions.md`) bei **29** Einträgen
(`grep -c '^### MR-' harness/conventions.md`). **Beide Zahlen wandern mit dem Register und sind
keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Bezugsmenge dieser Abgabe ist der Eintrags-Zähler, nicht sein heutiger Wert.
Ihre Masse ist **nicht** ein Absatz, sondern eine
Eintrags-Zahl — und dafür gibt es eine Form, die nicht erfunden werden muss: das Regelwerk stellt
sie ausdrücklich frei (*„ihre Form (Einzeldatei vs. Verzeichnis, ADR-artig vs. Prosa) ist Wahl"*,
[`grundlagen-harness-dateien.md` §harness/conventions.md als Konventionsspeicher](../../../../.harness/baseline/v5.12.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher)),
**nennt aber am gepinnten Stand die Verzeichnis-Form als Default** — *„Ein Eintrag je Datei …
Der **Default** ist die Verzeichnis-Form, weil sie mit der Adaptions-Zahl nicht mitwächst"*,
mit `harness/conventions/MR-<NNN>-<titel>.md` als Ort und `conventions/done/` als Ziel der
aufgelösten Einträge. Die Freistellung trägt also weiter, und der Default zeigt in die
Gegenrichtung unserer Einzeldatei —
und das Nachbar-Repo d-check fährt sie: Index plus ein Verzeichnis mit einer Datei je Eintrag,
aufgelöste Einträge in einem eigenen `done/`. Gegen einen lokalen Klon gemessen (2026-08-27,
Wurzel in `$DC`):

```
wc -l -c "$DC/harness/conventions.md"          # -> 178   23917
ls "$DC/harness/conventions"/*.md | wc -l      # -> 26
ls "$DC/harness/conventions/done" | wc -l      # -> 23
```

**Vier Gründe, warum das hier nicht mitgeschnitten wird — der erste ist der bindende:**

1. **Der Adaptions-Block gehört dem Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.8,
   [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1). Ein Umzug
   schreibt jeden Eintrag an einen neuen Ort und den Index neu; das ist Schreiben, nicht Lesen.
2. **Anderer Gegenstand, andere Ziel-Form.** Dort ist die Einheit der **Eintrag** und die Lösung
   ein **Behälter**; hier ist die Einheit der **Absatz**, und für ihn gibt es keinen Behälter.
   Ein Slice, der beides trüge, hätte zwei Ziel-Formen und mehr als drei DoD-Punkte.
3. **Der Umzug hat einen Wächter, dieser Slice hat keinen** — und das ist der Unterschied, der
   ihn billig macht. Wie viele Verweise auf `conventions.md#mr-…` zeigen, sagt
   `git grep -oE 'conventions\.md#mr-[a-z0-9-]+' -- '*.md' | wc -l`, und wie viele davon in
   lebenden Artefakten stehen, dieselbe Suche mit
   `':!docs/reviews/**' ':!docs/plan/planning/done/**' ':!.harness/baseline/**'`. **Beide Zahlen
   stehen hier nicht:** sie wandern mit **jeder** Datei des Repos, nicht mit dem Gegenstand, und
   wären damit keine Erwartungswerte
   ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 2) — die Bezugsmenge der Anker liefert der Nenner oben
   (`grep -c '^### MR-' harness/conventions.md`), je Eintrag einer. **Tragend ist die eine Zahl,
   die sich nicht bewegen darf:** außerhalb von Markdown liegen **0** Verweise (dieselbe Suche mit
   `-- ':!*.md'`) — der Umzug bleibt damit eine reine Markdown-Bewegung.
   Jeder einzelne Verweis wird von `make docs-check` gehalten;
   d-check löst das im eigenen Repo mit einem expliziten `<a id>` je Index-Zeile. **Ob unser Pin
   einen HTML-Anker als Link-Ziel auflöst, ist hier ungeprüft** — und das ist eine Messung, keine
   Vorsicht: `git grep -l '<a id=' -- '*.md' ':!docs/plan/planning/open/slice-114-*.md'` findet
   **7** Dateien — **ohne** den Ausschluss **8**, weil diese Datei ihr eigenes Suchmuster
   enthält und sich selbst findet. Der einzige dieser Anker,
   auf den überhaupt verlinkt wird (`werkzeug-wahl`), liegt in der vendored Baseline, deren Links
   der Doku-Gate gar nicht liest (`scan.ignore` in [`.d-check.yml`](../../../../.d-check.yml)).
   Der Umzug hätte damit eine Vorfrage, die vor ihm zu beantworten ist — mit einem Trockenlauf,
   nicht mit einer Modul-Beschreibung.
4. **Die Vorlage für einen Einzeleintrag liegt seit dem Sprung vendored vor — der vierte Grund
   ist damit nicht mehr die fehlende Vorlage, sondern die Reichweite des Umzugs.** Der gepinnte
   Baum trägt sie: `ls .harness/baseline/v5.12.0/templates/harness/conventions/`
   → `MR-NNN-titel.template.md`. Ein `cp` je Eintrag ist damit regelkonform
   ([`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)),
   und der Umzug ist herstellbar, statt an der Vorlage zu scheitern. Was bleibt, ist sein Umfang:
   je Eintrag eine Datei, jeder Eintrag mit den sechs Pflichtfeldern der Vorlage, und der Index
   trägt danach Zeilen statt Rümpfe — eine eigene Sitzung mit eigenem Gegenstand, nicht ein
   Nebenprodukt dieses Slice.

**Damit ist die Abgabe präzise:** an den Architect geht die **Entscheidung**, ob der
Adaptions-Block ein Verzeichnis wird — mit den Zahlen oben, dem Anker-Mechanismus und dem Befund,
dass die Vorlage dafür vendored vorliegt und der Default des gepinnten Stands in dieselbe Richtung
zeigt. Ein repo-internes CR-Format gibt
es dafür nicht und soll es nicht geben:
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
adoptiert wörtlich *„kein `CR-*`-ID-Schema, keine eigene Datei, kein Gate"* und regelt den
**Lastenheft**-Vorgang, nicht die Übergabe zwischen zwei Rollen. Die Form, die
[`AGENTS.md`](../../../../AGENTS.md) §3.8 dafür selbst benennt, ist das **Übergabe-Artefakt**:
*„die Anweisung ist die Quelle; was der laufende Kontext liefert, ist ein Übergabe-Artefakt, und
der Norm-Text entsteht im Architect-Lauf."* Dieser Abschnitt **ist** dieses Artefakt.

### Was die Re-Baseline an diesem Slice bewegt hat

**Die Ziel-Form ist gewachsen, der Gegenstand nicht.** Der Abschnitts-Satz der Vorlage
unterscheidet sich zwischen dem abgelösten und dem gepinnten Stand um **eine hinzugefügte** Zeile
(`## Leseordnung`) und sonst um nichts — messbar ohne zweiten Baum, weil die alte Seite als
Tree-Operand in `git` liegt (dieselbe Zugriffsform, die
[slice-083](../next/slice-083-form-vergleich-pflichtfelder.md) für den ganzen Form-Vergleich nutzt):

```
diff <(git show <Tausch-Commit>^:.harness/baseline/v3.5.2/templates/harness/README.template.md | grep '^## ') \
     <(grep '^## ' .harness/baseline/v5.12.0/templates/harness/README.template.md)
```

→ eine Zeile `> ## Leseordnung`, Exit 1. Die sieben bisherigen Pflicht-Abschnitte stehen
unverändert; keiner ist umbenannt, keiner entfallen. Die Arbeit dieses Slice wächst damit um
**einen** Abschnitt und keine Zeile Umbau — im Unterschied zur Verzeichnis-Frage aus dem vorigen
Abschnitt, deren Vorlage mit demselben Sprung überhaupt erst vendored vorliegt.

## 2. Definition of Done

Drei Liefer-Punkte
([`modul-05-planning-harness.md` §Ziel-Form: Slice](../../../../.harness/baseline/v5.12.0/regelwerk/modul-05-planning-harness.md#ziel-form-slice):
*„≤ 3 Liefer-Punkte"*). Der gepinnte Stand zählt sie selbst ab — *„gezählt wird nur, was mit dem
Umfang wächst … Nicht gezählt: Gate-Läufe, Closure-Notiz, Register, Risiko-Ausgänge"* —, und damit
ist die Trennung, die dieser Plan unten als *Standard-Punkte der Vorlage* führt, die Regel selbst
und keine Auslegung mehr. Wo kein Kommando einen Punkt rot färbt, steht das dabei, statt sich
hinter einem anderen zu verstecken.

- [ ] **(1) Die Gliederung ist vollständig, und die Sätze, die in den neuen Abschnitt gehören,
      sind dorthin gezogen — nicht dupliziert.** Das Kommando aus §1 über die **acht**
      Pflicht-Abschnitte gibt **nichts** mehr aus (heute: zwei Zeilen). Die zwei fehlenden
      Abschnitte entstehen auf verschiedenen Wegen, und der Nachweis unterscheidet sie: Jeder
      Satz, der nach `## Safety and scope boundaries` wandert, verschwindet an seiner alten
      Stelle — Nachweis ist ein `git diff`, in dem jede hinzugefügte Zeile dieses Abschnitts eine
      gelöschte Zeile im Sensors-Block hat. `## Leseordnung` ist dagegen **neuer** Text und hat
      keine Herkunft im Bestand; für ihn gilt der Deckel der Vorlage — *„Drei bis fünf geordnete
      Zeiger genügen; eine Leseordnung, die alles nennt, ist keine"*. **Rot färbt nur die halbe
      Zusage:** dass beide Abschnitte existieren, sagt das Kommando; dass beim einen nichts
      danebengestellt statt gezogen wurde und der andere keine Vollaufzählung ist, trägt das
      Review.
- [ ] **(2) Je Werkzeug eine Zeile im Einstieg, die Grenzen im Kopf des Werkzeugs — und der
      Einstieg misst danach in der Größenordnung seiner Vorlage.** Die Prosa des Abschnitts
      `## Sensors` misst höchstens **2 500** Zeichen (heute **11 983**, Vorlage **1 158** — die
      zwei Kommandos stehen in §1), und die längste Zeile der Datei liegt unter **800** Zeichen
      (heute **6 047**, Vorlage **311**). **Beide Werte sind Abnahme-Kriterien dieses einen Laufs
      und ausdrücklich keine Erwartungswerte über den Bestand**
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2): sie wandern mit jedem neuen Werkzeug mit, und kein Sensor hält sie nach dem
      Slice. Der Aufschlag über die Vorlage ist gewollt — die Tabelle führt **11** Ziele statt
      **8**. **Und kein Wert wird durch Umbrechen erfüllt:** DoD (1) und die Zuordnung aus §3
      verlangen den **Ort**, nicht den Zeilenumbruch; ein umgebrochener Absatz ohne Adressat
      erfüllt (2) und verfehlt (1).
- [ ] **(3) Der Lauf berührt kein Artefakt einer anderen schreibenden Rolle.**
      `git log --format=%H <erster>..<letzter> -- AGENTS.md harness/conventions.md | wc -l` → **0**
      über die Commits dieses Slice. Was an eine der zwei Stellen gehörte — die Setzung über die
      Bauart und die Entscheidung über den Adaptions-Block —, verlässt den Slice als
      Übergabe-Artefakt (§1 und §7), nicht als Norm-Text
      ([`AGENTS.md`](../../../../AGENTS.md) §3.8,
      [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1).

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/README.md`](../../../../harness/README.md) | update | der Gegenstand: fehlender Pflicht-Abschnitt ergänzt, Werkzeug-Prosa auf je eine Zeile gezogen, Grenzen an ihre Werkzeuge abgegeben |
| [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) | update | Ziel für die Grenzen des Mutations-Sensors (Isolation, Residuen, Erwartungs-Zeile). Der Kopf ist die Stelle, die `make comment-claims` liest — anders als jede Markdown-Datei |
| [`harness/tools/smoke.sh`](../../../../harness/tools/smoke.sh) | update | dasselbe für den Tier-2-Emit-Smoke |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh), [`harness/tools/full-smoke-ausgang.sh`](../../../../harness/tools/full-smoke-ausgang.sh) | **update nur, soweit slice-106 sie freigibt** | der Ausgangs-Absatz im Einstieg ist zugleich der, den slice-106 gerade neu schreibt (§6). Sein Kopf trägt die Formen bereits — hier ist die Bewegung eine **Verkürzung im Einstieg**, keine zweite Fassung im Skript |
| [`harness/tools/hook-overhead.sh`](../../../../harness/tools/hook-overhead.sh) | **unverändert** | sein Kopf trägt den Mess-Stand schon; der Einstieg verweist bereits dorthin. Was daran fehlt, ist Gegenstand von slice-102, nicht von diesem Slice |
| [`AGENTS.md`](../../../../AGENTS.md) | **unverändert** | §3 gehört dem Architect ([`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1); §4 ist am 2026-08-27 zurückgeführt worden — von **7 604** auf **2 667** Zeichen (`git show c5d9a47^:AGENTS.md \| awk '/^## 4\./{f=1} /^## 5\./{f=0} f' \| wc -c` gegen dasselbe `awk` über die heutige Datei), und die verbliebene Ziel-Liste ist die gewollte Dopplung aus §1 (c) |
| [`harness/conventions.md`](../../../../harness/conventions.md) | **unverändert** | Adaptions-Block, Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Die Setzung über die Bauart **und** die Verzeichnis-Entscheidung gehen als Übergabe-Artefakt hinaus (§1) |
| [`.d-check.yml`](../../../../.d-check.yml) | **unverändert** | `structure` wird hier **nicht** aktiviert; ein Trockenlauf darüber ist Erkenntnis für §7, seine Aktivierung ein eigener Schnitt und ein Steering-Loop ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)) |
| [`internal/`](../../../../internal) und die emittierte Ebene | **unverändert** | der Adopter bekommt die Vorlage, nicht diese Datei (Kopfzeile *Ebene*). Ob ein emittiertes Repo eine Bauart-Regel bekommt, ist ein eigener Schnitt mit eigener Abwägung |
| [`docs/plan/adr`](../../adr) | **unverändert** | der Slice senkt keine Schwelle: er stellt eine Pflichtgliederung her und verschiebt Prosa. Ergibt der Lauf, dass ein Satz nur unter einer **gelockerten** Zusage an sein neues Ziel passt, greift die Rückführung aus §4 |
| [`docs/reviews`](../../../reviews), [`docs/plan/planning/done`](../done) | **unverändert** | Zeitdokumente ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §Geltungsbereich) |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

**Die Zuordnung gehört an den Anfang des Laufs, nicht an sein Ende.** Vor der ersten Änderung
entsteht die Liste *Aussage → Ziel* über den Sensors-Block: je Satz entweder eine Tabellenzeile,
der neue `## Safety and scope boundaries`-Abschnitt, der Kopf eines Werkzeugs — oder die
ausdrückliche Feststellung, dass er entfällt, mit Grund. Ein Satz, der während des Laufs still
verschwindet, macht aus der Verschiebung eine Löschung, und niemand sieht später den Unterschied.

**Vor dem Verschieben zu entscheiden:** Ein Satz, der in einen Skript-Kopf wandert, wird damit
Gegenstand von `make comment-claims` — er muss seinen Sensor nennen, wenn er eine Abdeckung
behauptet. Was diese Prüfung nicht besteht, gehört **nicht** in den Kopf, sondern in die Zeile der
Tabelle oder in den Safety-Abschnitt. Der Prüfbereich ist gemessen: `harness/tools/*.sh` ist eines
seiner vier Muster (**18** Dateien, `git ls-files 'harness/tools/*.sh' | wc -l`), Markdown ist
dauerhaft draußen (`git ls-files 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' 'harness/tools/*.sh' '.claude/hooks/*.sh' | grep -c '\.md$'`
→ **0**, Exit 1).

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): wenn slice-106 `in-progress/` verlassen hat.** Die
Bedingung ist beobachtbar ohne Rückfrage — `ls docs/plan/planning/in-progress/` nennt seine Datei
nicht mehr. Sie ist keine Vorsichtsmaßnahme, sondern eine gemessene Kollision: slice-106 führt
`harness/README.md` in seiner eigenen Plan-Tabelle und schreibt genau den Absatz um, der hier der
größte ist — *„der Satz wird gezogen, nicht danebengestellt"*. Zwei Läufe an derselben Zeile
erzeugen einen Konflikt, den keiner von beiden sieht, bis er entsteht.

**Nicht Bedingung:** die Re-Baseline. Der Abschnitts-Satz der Ziel-Fassung unterscheidet sich um
eine hinzugefügte Zeile (§1 letzter Abschnitt) — dieser Slice arbeitet ihr vor.

Die zwei Rückführungen, vorab benannt:

- **`in-progress` → `next` (zu groß):** wenn die Zuordnungs-Liste aus §3 ergibt, dass die Sätze
  über die Nicht-Gate-Werkzeuge nicht in Skript-Köpfe passen, sondern eine eigene Ziel-Form
  brauchen (eine Werkzeug-Seite unter `docs/`). Dann sind es zwei Slices: einer für die
  Gliederung, einer für den Behälter — und der zweite ist derselbe Gegenstand wie die abgegebene
  Verzeichnis-Frage, nur für ein anderes Artefakt.
- **`in-progress` → `open` (blockiert):** wenn sich beim Verschieben zeigt, dass ein Satz nur
  deshalb im Einstieg steht, weil das Werkzeug ihn nicht halten kann — dann ist der Befund am
  Werkzeug, nicht am Text, und der Slice wartet auf dessen eigenen Schnitt, statt die Aussage
  abzuschwächen, damit sie an ihr neues Ziel passt.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt; die Zuordnungs-Liste aus §3 vollständig abgearbeitet, jeder Satz mit seinem
Ziel oder seinem Entfall-Grund; Review konform (Modul 10); Verifikation bestätigt (Modul 11);
`make gates` grün; `git mv` nach `done/` als eigener Move-Commit; Closure-Notiz mit
Steering-Loop-Eintrag in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte
Spec-Lücke).

**Ausdrücklich nicht Teil des Closure-Triggers: dass die Masse dauerhaft unten bleibt.** Kein
Kommando hält die Werte aus DoD (2) nach dem Move — das ist der Befund aus §1 und keine Lücke
dieses Slice. Was ihn tragen könnte, ist die abgegebene Setzung, und die entsteht in einem
anderen Lauf.

## 6. Risiken und offene Punkte

- **Der größte Absatz gehört gerade einem anderen Lauf.** slice-106 schreibt an derselben Zeile
  und an `harness/tools/full-smoke*.sh`. §4 macht daraus eine Trigger-Bedingung; wer sie
  übergeht, produziert einen Konflikt in einer Datei, die jeder Lauf liest.
- **Verschieben kann heimlich löschen.** Ein Satz, der von 6 047 Zeichen auf eine Tabellenzeile
  schrumpft, verliert Inhalt — die Frage ist nur, ob absichtlich. Die Zuordnungs-Liste aus §3 ist
  die einzige Stelle, an der das sichtbar wird; sie ersetzt kein Review, sie ermöglicht es.
- **Ein Skript-Kopf ist kein Ablageort für alles.** `make comment-claims` prüft dort die
  **Existenz** eines genannten Sensors, nicht die Richtigkeit der Aussage
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6 nennt genau diese Grenze). Ein Satz, der im Einstieg
  falsch war, ist im Kopf des Werkzeugs nicht richtiger — nur besser platziert.
- **Die Rückführung hält nichts fest.** Die Datei ist unter allen bisherigen Regeln um das
  Achtfache gewachsen; nichts an diesem Slice hindert den nächsten Anhang. Das ist der Grund
  für die Abgabe aus §1 und gehört in die Closure-Notiz, statt als gelöst zu gelten.
- **`structure` könnte die Gliederung nicht halten.** Der Trockenlauf ist Teil des Laufs, sein
  Ergebnis gehört nach §7 — auch und gerade, wenn es negativ ist. Ein negatives Ergebnis ist ein
  Befund über den Kandidaten, keine Aufforderung, einen eigenen Prüfer zu bauen; das wäre ein
  eigener Schnitt mit eigener Abwägung.
- **`make gates` deckt den Gegenstand nur formal.** Der Doku-Gate prüft Kennungen, Anker und
  Pfade; ein Einstieg, dessen Sätze am falschen Ort stehen, ist grün. Das ist keine Lücke dieses
  Slice, sondern die Grenze der Ebene, auf der er arbeitet.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. Drei Posten sind vorgemerkt: das Ergebnis des
`structure`-Trockenlaufs, die Zuordnungs-Liste aus §3 in ihrer abgearbeiteten Form, und die zwei
Übergaben an den Architect aus §1. -->

## 8. Sub-Area-Modus-Begründung

**Status:** Pflicht-Sektion bei mindestens einer berührten Sub-Area
in BF oder Hybrid. Bei reinem GF genügt der Hinweis
*"alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked
Mini-Example)"*. Optional bei reinem Refactor ohne neue
Sub-Area-Berührung. Die vier Pflichtkriterien (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand)
stehen in
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Worked Mini-Example](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#worked-mini-example-bootstrap-modus-pro-sub-area-für-einen-slice-begründen).

**Zwei Sub-Areas, zwei Blöcke** — die zweite steht bereits in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md) und wird hier nicht neu erfunden.
Beide sind GF.

### Sub-Area: Harness-Einstieg (`harness/README.md`)

Alle drei Inklusions-Achsen erfüllt: eine eigene Strukturregel ist plausibel formulierbar (die
abgegebene Setzung über die Bauart, Achse 1); Doku-Aussage und Werkzeug-Bestand sind als Paar
abgleichbar, ohne eine Nachbar-Sektion mitzuziehen (die Sensors-Tabelle gegen die realen
`make`-Ziele, Achse 2); und die Datei-Familie ist eigen (`harness/*.md`, Achse 3).

- **Modus:** GF. Die Datei ist in diesem Repo entstanden (Anlege-Commit `d30db38`, §1); es gibt
  keinen vorgefundenen Fremd-Bestand, gegen den zu inventarisieren wäre.
- **Konventionen-Dichte:** hoch, aber ungleich verteilt — der Gegenstand ist die Konvention
  selbst. Die Gliederung ist im vendored Regelwerk gesetzt, die **Masse** in keiner Regel; genau
  diese Lücke ist der Befund.
- **Phase-Reife:** Phase 5 (Betrieb). Die Datei wird von jedem Lauf als Schritt 1 gelesen und ist
  über dreißig Commits gewachsen (§1). Was fehlt, ist nicht Reife, sondern der Rückweg von der
  Ziel-Form in das Artefakt.
- **Evidenz-/Diskrepanz-Risiko:** niedrig für die Gliederung (ein Kommando entscheidet sie),
  mittel für die Verschiebung — welcher Satz wohin gehört, ist ein Urteil, und §3 macht es
  auflistbar statt beweisbar.
- **Reconciliation-Aufwand:** gering. Auf die Abschnitte dieser Datei zeigen Anker aus anderen
  Artefakten; wer einen Abschnitt **ergänzt**, bricht keinen davon, und `make docs-check` fängt
  jeden, der doch bricht. Graduation-Trigger entfällt (bereits GF).

### Sub-Area: `harness/tools/`

Bereits deklariert (Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md): *„adoptierte Harness-Mechanik"*),
berührt als **Ziel** der verschobenen Grenzen — nicht in ihrer Mechanik.

- **Modus:** GF, unverändert gegenüber der Deklaration.
- **Konventionen-Dichte:** hoch — die Köpfe dieser Skripte sind der einzige Ablageort im Spiel,
  über den ein Gate läuft (`make comment-claims`, vier Muster, §3).
- **Phase-Reife:** Phase 5. Die Skripte laufen in `make gates`, in CI und in der Wellen-Closure.
- **Evidenz-/Diskrepanz-Risiko:** niedrig — geändert werden Köpfe, keine Rezepte; ein
  Kopf-Kommentar, der eine Abdeckung behauptet, wird von `make comment-claims` gegen die Existenz
  seines Sensors gehalten.
- **Reconciliation-Aufwand:** gering, mit einer benannten Ausnahme: `full-smoke*.sh` liegt bis zum
  Abschluss von slice-106 in fremder Hand (§4).
