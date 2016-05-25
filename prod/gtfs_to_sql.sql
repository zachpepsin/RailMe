
CREATE TABLE agency(
	agency_id TEXT,
	agency_name TEXT,
	agency_url TEXT,
	agency_timezone TEXT,
	agency_lang TEXT,
	agency_phone TEXT,
	agency_fare_url TEXT,
	agency_email TEXT,
	);
	
CREATE TABLE stops (
	stop_id TEXT,
	stop_code TEXT,
	stop_name TEXT,
	stop_desc TEXT,
	stop_lat TEXT,
	stop_lon TEXT,
	zone_id TEXT,
	stop_url TEXT,
	location_type TEXT,
	parent_station TEXT,
	stop_timezone TEXT,
	wheelchair_boarding TEXT
	);
	
CREATE TABLE routes (
	route_id TEXT,
	agency_id TEXT,
	route_short_name TEXT,
	route_long_name TEXT,
	route_desc TEXT,
	route_type TEXT,
	route_url TEXT,
	route_color TEXT,
	route_text_color TEXT
	);
	
CREATE TABLE trips (
	route_id TEXT,
	service_id TEXT,
	trip_id TEXT,
	trip_headsign TEXT,
	trip_short_name TEXT,
	direction_id TEXT,
	block_id TEXT,
	shape_id TEXT,
	wheelchair_accessible TEXT,
	bikes_allowed TEXT
	);
	
CREATE TABLE stop_times (
	trip_id TEXT,
	arrival_time TEXT,
	departure_time TEXT,
	stop_id TEXT,
	stop_sequence TEXT,
	stop_headsign TEXT,
	pickup_type TEXT,
	drop_off_type TEXT,
	shape_dist_traveled TEXT
	timepoint TEXT
	);
	
CREATE TABLE calendar (
	service_id TEXT,
	monday TEXT,
	tuesday TEXT,
	wednesday TEXT,
	thursday TEXT,
	friday TEXT,
	saturday TEXT,
	sunday TEXT,
	start_date TEXT,
	end_date TEXT
	);

CREATE TABLE calendar_dates (
	service_id TEXT,
	date TEXT,
	exception_type TEXT
	);
	
CREATE TABLE fare_attributes (
	fare_id TEXT,
	price TEXT,
	currency_type TEXT,
	payment_method TEXT,
	transfers TEXT,
	transfer_duration TEXT
	);
	
CREATE TABLE fare_rules (
	fare_id TEXT,
	route_id TEXT,
	origin_id TEXT,
	destination_id TEXT,
	contains_id TEXT
	);
	
CREATE TABLE shapes (
	shape_id TEXT,
	shape_pt_lat TEXT,
	shape_pt_lon TEXT,
	shape_pt_sequence TEXT,
	shape_dist_traveled TEXT
	);
	
CREATE TABLE frequencies (
	trip_id TEXT,
	start_time TEXT,
	end_time TEXT,
	headway_secs TEXT,
	exact_times TEXT
	);
	
CREATE TABLE transfers (
	from_stop_id TEXT,
	to_stop_id TEXT,
	transfer_type TEXT,
	min_transfer_time TEXT
	);
	
CREATE TABLE feed_info (
	feed_publisher_name TEXT,
	feed_publisher_url TEXT,
	feed_lang TEXT,
	feed_start_date TEXT,
	feed_end_date TEXT,
	feed_version TEXT
	);
	
.separator ,
.import agency.txt agency
.import stops.txt stops
.import routes.txt routes
.import trips.txt trips
.import stop_times.txt stop_times
.import calendar.txt calendar
.import calendar_dates.txt calendar_dates
.import fare_attributes.txt fare_attributes
.import fare_rules.txt fare_rules
.import shapes.txt shapes
.import frequencies.txt frequencies
.import transfers.txt transfers
.import feed_info.txt feed_info

