
CREATE TABLE agency(
	agency_id TEXT NOT NULL,
	agency_name TEXT NOT NULL,
	agency_url TEXT NOT NULL,
	agency_timezone TEXT NOT NULL,
	agency_lang TEXT DEFAULT NULL,
	agency_email TEXT DEFAULT NULL,

	agency_phone TEXT DEFAULT NULL,
	agency_fare_url TEXT DEFAULT NULL,
	PRIMARY KEY(agency_id)
	);

CREATE TABLE stops(
	stop_id TEXT DEFAULT NULL,
	stop_name TEXT DEFAULT NULL,
	stop_desc TEXT DEFAULT NULL,
	stop_lat TEXT DEFAULT NULL,
	stop_lon TEXT DEFAULT NULL,
	zone_id TEXT DEFAULT NULL,
	stop_url TEXT DEFAULT NULL,

	stop_code TEXT DEFAULT NULL,
	location_type INTEGER DEFAULT NULL,
	parent_station INTEGER DEFAULT NULL,
	stop_timezone TEXT DEFAULT NULL,
	wheelchair_boarding INTEGER DEFAULT NULL,
	level_id TEXT DEFAULT NULL,
	platform_code TEXT DEFAULT NULL,
	PRIMARY KEY(stop_id)
	);

CREATE TABLE routes(
	route_id TEXT NOT NULL,
	route_short_name TEXT DEFAULT NULL,
	route_long_name TEXT DEFAULT NULL,
	route_desc TEXT DEFAULT NULL,
	agency_id TEXT DEFAULT NULL,
	route_type INTEGER NOT NULL,
	route_color TEXT DEFAULT NULL,
	route_text_color TEXT DEFAULT NULL,
	route_url TEXT DEFAULT NULL,

	route_sort_order INTEGER DEFAULT NULL,
	PRIMARY KEY(route_id)
	);

CREATE TABLE trips(
	route_id TEXT NOT NULL,
	service_id TEXT NOT NULL,
	trip_id TEXT NOT NULL,
	trip_headsign TEXT DEFAULT NULL,
	block_id TEXT DEFAULT NULL,
	trip_short_name TEXT DEFAULT NULL,
	shape_id TEXT DEFAULT NULL,
	direction_id INTEGER DEFAULT NULL,

	wheelchair_accessible INTEGER DEFAULT NULL,
	bikes_allowed INTEGER DEFAULT NULL,
	PRIMARY KEY(trip_id)
	);

CREATE TABLE stop_times(
	trip_id TEXT NOT NULL,
	arrival_time TEXT DEFAULT NULL,
	departure_time TEXT DEFAULT NULL,
	stop_id TEXT NOT NULL,
	stop_sequence INTEGER NOT NULL,
	pickup_type INTEGER DEFAULT NULL,
	drop_off_type INTEGER DEFAULT NULL,

	stop_headsign TEXT DEFAULT NULL,
	shape_dist_traveled REAL DEFAULT NULL,
	timepoint INTEGER DEFAULT NULL,
	PRIMARY KEY(trip_id, stop_sequence)
	);

CREATE TABLE calendar(
	service_id TEXT NOT NULL,
	monday INTEGER NOT NULL,
	tuesday INTEGER NOT NULL,
	wednesday INTEGER NOT NULL,
	thursday INTEGER NOT NULL,
	friday INTEGER NOT NULL,
	saturday INTEGER NOT NULL,
	sunday INTEGER NOT NULL,
	start_date TEXT NOT NULL,
	end_date TEXT NOT NULL

,
	PRIMARY KEY(service_id)
	);

CREATE TABLE calendar_dates(
	service_id TEXT NOT NULL,
	date TEXT NOT NULL,
	exception_type TEXT NOT NULL

,
	PRIMARY KEY(service_id, date)
	);

CREATE TABLE fare_attributes(
	fare_id TEXT NOT NULL,
	price TEXT NOT NULL,
	currency_type TEXT NOT NULL,
	payment_method TEXT NOT NULL,
	transfers TEXT DEFAULT NULL,
	agency_id TEXT DEFAULT NULL,
	transfer_duration TEXT DEFAULT NULL
,
	PRIMARY KEY(fare_id)
	);

CREATE TABLE fare_rules(
	fare_id TEXT NOT NULL,
	route_id TEXT DEFAULT NULL,
	origin_id TEXT DEFAULT NULL,
	destination_id TEXT DEFAULT NULL,
	contains_id TEXT DEFAULT NULL
,
	PRIMARY KEY(fare_id)
	);

CREATE TABLE shapes(
	shape_id TEXT NOT NULL,
	shape_pt_lat TEXT NOT NULL,
	shape_pt_lon TEXT NOT NULL,
	shape_pt_sequence INTEGER NOT NULL,
	shape_dist_traveled TEXT DEFAULT NULL
,
	PRIMARY KEY(shape_id)
	);

CREATE TABLE frequencies(
	trip_id TEXT NOT NULL,
	start_time TEXT NOT NULL,
	end_time TEXT NOT NULL,
	headway_secs TEXT NOT NULL,
	exact_times TEXT DEFAULT NULL
,
	PRIMARY KEY(trip_id)
	);

