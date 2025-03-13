enum LogCategory {
    Information
    Warning
    Error
}
Function Write-Log{
<#
.SYNOPSIS
   Create a functiont to Write Log
.DESCRIPTION
   Create a function that aimed at creating well structured log files with a timestamp
.PARAMETER Header
   Writes Header Information
.PARAMETER Category
   Accepts three categories and writes to screen in the colours: Warning in yellow, Error in red, cyan for an Information.
.PARAMETER ToScreen
   Writes output to screen
.PARAMETER Footer
   Writes Footer Information
.PARAMETER FilePath
   Path where the log will be saved
.PARAMETER Message
   Message to be output
.PARAMETER Delimiter
   A field delimiter (for instance : a comma, a tab, a semi-colon, etc.)
   Default is ";" 
.EXAMPLE
   Write Log with Footer to Screen
   Write-Log -Filepath C:\logs\mylog.txt -Footer -ToScreen
.EXAMPLE
   Write Log with Header to Screen
   Write-Log -Filepath C:\logs\mylog.txt -Header -ToScreen
.INPUTS
   Message
.OUTPUTS
   Log file defined on FilePath
.NOTES
   Initial Version V1.0 - 20250311 - GAM: Added Description
#>

[CmdletBinding(DefaultParameterSetName='Log',
                SupportsShouldProcess=$True)]

param (
    [Parameter(Mandatory)]
    [Alias('Path')]
    [String] $FilePath,

    [Parameter( Mandatory,
                ParameterSetName='Log')] 
    [LogCategory] $Category,

    [Parameter( Mandatory,
                ValueFromPipeline,
                ParameterSetName='Log',
                ValueFromPipelineByPropertyName=$true)] 
    [String] $Message,

    [Parameter(ParameterSetName='Log')] 
    [Char] $Delimiter = ";",

    [Parameter(ParameterSetName='Header')] 
    [Switch] $Header,

    [Parameter(ParameterSetName='Footer')] 
    [Switch] $Footer,

    [Parameter()] 
    [Switch] $ToScreen


)


    Begin {
        IF($PSCmdlet.ShouldProcess($FilePath, "Writting Message")) {
            "Writting to Path: $FilePath"
            }

    }

    Process {


        if ($_.Message) { 
            $Message
            }
            else {
            $Message.ValueFromPipelineByPropertyName
            }

        Switch($PsCmdlet.ParameterSetName){
            'Header' {
                $CIM = Get-CimInstance -ClassName Win32_OperatingSystem
                
                $Text = @"
+----------------------------------------------------------------------------------------+
Script fullname          : {0}
When generated           : {1}
Current user             : {2}\{3}
Current computer         : {4}
Operating System         : {5}
OS Architecture          : {6}
+----------------------------------------------------------------------------------------+
"@ -f $MyInvocation.MyCommand.Path, (Get-Date).toString('yyyy-MM-dd HH:mm:ss'), $env:USERDOMAIN, $env:userName, $env:ComputerName, $CIM.Caption, $CIM.OSArchitecture

                Add-Content -Path $FilePath -Value $Text
            }

            'Footer' {
                $CreatedOn = (Get-Item -Path $FilePath).CreationTime
                $EndDate = (Get-Date)
                $Text = @"
+----------------------------------------------------------------------------------------+
End time                 : {0}
Total duration (seconds) : {1}
Total duration (minutes) : {2}
+----------------------------------------------------------------------------------------+
"@ -f (Get-Date).toString('yyyy-MM-dd HH:mm:ss'), ($EndDate - $CreatedOn).TotalSeconds, ($EndDate - $CreatedOn).TotalMinutes

                Add-Content -Path $FilePath -Value $Text
            }

            'Log' {
                #$host.enternestedprompt()

                $LogColors = @{
                    [LogCategory]::Information = 'Cyan'
                    [LogCategory]::Warning = 'Yellow'
                    [LogCategory]::Error = 'Red'
                }
                $Color = $LogColors[$Category]
                
                $Text = '{0} {3} {1} {3} {2}' -f (Get-Date).toString('yyyy-MM-dd HH:mm:ss'), $Category, $Message, $Delimiter
                Add-Content -Path $FilePath -Value $Text
            }
        }

     
        If($ToScreen){ 
            If($Color){
                Write-Host $Text -Foregroundcolor $Color
            }else{
                Write-Host $Text
            }
        }
    
    }

 

        


    End {}
}

