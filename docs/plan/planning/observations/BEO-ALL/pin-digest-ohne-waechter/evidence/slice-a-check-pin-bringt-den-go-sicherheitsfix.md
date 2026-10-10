**Vorgang:** slice-a-check-pin-bringt-den-go-sicherheitsfix

**Fund:** Der a-check-Index-Digest `v0.23.2` ist durch `imagetools inspect` belegt; `TestArchImagePin_CouplesToDirectionPorts` hält nur die Digest-Form, und Fall 66 verfälscht den Pin in der Verdrahtung, nicht Tag gegen Digest. Ein Tag, der nicht zum Digest passt, geht durch.
