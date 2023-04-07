<#
.SYNOPSIS
    Write a line of characters to the console
.DESCRIPTION
    Write a line of characters to the console
.EXAMPLE
    Write-Line
    Write-Line -char '=' -length 40

.PARAMETER char
    The character to write.  Default is '-'
.PARAMETER length
    The number of characters to write.  Default is 80
#>


function Write-Line {
    param (
        $char = '-',
        $length = 80
    )
    Write-Host $( $char * $length)
}


