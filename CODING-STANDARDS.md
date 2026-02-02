# NSO Services Coding Standards Reference

This document provides a comprehensive overview of all coding standards enforced in this project and where they are defined.

## 📋 Style Policies Overview

| Policy | Description | Enforcement Tool | Configuration File | Auto-fix Available |
|--------|-------------|------------------|-------------------|-------------------|
| **Naming Conventions** |
| Package suffix `-cfs` or `-rfs` | All package/service folders must end with `-cfs` (customer-facing) or `-rfs` (resource-facing) | Custom pre-commit hook | `scripts/check_naming.py` | ❌ Manual fix required |
| Service name suffix | Service names must follow same `-cfs` or `-rfs` convention | Custom pre-commit hook | `scripts/check_naming.py` | ❌ Manual fix required |
| Function/variable naming | Use `snake_case` for functions and variables | pylint | `pyproject.toml` | ❌ Manual fix required |
| Class naming | Use `PascalCase` for class names | pylint | `pyproject.toml` | ❌ Manual fix required |
| **Documentation** |
| Function docstrings | All functions must have Google-style docstrings | Custom pre-commit hook | `scripts/check_naming.py` | ❌ Manual fix required |
| Class docstrings | All classes must have docstrings | pylint | `pyproject.toml` | ❌ Manual fix required |
| Docstring format | Must follow Google style format | GitHub Copilot | `.github/copilot-instructions.md` | ✅ Copilot suggests correct format |
| **Type Hints** |
| Parameter type hints | All function parameters must have type hints | mypy + custom hook | `pyproject.toml` + `scripts/check_naming.py` | ❌ Manual fix required |
| Return type hints | All functions must have return type hints | mypy | `pyproject.toml` | ❌ Manual fix required |
| Type hint completeness | No incomplete type definitions allowed | mypy | `pyproject.toml` | ❌ Manual fix required |
| **Code Formatting** |
| Line length | Maximum 88 characters per line | Black | `pyproject.toml` | ✅ Auto-fixed by Black |
| Code style | PEP 8 compliance | Black + pylint | `pyproject.toml` | ✅ Auto-fixed by Black |
| Import sorting | Imports must be sorted alphabetically and grouped | isort | `pyproject.toml` | ✅ Auto-fixed by isort |
| Trailing whitespace | No trailing whitespace allowed | pre-commit hooks | `.pre-commit-config.yaml` | ✅ Auto-fixed |
| End of file | Files must end with newline | pre-commit hooks | `.pre-commit-config.yaml` | ✅ Auto-fixed |
| **Code Quality** |
| Unused imports | No unused imports allowed | pylint | `pyproject.toml` | ❌ Manual fix required |
| Unused variables | No unused variables allowed | pylint | `pyproject.toml` | ❌ Manual fix required |
| Code complexity | Functions should not be overly complex | pylint | `pyproject.toml` | ❌ Manual fix required |
| Maximum arguments | Functions should have max 7 arguments | pylint | `pyproject.toml` | ❌ Manual fix required |
| **NSO-Specific** |
| NSO imports | Proper use of `ncs` package imports | GitHub Copilot | `.github/copilot-instructions.md` | ✅ Copilot suggests correct imports |
| Callback naming | Service callbacks follow NSO patterns (cb_create, etc.) | GitHub Copilot | `.github/copilot-instructions.md` | ✅ Copilot suggests correct names |
| Transaction handling | Proper transaction and context handling | GitHub Copilot | `.github/copilot-instructions.md` | ✅ Copilot suggests correct patterns |

## 🔧 Configuration Files Detail

### `.github/copilot-instructions.md`
**Purpose**: Instructs GitHub Copilot on coding standards for AI-assisted code generation

**Enforces**:
- Package naming with `-cfs` or `-rfs` suffixes
- Google-style docstrings
- Type hints on all parameters and returns
- NSO-specific patterns (callbacks, imports, transactions)
- snake_case and PascalCase conventions

### `pyproject.toml`
**Purpose**: Central configuration for Python tooling

**Enforces**:
- Black formatting (88 char line length, Python 3.7+ target)
- isort import sorting (Black-compatible profile)
- mypy type checking (strict mode, no untyped definitions)
- pylint linting rules (max line length, max args, good variable names)

### `.pre-commit-config.yaml`
**Purpose**: Automated pre-commit validation hooks

**Enforces**:
- Code formatting with Black (auto-fix)
- Import sorting with isort (auto-fix)
- Type checking with mypy
- Custom naming conventions check
- Trailing whitespace removal (auto-fix)
- End-of-file newline (auto-fix)

### `scripts/check_naming.py`
**Purpose**: Custom validation for NSO-specific naming conventions

**Enforces**:
- Package/service folder names ending with `-cfs` or `-rfs`
- Presence of docstrings in all functions
- Presence of type hints in function parameters

### `.vscode/settings.json`
**Purpose**: VS Code editor configuration for team consistency

**Enforces**:
- Auto-formatting on save
- Linting on save
- Import organization on save
- Type checking mode
- Google-style docstring generation

## 📊 Enforcement Stages

### 1. **Development Time** (Interactive)
- **Tool**: GitHub Copilot + VS Code extensions
- **When**: While writing code
- **Action**: Suggests compliant code automatically

### 2. **Save Time** (Automatic)
- **Tool**: VS Code settings
- **When**: On file save
- **Action**: Auto-formats code, organizes imports

### 3. **Commit Time** (Blocking)
- **Tool**: Pre-commit hooks
- **When**: Before git commit
- **Action**: Validates all standards, blocks non-compliant commits

### 4. **Manual Check** (On-demand)
- **Tool**: Makefile targets
- **When**: Running `make dev-check`
- **Action**: Comprehensive validation report

## 🎯 Quick Reference

### To check compliance:
```bash
make dev-check
```

### To auto-fix formatting issues:
```bash
make dev-format
```

### To see what will be checked on commit:
```bash
pre-commit run --all-files
```

## ✅ Compliance Checklist

Before committing code, ensure:

- [ ] Package/service folders end with `-cfs` or `-rfs`
- [ ] All functions have Google-style docstrings
- [ ] All function parameters have type hints
- [ ] All functions have return type hints
- [ ] Code follows PEP 8 (Black will auto-fix this)
- [ ] Imports are sorted (isort will auto-fix this)
- [ ] No trailing whitespace (pre-commit will auto-fix this)
- [ ] No unused imports or variables
- [ ] NSO callbacks follow proper naming (cb_create, cb_pre_modification, etc.)

---

**Note**: Tools marked with ✅ for auto-fix will automatically correct violations. Tools marked with ❌ require manual code changes.
