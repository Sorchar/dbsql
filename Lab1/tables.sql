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
