# Lists

All members of a list are lines beginning at the same indentation level starting with a "- " (a dash and a space):

```yaml
# A list of tasty fruits
- Apple
- Orange
- Strawberry
- Mango
```

```yaml
---
# Abbreviated form
['Apple', 'Orange', 'Strawberry', 'Mango']
```

# Dictionary

```yaml
martin:
  name:  Martin D'vloper
  job:   Developer
  skill: Elite
  skills:
    - python
    - perl
    - pascal
```

```yaml
# Abbreviated form
martin: {name: Martin D'vloper, job: Developer, skill: Elite}
```

# Multiple Line Span

```yaml
include_newlines: |
            exactly as you see
            will appear these three
            lines of poetry

fold_newlines: >
            this is really a
            single line of text
            despite appearances
```