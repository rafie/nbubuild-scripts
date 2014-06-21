@echo off

if exist global.db move global.db global.db.1
sqlite3 -init global.schema.sql global.db .exit
sqlite3 -init global.data.sql global.db .exit
