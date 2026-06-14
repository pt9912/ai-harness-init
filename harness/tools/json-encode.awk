# json-encode.awk — gibt den stdin-Inhalt als JSON-escapten String-INHALT aus
# (ohne umschliessende Anfuehrungszeichen). POSIX-awk (busybox/gawk/BSD), kein
# gawk-Spezifikum. Zweck: additionalContext-Encoding fuer den SessionStart-
# Injektor ohne node/jq (LH-QA-03). Byteweise -> UTF-8-sicher (Mehrbyte-Zeichen
# kollidieren nie mit ASCII " \ \t \r). Zeilenumbrueche werden zu \n.
# Steuerzeichen U+0000-U+001F sind in JSON escape-pflichtig: \t und \r explizit,
# alle uebrigen als \uXXXX (sonst entsteht ungueltiges JSON).
BEGIN { for (k = 1; k < 32; k++) ctrl[sprintf("%c", k)] = k }
{ lines[NR] = $0 }

END {
  out = ""
  for (n = 1; n <= NR; n++) {
    if (n > 1) out = out "\\n"          # Zeilentrenner -> \n
    s = lines[n]
    L = length(s)
    for (i = 1; i <= L; i++) {
      c = substr(s, i, 1)
      if (c == "\\")      out = out "\\\\"
      else if (c == "\"") out = out "\\\""
      else if (c == "\t") out = out "\\t"
      else if (c == "\r") out = out "\\r"
      else if (c in ctrl) out = out sprintf("\\u%04x", ctrl[c])   # uebrige C0
      else                out = out c
    }
  }
  printf "%s", out
}
