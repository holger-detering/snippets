# snippets

This is my personal collection of small scripts.

## join.to.and.cc.awk

`join.to.and.cc.awk` reformats the contents of the "To:" and "Cc:" headers in
mail files, such that each recipient is provided on its own line.

Example:

```
join.to.and.cc.awk file ...
```

If no filename is given on the command line, the script expects the content of
the mail file on `stdin`.

## muttprint.sh

Drop-in replacement for muttprint.

Requires:

+ formail (from procmail)
+ pdflatex
+ latex fonts:
  * inconsolata
  * lubre baskerville
+ latex packages:
  * a4wide
  * fancyhdr
  * lastpage:
+ lp

Usage in .muttrc:

```
set print_command=/path/to/muttprint.sh
```

## License

Copyright 2016 Holger Detering

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
