function SetAlternateCss {
[CmdletBinding()]
  <# 
  .SYNOPSIS 
  Sets or documents (only) the AlternateCssUrl properties of a SharePoint web (SPWeb). 
  .DESCRIPTION 
  Sets or documents (only) the AlternateCssUrl properties of a SharePoint web (SPWeb). Specify the -File parameter which contains a list of urls to work against.
  .EXAMPLE 
  SetAlternateCss -File C:\temp\mySiteList.csv
  .EXAMPLE 
  SetAlternateCss -File C:\temp\mySiteList.csv -DocumentExisting
  .PARAMETER File 
  Specify the path and name of the CSV file containing a list of URLs for the SharePoint sites.
  .PARAMETER DocumentExisting 
  Use this switch to only document the existing values. It will create a file at $env:TEMP\SiteInfo.csv
  #> 
Param(
[Parameter(Position=0,Mandatory=$True,HelpMessage="Enter a file name to process")]
[string]$File="C:\temp\sites.csv",
[Parameter()]
[switch]$DocumentExisting
)

#Set some parameters
$siteinfo = "$env:TEMP\SiteInfo.csv"

#Load the DLL's
$12hive = (join-path -path "c:\program files\common files\microsoft shared\web server extensions\12\" -childPath "\isapi")
Get-ChildItem -Path (join-path -path $12hive -childPath "Microsoft*.dll") | ForEach-Object {[System.Reflection.Assembly]::LoadFrom((join-path -path $12hive -childPath $_.Name))}

#Get the file
$sites = Get-Content $file

#Get the existing AlternateCssUrl
function RecordSiteInfo {
foreach ($site in $sites)
    {
        $spsite = [Microsoft.SharePoint.SPSite]($site)
        foreach ($web in $spsite.AllWebs)
                    {
                    Write-Output "Retrieving information from $web.Title"
                    $web | select Url, AlternateCssUrl, AllProperties["__InheritsAlternateCssUrl"] | Export-Csv $siteinfo
                    }
    }
}


#Define the function to change the AlternateCssUrl
function ProcessSites {
foreach ($site in $sites)
    {
        $spsite = [Microsoft.SharePoint.SPSite]($site)
        foreach ($web in $spsite.AllWebs)
                    {
                    Write-Output "Updating $web.Title"
                    $web.AlternateCssUrl = "/Style Library/CustomStyles/custom.css"
                    $web.AllProperties["__InheritsAlternateCssUrl"] = $True
                    $web.Update()
                    }
    }
}

#Execute
If ($DocumentExisting)
    {
        RecordSiteInfo
    }
Else {ProcessSites}

}

SetAlternateCss
