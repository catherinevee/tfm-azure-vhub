# Testing Guide for Azure Virtual WAN Module

This directory contains tests for the Azure Virtual WAN Terraform module to ensure reliability and functionality.

## Test Structure

### `basic.tftest.hcl`
Comprehensive test suite that validates:
- Basic Virtual WAN and Virtual Hub creation
- Custom configuration options
- VPN Gateway functionality
- ExpressRoute Gateway functionality
- Point-to-Site VPN Gateway functionality
- Network Security Group configuration
- Route Table configuration

## Running Tests

### Prerequisites
- Terraform 1.13.0 or later
- Azure provider 4.38.1 or later
- Azure CLI configured with appropriate permissions

### Running All Tests
```bash
cd tests
terraform test
```

### Running Specific Tests
```bash
cd tests
terraform test -run="basic_virtual_wan_creation"
```

### Running Tests with Verbose Output
```bash
cd tests
terraform test -verbose
```

## Test Coverage

The test suite covers the following scenarios:

### Core Functionality
- ✅ Virtual WAN creation with default settings
- ✅ Virtual Hub creation and association
- ✅ Custom Virtual WAN and Hub configurations
- ✅ Address prefix validation
- ✅ SKU and type validation

### VPN Connectivity
- ✅ Site-to-Site VPN Gateway creation
- ✅ VPN Gateway scale unit configuration
- ✅ VPN Gateway association with Virtual Hub

### ExpressRoute Connectivity
- ✅ ExpressRoute Gateway creation
- ✅ ExpressRoute Gateway scale units
- ✅ ExpressRoute Gateway association with Virtual Hub

### Point-to-Site VPN
- ✅ P2S VPN Gateway creation
- ✅ P2S VPN Gateway scale unit configuration
- ✅ P2S VPN Gateway association with Virtual Hub

### Network Security
- ✅ Network Security Group creation
- ✅ Security rule configuration
- ✅ NSG rule validation

### Routing
- ✅ Route table creation
- ✅ Custom route configuration
- ✅ Route validation

## Test Validation

Each test includes assertions to validate:
- Resource names match input variables
- Resource associations are correct
- Configuration values are properly set
- Resource dependencies are established
- Default values are applied correctly

## Adding New Tests

When adding new tests:

1. **Follow the naming convention**: Use descriptive names that indicate the test purpose
2. **Include comprehensive assertions**: Test both the resource creation and configuration
3. **Use realistic test data**: Use values that represent real-world scenarios
4. **Test edge cases**: Include tests for boundary conditions and error scenarios
5. **Document test purpose**: Add comments explaining what the test validates

### Example Test Structure
```hcl
run "test_name" {
  command = plan

  variables {
    # Test variables
  }

  assert {
    condition     = resource.attribute == expected_value
    error_message = "Descriptive error message"
  }
}
```

## Continuous Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run Terraform Tests
  run: |
    cd tests
    terraform init
    terraform test
```

## Troubleshooting

### Common Issues

1. **Provider Version Mismatch**: Ensure you're using the correct Azure provider version
2. **Authentication Issues**: Verify Azure CLI is properly configured
3. **Resource Naming Conflicts**: Use unique names for test resources
4. **Timeout Issues**: Some resources may take time to validate

### Debug Mode
Run tests with debug output:
```bash
export TF_LOG=DEBUG
terraform test
```

## Best Practices

1. **Isolation**: Each test should be independent and not rely on other tests
2. **Cleanup**: Tests should not create persistent resources
3. **Validation**: Always include assertions to validate expected behavior
4. **Documentation**: Keep test documentation up to date
5. **Performance**: Optimize tests to run quickly while maintaining coverage

## Contributing

When contributing tests:
- Follow the existing test patterns
- Add appropriate assertions
- Update this README if adding new test categories
- Ensure tests pass before submitting pull requests 