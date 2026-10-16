#!/bin/zsh
# Maakt van elk bord in borden.html een PDF (A4) met headless Chrome, plus alle-borden.pdf,
# ceremonie-alle-richtingen.pdf (links, rechtdoor, rechts), verdragen.pdf (alle acht hoofdstukken van artikel-1710.html)
# en draaiboek-team-ceremonie.pdf (draaiboek.html: per ceremoniemeester voorkant volledig, achterkant persoonlijk).
# Gebruik: ./borden/maak-pdfs.sh   (vanuit de hoofdmap van de site; python3 met pypdf nodig voor verdragen.pdf)
set -e
cd "$(dirname "$0")/.."
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
PAGE="file://$PWD/borden.html"
mkpdf(){ "$CHROME" --headless=new --disable-gpu --no-pdf-header-footer --virtual-time-budget=10000 --print-to-pdf="$2" "$1" >/dev/null 2>&1; echo "${2#$PWD/}"; }
bord(){ mkpdf "$PAGE?$2" "$PWD/borden/$1.pdf"; }
ARROW=(ceremonie)
PLAIN=(welkom programma cadeaus verdrag gereserveerd gereserveerd-naam muziek stilte)
for s in $ARROW; do
  for d in links rechtdoor rechts; do bord "$s-$d" "print=$s&dir=$d"; done
  bord "$s-alle-richtingen" "print=$s&dir=all"
done
for s in $PLAIN; do bord "$s" "print=$s"; done
bord alle-borden "print=all"
mkpdf "file://$PWD/draaiboek.html" "$PWD/borden/draaiboek-team-ceremonie.pdf"

# Verdragsvellen: per hoofdstuk twee pagina's (artikel + overige bepalingen), samengevoegd tot één PDF.
TMP="$(mktemp -d)"
for h in 1 2 3 4 5 6 7 8; do mkpdf "file://$PWD/artikel-1710.html?hoofdstuk=$h" "$TMP/verdrag-$h.pdf" >/dev/null; done
python3 - "$TMP" "$PWD/borden/verdragen.pdf" <<'PY'
import sys,glob,os
from pypdf import PdfWriter
tmp,out=sys.argv[1],sys.argv[2]
w=PdfWriter()
for h in range(1,9): w.append(os.path.join(tmp,f"verdrag-{h}.pdf"))
w.add_metadata({"/Title":"Verdragsvellen Anna & Balraz (alle hoofdstukken)"})
w.write(out); w.close()
PY
rm -rf "$TMP"
echo "borden/verdragen.pdf"
