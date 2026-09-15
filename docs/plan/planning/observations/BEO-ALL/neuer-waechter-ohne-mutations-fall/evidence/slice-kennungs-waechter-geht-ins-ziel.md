**Vorgang:** slice-kennungs-waechter-geht-ins-ziel
**Fund:** Der Vorgang legt **18** neue Wächter an — **7** Go-Wächter
(`internal/emit/commitmsg_test.go`), **10** bats-Fälle (`test/commit-msg-emission.bats`) und **eine**
E2E-Sektion (`kennungs_traeger_im_ziel` in `harness/tools/full-smoke.sh`) — und listet **10**
Mutationsfälle (die Fälle `347` bis `356`). **Gemessen** ist die Zuordnung, die ein `# expect:`-Kopf
herstellt: die sieben Go-Wächter und drei bats-Fälle sind benannt, **acht** Wächter nennt kein Fall.

```sh
grep -c '^func Test' internal/emit/commitmsg_test.go   # 7 Go-Waechter — jeder von einem Fall genannt
grep -c '^@test' test/commit-msg-emission.bats         # 10 bats-Faelle
for t in 'rot: eine Message ohne' 'kopplung: die Klassen-Aufzaehlung' 'rot: der Grund nennt den Ort' \
         'gruen: jede der vier' 'gruen: die Kennung darf' 'gruen: die Merge-' \
         'rot: eine Kennung in einer Kommentarzeile' 'fail-closed: fehlende Datei' \
         'kopplung: die zwei bash-Fassungen' 'kopplung: die Betreff-Ausnahme' \
         'kennungs_traeger_im_ziel'; do
  printf '%s  %s\n' "$(grep -rlF -- "$t" test/mutations/ | wc -l)" "$t"; done
# 3x 1 (die ersten drei) und 8x 0 (die uebrigen, darunter die E2E-Sektion)
```

**Von den acht ist einer der gewichtigere.** Der Eintrag `'auch die Commits der Repo-Werkzeuge'` in
der `for noetig`-Liste des E2E ist der **zusätzliche** Wächter einer Zusage, die **vier** Träger
hat: das Aktivierungs-Fragment (bewacht — ein Go-Wächter mit seinen Markern, Fall `357`), die
Command-Vorlage und die Prosa in `harness/README.md` (Wiederholungen derselben Zusage in eigenen
Worten, ohne eigene Prüfung) und eben dieser Eintrag. Er ist der einzige **Wächter** unter den
vier, den weder `make gates` noch `make mutate` meldet — `full-smoke` steht in keiner
`gates`-Kette, und kein gelisteter Fall nennt die Datei:

```sh
grep -l '^# files:.*full-smoke.sh' test/mutations/*.sh    # nur 190 — anderer Gegenstand
```

**Und einer der acht hat Zähne, ohne benannt zu sein.** Die Kopplungs-Gruppe der `exempt=`-Zeile
(`kopplung: die Betreff-Ausnahme der zwei Fassungen ist dieselbe`) fällt in einer eigenen Sonde —
einseitig geänderte Zeile, zwei bats-Fälle rot (`not ok 56`, `not ok 85`); sie ist unbewacht im
gelisteten Set, aber nicht zahnlos. Dazu die E2E-Sektion selbst, ebenfalls in einer Sonde:

```sh
# HOOKS_DIR ?= .githooks  ->  .git/hooks
make test-go     # Exit 0
make test-bats   # Exit 0, keine not-ok-Zeile
```

Sie fällt allein in `make full-smoke`, das kein Gate ist.

**Der Unterschied zur Zahl des Verifikations-Reports ist gemessen, nicht übernommen.** Er zählt
**11** benannte; seine Zeile führt die Kopplungs-Gruppe der zwei bash-Fassungen über
`340`/`341`/`342` als gedeckt, deren `# expect:` aber `test/commit-msg-hook.bats` nennt — einen
anderen Wächter. Als *benannt* zählt hier, was `make mutate` liest.

**Kein Verstoß gegen [`AGENTS.md`](../../../../../../../AGENTS.md) §3.6, und darum diese Zeile statt
einer Reparatur:** weder Code noch Doku behaupten, die acht seien über `test/mutations/` bewacht —
der Rest ist benannt, nicht geschlossen.
