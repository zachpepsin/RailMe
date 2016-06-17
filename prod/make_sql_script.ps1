Write-Host "make_sql_script.ps1"
Write-Host "Zach Pepsin"
Write-Host "17 June 2016"
Write-Host "`nThis script should be located in folder 
above the GTFS folders, along with the root folders, 
in order to function properly"

#Get root folder
$rootFolder = Read-Host 'Root Folder'
if( ($rootFolder -contains '*') -or ($rootFolder -eq '') ){
	Write-Host "Don't leave folder name empty or use an '*' in folder name."
	Read-Host -Prompt 'Press Enter to exit'
	Exit
}
while(-not (Test-Path .\$rootFolder) ) {  #if path isn't found, try again/exit
	Write-Host 'Root folder not found'
	$rootFolder = Read-Host 'Try again or press Enter to exit'
	if( $rootFolder -eq ''){
		Exit
	}
}

##Get sub folder (version folder)
$subFolder = Read-Host 'Sub Folder'
if( ($subFolder -contains '*') -or ($subFolder -eq '') ){
	Write-Host "Don't leave sub folder name empty or use an '*' in folder name."
	Read-Host -Prompt 'Press Enter to exit'
	Exit
}
while(-not (Test-Path .\$rootFolder\$subFolder) ) {  #if path isn't found, try again/exit
	Write-Host 'Subfolder not found'
	$subFolder = Read-Host 'Try again or press Enter to exit'
	if( $subFolder -eq ''){
		Exit
	}
}


##Get DB Version
$dbVersion = Read-Host 'DB Version (ex: 1)'
if( $dbVersion -eq ''){
	Write-Host "Don't leave dbVersion name empty."
	Read-Host -Prompt 'Press Enter to exit'
	Exit
}

[System.Collections.ArrayList]$agencyParams = @("agency_id", "agency_name", "agency_url", 
		"agency_timezone", "agency_lang", "agency_phone", 
		"agency_fare_url", "agency_email")
		
[System.Collections.ArrayList]$stopsParams = @("stop_id", "stop_code", "stop_name",
		"stop_desc", "stop_lat", "stop_lon", "zone_id", "stop_url", "location_type",
		"parent_station", "stop_timezone", "wheelchair_boarding")
		
[System.Collections.ArrayList]$routesParams = @("route_id", "agency_id", "route_short_name",
	"route_long_name", "route_desc", "route_type", "route_url", "route_color", "route_text_color")

[System.Collections.ArrayList]$tripsParams = @("route_id", "service_id", "trip_id", 
	"trip_headsign", "trip_short_name", "direction_id", "block_id", "shape_id",
	"wheelchair_accessible", "bikes_allowed")

[System.Collections.ArrayList]$stop_timesParams = @("trip_id", "arrival_time", 
	"departure_time", "stop_id", "stop_sequence", "stop_headsign", "pickup_type",
	"drop_off_type", "shape_dist_traveled", "timepoint")

[System.Collections.ArrayList]$calendarParams = @("service_id", "monday", "tuesday",
	"wednesday", "thursday", "friday", "saturday", "sunday", "start_date", "end_date")

[System.Collections.ArrayList]$calendar_datesParams = @("service_id", "date", "exception_type")

[System.Collections.ArrayList]$fare_attributesParams = @("fare_id", "price", "currency_type",
	"payment_method", "transfers", "transfer_duration")

[System.Collections.ArrayList]$fare_rulesParams = @("fare_id", "route_id", 
	"origin_id", "destination_id", "contains_id")

[System.Collections.ArrayList]$shapesParams = @("shape_id", "shape_pt_lat",
	"shape_pt_lon", "shape_pt_sequence", "shape_dist_traveled")

[System.Collections.ArrayList]$frequenciesParams = @("trip_id", "start_time",
	"end_time", "headway_secs", "exact_times")

[System.Collections.ArrayList]$transfersParams = @("from_stop_id", 
	"to_stop_id", "transfer_type", "min_transfer_time")

