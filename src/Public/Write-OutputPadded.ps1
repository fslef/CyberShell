function Write-OutputPadded {
    <#
.SYNOPSIS
   Writes colorized and formatted output to the console.

.DESCRIPTION
   The Write-OutputPadded function writes colorized and formatted output to the console. It supports indentation, centering, and different types of messages (Error, Warning, Success, Information, Data, Debug, Important).

.PARAMETER Text
   The text to be written to the console.

.PARAMETER IdentLevel
   The level of indentation for the output text. Default is 0.

.PARAMETER Width
   The width of the output text. Default is 120.

.PARAMETER Centered
   If set, the output text will be centered.

.PARAMETER isTitle
   If set, the output text will be formatted as a title.

.PARAMETER Type
   The type of the message. It can be one of the following: "Error", "Warning", "Success", "Information", "Data", "Debug", "Important". The type determines the color of the output text.

.PARAMETER BlankLineBefore
    If set, a blank line will be written before the output text.

.EXAMPLE
   Write-OutputPadded -Text "Title" -isTitle -Type "Important"
   Writes the text "Title" formatted as a title and colors it as an Important message.

.EXAMPLE
   Write-OutputPadded -Text "This is a ERROR demo text" -Type "Error" -IdentLevel 2
   Writes the text "This is a ERROR demo text" with an indentation level of 2 and colors it as an Error message.

.EXAMPLE
   Write-OutputPadded -Text "This is a WARNING demo text" -Type "Warning" -IdentLevel 2
   Writes the text "This is a WARNING demo text" with an indentation level of 2 and colors it as a Warning message.

.EXAMPLE
   Write-OutputPadded -Text "This is a SUCCESS demo text" -Type "Success" -IdentLevel 2
   Writes the text "This is a SUCCESS demo text" with an indentation level of 2 and colors it as a Success message.

.EXAMPLE
   Write-OutputPadded -Text "This is a INFORMATION demo text" -Type "Information" -IdentLevel 2
   Writes the text "This is a INFORMATION demo text" with an indentation level of 2 and colors it as an Information message.

.NOTES
   The function uses Write-Host for colorized output formatting.
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