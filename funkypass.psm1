# Implement your module commands in this script.

function Get-FunkyPass {
    param(
        [string] $Dictionary,
        [int][ValidateRange(10,100)] $MinLength=10,
        [int][ValidateRange(1,10000)] $Count=1
    )

    Write-Progress -Activity "Starting" -PercentComplete 5

    $words = @()
    $passwords = @()
    $dictionaryPath
    if (!($Dictionary))
    {
        $dictionaryPath = Get-FunkyDictionary -Random
        Write-Host ("Using random dictionary " + $dictionaryPath.BaseName) -ForegroundColor Green
    }
    else  {
        $dictionaryPath = Get-FunkyDictionary -Name $Dictionary
    }
    Write-Progress -Activity "Getting random words" -PercentComplete 10
    #it could be optimized by using .net classes but the goal is to keep pure PowerShell for better portability
    
    $words = get-content -Path $dictionaryPath.FullName | Get-Random -Count ($minlength * $Count) | Where-Object {$_ -match '\w'}

       
    $specials = (',./<>?;:\"|[]{}!@#$%^&*()_+-=').ToCharArray()

    for($i=0;$i -lt $Count; $i++)
    {
        $password = ""
        do {
            $word = $words | Get-Random -Count 1
            $words = $words | Where-Object {$_ -ne $word}

            #fallback to random characters if array of words is empty
            if (!($word)) {
                Write-Warning -Message "Word list empty, you need bigger dictionary. Using random characters"
                $word = ([char]((65..90)|Get-Random)).ToString()
            }
            #random capitalization
            switch (Get-Random -Maximum 3) {
                0 {$word = $word.ToUpper()}
                1 {$word = $word.ToLower()}
                2 {$word = (Get-Culture).TextInfo.ToTitleCase($word.ToLower())}
            }
            $password += $word
            $password += $specials | Get-Random -Count 1
            $password += Get-Random -Maximum 1000

            #show progress bar
            $progress = ($minlength / $password.Length)
            if ($progress -lt 1)
            {
                $progress = 1
            }
            Write-Progress -Activity "Generating password" -PercentComplete (50 + ($i/$Count) * 50) -Status "$i/$Count"

        }
        while ($password.Length -lt $minlength)
        $passwords += $password
    }
    return $passwords
}

function Get-FunkyDictionary {
    [cmdletbinding(
        DefaultParameterSetName='GetAll'
    )]
    param (
        [Parameter(ParameterSetName='ByName')][string] $Name,
        [Parameter(ParameterSetName='GetAll')][switch] $ListAll,
        [Parameter(ParameterSetName='Random')][switch] $Random
    )
    #ToDo Replace with module path
    $dictionariesPath = ".\dictionaries"

    $allfiles = (Get-ChildItem $dictionariesPath)
    if ($allfiles.Count -eq 0)
    {
        # ToDo - write better message
        Write-Warning "Dictionaries folder is empty"
    }
    elseif ($allfiles.Name -eq "sample.txt" -and $allfiles.count -eq 1)
    {
        # ToDo - write better message
        Write-Warning "You are using sample dictionary"
    }

    if ($PsCmdlet.ParameterSetName -eq "ByName")
    {
        $files = Get-ChildItem $dictionariesPath -Filter "$Name.txt" 
        if($files.count -eq 1)
        {
            return $files
        }
        elseif ($files.count -gt 1){
            $warnmsg = $files | Format-Table -Property Name | Out-String
            Write-Warning "Please be more precise with language name, selecting random from $warnmsg"
            return $files | Get-Random
        }
        else {
            Write-Warning "Dictionary not found, selecting random"
            Get-FunkyDictionary -Random
        }   
    }
    elseif ($PsCmdlet.ParameterSetName -eq "Random")
    {
        return Get-ChildItem $dictionariesPath | Get-Random
    }
    elseif ($PsCmdlet.ParameterSetName -eq "GetAll") {
        Get-ChildItem $dictionariesPath | Format-Table -Property Name | Out-String| Write-Host
    }
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
