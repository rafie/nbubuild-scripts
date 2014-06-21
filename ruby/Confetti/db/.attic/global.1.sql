PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

-----------------------------------------------------------------------------------------------

CREATE TABLE "projects" (
	[name] text PRIMARY KEY NOT NULL UNIQUE,
	int_branch text NOT NULL,
	admin_vob text,
	cspec text NOT NULL);

INSERT INTO "projects" VALUES('main',     'main',            '', '');
INSERT INTO "projects" VALUES('ucgw-7.7', 'ucgw_7.7_int_br', '', '');
INSERT INTO "projects" VALUES('ucgw-8.0', 'ucgw_8.0_int_br', '', '');
INSERT INTO "projects" VALUES('mcu-7.7',  '',                '', '');
INSERT INTO "projects" VALUES('mcu-8.0',  'mcu_8.0_int_br',  '', '');
INSERT INTO "projects" VALUES('mcu-8.0',  'mcu_8.0_int_br',  '', '');
INSERT INTO "projects" VALUES('test',     'test_int_br',     '.test', '');

-----------------------------------------------------------------------------------------------

CREATE TABLE activities (
	name text PRIMARY KEY NOT NULL UNIQUE, 
	view text UNIQUE NOT NULL, 
	branch text UNIQUE NOT NULL, 
	project text NOT NULL,
	user text NOT NULL, 
	last_mark integer);

INSERT INTO "activities" VALUES ('rafie_prod-1', 'rafie_prod-1', 'rafie_prod-1_br', 'mcu-8.0', 'rafie', 0);

-----------------------------------------------------------------------------------------------

COMMIT;