CREATE TABLE transfers(
	from_stop_id TEXT NOT NULL,
	to_stop_id TEXT NOT NULL,
	transfer_type TEXT NOT NULL,
	min_transfer_time INTEGER DEFAULT NULL
,
	PRIMARY KEY(from_stop_id, to_stop_id)
	);

CREATE TABLE pathways(
	pathway_id TEXT NOT NULL,
	from_stop_id TEXT NOT NULL,
	to_stop_id TEXT NOT NULL,
	pathway_mode TEXT NOT NULL,
	is_bidirectional TEXT NOT NULL,
	length TEXT DEFAULT NULL,
	traversal_time TEXT DEFAULT NULL,
	stair_count TEXT DEFAULT NULL,
	max_slope TEXT DEFAULT NULL,
	min_width TEXT DEFAULT NULL,
	signposted_as TEXT DEFAULT NULL,
	reversed_signposted_as TEXT DEFAULT NULL
,
	PRIMARY KEY(pathway_id)
	);

CREATE TABLE levels(
	level_id TEXT NOT NULL,
	level_index TEXT NOT NULL,
	level_name TEXT DEFAULT NULL
,
	PRIMARY KEY(level_id, level_index)
	);

CREATE TABLE translations(
	table_name TEXT NOT NULL,
	field_name TEXT NOT NULL,
	language TEXT NOT NULL,
	translation TEXT NOT NULL,
	record_id TEXT DEFAULT NULL,
	record_sub_id TEXT DEFAULT NULL,
	field_value TEXT DEFAULT NULL
,
	PRIMARY KEY(table_name, field_name, language)
	);

CREATE TABLE feed_info(
	feed_publisher_name TEXT NOT NULL,
	feed_publisher_url TEXT NOT NULL,
	feed_lang TEXT NOT NULL,
	feed_start_date TEXT DEFAULT NULL,
	feed_end_date TEXT DEFAULT NULL,
	feed_version TEXT DEFAULT NULL,

	default_lang TEXT DEFAULT NULL,
	feed_contact_email TEXT DEFAULT NULL,
	feed_contact_url TEXT DEFAULT NULL,
	PRIMARY KEY(feed_publisher_name)
	);

CREATE TABLE attributions(
	attribution_id TEXT DEFAULT NULL,
	agency_id TEXT DEFAULT NULL,
	route_id TEXT DEFAULT NULL,
	trip_id TEXT DEFAULT NULL,
	organization_name TEXT NOT NULL,
	is_producer TEXT DEFAULT NULL,
	is_operator TEXT DEFAULT NULL,
	is_authority TEXT DEFAULT NULL,
	attribution_url TEXT DEFAULT NULL,
	attribution_email TEXT DEFAULT NULL,
	attribution_phone TEXT DEFAULT NULL
,
	PRIMARY KEY(organization_name)
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
.import shapes.txt shapes
.import frequencies.txt frequencies
.import transfers.txt transfers
.import feed_info.txt feed_info


DELETE FROM agency WHERE agency_name IN (
	SELECT agency_name FROM agency WHERE
		(
		agency_name LIKE '%agency_id%' COLLATE NOCASE OR
		agency_name LIKE '%agency_name%' COLLATE NOCASE OR
		agency_name LIKE '%agency_url%' COLLATE NOCASE OR
		agency_name LIKE '%agency_timezone%' COLLATE NOCASE OR
		agency_name LIKE '%agency_lang%' COLLATE NOCASE OR
		agency_name LIKE '%agency_phone%' COLLATE NOCASE OR
		agency_name LIKE '%agency_fare_url%' COLLATE NOCASE OR
		agency_name LIKE '%agency_email%' COLLATE NOCASE
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
		route_id LIKE '%route_text_color%' COLLATE NOCASE OR
		route_id LIKE '%route_sort_order%' COLLATE NOCASE
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
		feed_publisher_name LIKE '%feed_version%' COLLATE NOCASE OR
		feed_publisher_name LIKE '%feed_contact_email%' COLLATE NOCASE OR
		feed_publisher_name LIKE '%feed_contact_url%' COLLATE NOCASE
		)
		LIMIT 1
	);


UPDATE agency
	SET agency_name = 'SEPTA Regional Rail'
	WHERE agency_name = 'SEPTA';

UPDATE agency
	SET agency_phone = '215-580-7800'
	WHERE agency_phone IS NULL;

UPDATE agency
	SET agency_fare_url = 'http://www.septa.org/fares/transit/index.html'
	WHERE agency_fare_url IS NULL;

UPDATE agency
	SET agency_email = NULL
	WHERE agency_email = 'noreply@septa.org';

UPDATE routes
	SET route_url = NULL
	WHERE route_url = 'http://www.septa.org/schedules/rail/index.html';

UPDATE trips
	SET wheelchair_accessible = '1';

--sqlite3 septa_20200906_4.db < septa_20200906_gtfs_to_sql.sql
