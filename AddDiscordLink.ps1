function GetGameMenuItems
{
    param(
      $menuArgs
    )

    $menuItem = New-Object Playnite.SDK.Plugins.ScriptGameMenuItem
    $menuItem.Description =  "Add Link(s)"
    $menuItem.FunctionName = "Invoke-ReviewViewer"
    $menuItem.MenuSection = "Discord"
   
    return $menuItem
}

function Invoke-ReviewViewer
{
	$ExtensionName = "Add Discord Link"
	$LinksAdded = 0
	$selection = $PlayniteApi.MainView.SelectedGames
	foreach ($game in $selection)
	{
		$description = $game.description 
		[regex]$regex = '((http|https):\/\/discord\.gg\/)(.*?)(?=" )'
		if ($description -like "*https://discord.gg/*" -or $description -like "*http://discord.gg/*")
		{
			
			$discordlink = $regex.Matches($description).Value
			if ($game.Links | Where-Object {$_.Name -eq "Discord"}) 
			{
				Add-Content -Path "$logPath\debug.log" -Value "Skip game: $($game.Name)"
				continue
			}
			if ($discordlink.Length -gt 0) {
				$link = [Playnite.SDK.Models.Link]::New("Discord",$discordlink)
				# create links if game currently has none.
				if (-not $game.Links) 
				{
					$Links = New-Object System.Collections.ObjectModel.ObservableCollection[Playnite.SDK.Models.Link]
					$game.Links = $Links
				}
				$game.Links.Add($link)
				$PlayniteApi.Database.Games.Update($game)
				$LinksAdded++
			}
		}
	}
	$PlayniteApi.Dialogs.ShowMessage("Links Added: $LinksAdded", "$ExtensionName");
}