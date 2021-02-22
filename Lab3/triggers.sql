/* Write two different triggers in this lab */

CREATE OR REPLACE FUNCTION RegisterCourse () RETURNS trigger $Register_To_Course$

DECLARE 

preCourse TEXT;

lastPos := (SELECT COALESCE(MAX (waiting.position), 0), 
            FROM WaitingList AS waiting 
            WHERE NEW.course = waiting.course);

reggedStudent := (SELECT COUNT(student) FROM Registrations AS rgged 
                  WHERE regged.course = NEW.course AND regged.status = 'registered');

capacity := (limitCourses.capacity FROM LimitedCourses AS limitCourses
             WHERE NEW.course = limitCourses.code);

begin
--First look for the prerequisites

IF (SELECT prerequisites FROM Courses WHERE Courses.code = NEW.course) NOTNULL THEN
    FOREACH preCourse in ARRAY (SELECT prerequisites FROM Courses WHERE Courses.code = NEW.course)
     LOOP 
        IF (preCourse NOTNULL) AND preCourse NOT IN (SELECT passCours.course FROM PassedCourses AS passCours
              WHERE passCours.student = NEW.student) THEN
              RAISE EXCEPTION '% Prerequisites is not fullfilled in order to be registered for this course';
        END IF;
     END LOOP;

END IF;

--Then look at if the student is Registered already or not

IF (NEW.student IN (SELECT Registrations.student FROM Registrations
    WHERE Registrations.course =  NEW.course) THEN
        RAISE EXCEPTION '% The student is already registered in this course');
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