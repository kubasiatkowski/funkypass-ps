# Implement your module commands in this script.

function Get-FunkyPass {
    param(
        [string] $dictionaryPath,
        [int][ValidateRange(10,100)] $minlength=10,
        [int][ValidateRange(1,100)] $howmanypasswords=1
    )

    Write-Progress -Activity "Starting" -PercentComplete 5


    $words = @()
    $passwords = @()
    if (!($dictionaryPath))
    {
        #ToDo
        #get random dictionary
    }
    elseif (!(Test-Path -Path $dictionaryPath)) {
        Write-Warning "Dictionary file not found, getting random"
    }
    else {
        Write-Progress -Activity "Getting random words" -PercentComplete 10
        #it could be optimized by using .net classes but the goal is to keep pure PowerShell for better portability
        $words = get-content $dictionaryPath | Get-Random -Count ($minlength * $howmanypasswords) | Where-Object {$_ -match '\w'}
    }

    for($i=0;$i -lt $howmanypasswords; $i++)
    {
        $password = ""
        $specials = (',./<>?;:\"|[]{}!@#$%^&*()_+-=').ToCharArray()
        do {

            $word = $words | Get-Random
            $words = $words | Where-Object {$_ -ne $word}

            #fallback to random characters if array of words is empty
            if (!($word)) {
                $word = ([char]((65..90)|Get-Random)).ToString()
            }
            #random capitalization
            switch (Get-Random -Maximum 3) {
                0 {$word = $word.ToUpper()}
                1 {$word = $word.ToUpper()}
                2 {$word = (Get-Culture).TextInfo.ToTitleCase($word.ToLower())}
            }
            $password += $word
            $password += $specials | Get-Random
            $password += Get-Random -Maximum 1000

            #show progress bar
            $progress = ($minlength / $password.Length)
            if ($progress -lt 1)
            {
                $progress = 1
            }
            Write-Progress -Activity "Generating password" -PercentComplete (50 + (1 /  $progress) *50 )

        }
        while ($password.Length -lt $minlength)
        $passwords += $password
    }
    return $passwords
}


# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
