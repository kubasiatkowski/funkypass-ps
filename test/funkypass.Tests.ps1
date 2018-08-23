$ModuleManifestName = 'funkypass.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\$ModuleManifestName"

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}

Describe 'Get-FunkyPass' {
    It "Given no parameters it should generate one random password" {
      $password = Get-FunkyPass
      $password.Count | Should -Be 1
    }
    It "Given minimum length it should generate one random password longer than required minimum" {
        $password = Get-FunkyPass -minlength 50
        $password.Count | Should -Be 1
        $password.Length | Should -BeGreaterThan 50
    }
    It "Given password count it should generate correct amount of random passwords" {
        $password = Get-FunkyPass -howmanypasswords 10
        $password.Count | Should -Be 10
    }
    It "Given password count and minimum length it should generate correct amount of random passwords longer than required minimum" {
        $password = Get-FunkyPass -minlength 50 -howmanypasswords 10
        $password.Count | Should -Be 10
        $password | %{$_.Length | Should -BeGreaterOrEqual 50}
    }
}