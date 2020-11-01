# Let Me Out, Let Me Out!

This is not a dance !

LMO is a ruby app used to generate french "attestation de déplacement dérogatoire"
directly from cli.

Now supports QRCode output to SVG ! Covid Season 2 approved !

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
- "LMO_REASON" (supported values : "work", "purchase", "health", "familly", "handicap", "pets", "sport", "justice", "missions", "children")

With this method just pipe the output directly to the `lp` command and you're
out !

You can also output your attestation as a SVG QRCode with a combo of `-qr` and `-o` options !

#### Profiles

```yaml
name: NAME
firstname: Firstname
birth_date: 01/11/1990
birth_location: City
street: address
postal_code: code
city: city
```

LMO can read from key value pairs from profile files. Profile files are `.yml` file put in `profiles dir`. By default, profile dir is set to `~/.config/lmo/profiles` and can be customize with `LMO_PROFILES_DIR` env value.

When using a profile, just use `-p` to select profile name and `-r` flag to select a reason.

For example, using profile `example` from `~/.config/lmo/profiles/example.yml` with reason `purchase`

```bash
bundle exec ruby lmo.rb -r purchase -p example
```

### Forwarders

LMO can also send certificate and asssociated `svg` to multiple ouputs.

This outputs are enabled with the `-f` flag

Each forwarder requires a specific configuration, specified bellow

#### Mail

Enabled with `-f mail`

- "LMO_MAIL_DEST", destination mail address
- "LMO_MAIL_PORT", smtp server port
- "LMO_MAIL_USER", smtp server user
- "LMO_MAIL_PASSWORD" smtp server password
- "LMO_MAIL_SERVER", smtp server address

With **Google** and **2FA**, you need to [create an application with application password](https://support.google.com/accounts/answer/185833?hl=en).

Use this password as `LMO_MAIL_PASSWORD` value.

#### Telegram

Create a [Telegram Bot](https://core.telegram.org/bots#creating-a-new-bot) and save the bot token

Enabled with `-f telegram`

- "LMO_TELEGRAM_CHAT", destination chat ID
- "LMO_TELEGRAM_TOKEN", bot token

To get your **Telegram Chat ID**, invite your bot to a channel, send a dummy message to it (do not forget to mention it with @botname),
check `https://api.telegram.org/bot$BOT_TOKEN/getUpdates` and replace bot token value.

### Bot usage

LMO now supports a Telegram Bot mode ! (kudos [@tomMoulard](https://github.com/tomMoulard) for the motivation)

```bash
LMO_TELEGRAM_TOKEN=VALUE bundle exec ruby bot/bot.rb
```

Use `/start` or `/help` to get help message.

This mode use profile files as decribe in profiles section. Profile name is the Telegram user ID. To get your ID ask `/me` to the bot instance.

#### Docker container

A [Docker container](https://hub.docker.com/r/papey/lmo) is available with bot mode as default.

```bash
docker container run e LMO_TELEGRAM_TOKEN=VALUE -v /path/to/profile:/srv/lmo/profiles papey/lmo:latest
```

## Authors

- **Wilfried OLLIVIER** - _Main author_ - [Papey](https://github.com/papey)

## License

[LICENSE](LICENSE) file for details