--Delete first rows that are actually header text rows
DELETE FROM agency WHERE agency_id IN (
	SELECT agency_id FROM agency WHERE
		(
		agency_id LIKE '%agency_id%' COLLATE NOCASE OR
		agency_id LIKE '%agency_name%' COLLATE NOCASE OR
		agency_id LIKE '%agency_url%' COLLATE NOCASE OR
		agency_id LIKE '%agency_timezone%' COLLATE NOCASE OR
		agency_id LIKE '%agency_lang%' COLLATE NOCASE OR
		agency_id LIKE '%agency_phone%' COLLATE NOCASE OR
		agency_id LIKE '%agency_fare_url%' COLLATE NOCASE OR
		agency_id LIKE '%agency_email%' COLLATE NOCASE
		)
		LIMIT 1
	);
	
DELETE FROM stops WHERE stop_id = (
	SELECT stop_id FROM stops WHERE
		(
		stop_id LIKE '%stop_id%' COLLATE NOCASE OR
		stop_id LIKE '%stop_code%' COLLATE NOCASE OR
		stop_id LIKE '%stop_name%' COLLATE NOCASE OR
		stop_id LIKE '%stop_desc%' COLLATE NOCASE OR
		stop_id LIKE '%stop_lat%' COLLATE NOCASE OR
		stop_id LIKE '%stop_long%' COLLATE NOCASE OR
		stop_id LIKE '%zone_id%' COLLATE NOCASE OR
		stop_id LIKE '%location_type%' COLLATE NOCASE OR
		stop_id LIKE '%parent_station%' COLLATE NOCASE OR
		stop_id LIKE '%stop_timezone%' COLLATE NOCASE OR
		stop_id LIKE '%wheelchair_boarding%' COLLATE NOCASE 
		)
		LIMIT 1
	);

DELETE FROM routes WHERE route_id = (
	SELECT route_id FROM routes WHERE
		(
		route_id LIKE '%route_id%' COLLATE NOCASE OR
		route_id LIKE '%agency_id%' COLLATE NOCASE OR
		route_id LIKE '%route_short_name%' COLLATE NOCASE OR
		route_id LIKE '%route_long_name%' COLLATE NOCASE OR
		route_id LIKE '%route_desc%' COLLATE NOCASE OR
		route_id LIKE '%route_type%' COLLATE NOCASE OR
		route_id LIKE '%route_url%' COLLATE NOCASE OR
		route_id LIKE '%route_color%' COLLATE NOCASE OR
		route_id LIKE '%route_text_color%' COLLATE NOCASE
		)
		LIMIT 1
	);
	
DELETE FROM trips WHERE trip_id = (
	SELECT trip_id FROM trips WHERE
		(
		trip_id LIKE '%route_id%' COLLATE NOCASE OR
		trip_id LIKE '%service_id%' COLLATE NOCASE OR
		trip_id LIKE '%trip_id%' COLLATE NOCASE OR
		trip_id LIKE '%trip_headsign%' COLLATE NOCASE OR
		trip_id LIKE '%trip_short_name%' COLLATE NOCASE OR
		trip_id LIKE '%direction_id%' COLLATE NOCASE OR
		trip_id LIKE '%block_id%' COLLATE NOCASE OR
		trip_id LIKE '%shape_id%' COLLATE NOCASE OR
		trip_id LIKE '%wheelchair_accessible%' COLLATE NOCASE OR
		trip_id LIKE '%bikes_allowed%' COLLATE NOCASE
		)
		LIMIT 1
	);

DELETE FROM stop_times WHERE trip_id = (
	SELECT trip_id FROM stop_times WHERE
		(
		trip_id LIKE '%trip_id%' COLLATE NOCASE OR
		trip_id LIKE '%arrival_time%' COLLATE NOCASE OR
		trip_id LIKE '%departure_time%' COLLATE NOCASE OR
		trip_id LIKE '%stop_id%' COLLATE NOCASE OR
		trip_id LIKE '%stop_sequence%' COLLATE NOCASE OR
		trip_id LIKE '%stop_headsign%' COLLATE NOCASE OR
		trip_id LIKE '%pickup_type%' COLLATE NOCASE OR
		trip_id LIKE '%drop_off_type%' COLLATE NOCASE OR
		trip_id LIKE '%shape_dist_traveled%' COLLATE NOCASE OR
		trip_id LIKE '%timepoint%' COLLATE NOCASE
		)
		LIMIT 1
	);
	
