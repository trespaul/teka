# teka: Bibliography and library management on the command line

## Structure

- records stored in a database containing CSL JSON data + extras
- attachments stored in filesystem; each attachment has description, location, hash, added, updated

## Global config

- how to connect to db
- how to connect to storage
- storage schema (?)
- ID and citation-key schema (?)
- attachment ID schema
- default file format override
- use specific config file

## Commands

- `add|import FILE(s) [-f|--format FORMAT]`: add a record(s)
  - takes JSON/YAML/bibtex from file or stdin (specify format with `--format`)
  - looks up DOI or ISBN or normal URL or whatever
    - specify how to lookup `ID` by specifying `--format` (alias `--type`) as "doi", "json", etc., otherwise decide with heuristics à la Zotero; also use Zotero's translators for website URLs
- `remove|rm|delete ID(s)|QUERY [--noconfirm]`
- `export|save|show ID(s)|QUERY [-f|--format FORMAT] [-o|--output FILE] [-a|--annotations]`
- `search STRING [--fulltext]`: does plain search
- `query QUERY`: does SQL query
- `edit ID(s)|QUERY`: export, open in ` $EDITOR`, and re-import / update
- `attach RECORD_ID FILE [-d|--description DESCRIPTION]`: if `FILE` is URL, fetch from web.
- `open ID(s)|QUERY [ATTACHMENT_ID]`: opens attachment with default applicatdion, ask for confirmation if no `ATTACHMENT_ID`

In a different format:

```
[-f|--format $FORMAT :: String]
[-c|--config $CONFIG :: String]
( add
    $FILES :: [String]
| remove
    ($QUERY :: String | $IDs :: [String])
| export
    ($QUERY :: String | $IDs :: [String])
    [-a|--annotations]
| search
    ($SEARCH :: String)
    [--fulltext]
| query
    ($QUERY :: String)
| edit
    ($QUERY :: String | $IDs :: [String])
| attach
    ($RECORD_ID :: String) ($FILE :: String)
    [-d|--description DESC :: String]
| open
    ($RECORD_ID :: String)
    [$ATTACHMENT_ID :: String]
)
```


## Query

- SQL query
- can leave out `SELECT ... FROM ... WHERE` --- will default to `SELECT * from db WHERE $QUERY`
- can leave out `FROM ...` since there is only one db
- can leave out `SELECT`, e.g., `author, title WHERE title = ...`
