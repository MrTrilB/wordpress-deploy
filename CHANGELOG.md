# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/SemVer).

## [1.1.0] - 2025-11-16

### Added

- Automatic use of `.deployignore` file if it exists in the source path for excluding files from deployment

- Automatic cleanup (removal of non-deployment files) when `.deployignore` is present

### Changed

- Removed separate `CLEANUP` option; cleanup is now automatic when `.deployignore` is used

- Updated documentation to reflect automatic cleanup behavior

- Modified example workflow to remove `CLEANUP` input

## [1.0.1] - 2025-11-15

### Changed

- Update action.yml with minor improvements

## [1.0.0] - 2025-11-14

### Added

- Initial release of WordPress Plugin/Theme Deployment Action

- SSH-based deployment using rsync

- Support for custom source paths, flags, PHP linting, cache clearing, and post-deploy scripts

- Basic file exclusion with `--exclude='.*'`
