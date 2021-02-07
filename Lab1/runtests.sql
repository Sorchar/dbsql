-----------------------
-- Delete everything --
-----------------------

-- Use this instead of drop schema if running on the Chalmers Postgres server
-- DROP OWNED BY TDA357_XXX CASCADE;

-- Less talk please.
\set QUIET true
SET client_min_messages TO WARNING; 

DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;

-- Enable log messages again.
SET client_min_messages TO NOTICE; 
\set QUIET false

-----------------------
-- Reload everything --
-----------------------

-- Stop processing files as soon as we find any error.
\set ON_ERROR_STOP on

-- Load your files (they need to be in the same folder as this script!)
\i tables.sql
\i views.sql
\i inserts.sql

------------------
-- Test queries --
------------------

-- Uncomment the following (or add your own) SELECTs to print queries when you run this file: 

 SELECT idnr, name, login, program, branch FROM BasicInformation;
 SELECT student, course, grade, credits FROM FinishedCourses;
 SELECT student, course, credits FROM PassedCourses;
 SELECT student, course, status FROM Registrations;
 SELECT student, course FROM UnreadMandatory;
 SELECT student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified FROM PathToGraduation;
