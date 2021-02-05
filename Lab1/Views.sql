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
SELECT student, course, status
FROM Registered WHERE status = 'registered'
UNION
SELECT student, course, status
FROM WaitingList WHERE status = 'waiting';
/* not sure if correct havnt tested*/