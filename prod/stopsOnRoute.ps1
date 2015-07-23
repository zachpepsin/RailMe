Write-Host "stopsOnRoute.ps1"
Write-Host "Zach Pepsin"
Write-Host "20 July 2015"
Write-Host "`nThis script should be located in folder 
above the agency folders to function properly"
Write-Host "`nRemember: NEVER run in current production
folder! ALWAYS make a new folder first and
test in dev mode!`n"


#get root agency folder
$agency = Read-Host 'Root (agency)'
if( ($agency -contains '*') -or ($agency -eq '') ){
	Write-Host "Don't leave folder name empty or use an '*' in folder name."
	Read-Host -Prompt 'Press Enter to exit'
	Exit
}
while(-not (Test-Path .\$agency) ) {  #if path isn't found, try again/exit
	Write-Host 'Root folder not found'
	$agency = Read-Host 'Try again or press Enter to exit'
	if( $agency -eq ''){
		Exit
	}
}

#get subfolder (version folder)
$folder = Read-Host 'Folder'
if( ($folder -contains '*') -or ($folder -eq '') ){
	Write-Host "Don't leave folder name empty or use an '*' in folder name."
	Read-Host -Prompt 'Press Enter to exit'
	Exit
}
while(-not (Test-Path .\$agency\$folder) ) {  #if path isn't found, try again/exit
	Write-Host 'Subfolder not found'
	$folder = Read-Host 'Try again or press Enter to exit'
	if( $folder -eq ''){
		Exit
	}
}

#check that routes.txt, trips.txt, and stop_times.txt files exist in the folder
if (-not ( (Test-Path .\$agency\$folder\routes.txt) -and (Test-Path .\$agency\$folder\trips.txt) -and (Test-Path .\$agency\$folder\stop_times.txt) ) ) {
	Write-Host 'routes.txt, trips.txt, or stop_times.txt file misisng in folder'
	Read-Host -Prompt 'Press Enter to exit'
	Exit
}

#if .json files are in the folder, they may be overwritten by new files.  confirm this.
if ( Test-Path .\$agency\$folder\stopsOnRoute.json ) {
	$input = ''
	while( $input -eq '' ){
		$input = Read-Host 'Existing stopsOnRoute.json file found in this folder.  Continue? (Y/N)'
		if( $input -ieq 'N' ){
			Exit
		}elseif( $input -ieq 'Y'){
			Continue  #don't change $input value, loop will break
		}else{
			$input = ''  #reset input to '' so loop continues
		}
	}
}

Write-Host "`nImporting CSV files..."
$finRoutes = Import-Csv .\$agency\$folder\routes.txt -delimiter "," #import from file to object
$finTrips = Import-Csv .\$agency\$folder\trips.txt -delimiter ","
$finStop_Times = Import-Csv .\$agency\$folder\stop_times.txt -delimiter ","
#$finStops = Import-Csv .\$agency\$folder\stops.txt -delimiter ","

$route_idList = @()
$route_idToTrip_idsList = @()
ForEach( $route in $finRoutes){
	#Write-Host route_id is $route.route_id
	$route_idList += $route.route_id
	$route_idToTrip_idsList += ,@() #allocate size of array
	$route_idToStop_idsList += ,@() 
}

$trip_idList = @()
$trip_idToStop_idsList = @()

Write-Host "Making routes to trip_ids"
ForEach( $trip in $finTrips){
	#Write-Host route_id is $route.route_id
	
	$trip_idList += $trip.trip_id
	$trip_idToStop_idsList += ,@()  #will fill each array within array with stop_ids on each trip
	
	$count = 0
	ForEach($route_id in $route_idList){
		if($trip.route_id -eq $route_id){
			$route_idToTrip_idsList[$count] += $trip.trip_id
		}
		$count += 1
	}
}

# | select -uniq  ## CAN DO SORT INSTEAD OF SELECT !!! ??!?!?

Write-Host "Making list of trips to stop_ids"
ForEach($stop_time in $finStop_Times){
	$count = 0
	ForEach($trip_id in $trip_idList){
		if($stop_time.trip_id -eq $trip_id){
			$trip_idToStop_idsList[$count] += $stop_time.stop_id
		}
		$count += 1
	}
}


Write-Host "Parsing everything..."
$count=0
ForEach ($route_idToTrip_idInnerArray in $route_idToTrip_idsList){
	Write-Host "`n"
	Write-Host ROUTE $route_idList[$count]
	Write-Host "---------------------------`n"
	ForEach($trip_idFromRouteList in $route_idToTrip_idInnerArray){
		Write-Host Trip $trip_idFromRouteList
		$innerCount=0
		:inner ForEach($trip_id in $trip_idList){
		
			if($trip_idFromRouteList -eq $trip_id){
			
				ForEach($stop_id in $trip_idToStop_idsList[$innerCount]){
					$route_idToStop_idsList[$count] += $stop_id
				}
				break inner
			}
			$innerCount+=1
		}
	}
	$count+=1
}

Write-Host "Trimming lists for uniques..."
$count = 0
ForEach($innerList in $route_idToStop_idsList){
	$route_idToStop_idsList[$count] = $route_idToStop_idsList[$count] | select -uniq
	$count+=1
}

Write-Host "Making output string..."
$output = '{"StopsOnRoute":['
$outerCount = 1
ForEach($innerArray in $route_idToStop_idsList){
	
	$output = $output + '{"route_id":"'
	$output = $output + ($route_idList[$outerCount - 1])
	$output = $output + '","stop_ids":['

	$innerCount = 1
	ForEach($trip_id in $innerArray){
		$output = $output + '"'
		$output = $output + $trip_id
		$output = $output + '"'
		if(-not ($innerArray.Count -le $innerCount)){
			$output = $output + ','
		}
		$innerCount+=1
	}
	$output = $output + ']'
	$output = $output + '}'
	if(-not ($route_idToStop_idsList.Count -le $outerCount)){
		$output = $output + ','
	}
	$outerCount+=1
}
$output = $output + ']}'

Write-Host "Writing to output file..."
#$output | Out-File ".\$agency\$folder\stopsOnRoute.json"  ###Using this method adds BOM
[System.IO.File]::WriteAllLines(".\$agency\$folder\stopsOnRoute.json", $output)
Write-Host "Done!`n"
