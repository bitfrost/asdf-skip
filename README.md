# asdf-skip

[![Test](https://github.com/YOUR_USERNAME/asdf-skip/actions/workflows/test.yaml/badge.svg)](https://github.com/YOUR_USERNAME/asdf-skip/actions/workflows/test.yaml)

[Skip](https://skip.dev) plugin for the [asdf version manager](https://asdf-vm.com).

Skip enables the creation of dual-platform native apps in Swift that run on both iOS and Android.

## Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Configuration](#configuration)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Dependencies

- `bash`, `curl`, `unzip`: generic POSIX utilities

## Install

Plugin:

```shell
asdf plugin add skip https://github.com/YOUR_USERNAME/asdf-skip.git
```

Skip:

```shell
# Show all installable versions
asdf list all skip

# Install specific version
asdf install skip 1.7.0

# Install latest version
asdf install skip latest

# Set a version globally (in your ~/.tool-versions file)
asdf set -u skip 1.7.0

# Verify installation
skip --version

# Run Skip checkup to verify your development environment
skip checkup
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to install & manage versions.

## Configuration

### GitHub API Token

When listing versions, this plugin makes requests to the GitHub API. To avoid rate limiting (especially in CI environments), you can set a GitHub token:

```shell
# Option 1: asdf-specific token (recommended)
export GITHUB_API_TOKEN="your_github_token"

# Option 2: Generic GitHub token (also supported)
export GITHUB_TOKEN="your_github_token"
```

The plugin checks `GITHUB_API_TOKEN` first, then falls back to `GITHUB_TOKEN`.

To create a token, visit [GitHub Settings > Tokens](https://github.com/settings/tokens) and create a token with `public_repo` scope (or no scopes for public repositories).

### In GitHub Actions

```yaml
- name: Install Skip
  env:
    GITHUB_API_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    asdf plugin add skip https://github.com/YOUR_USERNAME/asdf-skip.git
    asdf install skip latest
```

## Usage

After installation, you can use all Skip CLI commands:

```shell
# Check your development environment
skip checkup

# Create a new Skip project
skip create

# Get help
skip --help
```

For more information on using Skip, see the [Skip documentation](https://skip.dev/docs/).

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| macOS | Supported | Universal binary (Intel + Apple Silicon) |
| Linux | Supported | Static binary |
| Windows | Not supported | Use WSL2 with Linux binary |

> **Note:** While Skip can be installed on Linux, full app development (creating iOS apps) requires macOS with Xcode installed.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork it
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Create a new Pull Request

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Links

- [Skip Website](https://skip.dev)
- [Skip Documentation](https://skip.dev/docs/)
- [Skip GitHub](https://github.com/skiptools/skip)
- [asdf Version Manager](https://asdf-vm.com)
