# simple-templater

This is a simple Bash script that renders content by expanding variables in a template file. The script takes a template file and a set of variable-value pairs as input, and outputs the result of expanding the variables in the template file.

## Getting Started

This script is designed to be run in a Unix/Linux environment with Bash installed. To use the script, simply execute it with the following command:

```shell
./simple_tplter.sh [-f] TEMPLATE_FILE VARIABLE1=VALUE1 VARIABLE2=VALUE2...
```
Here's what each of the command-line arguments does:

- `-f`: Use this option to ignore any expansion errors.
- `TEMPLATE_FILE`: This is the path to the template file that you want to expand. To read from standard input, use `-`.
- `VARIABLE1=VALUE1 VARIABLE2=VALUE2...`: These are the variable-value pairs that you want to use to expand the template. Each pair should be delimited by the `=` character.

## Example1: Basic Usage

In this example, we'll use the script to expand a template file with a single variable:

```shell
$ cat sample_tpls/01_basic.txt
Hello, ${NAME}!

$ ./simple_tplter.sh sample_tpls/01_basic.txt NAME=World
Hello, World!
```

In this example, we're using the `01_basic.txt` file as our template, and we're passing in a variable `NAME` with a value of `World` to expand the template.

The resulting output is `Hello, World!`.

## Example2: Handling Variable Assignments

In this example, we'll use the script with incomplete variable assignments, and see how it handles them.

1. **Missing Variable Assignments**

In this sub-example, we'll use the script with an incomplete set of variable assignments, causing an error to occur. We won't use the `-f` option, so the script will exit with an error:

```shell
$ cat sample_tpls/02_no_default_values.txt
Hello, ${NAME}! My favorite color is ${COLOR}.

$ ./simple_tplter.sh sample_tpls/02_no_default_values.txt NAME=John
./simple_tplter.sh: line XXX: _TPLTER_COLOR: unbound variable
simple_tplter.sh: Error: A variable expansion error has occurred. Please check the variables in your template to ensure that your input variable assignments are valid and sufficient.
  Template: sample_tpls/02_no_default_values.txt, Assignments: "NAME=John"
simple_tplter.sh: Usage: ./simple_tplter.sh [-f] TEMPLATE_FILE VARIABLE1=VALUE1 VARIABLE2=VALUE2...
  Generate contents by a template, expanding variables. Use the -f option to ignore any expansion errors. when TEMPLATE_FILE is -, read standard input.
```

In this sub-example, we're using the `02_no_default_values.txt` file as our template, and we're passing in a variable `NAME` with a value of `John`, but we're not passing in a value for the `COLOR` variable. Since we didn't use the `-f` option, the script exits with an error, indicating that a variable expansion error has occurred.

2. **Using Default Values in Variables**

In this sub-example, we'll use the script with an incomplete set of variable assignments, but this time the template has a default value for the missing variable:

```shell
$ cat sample_tpls/02_default_values.txt
Hello, ${NAME:-World}! My favorite color is ${COLOR:-blue}.

$ ./simple_tplter.sh sample_tpls/02_default_values.txt NAME=John
Hello, John! My favorite color is blue.
```

In this sub-example, we're using the `02_default_values.txt` file as our template, and we're passing in a variable `NAME` with a value of `John`, but we're not passing in a value for the `COLOR` variable. However, this time the template has a default value for the missing variable, so the script is able to complete the expansion without error.

## Example3: Handling Special Characters and Spaces in Variable Assignments

In this example, we'll use double quotes or single quotes to pass in variable values with spaces, newlines, and special characters:

```shell
$ cat sample_tpls/03_two_variables.txt
Hello, ${NAME}! My favorite color is ${COLOR}.

$ ./simple_tplter.sh sample_tpls/03_two_variables.txt 'NAME=John Doe' "COLOR='red
and blue'"
Hello, John Doe! My favorite color is 'red
and blue'.
```

In this example, we're passing in two variable assignments: `NAME=John Doe` and `COLOR='red\nand blue'`. Note that we're using single quotes to enclose the `NAME` variable assignment, since it contains a space, and we're using double quotes to enclose the `COLOR` variable assignment, since it contains single quotes and a newline character.

Using double quotes or single quotes around variable assignments is a good way to ensure that values with special characters, spaces, and newlines are passed to the script correctly.

## Example4: Handling "$" and "\\" in Template

In this example, we'll use the escape character `\` to include a literal `$` and a literal `\` in the template file:

```shell
$ cat sample_tpls/04_escaped.txt
Hello, ${NAME}! My favorite character is the backslash: \\. The variable \${VAR} contains: ${VAR}.

$ ./simple_tplter.sh sample_tpls/04_escaped.txt NAME=John VAR=hello
Hello, John! My favorite character is the backslash: \. The variable ${VAR} contains: hello.
```

In this example, we're using the `04_escaped.txt` file as our template, which contains a literal `$` and a literal `\` that we want to preserve in the output.

To include a literal `$` or `\` in the template file, we can use the escape character `\`. This tells the script to treat the following character as a literal character, rather than as a special character that is used for variable expansion. For example, in the `04_escaped.txt` file, we use `\\` to represent a literal backslash character, and `\$` to represent a literal dollar sign.

Using the escape character `\` is a useful way to include special characters in the template file without triggering variable expansion.

## Example5: Passing File Contents as a Variable Value

In this example, we'll pass the contents of a file as a variable value using the `cat` command:

```shell
$ cat sample_tpls/05_template.txt
Contents of the file:
${FILE_CONTENTS}

$ cat sample_tpls/05_contents.txt
This is the contents of the file.
It spans multiple lines.

$ ./simple_tplter.sh sample_tpls/05_template.txt "FILE_CONTENTS=$(cat sample_tpls/05_contents.txt)"
Contents of the file:
This is the contents of the file.
It spans multiple lines.
```

In this example, we're using the `cat` command to read the contents of the `05_contents.txt` file, and passing the output to the `FILE_CONTENTS` variable using the `$(cat 05_contents.txt)` syntax.

Using the `cat` command to read the contents of a file is a simple and convenient way to pass the contents of a file as a variable value in the `simple_tplter.sh` script.
