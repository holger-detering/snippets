#!/usr/bin/gawk -f

# Author:   Holger Detering
# Purpose:  Reformat "To:" and "Cc:" header lines in a pretty way.
# Usage:
#           join.to.and.cc.awk file1 ...
#
# If no filename is given on the command line, the script expects the content
# of the mail file on stdin.

# Copyright 2016 Holger Detering <github@detering-springhoe.de>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License.  You may obtain a copy
# of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.

function do_print(prefix, value) {
  n = split(value, a, ",")
  for (i=1; i<=n; ++i) {
    gsub(/^[ \t]+|[ \t]+$/, "", a[i]);
    gsub(/[ \t]+/, " ", a[i]);
    if (i < n)
      a[i] = a[i] ","
    if (i == 2)
      gsub( /[^ ]/, " ", prefix)
    print prefix, a[i]
  }
}

function do_end_header(prefix, status, content) {
  if (status == 1) {
    do_print(prefix, content)
    status = 2
  }
  return status
}

function do_end_to() {
  in_to = do_end_header("To:", in_to, joined_to)
}

function do_end_cc() {
  in_cc = do_end_header("Cc:", in_cc, joined_cc)
}

function trim_and_add_line(result) {
  gsub(/^[ \t]+|[ \t]+$/, "");
  if (length(result) == 0)
    result = $0
  else
    result = result " " $0
  return result
}

BEGINFILE {
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

ENDFILE {
  do_end_to()
  do_end_cc()
}
