# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Resource Map documentation (`RESOURCE_MAP.md`)
- MIT License file
- Enhanced README with documentation links

### Changed
- Updated Terraform version requirement to `>= 1.13.0`
- Updated Azure provider version to `~> 4.38.1`
- Updated all examples to use latest provider versions

### Fixed
- Version constraints in `versions.tf`
- Provider version references in README
- Example configurations to match current requirements

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Azure Virtual WAN Terraform module
- Support for Virtual WAN and Virtual Hub creation
- Site-to-Site VPN Gateway and connections
- ExpressRoute Gateway and connections
- Point-to-Site VPN Gateway with server configuration
- Virtual Hub route tables and custom routing
- Network Security Groups for Virtual Hub
- Virtual network connections (spoke connectivity)
- Comprehensive variable validation
- Extensive output values for integration
- Basic and advanced examples
- Complete documentation with architecture diagrams

### Features
- Modular design with conditional resource creation
- Comprehensive tagging strategy
- Input validation for all critical parameters
- Support for all major Virtual WAN components
- Flexible configuration options
- Production-ready security controls

## Version Compatibility

| Module Version | Terraform Version | Azure Provider Version |
|----------------|-------------------|------------------------|
| 1.0.0+         | >= 1.13.0         | ~> 4.38.1              |

## Migration Guide

### From Pre-1.0.0 Versions
- Update Terraform version to 1.13.0 or later
- Update Azure provider to 4.38.1 or later
- Review variable names for any breaking changes
- Test in non-production environment first

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 