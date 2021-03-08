
-- Registered to an unlim Course
INSERT INTO Registrations VALUES ('1111111111', 'CCC111');
SELECT * FROM Registrations;

-- Register to limited course 
INSERT INTO Registrations VALUES ('2222222222','CCC222'); 
SELECT * FROM Registrations;


INSERT INTO Registrations VALUES ('1111111111','CCC222'); 

INSERT INTO Registrations VALUES ('3333333333','CCC222'); 
SELECT * FROM Registrations;

--Register several times 
INSERT INTO Registrations VALUES ('1111111111','CCC111'); 

INSERT INTO Registrations VALUES ('2222222222','CCC222'); 

--Try register if in WL

INSERT INTO Registrations VALUES ('1111111111','CCC222'); 
SELECT * FROM Registrations;

--Try register for a taken course (Passed) Fixat
INSERT INTO Taken VALUES('4444444444','CCC222','5');
INSERT INTO Registrations VALUES ('4444444444','CCC222');
SELECT * FROM Registrations;

--Try register for a taken course (Failed) Fixat
INSERT INTO Taken VALUES('333333333','CCC222','U');
INSERT INTO Registrations VALUES ('3333333333','CCC222');
SELECT * FROM Registrations;

-- prerequisite not met
INSERT INTO Registrations VALUES ('1111111111','CCC333');  -- KLaga
SELECT * FROM Registrations;

-- Prerequisite met
INSERT INTO Taken VALUES('4444444444','CCC111','5');--kanske för att den inte ens läser in '5'
INSERT INTO Registrations VALUES ('4444444444','CCC333');
SELECT * FROM Registrations;

--Insert a value to WL in order to remove att next test (Remove middle (2))
INSERT INTO Registrations VALUES ('4444444444','CCC222'); 

DELETE FROM WaitingList WHERE student = '3333333333' AND Course = 'CCC222'; --Positionen förändras ej (no update)
SELeCT * FROM WaitingList;


-- Unregistered from unlim course
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC111';  
SELECT * FROM Registrations;

--Unregister from limited course 
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC333';  
SELECT * FROM Registrations;

--Unregister from WaitingList
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC222';  
SELECT * FROM Registrations;

--Unergister from registered 
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC222'; 
SELECT * FROM Registrations;

--unregister from an overfull course with the WaitingList
INSERT INTO Registered VALUES ('2222222222','CCC222'); 
SELECT * FROM Registrations;

INSERT INTO Registrations VALUES ('1111111111','CCC222'); 
SELECT * FROM Registrations;

DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC222';   
SELECT * FROM Registrations;









