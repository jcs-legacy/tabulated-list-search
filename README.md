[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

# tabulated-list-search 
> Provide filtering/searching tabulated-list interface.

[![Build Status](https://travis-ci.com/jcs-elpa/tabulated-list-search.svg?branch=master)](https://travis-ci.com/jcs-elpa/tabulated-list-search)

Any package that uses `tabulated-list` as their display could use this 
library/package to add the search functionalities to enhance the user experience.

[Here](https://github.com/jcs090218/jcs-emacs-init/tree/master/features/buffer-menu-search)
is one example using this package to `*Buffer List*`.

## How does it works?

This package look form each item inside list and do the regular 
expression matching for target information. If the target 
information doesn't matched then remove it from the list otherwise 
keep it inside the list.

## Issue & Improvement

One huge issue is that the performance maybe very slow due to the 
size of the list itself. Hence the time complexity is `O(n)` and 
I couldn't find any other ideal solution that may be fit into this 
kind of the circumstances. 

Maybe by restraining the input inside the `fake header` could 
somehow trick the full list not to loop through the whole list. 
Anyway, if you find out the solution feel free to enhance this 
by making the PR or just open a new issue! Thanks!

## Todo List

- [ ] Resolve performance issue explain [here](#issue--improvement).

## Contribute

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)
[![Elisp styleguide](https://img.shields.io/badge/elisp-style%20guide-purple)](https://github.com/bbatsov/emacs-lisp-style-guide)
[![Donate on paypal](https://img.shields.io/badge/paypal-donate-1?logo=paypal&color=blue)](https://www.paypal.me/jcs090218)

If you would like to contribute to this project, you may either
clone and make pull requests to this repository. Or you can
clone the project and establish your own branch of this tool.
Any methods are welcome!
