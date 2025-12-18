function Write-OutputPadded {
    <#
.SYNOPSIS
    Writes colorized console output with indentation.

.DESCRIPTION
    This function formats text for console display with indentation, centering and
    message styles (Information, Success, Warning, Error, Important, Verbose, Debug, Data).
    Verbose/Debug/Data messages are controlled by $script:VerbosePreference and
    $script:DebugPreference.

.PARAMETER Text
    Text to display.
    Does not accept pipeline input.

.PARAMETER IdentLevel
    Indentation level (4 spaces per level).
    Default: 0.

.PARAMETER Width
    Total output width used for centering and title borders.
    Default: 120.

.PARAMETER Centered
    When specified, centers the text within Width.

.PARAMETER isTitle
    When specified, writes a top/bottom border and applies centering.

.PARAMETER Type
    Message type that controls coloring.
    Valid values: Information, Success, Warning, Error, Important, Verbose, Debug, Data.

.PARAMETER BlankLineBefore
    When specified, writes a blank line before the output.

.EXAMPLE
    Write-OutputPadded -Text 'Governance Assignments' -IdentLevel 1 -isTitle -Type Information

    Writes an indented title.

.EXAMPLE
    Write-OutputPadded -Text 'Something failed' -Type Error -IdentLevel 2

    Writes an indented error message.

.OUTPUTS
    None
    Writes to the host via Write-Host.

.NOTES
    Uses Write-Host to support coloring.
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Write-Host used for colorized output formatting.")]
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Text,

        [Parameter(Position = 1, Mandatory = $false)]
        [int]$IdentLevel = 0,

        [Parameter(Mandatory = $false)]
        [int]$Width = 120,

        [Parameter(Mandatory = $false)]
        [switch]$Centered = $false,

        [Parameter(Mandatory = $false)]
        [switch]$isTitle = $false,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Information", "Success", "Warning", "Error", "Important", "Verbose", "Debug", "Data")]
        [string]$Type,

        [Parameter(Mandatory = $false)]
        [switch]$BlankLineBefore = $false

    )

    # Skip if the message type is "Debug" or "Data" and the debug preference is false
    # or if the message type is "Verbose" and the verbose preference is false
    if ((($Type -eq "Debug" -or $Type -eq "Data") -and $script:DebugPreference -ne "Continue") -or
        ($Type -eq "Verbose" -and $script:VerbosePreference -ne "Continue")) {
        return
    }

    $indentation = $IdentLevel * 4
    $effectiveWidth = $Width - $indentation
    $wrappedLines = @()

    if ($Text.Length -le $effectiveWidth) {
        $wrappedLines += $Text
    }
    else {
        $numLines = [math]::Ceiling($Text.Length / $effectiveWidth)
        for ($i = 0; $i -lt $numLines; $i++) {
            $start = $i * $effectiveWidth
            $length = [math]::Min($effectiveWidth, $Text.Length - $start)
            $wrappedLines += $Text.Substring($start, $length)
        }
    }


    if ($BlankLineBefore) {
        Write-Host ""
    }

    if ($isTitle) {
        $topBorder = "=" * $Width
        Write-Host $topBorder
    }

    foreach ($line in $wrappedLines) {
        $linePadding = ""
        if ($Centered -or $isTitle) {
            $totalPadding = $Width - $line.Length
            $leftPadding = [math]::Floor($totalPadding / 2)
            $linePadding = ' ' * ($leftPadding + $indentation)
            #$line = $line.PadRight($Width - $leftPadding, ' ')
        }
        else {
            $linePadding = ' ' * $indentation
            # Remove right padding if not a title
            if (!$isTitle) {
                $line = $line.TrimEnd(' ')
            }
        }

        Write-Host -NoNewline $linePadding

        switch ($Type) {
            "Information" {
                Write-Host $line -ForegroundColor Cyan
            }
            "Success" {
                Write-Host $line -ForegroundColor Green
            }
            "Warning" {
                Write-Host $line -ForegroundColor Black -BackgroundColor DarkYellow -NoNewline
                Write-Host " "
            }
            "Error" {
                Write-Host $line -ForegroundColor Red
            }
            "Important" {
                Write-Host $line -ForegroundColor White -BackgroundColor DarkRed -NoNewline
                Write-Host " "
            }
            "Verbose" {
                if ($script:VerbosePreference -eq "Continue") {
                    Write-Host $line -ForegroundColor DarkGray
                }
            }
            "Debug" {
                if ($script:DebugPreference -eq "Continue") {
                    Write-Host $line -ForegroundColor DarkGray
                }
            }
            "Data" {
                if ($script:DebugPreference -eq "Continue") {
                    Write-Host $line -ForegroundColor Magenta
                }
            }
            default { Write-Host $line }
        }
    }

    if ($isTitle) {
        $bottomBorder = "-" * $Width
        Write-Host $bottomBorder
    }
}