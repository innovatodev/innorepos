<#
        .SYNOPSIS
            Script used to clone and maintain repositories updated over time.
        .DESCRIPTION
           Script used to clone and maintain repositories updated over time.
           - Add a list called "LIST.txt" at root directory
           - Add some repositories one per line ( example https://github.com/PowerShell/PowerShell )
           - Profit
#>
foreach ($SOURCE in Get-Content "$PSScriptRoot\LIST.txt")
{
    if (![string]::IsNullOrEmpty($SOURCE))
    {
        # Return at root directory
        Set-Location $PSScriptRoot
        # URL split (SITEWEB + ORGANIZATION + REPOSITORY)
        $URL = $Source.Split('/')[-3]
        $ORG = $Source.Split('/')[-2]
        $REP = $Source.Split('/')[-1]
        if (!(Test-Path -Path "$PSScriptRoot\$ORG\$REP")) # The repository does not exist, we clone it
        {
            Write-Host "[CLONING]$Source" -ForegroundColor Green
            git clone """https://$URL/$ORG/$REP.git""" """$ORG/$REP"""
        }
        else #  The repository exist, we update it
        {
            Write-Host "[UPDATING]$Source" -ForegroundColor Red
            Set-Location "$ORG/$REP"
            # To know the main branch
            $GET = (git remote show origin | Select-String "HEAD branch: " -Raw).Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)[2]
            git pull $Source $GET
        }
    }
}
# Clean all git process (there probably a better way to do that)
foreach ($item in Get-Process "git")
{
    Stop-Process $item -Force
}
