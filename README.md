# asdf-skip

[![Test](https://github.com/bitfrost/asdf-skip/actions/workflows/test.yml/badge.svg)](https://github.com/bitfrost/asdf-skip/actions/workflows/test.yml)

[Skip](https://skip.dev) plugin for the [asdf version manager](https://asdf-vm.com).

## Dependencies

- `bash`, `curl`, `unzip`

## Install

Plugin:

```shell
asdf plugin add skip https://github.com/bitfrost/asdf-skip.git
```

Skip:

```shell
# Show all installable versions
asdf list all skip

# Install latest version
asdf install skip latest

# Install specific version
asdf install skip 1.7.0

# Set a version globally
asdf set -u skip 1.7.0

# Verify installation
skip version
```

Check the [asdf documentation](https://asdf-vm.com) for more instructions on managing versions.

## Configuration

### GitHub API Token

To avoid rate limiting when listing versions, you can set a GitHub token:

```shell
export GITHUB_API_TOKEN="your_github_token"
# or
export GITHUB_TOKEN="your_github_token"
```

In GitHub Actions:

```yaml
env:
  GITHUB_API_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Usage

After installation, the `skip` CLI is available. See the [Skip CLI Reference](https://skip.dev/docs/skip-cli/) for all commands.

```shell
skip checkup  # Verify development environment
skip create   # Create a new project
skip --help   # Show available commands
```

## Platform Support

See [Skip's Getting Started guide](https://skip.dev/docs/gettingstarted/) for requirements.

This plugin supports **macOS** and **Linux**. Full Skip app development requires macOS with Xcode.

## Links

- [Skip Website](https://skip.dev)
- [Skip Documentation](https://skip.dev/docs/)
- [Skip GitHub](https://github.com/skiptools/skip)

## License

MIT - see [LICENSE](LICENSE)
