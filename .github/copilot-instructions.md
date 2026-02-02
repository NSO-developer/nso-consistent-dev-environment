# NSO Services Development Guidelines for GitHub Copilot

You are assisting with Cisco NSO service development in Python.

## Naming Conventions
- ALL package folder names MUST end with `-cfs` (for customer-facing services) or `-rfs` (for resource-facing services)
- ALL service names MUST end with `-cfs` or `-rfs`
- Use snake_case for functions and variables
- Use PascalCase for classes

## Code Style Requirements
- ALWAYS add docstrings to every function and class using Google style format
- ALWAYS add type hints to every function parameter and return value
- Use Python 3.7+ type hints from `typing` module when needed
- Follow PEP 8 style guide

## Docstring Format
Use Google-style docstrings:
```python
def function_name(param1: str, param2: int) -> bool:
    """Brief description of function.
    
    Detailed description if needed.
    
    Args:
        param1: Description of param1
        param2: Description of param2
        
    Returns:
        Description of return value
        
    Raises:
        ExceptionType: When this exception is raised
    """
```

## NSO-Specific Guidelines
- Service callbacks should follow NSO naming patterns (cb_create, cb_pre_modification, etc.)
- Use proper NFVO/NSO imports from `ncs` package
- Handle transactions and service context properly
