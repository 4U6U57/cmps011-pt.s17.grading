# cmps011-pt.s17/pa4

The following is a set of performance tests to run on your Roots program. It takes
six example input files and compares your results to our correct model outputs.
We have made this available to you to check your work before making your final
submission.

## Warning

This script should confirm all components of your performance based grade but
doesn't confirm every component of your grade for things like comment blocks
(It'll definitely get you most of the points though)

## Installation

Run the following in your working directory (the directory you wrote your code
in) to download the test script.

```bash
curl https://raw.githubusercontent.com/4u6u57/cmps011-pt.s17.grading/master/pa4/pa4.sh > pa4.sh
chmod +x pa4.sh
```

# Usage

After downloading the script, you can then run it with the following command:

```bash
./pa4.sh
```

It will print out the difference between your output and the correct output,
using the `diff` command. Lack of any output between the set of "=========="
means that your program is running correctly.

> WARNING: For now on you will not get a perfect score if there is any output
between any of the pairs of equal signs

## Removal

You can delete the test and all other downloaded/generated files with:
`rm -f pa4.sh diff*.txt out*.txt model-out*.txt`.
