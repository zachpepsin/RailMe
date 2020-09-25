Write-Host "updateCsv.ps1"
Write-Host "Zach Pepsin"
Write-Host "22 September 2020"
Write-Host "`nThis script should be located in folder 
above the agency folders to function properly."
Write-Host "`nThis script will make updates to CSVs to format/add
missing data for select GTFS static feeds.`n"
Write-Host "`nRemember: NEVER run in current production
folder! ALWAYS make a new folder first and
test in dev mode!`n"

#Names of GTFS .txt files in CSV format. Any missing files in folder will be ignored.
$fileNames = @("agency", "stops", "routes", "trips", "stop_times", "calendar", "calendar_dates", 
	"fare_attributes", "fare_rules", "shapes", "frequencies", "transfers", "feed_info")

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

#check that .txt files exist in the folder
if (-not (Test-Path .\$rootFolder\$subFolder\*.txt) ) {
	Write-Host 'No .txt files in this folder'
	Read-Host -Prompt 'Press Enter to exit'
	Exit
}

function Export-Updated-Csv
{
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         $csv,
         [Parameter(Mandatory=$true, Position=1)]
         $feedFileName,
         [Parameter(Mandatory=$true, Position=2)]
         $rootFolder
    )
	
	$csv | Export-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' -NoType
	Write-Host "Updated "$feedFileName
	
}

# NJT Customization
if($rootFolder -eq 'njt') {
	Write-Host "Updating "$rootFolder
	foreach($feedFileName in $fileNames) {
	
		# Change the agency_name from NJ TRANSIT RAIL to "NJ Transit Rail"
		if($feedFileName -eq "agency") {
			#$csvfile = Import-csv .\$rootFolder\$subFolder\$feedFileName.txt
			
			#($csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',') | ? agency_id -ne 'NJB' | ForEach { 
			
			# skip (delete) the NJB row in agency
			$csv = Import-Csv -Path .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' | ? agency_id -ne 'NJB'
			foreach($rows in $csv) {
				if ($rows.agency_id -match "NJT") {
					$rows.agency_name = "NJ Transit Rail"
					$rows.agency_phone = "973-275-5555"
				}
			}
	
			Export-Updated-Csv $csv $feedFileName $rootFolder
			#$csv | Export-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' -NoType
		} elseif ($feedFileName -eq "stops") {
			# Set the wheelchair_boarding for ACL stops
			#Need to add the new column first
			$csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' | Select-Object *,"wheelchair_boarding" 
			$csv | Export-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' -NoType
			
			($csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',') | ForEach { 
				if ($_.stop_id -in ('1', '43298', '28', '71', '9', '55', '39', '2', '10')) {
					# Set the wheelchair_boarding for ACL stops
					$_.wheelchair_boarding = "1"
				} elseif ($_.stop_id -in ('38291', '38292', '38293', '38294', '38295', '38296', '38297', '38298', '38299', '38300', '38301', '38302', '38303', '38304', '38305', '43288', '38306', '38307', '38308', '38309', '38310')) {
					# Set the wheelchair_boarding for River Line stops
					$_.wheelchair_boarding = "1"
				} elseif ($_.stop_id -in ('148', '32905', '125', '103', '38', '84', '83', '127', '70', '41', '109', '37953', '107', '38187', '105')) {
					# Set the wheelchair_boarding for NEC accessible stops
					$_.wheelchair_boarding = "1"
				} elseif ($_.stop_id -in ('32906')) {
					# Set the wheelchair_boarding for NEC non-accessible stops
					$_.wheelchair_boarding = "2"
				}
			}
			
			Export-Updated-Csv $csv $feedFileName $rootFolder
		
		} elseif ($feedFileName -eq "trips") {
			#Add the wheelchair_accessible and bikes_allowed
			#Need to add the new columns first
			$csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' | Select-Object *,"wheelchair_accessible","bikes_allowed" 
			$csv | Export-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' -NoType
			
			($csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',') | ForEach { 
				#All NJT trains can accomidate wheelchairs
				$_.wheelchair_accessible = "1"
				
				#Bikes are allowed on RiverLine at all times.  Other routes depends on time of day
				if ($_.route_id -in ('16')) {
					# Set the wheelchair_boarding for ACL stops
					$_.bikes_allowed = "1"
				}
			}
			
			Export-Updated-Csv $csv $feedFileName $rootFolder
		
		}
	}
	
} elseif($rootFolder -eq 'septa') {
	Write-Host "Updating "$rootFolder
	foreach($feedFileName in $fileNames) {
		if($feedFileName -eq "agency") {
			#Add the agency_phone and agency_fare_url columns
			#Need to add the new columns first
			$csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' | Select-Object *,"agency_phone","agency_fare_url"
			$csv | Export-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' -NoType

			($csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',') | ForEach {
				if ($_.agency_id -match "SEPTA") {
					# Change the agency_name from SEPTA to "SEPTA Regional Rail"
					$_.agency_name = "SEPTA Regional Rail"
					$_.agency_phone = "215-580-7800"
					$_.agency_fare_url = "http://www.septa.org/fares/transit/index.html"
				}
				
				# Do not use noreply@septa.org for agency_email
				if ($_.agency_email -match "noreply@septa.org") {
					$_.agency_email = ""
				}
			}
	
			Export-Updated-Csv $csv $feedFileName $rootFolder
		} elseif ($feedFileName -eq "trips") {
			#Add the wheelchair_accessible
			#Need to add the new columns first
			$csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' | Select-Object *,"wheelchair_accessible"
			$csv | Export-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' -NoType
			
			($csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',') | ForEach { 
				#All SEPTA regional trains can accomidate wheelchairs
				$_.wheelchair_accessible = "1"
			}
			
			Export-Updated-Csv $csv $feedFileName $rootFolder
		}
		
	}
} elseif($rootFolder -eq 'septa_bus') {
	Write-Host "Updating "$rootFolder
	foreach($feedFileName in $fileNames) {
		if($feedFileName -eq "agency") {
			#Add the agency_phone column
			#Need to add the new columns first
			$csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' | Select-Object *,"agency_phone","agency_fare_url"
			$csv | Export-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',' -NoType

			($csv = Import-Csv .\$rootFolder\$subFolder\$feedFileName.txt -Delimiter ',') | ForEach {
				if ($_.agency_id -match "SEPTA") {
					# Change the agency_name from SEPTA to "SEPTA Bus/Light Rail"
					$_.agency_name = "SEPTA Bus/Light Rail"
					$_.agency_phone = "215-580-7800"
					$_.agency_fare_url = "http://www.septa.org/fares/transit/index.html"
				}
			}
	
			Export-Updated-Csv $csv $feedFileName $rootFolder
		}
	}
}





