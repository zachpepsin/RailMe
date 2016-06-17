CREATE TABLE agency(
	agency_id TEXT DEFAULT NULL,
	agency_name TEXT DEFAULT NULL,
	agency_url TEXT DEFAULT NULL,
	agency_timezone TEXT DEFAULT NULL,
	agency_lang TEXT DEFAULT NULL,

	agency_phone TEXT DEFAULT NULL,
	agency_fare_url TEXT DEFAULT NULL,
	agency_email TEXT DEFAULT NULL
	);

CREATE TABLE stops(
	stop_id TEXT DEFAULT NULL,
	stop_name TEXT DEFAULT NULL,
	stop_desc TEXT DEFAULT NULL,
	stop_lat TEXT DEFAULT NULL,
	stop_lon TEXT DEFAULT NULL,
	zone_id TEXT DEFAULT NULL,
	wheelchair_boarding TEXT DEFAULT NULL,

	stop_code TEXT DEFAULT NULL,
	stop_url TEXT DEFAULT NULL,
	location_type TEXT DEFAULT NULL,
	parent_station TEXT DEFAULT NULL,
	stop_timezone TEXT DEFAULT NULL
	);

CREATE TABLE routes(
	route_id TEXT DEFAULT NULL,
	route_short_name TEXT DEFAULT NULL,
	route_long_name TEXT DEFAULT NULL,
	route_desc TEXT DEFAULT NULL,
	agency_id TEXT DEFAULT NULL,
	route_type TEXT DEFAULT NULL,
	route_color TEXT DEFAULT NULL,
	route_text_color TEXT DEFAULT NULL,
	route_url TEXT DEFAULT NULL

	);

CREATE TABLE trips(
	route_id TEXT DEFAULT NULL,
	service_id TEXT DEFAULT NULL,
	trip_id TEXT DEFAULT NULL,
	trip_headsign TEXT DEFAULT NULL,
	block_id TEXT DEFAULT NULL,
	trip_short_name TEXT DEFAULT NULL,
	shape_id TEXT DEFAULT NULL,
	direction_id TEXT DEFAULT NULL,

	wheelchair_accessible TEXT DEFAULT NULL,
	bikes_allowed TEXT DEFAULT NULL
	);

CREATE TABLE stop_times(
	trip_id TEXT DEFAULT NULL,
	arrival_time TEXT DEFAULT NULL,
	departure_time TEXT DEFAULT NULL,
	stop_id TEXT DEFAULT NULL,
	stop_sequence INTEGER DEFAULT NULL,
	pickup_type TEXT DEFAULT NULL,
	drop_off_type TEXT DEFAULT NULL,

	stop_headsign TEXT DEFAULT NULL,
	shape_dist_traveled TEXT DEFAULT NULL,
	timepoint TEXT DEFAULT NULL
	);

CREATE TABLE calendar(
	service_id TEXT DEFAULT NULL,
	monday TEXT DEFAULT NULL,
	tuesday TEXT DEFAULT NULL,
	wednesday TEXT DEFAULT NULL,
	thursday TEXT DEFAULT NULL,
	friday TEXT DEFAULT NULL,
	saturday TEXT DEFAULT NULL,
	sunday TEXT DEFAULT NULL,
	start_date TEXT DEFAULT NULL,
	end_date TEXT DEFAULT NULL

	);

CREATE TABLE calendar_dates(
	service_id TEXT DEFAULT NULL,
	date TEXT DEFAULT NULL,
	exception_type TEXT DEFAULT NULL

	);

CREATE TABLE fare_attributes(
	fare_id TEXT DEFAULT NULL,
	price TEXT DEFAULT NULL,
	currency_type TEXT DEFAULT NULL,
	payment_method TEXT DEFAULT NULL,
	transfers TEXT DEFAULT NULL,
	transfer_duration TEXT DEFAULT NULL
	);

CREATE TABLE fare_rules(
	fare_id TEXT DEFAULT NULL,
	route_id TEXT DEFAULT NULL,
	origin_id TEXT DEFAULT NULL,
	destination_id TEXT DEFAULT NULL,
	contains_id TEXT DEFAULT NULL
	);

CREATE TABLE shapes(
	shape_id TEXT DEFAULT NULL,
	shape_pt_lat TEXT DEFAULT NULL,
	shape_pt_lon TEXT DEFAULT NULL,
	shape_pt_sequence INTEGER DEFAULT NULL,

	shape_dist_traveled TEXT DEFAULT NULL
	);

CREATE TABLE frequencies(
	trip_id TEXT DEFAULT NULL,
	start_time TEXT DEFAULT NULL,
	end_time TEXT DEFAULT NULL,
	headway_secs TEXT DEFAULT NULL,
	exact_times TEXT DEFAULT NULL
	);

CREATE TABLE transfers(
	from_stop_id TEXT DEFAULT NULL,
	to_stop_id TEXT DEFAULT NULL,
	transfer_type TEXT DEFAULT NULL,

	min_transfer_time INTEGER DEFAULT NULL
	);

CREATE TABLE feed_info(
	feed_publisher_name TEXT DEFAULT NULL,
	feed_publisher_url TEXT DEFAULT NULL,
	feed_lang TEXT DEFAULT NULL,
	feed_start_date TEXT DEFAULT NULL,
	feed_end_date TEXT DEFAULT NULL,
	feed_version TEXT DEFAULT NULL
	);

.separator ,
.mode csv
.import agency.txt agency
.import stops.txt stops
.import routes.txt routes
.import trips.txt trips
.import stop_times.txt stop_times
.import calendar.txt calendar
.import calendar_dates.txt calendar_dates
.import fare_attributes.txt fare_attributes
.import fare_rules.txt fare_rules
--.import shapes.txt shapes
.import frequencies.txt frequencies
.import transfers.txt transfers
.import feed_info.txt feed_info


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

--sqlite3 septa_20160619_1.db < septa_20160619_gtfs_to_sql.sql
