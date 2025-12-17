# Changelog for CyberShell

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Update Plaster build tool to last version

## [0.6.1] - 2024-04-30

### Added
- `Get-CsAzGovAssignment` to get azure governance assignments
- `Update-CsAzGovAssignment` to update governance assignments
- Automatic documentation generation

### Changed
- `Write-OutputPadded`: improve message handling
- `Import-CsEnvironment`: add capability to specify custom path for the config file using the CYBERSHELL_CONFIG environment variable

## [0.2.0] - 2024-04-08

### Added

- `Import-CsEnvironment`: Import settings and environments from JSON/JSONC files to configure PowerShell environments easily.
- `Write-OutputPadded`: Enhance output readability by formatting it with customizable padding and styling options.
- `Set-CsConfig`: Create or update configuration files to adjust PowerShell environment settings as needed.
- `Set-ScriptExecutionPreference`: Control script execution policies within scripts scope for improved display of verbose and debug messages

## [0.1.0-preview] - 2024-04-02

### Added

- Initialize module with Sampler: Use the [Sampler](https://github.com/gaelcolas/Sampler) framework to streamline PowerShell module development, including testing and CI/CD processes.
