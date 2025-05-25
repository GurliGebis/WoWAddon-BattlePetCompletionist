$jsonData = Get-Content -Path "PetDataRetail.json" | ConvertFrom-Json
$stringBuilder = [System.Text.StringBuilder]::new()

$stringBuilder.Append("{") | Out-Null

$mapAdded = $false;

foreach ($map in $jsonData)
{
    $stringBuilder.Append("[$($map.map)]={") | Out-Null

    $petAdded = $false

    foreach ($pet in $map.pets)
    {
        $stringBuilder.Append("[$($pet.id)]=`"") | Out-Null

        $alreadyAddedList = @{}

        foreach ($coordinate in $pet.coordinates)
        {
            $key = "$($coordinate.Split(' ')[0].Split('.')[0])-$($coordinate.Split(' ')[1].Split('.')[0])"

            if ($alreadyAddedList.ContainsKey($key))
            {
                continue;
            }
            else
            {
                $alreadyAddedList[$key] = $key
            }

            $x = $coordinate.Split(' ')[0].Replace(".", "")
            $y = $coordinate.Split(' ')[1].Replace(".", "")

            while ($x.Length -lt 3)
            {
                $x = "0$($x)"
            }

            while ($y.Length -lt 3)
            {
                $y = "0$($y)"
            }

            $stringBuilder.Append($x).Append($y) | Out-Null
        }

        $petAdded = $true
        $stringBuilder.Append("`",") | Out-Null
    }

    if ($petAdded)
    {
        $stringBuilder.Remove($stringBuilder.Length - 1, 1) | Out-Null
    }

    $mapAdded = $true
    $stringBuilder.Append("},") | Out-Null
}

if ($mapAdded)
{
    $stringBuilder.Remove($stringBuilder.Length - 1, 1) | Out-Null
}

$stringBuilder.Append("}") | Out-Null

################## SAVE DATA ##################

$result = Get-Content -Path "Templates\PetDataRetail.lua"
$result = $result.Replace("{DATA}", $stringBuilder.ToString())
$result | Out-File -FilePath "..\PetDataRetail.lua" -Encoding ascii