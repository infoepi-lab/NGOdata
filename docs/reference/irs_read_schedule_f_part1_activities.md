# Read "type of activities conducted" for each Schedule F Part I row in a 990 XML

Uses the same XPaths as the full parser
([`parse_990_xml()`](https://infoepi-lab.github.io/irs-data/reference/parse_990_xml.md)
→ foreign activities).

## Usage

``` r
irs_read_schedule_f_part1_activities(xml_path)
```

## Arguments

- xml_path:

  Path to a Form 990 XML file.

## Value

Character vector, one string per matching group (use `NA_character_` if
blank).
