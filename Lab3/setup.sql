--Drop Everything
DROP TABLE IF EXISTS Students, Branches, Courses,
    LimitedCourses, StudentBranches, Classifications, 
    Classified, MandatoryProgram, MandatoryBranch, 
    RecommendedBranch, Registered, Taken, WaitingList
    CASCADE;


DROP VIEW IF EXISTS BasicInformation, FinishedCourses, 
PassedCourses, Registrations, UnreadMandatory, RecommendedCredit, 
PathToGraduation CASCADE;
---------------------------------------------------------------------
-- Tables
CREATE TABLE Students(
	idnr NUMERIC(10),
	name TEXT NOT NULL,
	login TEXT NOT NULL UNIQUE,
	program TEXT NOT NULL,
	PRIMARY KEY(idnr)
);

CREATE TABLE Branches(
	name TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY(name, program)
);

CREATE TABLE Courses( 
	code CHAR(6) NOT NULL, 
	name TEXT NOT NULL,
	credits FLOAT CHECK (credits > 0) NOT NULL,
	department TEXT NOT NULL,
	prerequisites TEXT ARRAY, --Behövs för Triggern Part 3
	PRIMARY KEY(code)
);

CREATE TABLE LimitedCourses(
	code CHAR(6) REFERENCES Courses(code),
	capacity INT CHECK (capacity > 0) NOT NULL,
	PRIMARY KEY(code)
);

CREATE TABLE StudentBranches(
	student NUMERIC(10) REFERENCES Students(idnr),
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	FOREIGN KEY(branch, program) REFERENCES Branches(name,program),
	PRIMARY KEY(student)
);

CREATE TABLE Classifications(
	name TEXT NOT NULL,
	PRIMARY KEY(name)
);

CREATE TABLE Classified(
	course CHAR(6) REFERENCES Courses(code),
	classification TEXT REFERENCES Classifications(name),
	PRIMARY KEY(course, classification)
);

CREATE TABLE MandatoryProgram(
	course CHAR(6) REFERENCES Courses(code),
	program TEXT NOT NULL,
	PRIMARY KEY(course, program)
);

CREATE TABLE MandatoryBranch(
	course CHAR(6) REFERENCES Courses(code),
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY (course, branch,program),
	FOREIGN KEY (branch, program) REFERENCES Branches(name,program)
);

CREATE TABLE RecommendedBranch(
	course CHAR(6) REFERENCES Courses(code),
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY(course, branch,program),
	FOREIGN key(branch, program) REFERENCES Branches(name, program)
);

 CREATE TABLE Registered(
 	student NUMERIC(10) REFERENCES Students(idnr),
 	course CHAR(6) REFERENCES Courses(code),
 	PRIMARY KEY(student, course)
 );

 CREATE TABLE Taken(
 	student NUMERIC(10) REFERENCES Students(idnr),
 	course CHAR(6) REFERENCES Courses(code),
 	grade CHAR(1) NOT NULL CHECK(grade IN ('U', '3','4','5')),
 	PRIMARY key(student, course)
 );

 CREATE TABLE WaitingList(
 	student NUMERIC(10) REFERENCES Students(idnr),
 	course CHAR(6) REFERENCES LimitedCourses(code),
 	position SERIAL,
 	PRIMARY KEY (student,course) 
 );
-----------------------------------------------------------------------------------
--Views
CREATE VIEW BasicInformation AS
SELECT  idnr, Students.name, login, Students.program, StudentBranches.branch 
FROM Students
LEFT JOIN StudentBranches
ON StudentBranches.program = Students.program AND
    StudentBranches.student = Students.idnr;


CREATE VIEW FinishedCourses AS
SELECT student, course, grade, credits
FROM Courses, Taken
WHERE course = code;

CREATE VIEW PassedCourses AS 
SELECT student, course, credits 
FROM Taken, Courses 
WHERE grade <> 'U' AND course = code;

CREATE VIEW Registrations AS
SELECT student, course, 'registered' as status
FROM Registered 
UNION
SELECT student, course, 'waiting' as status
FROM WaitingList;

