# ADR-0039: Die eingefrorene Adresse in den vendored Baum bekommt ein baum-weites Referenz-Ventil, und der Breiten-Wächter misst gegen eine deklarierte Zahl

**Status:** Proposed

**Datum:** 2026-09-07

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) (ihre zweite Architect-Folgepflicht
verlangt genau diese Entscheidung),
[ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) (Festlegung 2 trägt den
Adress-Nachzug im lebenden Bestand; Festlegung 5 hat eine Ausnahme für Ziele **unter** dem
Baseline-Verzeichnis geprüft und verworfen, als der Bestand bei einer Adresse lag — diese
Entscheidung hält jene Prüfung gegen einen um zwei Größenordnungen gewachsenen Bestand),
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) (Folgepflicht 2 stellt den
Breiten-Wächter, dessen Maßstab Festlegung 2 unten neu fasst),
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
[ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md),
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(die vier bestehenden `ignore-refs`-Paare; jedes extensional geschlossen, jedes mit der Klausel,
dass ein weiteres Paar eine eigene ADR braucht — **diese** ist sie),
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) (die eine Datei-Ausnahme und
ihr Argument, dass ein unbehebbarer Befund dazu erzieht, Rot zu überlesen),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Form jedes Belegs in diesem Dokument),
[`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(Setzung 4 — ein Tag zur Zeit),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl neben ihrem Kommando),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Baseline-Aussage nennt ihren Tag),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie entscheidet über den Prüfumfang eines Gates und
über den Maßstab eines Wächters, nicht über den Inhalt eines Spec-Dokuments.

**Kopplung:** [`.d-check.yml`](../../../.d-check.yml) bekommt drei Einträge unter dem Top-Level-
Schlüssel `ignore-refs`, und `test/ignore-refs-restbreite.bats` bekommt einen neuen Maßstab. Beide
sind Implementer-Artefakte; diese Entscheidung ist das Constraint, nicht der Patch.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

Der Baum-Tausch `v6.0.0` → `v6.5.0` hat den vendored Pfad bewegt. Der lebende Bestand ist
nachgezogen ([ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 2). Was
bleibt, sind Adressen in Artefakten, die niemand mehr anfassen darf.

### Der Bestand — 36 Adressen, 16 Dateien, drei Bäume

```sh
PS=( 'docs/reviews/**' 'docs/plan/planning/done/**' 'docs/plan/planning/observations/**' )
git grep -oE '\]\([^)]*\.harness/baseline/v6\.0\.0/' -- "${PS[@]}" | wc -l   # 36 Adressen
git grep -lE '\]\([^)]*\.harness/baseline/v6\.0\.0/' -- "${PS[@]}" | wc -l   # 16 Dateien
```

**Keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die 36 verteilen sich auf 32 in `docs/reviews/`, 3 in einem geschlossenen Slice unter
`docs/plan/planning/done/` und 1 in einer `observation.md` des Beobachtungs-Registers — dieselbe
Zahl meldet `make docs-check` als `target-missing`.

**Alle drei Bäume frieren ein, und die Ziel-Fassung nennt sie namentlich.** `v6.5.0`,
`grundlagen-harness-dateien.md`, §harness/README.md als Einstiegspunkt: *„Einfrierend sind die
**Zeitdokumente** — Review-Report, Closure-Notiz, Archiv-Stub, `Accepted`-ADR, geschlossener
Slice"*. Für die `observation.md` sagt es die Vorlage
`v6.5.0` · `templates/docs/plan/planning/observation.template.md` in ihrem Bedienhinweis:
*„observation.md          unveraenderlich ab Anlage"*. Keine der 36 ist reparierbar.

### Warum sie überhaupt entstehen durften — eine Lücke in §3.11

[`AGENTS.md`](../../../AGENTS.md) §3.11 verlangt die Kennung statt der Adresse für alles, *was der
Prozess bewegt*, und nimmt im selben Absatz aus: *„ein Verzeichnis, ein Glob, eine stehende Ablage
und eine Datei, die ihren Lifecycle bereits verlassen hat, sind ortsfest und bleiben als Pfad
zulässig."* Der vendored Baum **ist** ein Verzeichnis. Nach dem Wortlaut der Hard Rule war jede der
36 Adressen zulässig, als sie geschrieben wurde.

Die Ziel-Fassung führt genau diesen Fall als dritte Form derselben Regel — `v6.5.0`,
`grundlagen-harness-dateien.md`, §harness/README.md als Einstiegspunkt:

> Eine Stelle der vendored Baseline heißt Tag **und** Pfad in Inline-Code, nicht als Link. Der
> Vendoring-Pfad ist `<tag>`-gescopt, alte und neue Form liegen beim Bump also eine Weile
> nebeneinander — der Link bricht nicht sofort, sondern wenn das alte Verzeichnis fällt. Genau das
> macht ihn gefährlich: Er bricht nicht beim Bump, sondern später, in einem Artefakt, das niemand
> mehr anfasst.

Die Lücke ist damit nicht theoretisch: Sie ist der Erzeuger dieses Befund-Bestands, und sie
produziert ihn bei **jedem** Bump neu.

### Das Instrument liegt vor, und es ist feiner als das erbetene

Gemessen an dem in [`d-check.mk`](../../../d-check.mk) gepinnten Digest, über einem synthetischen
Sonden-Repo aus drei eingefrorenen Bäumen und einem lebenden Artefakt. Aktive Module `links` und
`anchors`; die Ausnahme trägt einen **Glob auf beiden Achsen**
(`in: "docs/reviews/**"` · `refs: [".harness/baseline/**"]` und je einer für die zwei anderen
Bäume):

| Sonde | Erwartung | Ergebnis |
|---|---|---|
| toter Link in den **gefallenen** Baum, eingefrorene Datei | stumm | **stumm** |
| toter **Anker** in den lebenden Baum, eingefrorene Datei | stumm | **stumm** — `anchors` honoriert denselben Schlüssel |
| toter Link **ohne** Baseline-Bezug, eingefrorene Datei | bleibt rot | **rot** (`target-missing`) |
| toter Link in den gefallenen Baum, **lebende** Datei | bleibt rot | **rot** (`target-missing`) |

Der Schlüssel ist **ziel-weit**: Er nimmt eine benannte Referenz aus, keine Datei. Genau darin
unterscheidet er sich von `exempt-paths`, das **datei-weit** wirkt — Zeile 3 der Tabelle ist der
Unterschied, und sie fällt zugunsten von `ignore-refs` aus. Die Aussage, dem Werkzeug fehle für
diesen Fall ein Knopf, ist damit widerlegt: Sie hat `links` und `anchors` an ihrer
Options-Sektion gemessen statt an dem querschnittlichen Schlüssel, den beide honorieren. Die
Config sagt es an Ort und Stelle selbst — [`.d-check.yml`](../../../.d-check.yml), Kopf des
Blocks: *„ignore-refs (referenz-weit, geteilt seit d-check 0.49.0 — links, anchors und codepaths
honorieren denselben Top-Level-Schluessel)"*.

### Was tatsächlich versperrt war: der repo-eigene Breiten-Wächter

`test/ignore-refs-restbreite.bats` läuft in `make gates` und hält jedes Paar gegen den Bestand.
Zwei Zähne, und beide fallen an der Glob-Form: `in:` muss eine **existierende Datei** sein (sonst
`Quelldatei fehlt`), und ein Paar darf **höchstens einen** Markdown-Link decken (sonst
`$n aufloesende Links, hoechstens 1 ist gedeckt`). Die exakte Paar-Form skaliert hier nicht:

```sh
PS=( 'docs/reviews/**' 'docs/plan/planning/done/**' 'docs/plan/planning/observations/**' )
R="$(git rev-parse --show-toplevel)"
git grep -lE '\]\([^)]*\.harness/baseline/v6\.0\.0/' -- "${PS[@]}" | while read -r f; do
  d="$(dirname "$f")"
  grep -oE '\]\([^)]*\.harness/baseline/v6\.0\.0/[^)]*\)' "$f" | sed 's/^](//; s/)$//' |
    while read -r t; do echo "$f|$(cd "$d" && realpath -m --relative-to="$R" "$t")"; done
done | sort | uniq -c | awk '{n++; if ($1>1) m++; if ($1>x) x=$1} END {print n, m, x}'
# -> 24 6 4   (eindeutige Paare · davon mit mehr als einem Link · Maximum)
```

**6 der 24 Paare überschreiten die Kappung.** Die Kappung ist eine Konstante ohne Gegenstand: Ihr
Zweck ist, dass eine Ausnahme nicht mehr stumm schaltet, als jemand entschieden hat — und dieser
Zweck hängt an der **Deklaration**, nicht an der Zahl 1. Die 1 war die Deklaration der vier
bestehenden Paare, in den Wächter geschrieben statt in den Eintrag.

### Die Koexistenz-Option steht heute nicht offen

```sh
ls -d .harness/baseline/*/ | wc -l                                          # 1 — genau ein Tag im Baum
grep -c 'mehr als ein <tag>-Verzeichnis' harness/tools/baseline-verify.sh   # 1 — die Sperre
```

`make baseline-verify` läuft **in** `make gates` und bricht fail-closed ab, sobald ein zweites
`<tag>`-Verzeichnis liegt — so verlangt es
[`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
Setzung 4, und der SessionStart-Injektor trägt dieselbe Sperre. Den alten Baum zurückzulegen
tauschte die Befunde gegen ein rotes `baseline-verify` — und wäre ohnehin ein Aufschub: Die
Adressen sterben an dem Tag, an dem der Baum fällt.

## Entscheidung

**Drei Festlegungen.**

**1. Die eingefrorene Adresse in den vendored Baum bekommt ein Referenz-Ventil in Glob-Form —
drei Einträge unter dem Top-Level-Schlüssel `ignore-refs`, einer je einfrierendem Baum, alle mit
demselben `refs`-Wert `.harness/baseline/**`.**

| `in:` | `refs:` |
|---|---|
| `docs/reviews/**` | `.harness/baseline/**` |
| `docs/plan/planning/done/**` | `.harness/baseline/**` |
| `docs/plan/planning/observations/**` | `.harness/baseline/**` |

**Der `refs`-Wert ist baum-weit und nicht tag-weit, und das ist die tragende Hälfte dieser
Festlegung.** Die Eigenschaft, die das Ventil rechtfertigt, ist nicht *„zeigt auf `v6.0.0`"*,
sondern *„zeigt in ein `<tag>`-gescoptes Vendoring-Verzeichnis aus einem Artefakt, das niemand
mehr anfassen darf"* — und die trifft die Adresse in den **lebenden** Baum genauso, nur später.
Ein tag-weiter Wert verlangte bei jedem Bump drei neue Einträge und damit eine neue ADR je Sprung:
genau die Runde je Mitglied, gegen die [`AGENTS.md`](../../../AGENTS.md) §3.11 geschrieben ist.

**2. Der Breiten-Wächter misst gegen eine je Eintrag deklarierte Zahl statt gegen die Konstante 1,
und er liest die Glob-Form auf beiden Achsen.** Vier Bedingungen, alle urteilsfrei:

- Jeder Eintrag deklariert am Ort seiner Definition, **wie viele** Markdown-Links er deckt.
- Ein Eintrag **ohne** Deklaration ist rot — sonst wäre eine unbezifferte Ausnahme still grün.
- Deckt er **mehr**, ist er rot: eine Referenz fiele aus der Prüfung, die niemand entschieden hat.
- Deckt er **weniger**, ist er ebenfalls rot: eine zu hohe Zahl ist ein vorab bewilligtes Budget
  für künftiges Stummschalten, und genau das soll der Wächter verhindern.

Die vier bestehenden exakten Paare tragen dabei die Deklaration **1** und ändern ihr Verhalten
nicht. Gemessen für die drei neuen Einträge, am Tag dieser Entscheidung:

```sh
R="$(git rev-parse --show-toplevel)"
for t in docs/reviews docs/plan/planning/done docs/plan/planning/observations; do
  printf '%s\t' "$t"
  git ls-files -- "$t/*" | while read -r f; do d="$(dirname "$f")"
    grep -oE '\]\([^)]*\)' "$f" | sed 's/^](//; s/)$//; s/[[:space:]].*$//; s/#.*$//' |
    while read -r x; do [ -n "$x" ] || continue; case "$x" in [a-zA-Z]*:*) continue;; esac
      case "$(cd "$d" && realpath -m --relative-to="$R" "$x")" in .harness/baseline/*) echo x;; esac
    done; done | wc -l
done
# -> docs/reviews 33 · docs/plan/planning/done 3 · docs/plan/planning/observations 2
```

**Keine Erwartungswerte** — die Zahlen wandern mit dem Bestand, und **dass** sie wandern, ist der
Sinn der Festlegung: Jede Bewegung ist ab dann eine Entscheidung. Sie liegen über den 36
Gate-Befunden, weil sie **jeden** Markdown-Link in den vendored Baum zählen, auch die heute
auflösenden.

**3. Die drei Einträge sind extensional geschlossen — auf diese drei Quell-Bäume und auf diesen
einen `refs`-Wert.** Ein vierter Baum, ein anderer `refs`-Wert und jede Verbreiterung sind eine
neue Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5 und brauchen ihre eigene ADR — auch dann,
wenn sie dieselbe Bedingung erfüllen. Die Grenzen der vier bestehenden Paare gelten unverändert
weiter.

**Was diese Festlegungen nicht tun.**

- **Kein `Supersedes`.** [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
  [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md),
  [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
  [ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) und
  [ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) bleiben
  für ihr Paar unverändert wahr. Festlegung 2 fasst den **Maßstab** des Wächters neu, den
  [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) Folgepflicht 2 stellt; sein
  Verdikt über jene vier Paare bleibt dasselbe.
- **Sie heilen den lebenden Bestand nicht.** Eine tote Baseline-Adresse außerhalb der drei Bäume
  bleibt ein Befund und wird nachgezogen.
- **Sie schreiben die Hard Rule nicht.** Die Schärfung von §3.11 steht unten als Folgepflicht.
- **Sie bauen nichts.** Config und Wächter sind Implementer-Artefakte
  ([`AGENTS.md`](../../../AGENTS.md) §3.8).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — 24 exakte `ignore-refs`-Paare über 16 `in:`-Dateien | die Form, die der heutige Wächter liest | 6 der 24 überschreiten die Kappung, die Route braucht Festlegung 2 also trotzdem. Dazu 16 permanente Konfigurationszeilen, die je ein Zeitdokument benennen, und beim nächsten Bump derselbe Aufwand erneut |
| B — 16 exakte `in:`-Dateien mit Glob in `refs:` | `in:` bleibt eine existierende Datei, Zahn 1 des Wächters hält | Zahn 2 wird **blind**: `count_links` vergleicht das aufgelöste Link-Ziel mit dem `refs`-Literal, ein Glob trifft nie, der Wächter zählt 0 und ist grün, ohne gemessen zu haben — dieselbe Blindstelle, die er für die Code-Span-Achse selbst benennt |
| C — `scan.ignore` auf die drei Bäume | eine Zeile je Baum, kein Wächter-Umbau | nimmt die Dateien aus **allen** Modulen: `git ls-files 'docs/reviews/*.md' \| wc -l` → 299 Dateien und `git grep -oE '\]\((\.\./)+[^)]+\)' -- 'docs/reviews/*.md' \| grep -vc 'baseline/'` → 3887 repo-interne Link-Prüfungen fielen weg (keine Erwartungswerte). Und die Begründung des `archive-welle`-Suchraums in [`harness/README.md`](../../../harness/README.md) — *„`links`/`anchors` prüfen die Zeitdokumente wie jede andere Datei"* — würde falsch |
| D — `exempt-paths` unter `links`/`anchors` als Werkzeug-Anforderung | acht Module des Werkzeugs führen den Knopf | er ist **datei-weit** und damit gröber als der Fall: Zeile 3 der Sonden-Tabelle — ein toter Link ohne Baseline-Bezug in einer gedeckten Datei — verstummte mit. Der querschnittliche `ignore-refs` löst dieselbe Aufgabe ziel-weit und liegt vor; eine Anforderung an ein Nachbar-Repo für eine Fähigkeit, die es hat, ist keine |
| E — den alten Baum stehen lassen | die Ziel-Fassung sieht die Koexistenz vor | `make baseline-verify` bricht fail-closed bei zwei `<tag>`-Verzeichnissen ab ([`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 4). Und selbst ohne die Sperre nur ein Aufschub — die Adressen sterben, wenn der Baum fällt |
| F — das eingefrorene Artefakt doch anfassen | der Befund verschwindet an der Quelle | dann ist es kein Zeitdokument mehr ([`AGENTS.md`](../../../AGENTS.md) §3.4). Die Ziel-Fassung führt diesen Weg und benennt seinen Preis: *„es doch anfassen — dann ist es kein Zeitdokument mehr"* |
| G — gar kein Ventil, das Rot benannt aushalten | keine Senkung, kein Wächter-Umbau | `make gates` bliebe wegen 36 unbehebbarer Adressen dauerhaft rot, der Stop-Hook ließe keinen Abschluss zu und ein roter CI-Lauf sagte nichts mehr über neu eingebrachte Fehler. Genau der Schaden, den [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) für **eine** Datei vermeiden wollte |
| **H — gewählt: drei baum-weite Glob-Einträge, Wächter auf deklarierte Zahl** | trifft die Ursache dreifach — den Bestand über das vorhandene ziel-weite Instrument, die Ehrlichkeit der Ausnahme über die Deklaration, die Neuentstehung über die §3.11-Schärfung. Kostet keine der vier bestehenden ADR-Grenzen, keine Prüffläche außerhalb der drei Bäume und beim nächsten Bump keine Runde | drei Ausnahmen statt einer, und der Wächter braucht einen neuen Maßstab, bevor eine davon gelegt werden darf. Bis dahin bleibt `make gates` rot |

## Konsequenzen

- **Positiv:** Der lebende Bestand bleibt vollständig geprüft, und in den drei gedeckten Bäumen
  bleibt jeder Befund **ohne** Baseline-Bezug sichtbar — an der Sonden-Tabelle gemessen, nicht
  angenommen.
- **Positiv:** Die Ausnahme sagt, wie breit sie ist. Nach Festlegung 2 ist eine Verbreiterung
  nicht mehr still möglich; der Wächter behält seine Zähne und verliert nur die Konstante.
- **Positiv:** Der nächste Baum-Tausch kostet an dieser Stelle nichts. Der `refs`-Wert nennt die
  Eigenschaft statt des Tags.
- **Negativ, und es ist der Preis dieser Entscheidung:** Ein toter Anker in den **lebenden**
  Baum verstummt in den drei Bäumen mit. Heute ist das genau **1** Adresse
  (`git grep -oE '\]\([^)]*\.harness/baseline/v6\.5\.0/' -- 'docs/reviews/**' 'docs/plan/planning/done/**' 'docs/plan/planning/observations/**' | wc -l`,
  kein Erwartungswert); die §3.11-Schärfung sorgt dafür, dass keine hinzukommt, und die
  Deklaration aus Festlegung 2 macht jede neue sichtbar.
- **Negativ:** Der Wächter wird von *„höchstens 1"* auf *„genau N"* gestellt. Fällt eine
  Deklaration durch einen legitimen Vorgang — etwa wenn `make archive-welle` Review-Reports in
  ein Archiv zieht —, wird er rot und verlangt eine Entscheidung. Das ist gewollt und kostet.
- **Negativ:** Bis Annahme und Umsetzung bleibt `make docs-check` und damit `make gates` wegen
  dieser 36 Adressen rot.
- **Negativ /
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  **Kein Sensor** hält Status und Adress-Form zusammen; dieselbe Lücke, die
  [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) für sich benennt. Träger
  bleiben der Accept-Übergang und der Lauf, der den Bump plant.
- **Folgepflicht (Implementer), fällig mit der Annahme dieser ADR:** die drei Einträge in
  [`.d-check.yml`](../../../.d-check.yml) und der neue Maßstab in
  `test/ignore-refs-restbreite.bats`, je mit dem rot gesehenen Gegenbeispiel
  ([`AGENTS.md`](../../../AGENTS.md) §3.6) — fehlende Deklaration, zu hohe Zahl, zu niedrige Zahl.
- **Folgepflicht (Architect), fällig mit der Annahme dieser ADR:**
  [`AGENTS.md`](../../../AGENTS.md) §3.11 bekommt die vendored-Baseline-Adresse als ausdrücklichen
  Fall — die Ausnahme *„ein Verzeichnis … ist ortsfest"* gilt nicht für ein `<tag>`-gescoptes
  Vendoring-Verzeichnis, das mit dem Bump ersetzt wird. Verschärfung, kein ADR-Gefäß
  ([`AGENTS.md`](../../../AGENTS.md) §3.5).
- **Folgepflicht (Planner/Implementer), unabhängig von dieser Entscheidung:** die drei toten
  Adressen in `slice-114` lagen in einem **lebenden** Slice-Plan und sind nach
  [ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 2 nachgezogen; sie
  gehören nicht zu den 36.
- **Darüber hinaus ändert diese ADR keine Datei außer sich selbst und dem ADR-Index.**

## Fitness Function (falls maschinell prüfbar)

**Gebaut: eine, nach Festlegung 2 umzubauen.** `test/ignore-refs-restbreite.bats` misst die Breite
jedes Paares und wird damit zum Wächter über die Deklaration. Was er auch danach **nicht** misst,
ist einzeln geprüft statt verschwiegen:

| Frage | Wer sie misst |
|---|---|
| deckt ein Eintrag mehr/weniger als deklariert? | `test/ignore-refs-restbreite.bats` nach Festlegung 2 |
| kommt ein **vierter** Eintrag hinzu? | niemand — Hard-Rule-Aussage ([`AGENTS.md`](../../../AGENTS.md) §3.5), wie [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) es für sich selbst feststellt |
| ist die gedeckte Datei wirklich eingefroren? | niemand — kein Modul aus `modules:` der [`.d-check.yml`](../../../.d-check.yml) liest einen Status |
| deckt der Eintrag eine Code-Span-Referenz? | niemand — der Wächter zählt die Inline-Markdown-Form; [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Folgepflicht 2 führt die Lücke |

## Re-Evaluierungs-Trigger

- **Wenn eine Deklaration rot wird** *(beobachtbar an `make gates`)*: Entweder ist eine Adresse
  hinzugekommen — dann greift die §3.11-Schärfung nicht — oder eine ist weggefallen; beides
  gehört entschieden, nicht nachgezogen.
- **Wenn der nächste Baum-Tausch ansteht** *(feedforward, kein Gate meldet ihn)*: Die drei
  Deklarationen sind vor dem Tausch zu messen und danach erneut. Bewegt sich eine, hat die
  §3.11-Schärfung nicht getragen.
- **Wenn ein vierter Baum einfriert** *(beobachtbar an einer neuen Artefaktklasse in der
  Ziel-Fassung)*: Festlegung 3 verlangt dafür eine eigene ADR.
- **Wenn `.harness/baseline/` seine `<tag>`-Ebene verliert** *(beobachtbar an
  `ls -d .harness/baseline/*/`)*: Dann trägt der `refs`-Wert die Eigenschaft nicht mehr, auf die
  Festlegung 1 ihn stützt.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-07 | **Proposed** | Architect-Lauf; löst die zweite Architect-Folgepflicht von [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) ein |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0039` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
