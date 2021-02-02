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
	code TEXT NOT NULL, /* possibly char array*/
	name TEXT NOT NULL,
	credits FLOAT NOT NULL,
	department TEXT NOT NULL,
	PRIMARY KEY(code)
);

CREATE TABLE LimitedCourses(
	code TEXT NOT NULL,
	capacity INT CHECK (capacity>0),
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
	code TEXT REFERENCES Courses(code),
	classification TEXT REFERENCES Classifications(name),
	PRIMARY KEY(code, classification)
);

CREATE TABLE MandatoryProgram(
	course TEXT REFERENCES Courses(code),
	program TEXT NOT NULL,
	PRIMARY KEY(course, program)
);

CREATE TABLE MandatoryBranch(
	course TEXT REFERENCES Courses(code),
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY (course, branch,program),
	FOREIGN KEY (branch, program) REFERENCES Branches(name,program)
);

CREATE TABLE RecommendedBranch(
	course TEXT REFERENCES Courses(code),
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY(course, branch,program),
	FOREIGN key(branch, program) REFERENCES Branches(name, program)
);

 CREATE TABLE Registered(
 	student NUMERIC(10) REFERENCES Students(idnr),
 	course TEXT REFERENCES Courses(code),
 	PRIMARY KEY(student, course)
 );

 CREATE TABLE Taken(
 	student NUMERIC(10) REFERENCES Students(idnr),
 	course TEXT REFERENCES Courses(code),
 	grade CHAR(1) NOT NULL CHECK(grade IN ('U', '3','4','5')),
 	PRIMARY key(student, course)
 );

 CREATE TABLE WaitingList(
 	student NUMERIC(10) REFERENCES Students(idnr),
 	course TEXT REFERENCES LimitedCourses(code),
 	position SERIAL,
 	PRIMARY KEY (student,course) 
 );

