# Let Me Out, Let Me Out!

This is not a dance !

LMO is a ruby app used to generate french "attestation de déplacement dérogatoire"
directly from cli.

Now supports QRCode output to SVG !

## Getting Started

### Prerequisites

- [Ruby](https://www.ruby-lang.org/fr/)
- [Bundler](https://bundler.io/)

### Install

```sh
bundle install
```

### Usage

```sh
bundle exec ruby lmo.rb --help
```

#### Advanced usage

LMO can fetch key value pairs directly from env. Add thoose to your `.profile`
for a quick generation.

- "LMO_NAME"
- "LMO_FIRSTNAME"
- "LMO_BIRTH_DATE"
- "LMO_BIRTH_LOCATION"
- "LMO_STREET"
- "LMO_POSTAL_CODE"
- "LMO_CITY"
- "LMO_REASON" (supported values : "work", "food", "family", "health", "sport", "justice", "mission")

With this method just pipe the output directly to the `lp` command and you're
out !

You can also output your attestation as a SVG QRCode with a combo of `-qr` and `-o` options !

## Authors

- **Wilfried OLLIVIER** - _Main author_ - [Papey](https://github.com/papey)

## License

[LICENSE](LICENSE) file for details
