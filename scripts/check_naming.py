#!/usr/bin/env python3
"""Pre-commit hook to validate NSO service naming conventions."""

import re
import sys
from pathlib import Path
from typing import List


def check_package_naming(filepath: Path) -> List[str]:
    """Check if package/service names follow -cfs or -rfs suffix convention.
    
    Args:
        filepath: Path to the Python file being checked
        
    Returns:
        List of error messages, empty if no errors
    """
    errors = []
    parts = filepath.parts
    
    # Check if any parent directory looks like a service package
    for part in parts:
        if 'service' in part.lower() or part.endswith('-pkg'):
            if not (part.endswith('-cfs') or part.endswith('-rfs')):
                errors.append(
                    f"Package/service name '{part}' must end with '-cfs' or '-rfs'"
                )
    
    return errors


def check_docstrings_and_types(filepath: Path) -> List[str]:
    """Check for missing docstrings and type hints in Python functions.
    
    Args:
        filepath: Path to the Python file being checked
        
    Returns:
        List of error messages, empty if no errors
    """
    errors = []
    content = filepath.read_text()
    lines = content.split('\n')
    
    # Simple regex to find function definitions
    func_pattern = re.compile(r'^\s*def\s+(\w+)\s*\((.*?)\)')
    
    i = 0
    while i < len(lines):
        match = func_pattern.match(lines[i])
        if match:
            func_name = match.group(1)
            params = match.group(2)
            
            # Skip if it's a special method (but not __init__)
            if func_name.startswith('__') and func_name != '__init__':
                i += 1
                continue
            
            # Check for type hints in parameters
            if params and 'self' not in params and 'cls' not in params:
                if ':' not in params:
                    errors.append(
                        f"{filepath}:{i+1}: Function '{func_name}' missing type hints"
                    )
            
            # Check for docstring (next non-empty line should start with """)
            i += 1
            while i < len(lines) and not lines[i].strip():
                i += 1
            
            if i < len(lines):
                if not lines[i].strip().startswith('"""'):
                    errors.append(
                        f"{filepath}:{i}: Function '{func_name}' missing docstring"
                    )
        i += 1
    
    return errors


def main() -> int:
    """Main entry point for the naming convention checker.
    
    Returns:
        Exit code: 0 for success, 1 for failures
    """
    files = sys.argv[1:]
    all_errors = []
    
    for file_path in files:
        path = Path(file_path)
        
        # Check naming conventions
        errors = check_package_naming(path)
        all_errors.extend(errors)
        
        # Check docstrings and type hints
        errors = check_docstrings_and_types(path)
        all_errors.extend(errors)
    
    if all_errors:
        print("\n".join(all_errors))
        return 1
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
