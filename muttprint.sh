#! /usr/bin/env bash

#{{{ bash settings
# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail
#}}}

#{{{ variables
IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)
TEMP_DIR=$(mktemp -d --tmpdir muttprint.XXXXXXXXXX)
#}}}

main() {
  local mail_content
  mail_content=$(tee)
  local mail_date
  local formatted_date
  local mail_from
  local mail_to
  local subject
  mail_date=$(echo "$mail_content" | formail -czx Date:)
  formatted_date=$(date -d "$mail_date" +"%F %T %Z")
  mail_from=$(echo "$mail_content" | formail -czx From: | sed -e 's/_/\\_/g')
  mail_to=$(echo "$mail_content" | formail -czx To: | \
    awk -v len=70 '{ if (length($0) > len) print substr($0, 1, len-3) "..."; else print; }' | \
    sed -e 's/_/\\_/g')
  subject=$(echo "$mail_content" | formail -czx Subject: | sed -e 's/&/\\&/g' -e 's/_/\\_/g')

  local tex_file=$TEMP_DIR/output.tex
  {
    cat <<'EOF'
\documentclass[a4paper,12pt]{article}
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage{baskervald}
\usepackage{inconsolata}
\usepackage{a4wide}
\usepackage{fancyhdr}
\usepackage{lastpage}
\pagestyle{fancy}
\DeclareUnicodeCharacter{200B}{{\hskip 0pt}}
\DeclareUnicodeCharacter{2023}{-}
EOF

  cat << EOF
\\lhead{\\bfseries S: ${subject}\\\\\\normalfont F: ${mail_from}\\\\T: ${mail_to}}
\\rfoot{$formatted_date}
EOF

cat <<'EOF'
\cfoot{}
\lfoot{\thepage\ /\ \pageref{LastPage}}
\renewcommand{\headrulewidth}{0.6pt}
\renewcommand{\footrulewidth}{0.2pt}
\setlength{\headheight}{42pt}
\begin{document}
\begin{verbatim}
EOF

  echo "$mail_content" | formail -f -I "" | \
    sed -e :a -e '/./,$!d;/^\n*$/{$d;N;};/\n$/ba' | fold -w 76 -s

cat <<'EOF'
\end{verbatim}
\end{document}
EOF
  } >> "${tex_file}"

  (
    cd "$TEMP_DIR";
    pdflatex "${tex_file}" && pdflatex "${tex_file}"
  )  > "${TEMP_DIR}/latex.log"

  lp -o number-up=2 "${tex_file%.tex}.pdf"
}

#{{{ Helper functions
finish() {
  result=$?
  rm -rf "${TEMP_DIR}"
  unset TEMP_DIR
  exit ${result}
}

#}}}

trap finish EXIT ERR

main "${@}"
