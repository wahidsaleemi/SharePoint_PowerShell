$12hive = (join-path –path “c:\program files\common files\microsoft shared\web server extensions\12\" -childPath "\isapi")
Get-ChildItem -Path (join-path -path $12hive -childPath "Microsoft*.dll") | ForEach-Object {[System.Reflection.Assembly]::LoadFrom((join-path -path $12hive -childPath $_.Name))}

$spsite = [Microsoft.SharePoint.SPSite]("http://moss.cravenet.com/sites/site1")
foreach ($web in $spsite.AllWebs)
            {
            Write-Host "Updating $web.Title"
            $web.AlternateCssUrl = "/Style Library/CustomStyles/custom.css"
            $web.AllProperties["__InheritsAlternateCssUrl"] = $True
            $web.Update()
            }
