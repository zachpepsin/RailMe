# RailMe

## Data used within the RailMe mobile application


## feedData.json
* minAppVersionCode: The minimum reccomended version code for the app to function correectly (ex: "24").  If it is higher than what the user has, the user will see an alert on startup reccomending that they update the app.
* feeds: List of GTFS feeds being used
  * name: Name of the feed.  Used by the application during things such as updating, checking for most recent selection...
  * prodDbName: Name of the database being used in production (ex: patco_20160406_5.db)
  * devDbName: Name of the database being used while in dev mode
  * type: Could be used in the future to integreate online schedules.  for now, all are set to "offline"
  * alertMessage: Text of an alert a rider would see for various reasons, such as unexpected schedule change.  Left blank if no alert.
  * alertLink: Link user would see in the alert dialog mentioned above.  Left blank if no link.  Must use http:// or https://.



## RailMe Changelog

#### 3.0.0 (Pre-release)
* Migrated to Kotlin, AndroidX and RoomDB
* Added dark mode support
* New icons
* Updated UI for schedules
* A new Trip Details screen
* Information on Agencies, Routes, and Stops are available including URLs, phone numbers, emails, and wheelchair accessibility
* Live delay information for individual stops on trips
* Live service alerts are displayed for agencies, routes, trips and stops
* Support for "Cancelled" train status
* Added more support for wheelchair accessibility and bike policies for trips and stops
* Support for extra fare information including transfers or ticket expiration
* Route schedules now show all stops on block, rather than just the trip
* Status now shows statuses corresponding to their entire block_id, not just for their trip_id
* Delays reported for entire trips (not tied to stops) are now shown if not overridden by a stop delay
* Added support for route sort order
* Added support for feed info start and end dates
* Closed DBs in areas where they weren't being closed before.  Potential fix for "SQLiteDiskIOException" errors
* Fixed bug that prevented users on Android 8.0+ from seeing live train status information
* Fixed bug were duplicate trains appear in schedule list because they are on the same block

#### 2.2.3 (Production) (1 December 2018)
* Added adaptive icon support
* Fixed bug where app could crash if user exited app before a toast was shown
* Fixed bug where trips could incorrectly show on the schedule
* Increased minSdkVersion to 19

### 2.2.0 (Production) (9 September 2016)
* Added live train status information
* Added alert requesting user to rate the app

#### 2.1.4 (Production) (15 July 2016)
* Fixed block_id bug that caused some SEPTA trips to not be displayed
* Added "Automatic" option for Time Convention
* Updated SettingsActivity to use PreferenceFragments
* Updated ScheduleActivity to use RecyclerView

#### 2.1.3 (Production) (15 June 2016)
* Optimization for Android N
* Fixed bug where response code of 400 from GitHub JSON file would crash app
* Error handling for bad responses from GitHub

#### 2.1.2 (Prodution) (6 June 2016)
* Fixed bug where only one schedule could update/download at a time

#### 2.1.1 (Beta) (6 June 2016)
* Fixed bug where alert messages would not display

### 2.1.0 (Beta) (5 June 2016)
* Major performance improvements
* Added Samsung Multi Window support
* Added wheelchair accessibility information
* Raised minimum SDK from 8 to 16

#### 2.0.5 (Production) (6 September 2015)
* Added option to report an incorrect schedule or bug
* Bug fixes related to displaying fare/bike information

### 2.0.0 (Alpha) (9 August 2015)
* Completely redesigned UI
* Implemented Material Design
* Automatically updating train schedules
* Optimized for tablets
* New rail lines added
* Fare and bike accessibility information
* Reduced app permissions