[System.Collections.ArrayList]$feed_infoParams = @("feed_publisher_name",
	"feed_publisher_url", "feed_lang", "feed_start_date", "feed_end_date",
	"feed_version")
	
	
$feedFileNames = @("agency", "stops", "routes", "trips", "stop_times", "calendar", "calendar_dates", 
	"fare_attributes", "fare_rules", "shapes", "frequencies", "transfers", "feed_info")

[System.Collections.ArrayList]$feedFileParamsArray = @($agencyParams, $stopsParams,
			$routesParams, $tripsParams, $stop_timesParams, $calendarParams,
			$calendar_datesParams, $fare_attributesParams, $fare_rulesParams,
			$shapesParams, $frequenciesParams, $transfersParams, $feed_infoParams)

#################### CREATE TABLES ########################
Write-Host "`nMaking CREATE TABLE Statements"
Write-Host "----------"

##CREATE TABLES
$feedFileCount = 0
foreach($feedFileName in $feedFileNames){
	Write-Host -NoNewline "  " $feedFileName ":  "
	if(-not (Test-Path .\$rootFolder\$subFolder\$feedFileName.txt) ){  #skip file if not found
		Write-Host "FILE NOT FOUND, MAKING DEFAULT TABLE"
		
		$fileText += "CREATE TABLE " + $feedFileName + "(`r`n"
		$count = 0
		foreach($param in $feedFileParamsArray[$feedFileCount]){
			$count++
			$variableType = "TEXT"
			if(
				($feedFileName -eq "stop_times" -AND $param -eq "stop_sequence") -OR
				($feedFileName -eq "shapes" -AND $param -eq "shape_pt_sequence") -OR
				($feedFileName -eq "transfers" -AND $param -eq "min_transfer_time")
			){
				#It should be INTEGER type, not TEXT
				$variableType = "INTEGER"
			}
			
			#$fileText += "`t" + $param + " " + $variableType + " DEFAULT NULL`r`n"
			
			$fileText += "`t" + $param + " " +  $variableType + " DEFAULT NULL"
			
			if($count -lt $feedFileParamsArray[$feedFileCount].Count){
				$fileText += ","
			}
			
			$fileText += "`r`n"
		}
		
		$fileText += "`t);"
		
	}else{
			
		#Get the params from the first line of file
		$fileParams = (Get-Content .\$rootFolder\$subFolder\$feedFileName.txt)[0] -replace '"', '' -split ','
		
		$fileText += "CREATE TABLE " + $feedFileName + "(`r`n"
		[System.Collections.ArrayList]$foundParams = @()
		$count = 0
		$result = foreach($param in $fileParams){
			$count++
			$param = $param.ToLower()
			if($feedFileParamsArray[$feedFileCount] -contains $param){
				$foundParams.Add($param)
				
				$variableType = "TEXT"
				if(
					($feedFileName -eq "stop_times" -AND $param -eq "stop_sequence") -OR
					($feedFileName -eq "shapes" -AND $param -eq "shape_pt_sequence") -OR
					($feedFileName -eq "transfers" -AND $param -eq "min_transfer_time")
				){
					#It should be INTEGER type, not TEXT
					$variableType = "INTEGER"
				}
				
				$fileText += "`t" + $param + " " +  $variableType + " DEFAULT NULL"
				
				if($count -lt $feedFileParamsArray[$feedFileCount].Count){
					$fileText += ","
				}
				
				$fileText += "`r`n"
				
			}else{
				Write-Host "`tERROR. UNKNOWN PARAMETER FOUND (" $param ")"
				Read-Host -Prompt 'Press Enter to exit'
				Exit
			}
		}
		
		$fileText += "`r`n"
		
		#add any missing params
		$count = 0;
		foreach($param in $feedFileParamsArray[$feedFileCount]){
			if( -Not ($foundParams -contains $param) ){
			
				if($count -gt 0){
					$fileText += ",`r`n"
				}
			
				$variableType = "TEXT"
				if(
					($feedFileName -eq "stop_times" -AND $param -eq "stop_sequence") -OR
					($feedFileName -eq "shapes" -AND $param -eq "shape_pt_sequence") -OR
					($feedFileName -eq "transfers" -AND $param -eq "min_transfer_time")
				){
					#It should be INTEGER type, not TEXT
					$variableType = "INTEGER"
				}
				
				$fileText += "`t" + $param + " " +  $variableType + " DEFAULT NULL"
				
				$count++
			}
		}
		if($count -gt 0){
			$fileText += "`r`n"
		}
		
		$fileText += "`t);"
		
		$output = "`tDONE!"
		if($count -gt 0){
			$output += " (added " + $count + " missing columns)"
		}
		Write-Host $output
	}

	$fileText += "`r`n`r`n"
	$feedFileCount++
}

