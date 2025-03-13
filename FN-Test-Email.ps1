#Loops Through Email accepts by Pipeline and Variables

Function Test-Email {
    [CmdletBinding()]
    Param (
        [ValidateLength(0,35)]
        [Parameter(ValueFromPipeline)]
        [String[]]
        $emailAddress
    )

    Process {
        $emailAddress | ForEach-Object {
            if ($_ -notmatch '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') {
                throw "Invalid email Address"
            }

            $_
        }
    }
}

# This is a demo
Write-Host 'Testing email address'

$EmailList = 'admin@test.fr', 'gaby@acme.com', 'maxime@gmail.com', 'bruno@post.lux'

$EmailList | Test-Email


