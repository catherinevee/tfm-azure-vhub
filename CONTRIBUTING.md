# Contributing to Azure Virtual WAN Terraform Module

We welcome contributions to this Azure Virtual WAN Terraform module. Whether you're:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Development Process

We use GitHub to host code, track issues and feature requests, and accept pull requests.

## Pull Request Process

We follow the [GitHub Flow](https://guides.github.com/introduction/flow/) for contributions:

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

## Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/) for commit messages to help with automated changelog generation and semantic versioning.

### Commit Message Format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools

## License

Any contributions you make will be under the MIT Software License. When you submit code changes, your submissions are understood to be under the same [MIT License](http://choosealicense.com/licenses/mit/) that covers the project.

## Bug Reports

Report bugs using GitHub's [issue tracker](https://github.com/your-repo/issues). Report a bug by [opening a new issue](https://github.com/your-repo/issues/new).

### Bug Report Guidelines

Good bug reports include:

- A quick summary and/or background
- Steps to reproduce (be specific)
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

## Coding Style

* Use 2 spaces for indentation
* Use meaningful variable names
* Add comments to complex logic
* Follow Terraform best practices
* Use consistent naming conventions (lowercase with underscores)

## Terraform Guidelines

### Code Style
- Use `terraform fmt` to format your code
- Use `terraform validate` to check syntax
- Use `terraform plan` to verify changes
- Follow HashiCorp's [Terraform Style Guide](https://www.terraform.io/docs/language/style/index.html)

### Variable Definitions
- Always provide descriptions for variables
- Use appropriate types and constraints
- Add validation blocks where appropriate
- Use default values when reasonable

### Resource Definitions
- Use consistent naming conventions
- Add appropriate tags to all resources
- Use data sources when appropriate
- Follow the principle of least privilege

### Documentation
- Update README.md for any new features
- Add examples for new functionality
- Update the resource map if new resources are added
- Keep the changelog up to date

## License

By contributing, you agree that your contributions will be licensed under its MIT License. 