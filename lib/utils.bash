#!/usr/bin/env bash

set -euo pipefail

GITHUB_REPO="skiptools/skip"
GITHUB_API_BASE="https://api.github.com"
TOOL_NAME="skip"

fail() {
  echo -e "asdf-$TOOL_NAME: $*" >&2
  exit 1
}

# Get the current platform (darwin or linux)
get_platform() {
  local platform
  platform="$(uname -s | tr '[:upper:]' '[:lower:]')"
  case "$platform" in
    darwin) echo "macos" ;;
    linux) echo "linux" ;;
    *)
      fail "Unsupported platform: $platform. Skip only supports macOS and Linux."
      ;;
  esac
}

# Get architecture
get_arch() {
  local arch
  arch="$(uname -m)"
  case "$arch" in
    x86_64 | amd64) echo "x86_64" ;;
    aarch64 | arm64) echo "arm64" ;;
    *)
      fail "Unsupported architecture: $arch"
      ;;
  esac
}

# Get Linux architecture string for Skip artifactbundle paths
# Returns: x86_64 or aarch64 (matching Skip's directory naming)
get_linux_arch() {
  local arch
  arch="$(uname -m)"
  case "$arch" in
    x86_64 | amd64) echo "x86_64" ;;
    aarch64 | arm64) echo "aarch64" ;;
    *)
      fail "Unsupported Linux architecture: $arch"
      ;;
  esac
}

# Build curl command with optional authentication
# Uses GITHUB_API_TOKEN first, then GITHUB_TOKEN as fallback
curl_opts() {
  local token="${GITHUB_API_TOKEN:-${GITHUB_TOKEN:-}}"
  local opts=("--silent" "--fail" "--location")
  
  if [[ -n "$token" ]]; then
    opts+=("--header" "Authorization: token $token")
  fi
  
  opts+=("--header" "Accept: application/vnd.github+json")
  
  echo "${opts[@]}"
}

# Fetch a URL with curl and proper options
curl_github() {
  local url="$1"
  local opts
  read -ra opts <<< "$(curl_opts)"
  curl "${opts[@]}" "$url"
}

# Fetch a URL and include headers in output (for pagination)
curl_github_with_headers() {
  local url="$1"
  local token="${GITHUB_API_TOKEN:-${GITHUB_TOKEN:-}}"
  local opts=("--silent" "--fail" "--location" "--include")
  
  if [[ -n "$token" ]]; then
    opts+=("--header" "Authorization: token $token")
  fi
  
  opts+=("--header" "Accept: application/vnd.github+json")
  
  curl "${opts[@]}" "$url"
}

# Extract next page URL from Link header
# Link: <https://api.github.com/...?page=2>; rel="next", <https://...?page=67>; rel="last"
get_next_page_url() {
  local headers="$1"
  echo "$headers" | grep -i '^link:' | sed -n 's/.*<\([^>]*\)>; rel="next".*/\1/p'
}

# Fetch all releases with pagination support
# Outputs version numbers, one per line
fetch_all_versions() {
  local url="${GITHUB_API_BASE}/repos/${GITHUB_REPO}/releases?per_page=100"
  local versions=""
  local page_count=0
  local max_pages=100  # Safety limit
  
  while [[ -n "$url" && $page_count -lt $max_pages ]]; do
    page_count=$((page_count + 1))
    
    local response
    response="$(curl_github_with_headers "$url")" || fail "Failed to fetch releases from GitHub API"
    
    # Split response into headers and body
    local headers body
    headers="$(echo "$response" | sed '/^\r$/q')"
    body="$(echo "$response" | sed '1,/^\r$/d')"
    
    # Extract version tags from this page
    local page_versions
    page_versions="$(echo "$body" | grep -o '"tag_name": *"[^"]*"' | sed 's/"tag_name": *"\([^"]*\)"/\1/' || true)"
    
    if [[ -n "$page_versions" ]]; then
      if [[ -n "$versions" ]]; then
        versions="$versions"$'\n'"$page_versions"
      else
        versions="$page_versions"
      fi
    fi
    
    # Get next page URL
    url="$(get_next_page_url "$headers")"
  done
  
  echo "$versions"
}

# Sort versions (newest last for asdf convention)
sort_versions() {
  # Use version sort if available, otherwise basic sort
  if sort --version-sort /dev/null 2>/dev/null; then
    sort --version-sort
  else
    # Fallback: use sort with custom version handling
    sort -t. -k1,1n -k2,2n -k3,3n
  fi
}

# List all versions, space-separated
list_all_versions() {
  local versions
  versions="$(fetch_all_versions)"
  
  # Sort and output as space-separated list
  echo "$versions" | sort_versions | tr '\n' ' ' | sed 's/ $//'
}

# Get the latest stable version
get_latest_version() {
  local filter="${1:-}"
  
  if [[ -z "$filter" ]]; then
    # Use GitHub's latest release endpoint
    local response
    response="$(curl_github "${GITHUB_API_BASE}/repos/${GITHUB_REPO}/releases/latest")" || fail "Failed to fetch latest release"
    echo "$response" | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/"tag_name": *"\([^"]*\)"/\1/'
  else
    # Filter versions and get the latest matching one
    local versions
    versions="$(fetch_all_versions)"
    echo "$versions" | grep "^${filter}" | sort_versions | tail -1
  fi
}

# Get download URL for a specific version
get_download_url() {
  local version="$1"
  local platform
  platform="$(get_platform)"
  
  echo "https://github.com/${GITHUB_REPO}/releases/download/${version}/skip-${platform}.zip"
}

# Download a file to a destination
download_file() {
  local url="$1"
  local dest="$2"
  
  local token="${GITHUB_API_TOKEN:-${GITHUB_TOKEN:-}}"
  local opts=("--silent" "--fail" "--location" "--output" "$dest")
  
  if [[ -n "$token" ]]; then
    opts+=("--header" "Authorization: token $token")
  fi
  
  curl "${opts[@]}" "$url" || fail "Failed to download $url"
}