CREATE VIEW UnreadMandatory AS
SELECT idnr AS student, course
FROM BasicInformation, MandatoryProgram
WHERE BasicInformation.program = Mandatoryprogram.program
UNION
SELECT idnr AS student, course
FROM MandatoryBranch, BasicInformation
WHERE MandatoryBranch.branch = BasicInformation.branch
AND MandatoryBranch.program = BasicInformation.program
EXCEPT SELECT student, course
FROM PassedCourses;


CREATE VIEW PathToGraduation AS
WITH stuID AS (SELECT idnr AS student FROM Students),

    totalCredits AS (SELECT student, SUM(credits) AS 
    totalCredits FROM PassedCourses GROUP BY student),

    mandatoryLeft AS (SELECT stuID.student, COUNT(course)
    AS mandatoryLeft FROM stuID LEFT JOIN UnreadMandatory
    ON stuID.student = UnreadMandatory.student
     GROUP BY stuID.student),

    mathCredits AS (SELECT student, SUM(credits) AS mathCredits
    FROM PassedCourses, Classified
    WHERE classified.classification = 'math' AND PassedCourses.course = classified.course 
    GROUP BY student),

    researchCredits AS (SELECT student, SUM(credits)AS researchCredits
    FROM PassedCourses, Classified
    WHERE classified.classification = 'research' AND PassedCourses.course = classified.course 
    GROUP BY student),

    seminarCourses AS (SELECT student, COUNT(PassedCourses.course) AS seminarCourses
    FROM PassedCourses, Classified
    WHERE classified.classification = 'seminar' AND PassedCourses.course = classified.course 
    GROUP BY student),
	
     
     recommendedCredits AS (
     SELECT StudentBranches.student, SUM(credits) AS recommendedCredits
     FROM (StudentBranches LEFT JOIN RecommendedBranch ON StudentBranches.branch = RecommendedBranch.branch 
     AND StudentBranches.program = RecommendedBranch.program) LEFT JOIN PassedCourses ON ( PassedCourses.course = RecommendedBranch.course AND PassedCourses.student = StudentBranches.student)
     WHERE StudentBranches.student = PassedCourses.student
     GROUP BY StudentBranches.student),




    qualified AS (SELECT stuID.student, mandatoryLeft = 0
    AND recommendedCredits >= 10 AND mathCredits >= 20 AND
    researchCredits >= 10 AND seminarCourses >= 1 AND stuID.student IN(SELECT student FROM StudentBranches)
    AS qualified
    FROM stuID, mandatoryLeft, recommendedCredits, mathCredits, researchCredits,
    seminarCourses WHERE stuID.student = mandatoryLeft.student AND stuID.student = recommendedCredits.student
    AND stuID.student = mathCredits.student AND stuID.student = researchCredits.student
    AND stuID.student = seminarCourses.student
    )
SELECT stuID.student, COALESCE(totalCredits,0) AS totalCredits, COALESCE(mandatoryLeft,0) AS mandatoryLeft,
    COALESCE(mathCredits,0) AS mathCredits, COALESCE(researchCredits,0) AS researchCredits,
    COALESCE(seminarCourses,0) AS seminarCourses, COALESCE(qualified,false) AS qualified
FROM stuID
    LEFT JOIN totalCredits ON stuID.student = totalCredits.student
    LEFT JOIN mandatoryLeft ON stuID.student = mandatoryLeft.student
    LEFT JOIN mathCredits ON stuID.student = mathCredits.student
    LEFT JOIN researchCredits ON stuID.student = researchCredits.student
    LEFT JOIN seminarCourses ON stuID.student = seminarCourses.student
    LEFT JOIN qualified ON stuID.student = qualified.student;

CREATE VIEW CourseQueuePositions AS
 SELECT course, student, position AS place
FROM WaitingList;
------------------------------------------------------------------------------------------------------
--function and triggers
/* Write two different triggers in this lab */

CREATE OR REPLACE FUNCTION RegisterCourse() RETURNS trigger AS $Register_To_Course$

DECLARE 

lastPos INT;

preCourse TEXT;

capacity INT;

reggedStudent INT;

prereq TEXT;


begin


