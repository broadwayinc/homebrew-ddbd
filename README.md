# Homebrew tap for DDBD

[DDBD](https://ddbd.skapi.com) is a lightweight schemaless record database server with writer-based
access control. The program is called `ddbd`. It runs on macOS 11 and newer (Apple Silicon and Intel) and on
Linux with Homebrew. Source: [broadwayinc/DDBD](https://github.com/broadwayinc/DDBD).

```bash
brew install broadwayinc/ddbd/ddbd
```

or tap once, then use the short name:

```bash
brew tap broadwayinc/ddbd
brew install ddbd
```

Installing sets up a data folder at `$(brew --prefix)/var/ddbd` that listens on this machine only
(`127.0.0.1:7070`, plain HTTP). Run it in the background, and at every login:

```bash
brew services start ddbd
```

or in a terminal:

```bash
ddbd start --data "$(brew --prefix)/var/ddbd"
```

Then add the first user:

```bash
ddbd admin --data "$(brew --prefix)/var/ddbd" user add <name> --level 00
```

As a service, the server writes its log to `$(brew --prefix)/var/log/ddbd.log`. Its settings are in
`$(brew --prefix)/var/ddbd/ddbd.toml`; restart it after changing them (`brew services restart ddbd`).

Update with `brew upgrade ddbd`. The data folder stays where it is across upgrades and is not removed by
`brew uninstall ddbd`.

The formula is written for each release by `tools/formula.sh` in the DDBD repository.
