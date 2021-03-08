/* Write two different triggers in this lab */



CREATE OR REPLACE FUNCTION RegisterCourse() RETURNS trigger AS $Register_To_Course$

DECLARE 

lastPos INT;

preCourse TEXT;

capacity INT;

reggedStudent INT;

prereq TEXT;

numOFReqCourse INT;

numOFPassCourse INT;


begin

numOFReqCourse := (SELECT COUNT(forCourse) FROM Prerequisites WHERE forCourse = NEW.course);

numOFPassCourse := (SELECT COUNT(student) FROM Prerequisites JOIN PassedCourses ON Prerequisites.preCourse = course
                    WHERE student = NEW.student AND course = NEW.course);

lastPos := (SELECT COALESCE(MAX (waiting.position), 0) 
            FROM WaitingList AS waiting 
            WHERE NEW.course = waiting.course);
			
capacity := (SELECT limitCourses.capacity FROM LimitedCourses AS limitCourses
             WHERE NEW.course = limitCourses.code);


--First look for the prerequisites

IF (numOFReqCourse > numOFPassCourse) THEN
     RAISE EXCEPTION 'Prerequisite has not been fulfilled';
		END IF;


/*IF  ((SELECT Count(forCourse) FROM Prerequisites WHERE (forCourse = NEW.course) 
			AND (forCourse NOT IN (SELECT course FROM PassedCourses WHERE student = NEW.student))) > 0) -- Returns amount preqs that is NOT fulfilled

			THEN RAISE EXCEPTION 'Prerequisite has not been fulfilled';
		END IF;*/

--Look if the student arleady has done the Course
IF  (EXISTS(SELECT student FROM Taken 
            WHERE student = NEW.student
             AND course = NEW.course AND grade <> 'U'))
			THEN RAISE EXCEPTION 'The student has already completed the course before';
END IF;



--Look at if the student is in the Waiting list
IF(EXISTS (SELECT student FROM WaitingList 
           WHERE student = NEW.student AND course = NEW.course))
			
            THEN RAISE EXCEPTION 'The student is already in the Waiting list';
		END IF;

--Then look at if the student is Registered already or not

IF NEW.student IN (SELECT Registrations.student FROM Registrations
    WHERE Registrations.course =  NEW.course) 
	THEN
        RAISE EXCEPTION 'The student is already registered in this course, welps';
END IF;

-- look if the student has already passed the course
IF NEW.student IN (SELECT PassedCourses.student from PassedCourses
    WHERE PassedCourses.student = NEW.student)
AND
(NEW.course in (SELECT PassedCourses.course from PassedCourses 
    WHERE PassedCourses.course = NEW.course))
    THEN
        RAISE EXCEPTION 'Student has already passed the course';
END IF;


-- Look at the capacity of the course and att to WL
IF (SELECT COUNT(student) from Registrations AS regged 
    WHERE regged.course = NEW.course AND regged.status = 'registered') >= capacity THEN
    
    INSERT INTO WaitingList VALUES (NEW.student, NEW.course, lastPos + 1);
ELSE
    INSERT INTO Registered VALUES (NEW.student, NEW.course);

END IF;

RETURN NEW;

END;

$Register_To_Course$ LANGUAGE plpgsql;


--The trigger of register to course
CREATE TRIGGER Registercourse
       INSTEAD OF INSERT OR UPDATE
       ON Registrations
       FOR EACH ROW EXECUTE FUNCTION RegisterCourse();



---------------------------------------------------------- OVAN KLAR


--The function that runs when the trigger to Unregister

CREATE OR REPLACE FUNCTION UnregisterCourse() RETURNS trigger AS $Unregister_To_Course$
DECLARE 
     studentFromWaitingList INT;
   
    courseStillFull BOOLEAN;

    fstPosition INT;

    fstStudent INT;

BEGIN 
 courseStillFull := (SELECT Count(student) FROM Registered WHERE course = OLD.course) - 1 
                        >= (SELECT capacity FROM LimitedCourses WHERE code = OLD.course);
 
studentFromWaitingList := (SELECT student FROM WaitingList WHERE course = OLD.course AND student = OLD.student);

--Check first if student is in the waiting List
  IF (EXISTS(SELECT student FROM WaitingList WHERE course = OLD.course AND student = OLD.student))  
        THEN
         WITH student AS (DELETE FROM WaitingList WHERE course = OLD.course AND student = OLD.student RETURNING student, course, position)
            UPDATE WaitingList SET position = position - 1 WHERE course = OLD.course AND position > position; 
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
