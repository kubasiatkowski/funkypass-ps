function Get-FunkyPass {
    param(
        [string] $dictionaryPath,
        [int] $minlength
    )
    Write-Progress -Activity "Starting" -PercentComplete 5


    $words = @()
    if (!(Test-Path -Path $dictionaryPath)) {
        Write-Error  "Dictionary file not found" -errorId 3  
    }    
    Write-Progress -Activity "Getting random words" -PercentComplete 10
    #it could be optimized by using .net classes but the goal is to keep pure PowerShell
    $words = get-content $dictionaryPath | Get-Random -Count $minlength | Where-Object {$_ -match '\w'}
  
  
    $password = ""
    $specials = (',./<>?;:\"|[]{}!@#$%^&*()_+-=').ToCharArray()
    do {
        Write-Progress -Activity "Generating password" -PercentComplete (50 + (1 / ($minlength - $password.Length)) * 50)
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
    }
    while ($password.Length -lt $minlength) 
    $password
}

$dictionaryPath = "./words_alpha2.txt"
$minlength = 50

Get-FunkyPass -dictionaryPath $dictionaryPath  -minlength 50
