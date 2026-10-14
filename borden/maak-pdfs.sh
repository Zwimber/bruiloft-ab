#!/bin/zsh
# Maakt van elk bord in borden.html een PDF (A4) met headless Chrome, plus alle-borden.pdf.
# Gebruik: ./borden/maak-pdfs.sh   (vanuit de hoofdmap van de site)
set -e
cd "$(dirname "$0")/.."
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
PAGE="file://$PWD/borden.html"
mkpdf(){ "$CHROME" --headless=new --disable-gpu --no-pdf-header-footer --virtual-time-budget=10000 --print-to-pdf="$PWD/borden/$1.pdf" "$PAGE?$2" >/dev/null 2>&1; echo "borden/$1.pdf"; }
ARROW=(ceremonie)
PLAIN=(welkom programma cadeaus verdrag gereserveerd stilte)
for s in $ARROW; do for d in links rechtdoor rechts omlaag; do mkpdf "$s-$d" "print=$s&dir=$d"; done; done
for s in $PLAIN; do mkpdf "$s" "print=$s"; done
mkpdf alle-borden "print=all"
