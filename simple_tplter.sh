#!/bin/bash
# simple_templater.sh
# v1.0.4
# Copyright (c) 2023 ghostinhat
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

MY_NAME="$(basename "$0")"
MY_DIR="$(cd "$(dirname "$0")";pwd)"
DELIMITER="="

function usage() {
  echo >&2 "$MY_NAME: Usage: $0 [-f] TEMPLATE_FILE VARIABLE1${DELIMITER}VALUE1 VARIABLE2${DELIMITER}VALUE2...
  Generate contents by a template, expanding variables. Use the -f option to ignore any expansion errors. when TEMPLATE_FILE is -, read standard input."
}

IS_FORCED=0 # default value
while getopts ":f" opt; do
  case ${opt} in
    f  ) IS_FORCED=1
         shift $((OPTIND - 1))
         ;;
    \? ) echo >&2 "$MY_NAME: Error: Invalid option: -$OPTARG"
         usage
         exit 1
	 ;;
  esac
done

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

TEMPLATE_FILE="$1"
VARIABLE_AND_VALUE_ARRAY=("${@:2}")
VARIABLE_NAME_PREFIX="_TPLTER_"


function escape_value() {
  local value="$1"
  sed -e 's/["`\\$]/\\&/g' <<<"$value"
}

function escape_template() {
  local template_str="$1"
  sed -e 's/["`]/\\&/g' <<<"$template_str"
}

function add_prefix_to_variable_name() {
  local template_str="$1"
  sed -E 's/([^\\]|^)\$([^{]|$)/\1$'"$VARIABLE_NAME_PREFIX"'\2/g; s/([^\\]|^)\$\{/\1${'"$VARIABLE_NAME_PREFIX"'/g' <<<"$template_str"
}

function get_template_str() {
  local template_file="$1"
  if [ "$template_file" != "-" -a ! -f "$template_file" ]; then
    echo >&2 "$MY_NAME: Error: The specified path does not point to a file, or the file does not exist.
  Path: $template_file"
    usage
    return 1
  fi

  add_prefix_to_variable_name "$(escape_template "$(cat "$template_file")")"
}

function contains_delimiter() {
  local str="$1"
  if [ "$(head -1 <<<"$str" | grep "$DELIMITER" | wc -l)" -ge 1 ]; then
    echo 1
  else
    echo 0
  fi
}

function is_valid_variable_name {
  local str="$1"
  if [[ "$str" =~ ^[a-zA-Z_]+[a-zA-Z0-9_]*$ ]]; then
      echo 1
  else
      echo 0
  fi
}

function make_assignments() {
  for variable_and_value in "${VARIABLE_AND_VALUE_ARRAY[@]}"; do
    if [ $(contains_delimiter "$variable_and_value") -eq 0 ]; then
      echo >&2 "$MY_NAME: Error: Input a set of variable-value pairs delimited by the \"${DELIMITER}\" character.
  Invalid pair: $variable_and_value"
      usage
      return 1
    fi
    
    local variable="$(head -1 <<<"$variable_and_value" | cut -f 1 -d "$DELIMITER")"
    if [ $(is_valid_variable_name "$variable") -eq 0 ]; then
      echo >&2 "$MY_NAME: Error: Variable names must follow the same naming convention as bash variables, which means they can only contain letters, numbers, and underscores, and cannot start with a number.
  Invalid pair: $variable_and_value"
      usage
      return 1
    fi
    
    local value="$(sed "1 s/^[^$DELIMITER]*$DELIMITER//" <<<"$variable_and_value")"
    
    echo -n "$VARIABLE_NAME_PREFIX$variable=\"$(escape_value "$value")\";"
  done
}

function assign() {
  local template_str="$1"
  local assignments="$2"
  
  local uoption
  if [ $IS_FORCED -eq 1 ]; then
    uoption="+u"
  else
    uoption="-u"
  fi
  
  echo "$assignments echo \"$template_str\"" | PATH="" "$(which bash)" -r "$uoption"
}


template_str="$(get_template_str "$TEMPLATE_FILE")" || exit 2
assignments="$(make_assignments)" || exit 3

result="$(assign "$template_str" "$assignments")"
if [ $? -ne 0 ]; then
  echo >&2 "$MY_NAME: Error: A variable expansion error has occurred. Please check the variables in your template to ensure that your input variable assignments are valid and sufficient.
  Template: $TEMPLATE_FILE, Assignments: \"$(IFS=','; echo "${VARIABLE_AND_VALUE_ARRAY[*]}" | sed -e 's/,/, /g')\""
  usage
  exit 4
fi
echo "$result"

