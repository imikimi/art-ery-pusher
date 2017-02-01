# art-boilerplate

Recommended usage:

* **fork it on github** That way you can pull updates from the boiler-plate if you want.

### Organization

* `source/` all production source
* `test/` all test source
* `performance/` all performance tests

The only source files that should be in the root are aliases to files in source. The purpose of these files is to provide external reference points for other modules to require without needing to know the internal structure of this module.

Why no source in root? Because it supports the commond task of searching source code. Typically you want to search all produciton-source, all tests or all performance independently.