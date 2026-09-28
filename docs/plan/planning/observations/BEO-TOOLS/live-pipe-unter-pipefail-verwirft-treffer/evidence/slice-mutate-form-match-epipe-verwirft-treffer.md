**Vorgang:** slice-mutate-form-match-epipe-verwirft-treffer
**Fund:** `harness/tools/mutate.sh` Zeile 808 (Bedingung 4 von `make mutate`) traf das Muster real
im CI-Lauf `mutate.yml` und wurde in diesem Slice auf die Here-String-Form (`form_matched()`)
gehärtet. Der Reviewer fand mit Finding F-2 eine zweite, strukturell verwandte, **unveränderte**
Stelle außerhalb des Slice-Umfangs: `harness/tools/comment-claims.sh:105`
(`find … -print0 | xargs -0 grep -lE … | grep -q .`) — anderer konkreter Aufbau (Dateimengen- statt
Zeilen-Pipe), derselbe Mechanismus (früh aussteigendes `grep -q` unter `pipefail` gegen ein noch
schreibendes vorgelagertes Kommando).
