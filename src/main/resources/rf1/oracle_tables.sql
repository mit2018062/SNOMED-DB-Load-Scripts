WHENEVER SQLERROR EXIT -1
SET ECHO ON


-- Session settings.
ALTER SESSION SET NLS_LENGTH_SEMANTICS='CHAR';


-- Define helper procedure to drop tables.
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE drop_table';
EXCEPTION
    WHEN OTHERS THEN
        -- If procedure doesn't exist, it can't be dropped,
        -- so an exception will be thrown.  Ignore it.
        IF SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/
CREATE PROCEDURE drop_table (table_name IN VARCHAR2) IS
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ' || table_name || ' CASCADE CONSTRAINTS';
EXCEPTION
    -- If table doesn't exist, it can't be dropped,
    -- so an exception will be thrown.  Ignore it.
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/


-- Concepts file.
EXECUTE drop_table('concepts');
CREATE TABLE concepts (
    CONCEPTID NUMERIC(18) NOT NULL PRIMARY KEY,
    CONCEPTSTATUS INT NOT NULL,
    FULLYSPECIFIEDNAME VARCHAR2(255) NOT NULL,
    CTV3ID VARCHAR2(100) NOT NULL,
    SNOMEDID VARCHAR2(100) NOT NULL,
    ISPRIMITIVE NUMERIC(1) NOT NULL
)
PCTFREE 10 PCTUSED 80;


-- Descriptions file.
EXECUTE drop_table('descriptions');
CREATE TABLE descriptions (
    DESCRIPTIONID NUMERIC(18) NOT NULL PRIMARY KEY,
    DESCRIPTIONSTATUS INT NOT NULL,
    CONCEPTID NUMERIC(18) NOT NULL,
    TERM VARCHAR2(255) NOT NULL,
    INITIALCAPITALSTATUS INT NOT NULL,
    DESCRIPTIONTYPE VARCHAR2(100) NOT NULL,
    LANGUAGECODE VARCHAR2(5) NOT NULL
)
PCTFREE 10 PCTUSED 80;


-- Relationships file.
EXECUTE drop_table('relationships');
CREATE TABLE relationships (
    RELATIONSHIPID NUMERIC(18) NOT NULL PRIMARY KEY,
    CONCEPTID1 NUMERIC(18) NOT NULL,
    RELATIONSHIPTYPE NUMERIC(18) NOT NULL,
    CONCEPTID2 NUMERIC(18) NOT NULL,
    CHARACTERISTICTYPE INT NOT NULL,
    REFINABILITY INT NOT NULL,
    RELATIONSHIPGROUP INT NOT NULL,
    FOREIGN KEY (CONCEPTID1) REFERENCES concepts(CONCEPTID),
    FOREIGN KEY (RELATIONSHIPTYPE) REFERENCES concepts(CONCEPTID),
    FOREIGN KEY (CONCEPTID2) REFERENCES concepts(CONCEPTID)
)
PCTFREE 10 PCTUSED 80;


-- Component History file.
EXECUTE drop_table('componenthistory');
CREATE TABLE componenthistory (
    COMPONENTID NUMERIC(18) NOT NULL,
    RELEASEVERSION DATE NOT NULL,
    CHANGETYPE INT NOT NULL,
    STATUS INT NOT NULL,
    REASON VARCHAR2(255)
)
PCTFREE 10 PCTUSED 80;


-- References file.
EXECUTE drop_table('references');
CREATE TABLE references (
    COMPONENTID NUMERIC(18) NOT NULL,
    REFERENCETYPE INT NOT NULL,
    REFERENCEDID NUMERIC(18) NOT NULL
)
PCTFREE 10 PCTUSED 80;


-- CrossMapSets ICD9 file.
EXECUTE drop_table('crossmapsetsicd9');
CREATE TABLE crossmapsetsicd9 (
    MAPSETID NUMERIC(18) NOT NULL PRIMARY KEY,
    MAPSETNAME VARCHAR2(255) NOT NULL,
    MAPSETTYPE INT NOT NULL,
    MAPSETSCHEMEID VARCHAR2(255) NOT NULL,
    MAPSETSCHEMENAME VARCHAR2(255) NOT NULL,
    MAPSETSCHEMEVERSION VARCHAR2(255) NOT NULL,
    MAPSETREALMID NUMERIC(18),
    MAPSETSEPARATOR CHAR(1) NOT NULL,
    MAPSETRULETYPE INT
)
PCTFREE 10 PCTUSED 80;


