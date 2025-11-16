# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/SemVer).

## [1.1.0] - 2025-11-16

### Added
- `CLEANUP` option to remove files and folders from the server that are not present in the deployment source
- Preview functionality that lists files and folders to be removed when `CLEANUP` is enabled
- Automatic use of `.deployignore` file if it exists in the source path for excluding files from deployment

### Changed
- Updated documentation to reflect automatic `.deployignore` handling
- Modified example workflow to demonstrate new `CLEANUP` option

## [1.0.1] - 2025-11-15

### Changed
- Update action.yml with minor improvements

## [1.0.0] - 2025-11-14

### Added
- Initial release of WordPress Plugin/Theme Deployment Action
- SSH-based deployment using rsync
- Support for custom source paths, flags, PHP linting, cache clearing, and post-deploy scripts
- Basic file exclusion with `--exclude='.*'`