DELETE FROM calendar WHERE service_id = (
	SELECT service_id FROM calendar WHERE
		(
		service_id LIKE '%service_id%' COLLATE NOCASE OR
		service_id LIKE '%monday%' COLLATE NOCASE OR
		service_id LIKE '%tuesday%' COLLATE NOCASE OR
		service_id LIKE '%wednesday%' COLLATE NOCASE OR
		service_id LIKE '%thursday%' COLLATE NOCASE OR
		service_id LIKE '%friday%' COLLATE NOCASE OR
		service_id LIKE '%saturday%' COLLATE NOCASE OR
		service_id LIKE '%sunday%' COLLATE NOCASE OR
		service_id LIKE '%start_date%' COLLATE NOCASE OR
		service_id LIKE '%end_date%' COLLATE NOCASE
		)
		LIMIT 1
	);
	
DELETE FROM calendar_dates WHERE service_id = (
	SELECT service_id FROM calendar_dates WHERE
		(
		service_id LIKE '%service_id%' COLLATE NOCASE OR
		service_id LIKE '%date%' COLLATE NOCASE OR
		service_id LIKE '%exception_type%' COLLATE NOCASE
		)
		LIMIT 1
	);

DELETE FROM fare_attributes WHERE fare_id = (
	SELECT fare_id FROM fare_attributes WHERE
		(
		fare_id LIKE '%fare_id%' COLLATE NOCASE OR
		fare_id LIKE '%price%' COLLATE NOCASE OR
		fare_id LIKE '%currency_type%' COLLATE NOCASE OR
		fare_id LIKE '%payment_method%' COLLATE NOCASE OR
		fare_id LIKE '%transfers%' COLLATE NOCASE OR
		fare_id LIKE '%transfer_duration%' COLLATE NOCASE
		)
		LIMIT 1
	);
	
DELETE FROM fare_rules WHERE fare_id = (
	SELECT fare_id FROM fare_rules WHERE
		(
		fare_id LIKE '%fare_id%' COLLATE NOCASE OR
		fare_id LIKE '%route_id%' COLLATE NOCASE OR
		fare_id LIKE '%origin_id%' COLLATE NOCASE OR
		fare_id LIKE '%destination_id%' COLLATE NOCASE OR
		fare_id LIKE '%contains_id%' COLLATE NOCASE
		)
		LIMIT 1
	);
	
DELETE FROM shapes WHERE shape_id = (
	SELECT shape_id FROM shapes WHERE
		(
		shape_id LIKE '%shape_id%' COLLATE NOCASE OR
		shape_id LIKE '%shape_pt_lat%' COLLATE NOCASE OR
		shape_id LIKE '%shape_pt_lon%' COLLATE NOCASE OR
		shape_id LIKE '%shape_pt_sequence%' COLLATE NOCASE OR
		shape_id LIKE '%shape_dist_traveled%' COLLATE NOCASE
		)
		LIMIT 1
	);
	
DELETE FROM frequencies WHERE trip_id = (
	SELECT trip_id FROM frequencies WHERE
		(
		trip_id LIKE '%trip_id%' COLLATE NOCASE OR
		trip_id LIKE '%start_time%' COLLATE NOCASE OR
		trip_id LIKE '%end_time%' COLLATE NOCASE OR
		trip_id LIKE '%headway_secs%' COLLATE NOCASE OR
		trip_id LIKE '%exact_times%' COLLATE NOCASE
		)
		LIMIT 1
	);
	
DELETE FROM feed_info WHERE feed_publisher_name = (
	SELECT feed_publisher_name FROM feed_info WHERE
		(
		feed_publisher_name LIKE '%feed_publisher_name%' COLLATE NOCASE OR
		feed_publisher_name LIKE '%feed_publisher_url%' COLLATE NOCASE OR
		feed_publisher_name LIKE '%feed_lang%' COLLATE NOCASE OR
		feed_publisher_name LIKE '%feed_start_date%' COLLATE NOCASE OR
		feed_publisher_name LIKE '%feed_end_date%' COLLATE NOCASE OR
		feed_publisher_name LIKE '%feed_version%' COLLATE NOCASE
		)
		LIMIT 1
	);
	
--Do I need primary keys?
--_id INTEGER PRIMARY KEY
--Note: Have to check order every time this way manually
--sqlite3 gtfs.db < gtfs_to_sql.sql