-- CrossMapTargets ICD9 file.
EXECUTE drop_table('crossmaptargetsicd9');
CREATE TABLE crossmaptargetsicd9 (
    TARGETID NUMERIC(18) NOT NULL PRIMARY KEY,
    TARGETSCHEMEID VARCHAR2(255) NOT NULL,
    TARGETCODES VARCHAR2(100),
    TARGETRULE VARCHAR2(4000),
    TARGETADVICE VARCHAR2(4000)
)
PCTFREE 10 PCTUSED 80;


-- CrossMaps ICD9 file.
EXECUTE drop_table('crossmapsicd9');
CREATE TABLE crossmapsicd9 (
    MAPSETID NUMERIC(18) NOT NULL,
    MAPCONCEPTID NUMERIC(18) NOT NULL,
    MAPOPTION INT NOT NULL,
    MAPPRIORITY INT NOT NULL,
    MAPTARGETID NUMERIC(18) NOT NULL,
    MAPRULE VARCHAR2(4000),
    MAPADVICE VARCHAR2(4000) NOT NULL,
    FOREIGN KEY (MAPSETID) REFERENCES crossmapsetsicd9(MAPSETID),
    FOREIGN KEY (MAPCONCEPTID) REFERENCES concepts(CONCEPTID),
    FOREIGN KEY (MAPTARGETID) REFERENCES crossmaptargetsicd9(TARGETID)
)
PCTFREE 10 PCTUSED 80;


-- CrossMapSets ICDO file.
EXECUTE drop_table('crossmapsetsicdo');
CREATE TABLE crossmapsetsicdo (
    MAPSETID NUMERIC(18) NOT NULL PRIMARY KEY,
    MAPSETNAME VARCHAR2(255) NOT NULL,
    MAPSETTYPE INT NOT NULL,
    MAPSETSCHEMEID VARCHAR2(255) NOT NULL,
    MAPSETSCHEMENAME VARCHAR2(255) NOT NULL,
    MAPSETSCHEMEVERSION VARCHAR2(255) NOT NULL,
    MAPSETREALMID NUMERIC(18),
    MAPSETSEPARATOR CHAR(1) NOT NULL,
    MAPSETRULETYPE INT
)
PCTFREE 10 PCTUSED 80;


-- CrossMapTargets ICDO file.
EXECUTE drop_table('crossmaptargetsicdo');
CREATE TABLE crossmaptargetsicdo (
    TARGETID NUMERIC(18) NOT NULL PRIMARY KEY,
    TARGETSCHEMEID VARCHAR2(255) NOT NULL,
    TARGETCODES VARCHAR2(100),
    TARGETRULE VARCHAR2(4000),
    TARGETADVICE VARCHAR2(4000)
)
PCTFREE 10 PCTUSED 80;


-- CrossMaps ICDO file.
EXECUTE drop_table('crossmapsicdo');
CREATE TABLE crossmapsicdo (
    MAPSETID NUMERIC(18) NOT NULL,
    MAPCONCEPTID NUMERIC(18) NOT NULL,
    MAPOPTION INT NOT NULL,
    MAPPRIORITY INT NOT NULL,
    MAPTARGETID NUMERIC(18) NOT NULL,
    MAPRULE VARCHAR2(4000),
    MAPADVICE VARCHAR2(4000),
    FOREIGN KEY (MAPSETID) REFERENCES crossmapsetsicdo(MAPSETID),
    FOREIGN KEY (MAPCONCEPTID) REFERENCES concepts(CONCEPTID),
    FOREIGN KEY (MAPTARGETID) REFERENCES crossmaptargetsicdo(TARGETID)
)
PCTFREE 10 PCTUSED 80;


-- Subsets en-GB file.
EXECUTE drop_table('subsetsengb');
CREATE TABLE subsetsengb (
    SUBSETID NUMERIC(18) NOT NULL PRIMARY KEY,
    SUBSETORIGINALID NUMERIC(18) NOT NULL,
    SUBSETVERSION INT NOT NULL,
    SUBSETNAME VARCHAR2(255) NOT NULL,
    SUBSETTYPE INT NOT NULL,
    LANGUAGECODE CHAR(5) NOT NULL,
    REALMID NUMERIC(18),
    CONTEXTID NUMERIC(18)
)
PCTFREE 10 PCTUSED 80;