##SET SQL IMPORT PARAMS
$fileText += ".separator ,`r`n"
$fileText += ".mode csv`r`n"
$fileText += ".import agency.txt agency`r`n"
$fileText += ".import stops.txt stops`r`n"
$fileText += ".import routes.txt routes`r`n"
$fileText += ".import trips.txt trips`r`n"
$fileText += ".import stop_times.txt stop_times`r`n"
$fileText += ".import calendar.txt calendar`r`n"
$fileText += ".import calendar_dates.txt calendar_dates`r`n"
$fileText += ".import fare_attributes.txt fare_attributes`r`n"
$fileText += ".import fare_rules.txt fare_rules`r`n"
$fileText += "--.import shapes.txt shapes`r`n"
$fileText += ".import frequencies.txt frequencies`r`n"
$fileText += ".import transfers.txt transfers`r`n"
$fileText += ".import feed_info.txt feed_info`r`n"

$fileText += "`r`n`r`n"

####################### DELETE HEADER LINE FUNCTIONS ###################
$fileText += "DELETE FROM agency WHERE agency_id IN (`r`n"
$fileText += "`tSELECT agency_id FROM agency WHERE`r`n"
$fileText += "`t`t(`r`n"
$fileText += "`t`tagency_id LIKE '%agency_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tagency_id LIKE '%agency_name%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tagency_id LIKE '%agency_url%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tagency_id LIKE '%agency_timezone%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tagency_id LIKE '%agency_lang%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tagency_id LIKE '%agency_phone%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tagency_id LIKE '%agency_fare_url%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tagency_id LIKE '%agency_email%' COLLATE NOCASE`r`n"
$fileText += "`t`t)`r`n"
$fileText += "`t`tLIMIT 1`r`n"
$fileText += "`t);`r`n"

$fileText += "`r`n"

$fileText += "DELETE FROM stops WHERE stop_id = (`r`n"
$fileText += "`tSELECT stop_id FROM stops WHERE`r`n"
$fileText += "`t`t(`r`n"
$fileText += "`t`tstop_id LIKE '%stop_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tstop_id LIKE '%stop_code%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tstop_id LIKE '%stop_name%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tstop_id LIKE '%stop_desc%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tstop_id LIKE '%stop_lat%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tstop_id LIKE '%stop_long%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tstop_id LIKE '%zone_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tstop_id LIKE '%location_type%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tstop_id LIKE '%parent_station%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tstop_id LIKE '%stop_timezone%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tstop_id LIKE '%wheelchair_boarding%' COLLATE NOCASE `r`n"
$fileText += "`t`t)`r`n"
$fileText += "`t`tLIMIT 1`r`n"
$fileText += "`t);`r`n"

$fileText += "`r`n"

