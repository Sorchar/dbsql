
CREATE VIEW BasicInformation AS
SELECT  idnr, Students.name, login, Students.program, StudentBranches.branch 
FROM Students
LEFT JOIN StudentBranches
ON StudentBranches.program = Students.program AND
    StudentBranches.student = Students.idnr;


CREATE VIEW FinishedCourses AS
SELECT student, course, grade, courses.credits
FROM Courses, Taken
WHERE course = code;

CREATE VIEW PassedCourses AS SELECT
student, course, credits 
FROM Taken, Courses 
WHERE grade <> 'U' AND course = code;
