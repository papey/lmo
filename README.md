# Let Me Out, Let Me Out!

This is not a dance !

LMO is a ruby app used to generate french "attestation de déplacement dérogatoire"
directly from cli.

## Getting Started

### Prerequisites

- [Ruby](https://www.ruby-lang.org/fr/)

### Usage

```sh
ruby lmo.rb --help
```

#### Advanced usage

LMO can fetch key value pairs directly from env. Add thoose to you `.profile`
for a quick generation.

- "LMO_NAME"
- "LMO_BIRTH_DATE"
- "LMO_BIRTH_LOCATION"
- "LMO_ADDRESS"
- "LMO_CITY"
- "LMO_REASON" (supported values : "work", "food", "family", "health", "sport", "justice", "mission")

With this method just pipe the output directly to the `lp` command and you're
out !

## Authors

- **Wilfried OLLIVIER** - _Main author_ - [Papey](https://github.com/papey)

## License

[LICENSE](LICENSE) file for details
