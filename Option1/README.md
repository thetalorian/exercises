# Option 1 - Implement a script to update content

I'd like to see you implement a script to update the phone number embedded in many of the storeʼs HTML pages. Over the years, the content authors have embedded the number on pages using a wide variety of punctuation (i.e., 800 259-4357 or 800.259.4357) while others used letter mnemonics (e.g., 800-GET-HELP). Some inserted the US country code, with or without surrounding parentheses. The store has >50K HTML files, all under an NFS /var/www mount point shared by all servers.
Your job is to replace all the old number with one version of the new number: 202-221-1414. The job needs to be done tonight, while the web servers are running. You do NOT have to convert the new number to the existing format used on the page.

Bonus points for a solution that is implemented as a single pipeline of Linux commands.

## Implementation

The task can be accomplished with a combination of the 'find' command and a (admittedly complex) sed command with regex designed to catch all of the requested variations.

```
find /var/www/ -type f -exec sed -i -E "s/(\(?\+?1\)?([-\.]|\s)?)?\(?800\)?([-\.]|\s)?(259|get)([-\.]|\s)?(4357|help)/202-221-1414/i" {} +
```

To break down the regex for easier understanding:

First we deal with the optional country code.

```
(
    \(?
    \+?
    1
    \)?
    ([-\.]|\s)?
)?
```

This will match on 1, +1, (+1), and typo variations, and allows for an optional space, hyphen, or period between the country code and area code, but does not require any version for the final match.

Now the actual phone number:

```
\(?
800
\)?
([-\.]|\s)?
(259|get)
([-\.]|\s)?
(4357|help)
```

Matches the 800 with or without surrounding parentheses, including typos, when paired with 259-4357 or Get Help, separated by ., -, space, any combination of the above, or nothing at all.

## Caveats

For older / alternate versions of sed the regex may need to be adjusted to compensate for lacking features. Specifically in order to get the same results on the BSD version of sed you would need to make the following replacements:

- ? replaced with {0,1}
- ([-\.]|\s) replaced with [-\.[:space:]]
- To address lack of case insensitive search, replace /i with /g and replace get and help with [gG][ee][tT] and [hH][ee][lL][pp], respectively

Additionally the system may not recognize the "-exec {} +" syntax for find, especially on older systems. The command can still be run in the same way with "-exec {} ;", but will require more time to process as this will remove batching. Alternately the exec portion can be replaced with -print0 | xargs -0 for a similar result:

```
find /var/www/ -type f -print0 | xargs -0 sed -i -E "s/(\(?\+?1\)?([-\.]|\s)?)?\(?800\)?([-\.]|\s)?(259|get)([-\.]|\s)?(4357|help)/202-221-1414/i";
```

And of course all of the above is only performed with the assumption that we have a suitable backup of the html files in an alternate location, just in case the change needs to be undone, or something goes horribly horribly wrong.

Ideally there would also be a validation phase both before and after application of the above commands to determine the count of identified phone numbers, and additional large scale text searches looking for remnants of the phone numbers after the fact. (Possibly just doing a grep command for 4357 on its own, or doing a recursive grep -L to view all files that don't contain the new phone number.)
