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

/*CREATE VIEW RecommendedCredit AS
SELECT student, SUM (PassedCourses.credits)
FROM PassedCourses, RecommendedBranch
WHERE PassedCourses.course = RecommendedBranch.course
GROUP BY PassedCourses.student
ORDER BY student;*/


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
	
	recommendedCredits AS ( SELECT student, SUM(credits) AS recommendedCredits
    FROM PassedCourses, RecommendedBranch
    WHERE PassedCourses.course = RecommendedBranch.course
    GROUP BY student),
	

    qualified AS (SELECT stuID.student, mandatoryLeft = 0
    AND recommendedCourses >= 10 AND mathCredits >= 20 AND
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