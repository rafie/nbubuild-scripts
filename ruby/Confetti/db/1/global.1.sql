PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

#----------------------------------------------------------------------------------------------

CREATE TABLE "projects" ([name] text  PRIMARY KEY NOT NULL UNIUQE, branch NOT NULL);
INSERT INTO "projects" VALUES('ucgw-7.7', 'ucgw_7.7_int_br');
INSERT INTO "projects" VALUES('ucgw-8.0', 'ucgw_8.0_int_br');
INSERT INTO "projects" VALUES('mcu-7.7', '');
INSERT INTO "projects" VALUES('mcu-8.0', 'mcu_8.0_int_br');

CREATE TABLE project_lots (project text NOT NULL, lot text NOT NULL) PRIMARY KEY NOT NULL UNIUQE (project, lot);

#----------------------------------------------------------------------------------------------

CREATE TABLE activities (name text PRIMARY KEY NOT NULL UNIUQE, project text, user text, last_mark integer);

#----------------------------------------------------------------------------------------------

CREATE TABLE [lots] ([name] text  PRIMARY KEY NOT NULL UNIUQE);
INSERT INTO "lots" VALUES('nbu.prod.mcu');
INSERT INTO "lots" VALUES('nbu.mcu');
INSERT INTO "lots" VALUES('nbu.media');
INSERT INTO "lots" VALUES('nbu.dsp');
INSERT INTO "lots" VALUES('nbu.infra');

#----------------------------------------------------------------------------------------------

CREATE TABLE lot_vobs (lot text NOT NULL, vob text NOT NULL) PRIMARY KEY NOT NULL UNIUQE (lot, vob);

INSERT INTO "lot_vobs" VALUES('nbu.prod.mcu');

INSERT INTO "lot_vobs" VALUES('nbu.mcu', 'mcu');
INSERT INTO "lot_vobs" VALUES('nbu.mcu', 'adapters');
INSERT INTO "lot_vobs" VALUES('nbu.mcu', 'dialingInfo');
INSERT INTO "lot_vobs" VALUES('nbu.mcu', 'mcu');
INSERT INTO "lots_vobs" VALUES('nbu.mcu', 'mcu');

INSERT INTO "lots_vobs" VALUES('nbu.media');
INSERT INTO "lots_vobs" VALUES('nbu.media', 'nbu.media');
INSERT INTO "lots_vobs" VALUES('nbu.media', 'mvp');
INSERT INTO "lots_vobs" VALUES('nbu.media', 'mpc');
INSERT INTO "lots_vobs" VALUES('nbu.media', 'map');
INSERT INTO "lots_vobs" VALUES('nbu.media', 'mf');
INSERT INTO "lots_vobs" VALUES('nbu.media', 'mpInfra');
INSERT INTO "lots_vobs" VALUES('nbu.media', 'NBU_FEC');
INSERT INTO "lots_vobs" VALUES('nbu.media', 'NBU_RTP_RTCP_STACK');
INSERT INTO "lots_vobs" VALUES('nbu.media', 'NBU_ICE');

INSERT INTO "lots_vobs" VALUES('nbu.dsp');
INSERT INTO "lots_vobs" VALUES('nbu.dsp', 'dspIcsVideo');
INSERT INTO "lots_vobs" VALUES('nbu.dsp', 'dspInfra');
INSERT INTO "lots_vobs" VALUES('nbu.dsp', 'dspIntelInfra');
INSERT INTO "lots_vobs" VALUES('nbu.dsp', 'dspNetraInfra');
INSERT INTO "lots_vobs" VALUES('nbu.dsp', 'dspNetraVideo');
INSERT INTO "lots_vobs" VALUES('nbu.dsp', 'dspUCGW');
INSERT INTO "lots_vobs" VALUES('nbu.dsp', 'mpDsp');
INSERT INTO "lots_vobs" VALUES('nbu.dsp', 'NetraVideoCODEC');
INSERT INTO "lots_vobs" VALUES('nbu.dsp', 'swAudioCodecs');

INSERT INTO "lots_vobs" VALUES('nbu.infra');
INSERT INTO "lots_vobs" VALUES('nbu.infra', 'nbu.infra');
INSERT INTO "lots_vobs" VALUES('nbu.infra', 'boardInfra');
INSERT INTO "lots_vobs" VALUES('nbu.infra', 'configInfra');
INSERT INTO "lots_vobs" VALUES('nbu.infra', 'swInfra');
INSERT INTO "lots_vobs" VALUES('nbu.infra', 'loggerInfra');
INSERT INTO "lots_vobs" VALUES('nbu.infra', 'rvfc');
INSERT INTO "lots_vobs" VALUES('nbu.infra', 'nbu.contrib');

#----------------------------------------------------------------------------------------------

COMMIT;
