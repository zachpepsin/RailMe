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

### 2.0.0 (Alpha) (9 August 2015)
* Completely redesigned UI
* Implemented Material Design
* Automatically updating train schedules
* Optimized for tablets
* New rail lines added
* Fare and bike accessibility information
* Reduced app permissions

#### 2.0.5 (Production) (6 September 2015)
* Added option to report an incorrect schedule or bug
* Bug fixes related to displaying fare/bike information

### 2.1.0 (Beta) (5 June 2016)
* Major performance improvements
* Added Samsung Multi Window support
* Added wheelchair accessibility information
* Raised minimum SDK from 8 to 16

#### 2.1.1 (Beta) (6 June 2016)
* Fixed bug where alert messages would not display

#### 2.1.2 (Prodution) (6 June 2016)
* Fixed bug where only one schedule could update/download at a time

#### 2.1.3 (Beta, RC) (15 June 2016)
* Optimization for Android N
* Fixed bug where response code of 400 from GitHub JSON file would crash app
* Error handling for bad responses from GitHub

