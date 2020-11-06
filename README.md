# CleverCSV pre-commit dummy package

This repository contains a dummy package with a 
[pre-commit](https://pre-commit.com) hook for standardizing CSV files using 
[CleverCSV](https://www.github.com/alan-turing-institute/CleverCSV). 

To use this pre-commit hook, first install 
[pre-commit](https://pre-commit.com/#install). Next, add the following 
configuration to your ``.pre-commit-config.yaml`` file:

```yaml
repos:
  - repo: https://github.com/alan-turing-institute/CleverCSV-pre-commit
    rev: 0.6.6      # or any later version
    hooks:
      - id: clevercsv-standardize
```

Finally, run ``pre-commit install`` to register your pre-commit hook.
