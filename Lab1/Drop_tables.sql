DROP TABLE IF EXISTS Students, Branches, Courses,
    LimitedCourses, StudentBranches, Classifications, 
    Classified, MandatoryProgram, MandatoryBranch, 
    RecommendedBranch, Registered, Taken, WaitingList
    CASCADE;


DROP VIEW IF EXISTS BasicInformation, FinishedCourses, 
PassedCourses, Registrations, UnreadMandatory, RecommendedCredit, 
PathToGraduation CASCADE;