lastPos := (SELECT COALESCE(MAX (waiting.position), 0) 
            FROM WaitingList AS waiting 
            WHERE NEW.course = waiting.course);
			
capacity := (SELECT limitCourses.capacity FROM LimitedCourses AS limitCourses
             WHERE NEW.course = limitCourses.code);


					

--First look for the prerequisites

IF (SELECT courses.prerequisites FROM Courses WHERE Courses.code = NEW.course) NOTNULL
        THEN
            FOREACH prereq IN ARRAY (SELECT courses.prerequisites FROM Courses WHERE Courses.code = NEW.course)
            LOOP
                IF (prereq NOTNULL) AND prereq NOT IN 
                (
                    SELECT PassedCourses.course FROM PassedCourses 
                    WHERE PassedCourses.student = NEW.student)
                THEN
                    RAISE EXCEPTION 'Prerequisites has not been fulfilled';
                END IF;
            END LOOP;
        END IF;

--Then look at if the student is Registered already or not

IF NEW.student IN (SELECT Registrations.student FROM Registrations
    WHERE Registrations.course =  NEW.course) 
	THEN
        RAISE EXCEPTION ' the student is already registered in this course, welps';
END IF;

-- Look at the capacity of the course
IF (SELECT COUNT(student) from Registrations AS regged 
    WHERE regged.course = NEW.course AND regged.status = 'registered') >= capacity THEN
    
    INSERT INTO WaitingList VALUES (NEW.student, NEW.course, lastPos +1);
ELSE
    INSERT INTO Registered VALUES (NEW.student, NEW.course);

END IF;

RETURN NEW;

END;

$Register_To_Course$ LANGUAGE plpgsql;

--The trigger of register to course
CREATE TRIGGER register_course
       INSTEAD OF INSERT OR UPDATE
       ON Registrations
       FOR EACH ROW EXECUTE FUNCTION RegisterCourse();



---------------------------------------------------------- OVAN KLAR


--The function that runs when the trigger to Unregister

CREATE OR REPLACE FUNCTION UnregisterCourse() RETURNS trigger AS $Unregister_To_Course$

DECLARE 

 
   
    courseStillFull BOOLEAN;
    
    

BEGIN 
 courseStillFull := (SELECT Count(student) FROM Registered WHERE course = OLD.course) - 1 
                        >= (SELECT capacity FROM LimitedCourses WHERE code = OLD.course);
 


--Check first if student is in the waiting List
    IF (EXISTS(SELECT student FROM WaitingList WHERE Course = OLD.course AND student = OLD.student))  
        THEN
         WITH student AS (DELETE FROM WaitingList WHERE course = OLD.course AND student = OLD.student RETURNING student, course, position)
            UPDATE WaitingList SET position = position - 1 WHERE course = OLD.course and position > position; 
            RETURN NEW;
    END IF; 


-- Then check if the course us full
    IF courseStillFull
        THEN
        DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
        RETURN NEW;
    END IF;

-- Then check that if there is no student in the waiting list

    IF (NOT EXISTS(SELECT student FROM WaitingList WHERE course = OLD.course))
            THEN DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
            RETURN NEW;
    END IF;


    WITH student AS (DELETE FROM WaitingList WHERE course = OLD.course AND position = 1 RETURNING student, course)
                     INSERT INTO Registered (student, course) SELECT student, course FROM student;
            UPDATE WaitingList SET position = position - 1 WHERE course = OLD.course;
        DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
        RETURN NEW;
END

$Unregister_To_Course$ LANGUAGE plpgsql;

CREATE TRIGGER UnregisterCourse
       INSTEAD OF DELETE OR UPDATE
       ON Registrations
       FOR EACH ROW EXECUTE FUNCTION UnregisterCourse();
--------------------------------------------------------------------------------------------------------------------
--Insertions


INSERT INTO Students VALUES (1111111111,'S1','ls1','Prog1');
INSERT INTO Students VALUES (2222222222,'S2','ls2','Prog1');
INSERT INTO Students VALUES (3333333333,'S3','ls3','Prog1');

INSERT INTO Courses VALUES ('CCC111','C1',10,'Dep1');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Dep1');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Dep1', '{CCC111}');

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',2);