-- SubsetMembers en-GB file.
EXECUTE drop_table('subsetmembersengb');
CREATE TABLE subsetmembersengb (
    SUBSETID NUMERIC(18) NOT NULL,
    MEMBERID NUMERIC(18) NOT NULL,
    MEMBERSTATUS INT NOT NULL,
    LINKEDID VARCHAR2(100),
    FOREIGN KEY (SUBSETID) REFERENCES subsetsengb(SUBSETID),
    FOREIGN KEY (MEMBERID) REFERENCES descriptions(DESCRIPTIONID)
)
PCTFREE 10 PCTUSED 80;


-- Subsets en-US file.
EXECUTE drop_table('subsetsenus');
CREATE TABLE subsetsenus (
    SUBSETID NUMERIC(18) NOT NULL PRIMARY KEY,
    SUBSETORIGINALID NUMERIC(18) NOT NULL,
    SUBSETVERSION INT NOT NULL,
    SUBSETNAME VARCHAR2(255) NOT NULL,
    SUBSETTYPE INT NOT NULL,
    LANGUAGECODE CHAR(5) NOT NULL,
    REALMID NUMERIC(18),
    CONTEXTID NUMERIC(18)
)
PCTFREE 10 PCTUSED 80;


-- SubsetMembers en-US file.
EXECUTE drop_table('subsetmembersenus');
CREATE TABLE subsetmembersenus (
    SUBSETID NUMERIC(18) NOT NULL,
    MEMBERID NUMERIC(18) NOT NULL,
    MEMBERSTATUS INT NOT NULL,
    LINKEDID VARCHAR2(100),
    FOREIGN KEY (SUBSETID) REFERENCES subsetsenus(SUBSETID),
    FOREIGN KEY (MEMBERID) REFERENCES descriptions(DESCRIPTIONID)
)
PCTFREE 10 PCTUSED 80;


-- Subsets NonHuman file.
-- Commented out - no more non-human file
--EXECUTE drop_table('subsetsnonhuman');
--CREATE TABLE subsetsnonhuman (
--    SUBSETID NUMERIC(18) NOT NULL PRIMARY KEY,
--    SUBSETORIGINALID NUMERIC(18) NOT NULL,
--    SUBSETVERSION INT NOT NULL,
--    SUBSETNAME VARCHAR2(255) NOT NULL,
--    SUBSETTYPE INT NOT NULL,
--    LANGUAGECODE CHAR(5) NOT NULL,
--    REALMID NUMERIC(18),
--    CONTEXTID NUMERIC(18)
--)
--PCTFREE 10 PCTUSED 80;


-- SubsetMembers NonHuman file.
--EXECUTE drop_table('subsetmembersnonhuman');
--CREATE TABLE subsetmembersnonhuman (
--    SUBSETID NUMERIC(18) NOT NULL,
--    MEMBERID NUMERIC(18) NOT NULL,
--    MEMBERSTATUS INT NOT NULL,
--    LINKEDID VARCHAR2(100),
--    FOREIGN KEY (SUBSETID) REFERENCES subsetsnonhuman(SUBSETID),
--    FOREIGN KEY (MEMBERID) REFERENCES concepts(CONCEPTID)
--)
--PCTFREE 10 PCTUSED 80;


-- Subsets VTMVMP file.
EXECUTE drop_table('subsetsvtmvmp');
CREATE TABLE subsetsvtmvmp (
    SUBSETID NUMERIC(18) NOT NULL PRIMARY KEY,
    SUBSETORIGINALID NUMERIC(18) NOT NULL,
    SUBSETVERSION INT NOT NULL,
    SUBSETNAME VARCHAR2(255) NOT NULL,
    SUBSETTYPE INT NOT NULL,
    LANGUAGECODE CHAR(5) NOT NULL,
    REALMID NUMERIC(18),
    CONTEXTID NUMERIC(18)
)
PCTFREE 10 PCTUSED 80;


-- SubsetMembers VTMVMP file.
EXECUTE drop_table('subsetmembersvtmvmp');
CREATE TABLE subsetmembersvtmvmp (
    SUBSETID NUMERIC(18) NOT NULL,
    MEMBERID NUMERIC(18) NOT NULL,
    MEMBERSTATUS INT NOT NULL,
    LINKEDID VARCHAR2(100),
    FOREIGN KEY (SUBSETID) REFERENCES subsetsnonhuman(SUBSETID),
    FOREIGN KEY (MEMBERID) REFERENCES concepts(CONCEPTID)
)
PCTFREE 10 PCTUSED 80;


-- Clean up helper procedures.
DROP PROCEDURE drop_table;