$fileText += "DELETE FROM routes WHERE route_id = (`r`n"
$fileText += "`tSELECT route_id FROM routes WHERE`r`n"
$fileText += "`t`t(`r`n"
$fileText += "`t`troute_id LIKE '%route_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`troute_id LIKE '%agency_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`troute_id LIKE '%route_short_name%' COLLATE NOCASE OR`r`n"
$fileText += "`t`troute_id LIKE '%route_long_name%' COLLATE NOCASE OR`r`n"
$fileText += "`t`troute_id LIKE '%route_desc%' COLLATE NOCASE OR`r`n"
$fileText += "`t`troute_id LIKE '%route_type%' COLLATE NOCASE OR`r`n"
$fileText += "`t`troute_id LIKE '%route_url%' COLLATE NOCASE OR`r`n"
$fileText += "`t`troute_id LIKE '%route_color%' COLLATE NOCASE OR`r`n"
$fileText += "`t`troute_id LIKE '%route_text_color%' COLLATE NOCASE`r`n"
$fileText += "`t`t)`r`n"
$fileText += "`t`tLIMIT 1`r`n"
$fileText += "`t);`r`n"

$fileText += "`r`n"

$fileText += "DELETE FROM trips WHERE trip_id = (`r`n"
$fileText += "`tSELECT trip_id FROM trips WHERE`r`n"
$fileText += "`t`t(`r`n"
$fileText += "`t`ttrip_id LIKE '%route_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%service_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%trip_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%trip_headsign%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%trip_short_name%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%direction_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%block_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%shape_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%wheelchair_accessible%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%bikes_allowed%' COLLATE NOCASE`r`n"
$fileText += "`t`t)`r`n"
$fileText += "`t`tLIMIT 1`r`n"
$fileText += "`t);`r`n"

$fileText += "`r`n"

$fileText += "DELETE FROM stop_times WHERE trip_id = (`r`n"
$fileText += "`tSELECT trip_id FROM stop_times WHERE`r`n"
$fileText += "`t`t(`r`n"
$fileText += "`t`ttrip_id LIKE '%trip_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%arrival_time%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%departure_time%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%stop_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%stop_sequence%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%stop_headsign%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%pickup_type%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%drop_off_type%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%shape_dist_traveled%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%timepoint%' COLLATE NOCASE`r`n"
$fileText += "`t`t)`r`n"
$fileText += "`t`tLIMIT 1`r`n"
$fileText += "`t);`r`n"

$fileText += "`r`n"

$fileText += "DELETE FROM calendar WHERE service_id = (`r`n"
$fileText += "`tSELECT service_id FROM calendar WHERE`r`n"
$fileText += "`t`t(`r`n"
$fileText += "`t`tservice_id LIKE '%service_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tservice_id LIKE '%monday%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tservice_id LIKE '%tuesday%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tservice_id LIKE '%wednesday%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tservice_id LIKE '%thursday%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tservice_id LIKE '%friday%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tservice_id LIKE '%saturday%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tservice_id LIKE '%sunday%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tservice_id LIKE '%start_date%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tservice_id LIKE '%end_date%' COLLATE NOCASE`r`n"
$fileText += "`t`t)`r`n"
$fileText += "`t`tLIMIT 1`r`n"
$fileText += "`t);`r`n"

$fileText += "`r`n"

$fileText += "DELETE FROM calendar_dates WHERE service_id = (`r`n"
$fileText += "`tSELECT service_id FROM calendar_dates WHERE`r`n"
$fileText += "`t`t(`r`n"
$fileText += "`t`tservice_id LIKE '%service_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tservice_id LIKE '%date%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tservice_id LIKE '%exception_type%' COLLATE NOCASE`r`n"
$fileText += "`t`t)`r`n"
$fileText += "`t`tLIMIT 1`r`n"
$fileText += "`t);`r`n"

$fileText += "`r`n"

