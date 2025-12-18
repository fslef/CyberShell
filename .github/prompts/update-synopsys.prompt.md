---
description: "Review and update PowerShell function comment-based help to ensure complete and accurate documentation"
agent: "agent"
model: "GPT-5.2"
---

# Update PowerShell Function Synopsis

Review and update the comment-based help block for all PowerShell functions in this repository. Ensure that every file in scope (all public and private function scripts) is processed until completion. For each function, the comment-based help block (synopsis block) must be placed immediately after the function name and before the param block, inside the function definition, to comply with project conventions. All other requirements below must also be met. Do not stop until every file is compliant.

## Formatting and Style

- Use consistent indentation (4 spaces) for all content under each help tag (e.g., .SYNOPSIS, .DESCRIPTION, .PARAMETER, etc.).
- Place a blank line between each major help tag (e.g., between .SYNOPSIS and .DESCRIPTION, between .DESCRIPTION and .PARAMETER, etc.).
- For .PARAMETER and .EXAMPLE sections, keep the content readable and aligned, following the style of existing well-formatted help blocks in the codebase.
- Do not compress help blocks into a single paragraph; preserve logical line breaks and paragraph structure for clarity.
- Use the original style as seen in existing compliant files (such as Get-DSFileInventory.ps1) as the standard for all future help blocks.

## Requirements

All public PowerShell functions must have complete comment-based help that includes.prompts for the following sections:

### 1. .SYNOPSIS

- Must be present
- Should be a brief, one-line description of what the function does
- Keep it concise (typically under 100 characters)
- Use active voice and start with a verb

### 2. .DESCRIPTION

- Must be present
- Must be longer than 40 characters
- Should provide detailed explanation of the function's purpose and behavior
- Explain what the function does, not how it does it
- Include any important context or prerequisites

### 3. .EXAMPLE

- Must have at least one example
- Should demonstrate the most common use case first
- Include example output or results when helpful
- Add multiple examples for complex functions showing different scenarios
- Each example should have a description explaining what it does

### 4. .PARAMETER

- Must describe all parameters
- Each parameter description should explain:
  - What the parameter does
  - Valid values or format expected
  - Whether it accepts pipeline input
  - Any default values if applicable

## Example Format

```powershell
<#
.SYNOPSIS
    Gets the sanitization configuration for the current session.

.DESCRIPTION
    The Get-DSConfig function retrieves the current DataSanitizer configuration
    settings that control how data detection and sanitization operations are performed.
    This includes detection rules, file paths, and processing options.

.PARAMETER Path
    The path to the configuration file. If not specified, uses the default
    configuration location in the module directory.

.PARAMETER Detailed
    Returns additional configuration metadata including load time and source file.

.EXAMPLE
    Get-DSConfig

    Retrieves the current configuration using default settings.

.EXAMPLE
    Get-DSConfig -Path "C:\Custom\config.json"

    Loads configuration from a custom location.

.EXAMPLE
    Get-DSConfig -Detailed

    Returns the configuration with additional metadata about when and where
    it was loaded from.

.OUTPUTS
    PSCustomObject
    Returns a custom object containing the configuration settings.

.NOTES
    This function is typically called automatically during module initialization.
#>
```

## Validation Checklist

Before completing the update, verify:

- [ ] `.SYNOPSIS` exists and is concise
- [ ] `.DESCRIPTION` exists and is longer than 40 characters
- [ ] At least one `.EXAMPLE` is provided
- [ ] All function parameters have `.PARAMETER` descriptions
- [ ] Examples show realistic usage scenarios
- [ ] Parameter descriptions explain purpose and expected values
- [ ] Help text follows PowerShell conventions

## Accuracy Review

**CRITICAL**: Verify that existing help documentation matches the current code implementation:

- [ ] **Parameter list matches**: All parameters in the function signature have `.PARAMETER` entries
- [ ] **No orphaned parameters**: Remove `.PARAMETER` entries for parameters that no longer exist
- [ ] **Parameter types accurate**: Verify type declarations match the actual parameter types
- [ ] **Default values current**: Update any mentioned default values to match code
- [ ] **Mandatory status correct**: Document which parameters are mandatory vs optional
- [ ] **Pipeline support accurate**: Verify `ValueFromPipeline` and `ValueFromPipelineByPropertyName` claims
- [ ] **Return type matches**: `.OUTPUTS` section reflects what the function actually returns
- [ ] **Examples work**: Test each example to ensure it runs without errors
- [ ] **Behavior described correctly**: `.DESCRIPTION` accurately reflects current function logic
- [ ] **WhatIf/Confirm support**: Document if function supports `-WhatIf` and `-Confirm`

### Common Issues to Check

1. **Parameters added/removed**: Code may have been refactored without updating help
2. **Parameter renamed**: Old parameter names in examples or descriptions
3. **Changed default values**: Help mentions old defaults
4. **Modified behavior**: Description doesn't match current implementation
5. **Broken examples**: Examples use outdated syntax or removed features
6. **Missing new features**: Recent functionality not documented
7. **Incorrect pipeline behavior**: Help claims don't match actual implementation

## Additional Best Practices

- Use `.OUTPUTS` to document the type of object returned
- Ensure help text is grammatically correct and professional
- Test help display with `Get-Help <FunctionName> -Full`

## Files to Review

Review **all** functions in both public and private directories:

- `source/Public/**/*.ps1` - Exported functions used by module consumers (critical)
- `source/Private/**/*.ps1` - Internal functions used within the module

### Documentation Priority

**Public Functions** (highest priority):

- Complete, detailed documentation is critical
- These are exported and used by external consumers
- Examples must be comprehensive and realistic
- All parameters must be thoroughly documented

**Private Functions** (still important):

- Complete documentation helps maintainability
- Assists other developers working on the module
- May be less detailed than public functions but still required
- Examples can focus on internal use cases
- Helps with code understanding and refactoring

Both public and private functions must meet all requirements, but public functions should have more comprehensive examples and descriptions since they form the module's public API.
