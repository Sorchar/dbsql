--Drop Everything
DROP TABLE IF EXISTS Students, Branches, Courses,
    LimitedCourses, StudentBranches, Classifications, 
    Classified, MandatoryProgram, MandatoryBranch, 
    RecommendedBranch, Registered, Taken, WaitingList,
    Department, Program, Prerequisites
    CASCADE;


DROP VIEW IF EXISTS BasicInformation, FinishedCourses, 
PassedCourses, Registrations, UnreadMandatory, RecommendedCredit, 
PathToGraduation CASCADE;
---------------------------------------------------------------------
-- Tables
CREATE TABLE Department(
	abbreviation TEXT UNIQUE,
	name TEXT NOT NULL,
	PRIMARY KEY(name)
);

CREATE TABLE Program(
	name TEXT NOT NULL,
	abbreviation TEXT NOT NULL,
	PRIMARY KEY (name)
);

CREATE TABLE Students(
	idnr NUMERIC(10),
	name TEXT NOT NULL,
	login TEXT NOT NULL UNIQUE,
	program TEXT REFERENCES Program(name),
	UNIQUE(idnr, program),
	PRIMARY KEY(idnr)
);

CREATE TABLE Branches(
	name TEXT NOT NULL,
	program TEXT REFERENCES Program(name),
	PRIMARY KEY(name, program)
);

CREATE TABLE Courses( 
	code CHAR(6) NOT NULL, 
	name TEXT NOT NULL UNIQUE,
	credits FLOAT NOT NULL,
	department TEXT REFERENCES Department(name),
	PRIMARY KEY(code)
);

CREATE TABLE LimitedCourses(
	code CHAR(6) REFERENCES Courses(code),
	capacity INT CHECK (capacity>0) NOT NULL,
	PRIMARY KEY(code)
);

CREATE TABLE StudentBranches(
	student NUMERIC(10) REFERENCES Students(idnr),
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	FOREIGN KEY(branch, program) REFERENCES Branches(name,program),
	FOREIGN KEY(student, program) REFERENCES Students(idnr, program),
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
	program TEXT REFERENCES Program(name),
	PRIMARY KEY(course, program)
);

CREATE TABLE MandatoryBranch(
	course CHAR(6) REFERENCES Courses(code),
	branch TEXT NOT NULL,
	program TEXT REFERENCES Program(name),
	PRIMARY KEY (course, branch, program),
	FOREIGN KEY (branch, program) REFERENCES Branches(name,program)
);

CREATE TABLE RecommendedBranch(
	course CHAR(6) REFERENCES Courses(code),
	branch TEXT NOT NULL,
	program TEXT REFERENCES Program(name),
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
 	UNIQUE(course, position),
 	PRIMARY KEY (student,course) 
 );


CREATE TABLE Prerequisites(
	precourse CHAR(6) REFERENCES Courses(code),
	forCourse CHAR(6) REFERENCES Courses(code),
	PRIMARY KEY(precourse, forCourse)
);


 --------------------------------------------------------------------------------------------------------------------
--Insertions

INSERT INTO Department VALUES ('D1', 'Dep1');
INSERT INTO Program VALUES ('Prog1', 'P1');

INSERT INTO Students VALUES (1111111111,'S1','ls1','Prog1');
INSERT INTO Students VALUES (2222222222,'S2','ls2','Prog1');
INSERT INTO Students VALUES (3333333333,'S3','ls3','Prog1');

INSERT INTO Courses VALUES ('CCC111','C1',10,'Dep1');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Dep1');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Dep1');

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',2);

INSERT INTO Prerequisites VALUES('CCC111', 'CCC333');




-------------------------------------------------------------------------------------------------------------------
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