$fileText += "DELETE FROM fare_attributes WHERE fare_id = (`r`n"
$fileText += "`tSELECT fare_id FROM fare_attributes WHERE`r`n"
$fileText += "`t`t(`r`n"
$fileText += "`t`tfare_id LIKE '%fare_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tfare_id LIKE '%price%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tfare_id LIKE '%currency_type%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tfare_id LIKE '%payment_method%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tfare_id LIKE '%transfers%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tfare_id LIKE '%transfer_duration%' COLLATE NOCASE`r`n"
$fileText += "`t`t)`r`n"
$fileText += "`t`tLIMIT 1`r`n"
$fileText += "`t);`r`n"

$fileText += "`r`n"

$fileText += "DELETE FROM fare_rules WHERE fare_id = (`r`n"
$fileText += "`tSELECT fare_id FROM fare_rules WHERE`r`n"
$fileText += "`t`t(`r`n"
$fileText += "`t`tfare_id LIKE '%fare_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tfare_id LIKE '%route_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tfare_id LIKE '%origin_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tfare_id LIKE '%destination_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tfare_id LIKE '%contains_id%' COLLATE NOCASE`r`n"
$fileText += "`t`t)`r`n"
$fileText += "`t`tLIMIT 1`r`n"
$fileText += "`t);`r`n"

$fileText += "`r`n"

$fileText += "DELETE FROM shapes WHERE shape_id = (`r`n"
$fileText += "`tSELECT shape_id FROM shapes WHERE`r`n"
$fileText += "`t`t(`r`n"
$fileText += "`t`tshape_id LIKE '%shape_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tshape_id LIKE '%shape_pt_lat%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tshape_id LIKE '%shape_pt_lon%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tshape_id LIKE '%shape_pt_sequence%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tshape_id LIKE '%shape_dist_traveled%' COLLATE NOCASE`r`n"
$fileText += "`t`t)`r`n"
$fileText += "`t`tLIMIT 1`r`n"
$fileText += "`t);`r`n"

$fileText += "`r`n"

$fileText += "DELETE FROM frequencies WHERE trip_id = (`r`n"
$fileText += "`tSELECT trip_id FROM frequencies WHERE`r`n"
$fileText += "`t`t(`r`n"
$fileText += "`t`ttrip_id LIKE '%trip_id%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%start_time%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%end_time%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%headway_secs%' COLLATE NOCASE OR`r`n"
$fileText += "`t`ttrip_id LIKE '%exact_times%' COLLATE NOCASE`r`n"
$fileText += "`t`t)`r`n"
$fileText += "`t`tLIMIT 1`r`n"
$fileText += "`t);`r`n"

$fileText += "`r`n"

$fileText += "DELETE FROM feed_info WHERE feed_publisher_name = (`r`n"
$fileText += "`tSELECT feed_publisher_name FROM feed_info WHERE`r`n"
$fileText += "`t`t(`r`n"
$fileText += "`t`tfeed_publisher_name LIKE '%feed_publisher_name%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tfeed_publisher_name LIKE '%feed_publisher_url%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tfeed_publisher_name LIKE '%feed_lang%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tfeed_publisher_name LIKE '%feed_start_date%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tfeed_publisher_name LIKE '%feed_end_date%' COLLATE NOCASE OR`r`n"
$fileText += "`t`tfeed_publisher_name LIKE '%feed_version%' COLLATE NOCASE`r`n"
$fileText += "`t`t)`r`n"
$fileText += "`t`tLIMIT 1`r`n"
$fileText += "`t);`r`n"

$fileText += "`r`n"


$sqlCommandString = "sqlite3 " + $subFolder + "_" + $dbVersion + ".db < " + $subFolder + "_gtfs_to_sql.sql"
$fileText += "--" + $sqlCommandString
		
##Create SQL script in sub folder
$fileName = $subFolder + '_gtfs_to_sql.sql'
$fileText | Out-File -Encoding "UTF8" ./$rootFolder/$subFolder/$fileName


$dbName = $subFolder + "_" + $dbVersion

Write-Host "`n`nSQL Command String: "
Write-Host $sqlCommandString

Read-Host "`nFinished! SQL Script is located in the GTFS folder. Press Enter to exit"
