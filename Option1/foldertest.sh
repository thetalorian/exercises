#!/bin/bash
# Create multiple copies of the testfile.hmtl
# testing file within a subfolder to verify
# proper functionality of the find / sed command

# Note: provided grep validation test only applies
# in this specific case (test input files where all
# lines have a phone number and only a phone number,
# and the same number appears multiple times in the
# file in different formats.)
# Real world cases would require different options.

mkdir -p test
for i in {1..500}
do
    cp testfile.html test/testfile${i}.html
done

find test -type f -exec sed -i -E "s/(\(?\+?1\)?([-\.]|\s)?)?\(?800\)?([-\.]|\s)?(259|get)([-\.]|\s)?(4357|help)/202-221-1414/i" {} +

grep -v "^202-221-1414$" test/*