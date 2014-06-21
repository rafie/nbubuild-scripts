PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

-----------------------------------------------------------------------------------------------

INSERT INTO "projects" VALUES('main',  'main',        '', '');
INSERT INTO "projects" VALUES('.test', 'test_int_br', '', '');

-----------------------------------------------------------------------------------------------

INSERT INTO "activities" VALUES('rafie_test_bideyadu','rafie_test_bideyadu','rafie_test_bideyadu_br','.test_japinu','main','rafie',0);

-----------------------------------------------------------------------------------------------

COMMIT;
