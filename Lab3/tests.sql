\i startup.sql
-- Registered to an unlim Course
INSERT INTO Registrations VALUES ('1111111111', 'CCC111'); --No problem, "Insert 0 1"
-- Registered succesfully
SELECT * FROM Registrations;

-- Register to limited course 
INSERT INTO Registrations VALUES ('2222222222','CCC222'); --2, regged succesfully

SELECT * FROM Registrations;

-- Register and going into wait list
INSERT INTO Registrations VALUES ('1111111111','CCC222'); --1  waiting succesfully

INSERT INTO Registrations VALUES ('3333333333','CCC222'); --1 waiting succesfully

SELECT * FROM Registrations;

--Register several times 
INSERT INTO Registrations VALUES ('1111111111','CCC111'); --ERROR: the student is already registered in this course, welps

INSERT INTO Registrations VALUES ('2222222222','CCC222'); -- ERROR: the student is already registered in this course, welps

SELECT * FROM Registrations;


-- prerequisite not met
INSERT INTO Registrations VALUES ('1111111111','CCC333'); -- ERROR: Prerequisites has not been fulfilled


-- Prerequisite met
INSERT INTO Taken VALUES('1111111111','CCC222','5');
INSERT INTO Registrations VALUES ('1111111111','CCC333');
SELECT * FROM Registrations;  -- Registered succesfully


--------------------------------------------------------------^^ FOR first function and trigger (above)
-- Unregistered from unlim course
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC111';  --Deleted succesfully

SELECT * FROM Registrations;

--Unregister from limited course 
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC333';  --Deleted succesfully

SELECT * FROM Registrations;

--Unregister from WaitingList
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC222';  --Deleted succesfully

SELECT * FROM Registrations;

--Unergister from registered 
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC222';  --Deleted succesfully

SELECT * FROM Registrations;

--unregister from an overfull course with the WaitingList
INSERT INTO Registered VALUES ('2222222222','CCC222'); --Inserted succsessfully

INSERT INTO Registrations VALUES ('1111111111','CCC222');  --Inserted succsessfully

DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC222';  --Deleted succesfully, 

SELECT * FROM Registrations; 




