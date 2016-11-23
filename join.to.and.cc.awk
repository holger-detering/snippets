#!/usr/bin/gawk -f

#   Copyright 2016 Holger Detering <github@detering-springhoe.de>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

function do_print(header, value) {
  n = split(value, a, ",")
  for (i=1; i<=n; ++i) {
    gsub(/^[ \t]+|[ \t]+$/, "", a[i]);
    if (i < n)
      a[i] = a[i] ","
    if (i == 1)
      print header, a[i]
    else
      print "   ", a[i]
  }
}

function do_end_to() {
  if (in_to == 1) {
    do_print("To:", joined_to)
    in_to = 2
  }
}

function do_end_cc() {
  if (in_cc == 1) {
    do_print("Cc:", joined_cc)
    in_cc = 2
  }
}

function trim_and_add_line(result) {
  gsub(/^[ \t]+|[ \t]+$/, "");
  if (length(result) == 0)
    result = $0
  else
    result = result " " $0
  return result
}

BEGIN {
  in_to = 0
  joined_to = ""
  in_cc = 0
  joined_cc = ""
}

in_to == 0 && /^To:/ {
  do_end_cc()
  in_to = 1
  gsub(/^To:/, "")
  joined_to = trim_and_add_line(joined_to)
  next
}

in_cc == 0 && /^Cc:/ {
  do_end_to()
  in_cc = 1
  gsub(/^Cc:/, "")
  joined_cc = trim_and_add_line(joined_cc)
  next
}

/^[ \t]+/ {
  if (in_to == 1) {
    joined_to = trim_and_add_line(joined_to)
    next
  } else if (in_cc == 1) {
    joined_cc = trim_and_add_line(joined_cc)
    next
  }
}

{
  do_end_to()
  do_end_cc()
  print
}
