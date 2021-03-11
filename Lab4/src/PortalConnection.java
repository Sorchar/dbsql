
import netscape.javascript.JSObject;

import javax.swing.*;
import java.sql.*; // JDBC stuff.
import java.util.Properties;
import org.json.*;
import java.sql.Statement;


public class PortalConnection {

    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/lab1tda357";
    static final String USERNAME = "postgres";
    static final String PASSWORD = "postgres";

    // For connecting to the chalmers database server (from inside chalmers)
    // static final String DATABASE = "jdbc:postgresql://brage.ita.chalmers.se/";
    // static final String USERNAME = "tda357_nnn";
    // static final String PASSWORD = "yourPasswordGoesHere";

    java.sql.Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost/lab1tda357", "postgres","postgres");
    // This is the JDBC connection object you will be using in your methods.
  //  private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);  
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }


    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode) throws SQLException {

        int result = 0;

       String Sql_regiter = "INSERT INTO Registrations VALUES (?,?);";


        try(PreparedStatement statement = conn.prepareStatement(Sql_regiter); ) {
            statement.setString(1, student);
            statement.setString(2, courseCode);

            result =  statement.executeUpdate(); //Shows how many rows were affected


            return "{\"success\":true}";

        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\"" + getError(e) + "\"}";
        }

        // placeholder, remove along with this comment.
      //  return "{\"success\":false, \"error\":\"Registration is not implemented yet :(\"}";
    }
      

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode) throws SQLException {
        int result = 0;



       //String Sql_unregister = "DELETE FROM Registrations WHERE student = "+ student +" AND course = " + courseCode +"";
        String Sql_unregister = "DELETE FROM Registrations WHERE student = ? AND course = ?";
       PreparedStatement statement = conn.prepareStatement(Sql_unregister);

       // String sql_unregister = "DELETE FROM Registrations WHERE student = ? AND course = ?";

       // Statement statement = conn.createStatement(Sql_unregister);


        try{
            statement.setString(1, student);
            statement.setString(2,courseCode);

            System.out.println(statement);


            result = statement.executeUpdate();//How many rows were affected
            if (result == 0){
                return "{\"success\":false, \"error\":\"" + "Student already Unregged (Does not exist)" + "\"}";
            }

            return "{\"success\":true}";

        }  catch (SQLException e) {
        return "{\"success\":false, \"error\":\"" + getError(e) + "\"}";
    }
        //return "{\"success\":false, \"error\":\"Unregistration is not implemented yet :(\"}";
    }


    //_----------------------------------------------------------------------------------------------------------------------
    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregisterVul(String student, String courseCode) throws SQLException {

        int result = 0;

        String Sql_unregister = "DELETE FROM Registrations WHERE student = '" + student + "' AND course = '" + courseCode + "';";
        // String Sql_unregister = "DELETE FROM Registrations WHERE student = ? AND course = ?";
        PreparedStatement statement = conn.prepareStatement(Sql_unregister);


        try{
           // statement.setString(1, student);
           // statement.setString(2,courseCode);

            System.out.println(statement);

            result = statement.executeUpdate();//How many rows were affected

            return "{\"success\":true}";

        }  catch (SQLException e) {
            return "{\"success\":false, \"error\":\"" + getError(e) + "\"}";
        }

    }
    //_----------------------------------------------------------------------------------------------------------------------

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{
        
        String Sql_BasicInformation =   "SELECT  idnr, Students.name, login, Students.program, StudentBranches.branch \n" +
                                         "FROM Students\n" +
                                          "LEFT JOIN StudentBranches\n" +
                                           "ON (StudentBranches.student = Students.idnr) WHERE Students.idnr = ?";


        String Sql_Taken            = "SELECT name, course, grade, credits\n" +
                                        "FROM Courses, Taken\n" +
                                         "WHERE course = code AND student = ?";


        String Sql_RegStatus        = "SELECT name, course, 'registered' as status, NULL AS position\n" +
                                        " FROM Registered, Courses WHERE course = code AND student = ?\n" +
                                          "UNION\n" +
                                           "SELECT student, course, 'waiting' as status, place AS position\n" +
                                             "FROM CourseQueuePositions, Courses WHERE course = code AND student = ?";

        String Sql_PathToGrad       = "SELECT * FROM PathToGraduation WHERE student = ?";


        JSONObject json = new JSONObject();

        PreparedStatement psSQLBasicInfo = conn.prepareStatement(Sql_BasicInformation);

        try(psSQLBasicInfo){

            psSQLBasicInfo.setString(1, student);
            
            ResultSet resultset = psSQLBasicInfo.executeQuery();
            
            if(resultset.next() != false){
                json.put("student", resultset.getString("idnr"));
                json.put("name", resultset.getString("name"));
                json.put("login", resultset.getString("login"));
                json.put("program", resultset.getString("program"));
                json.put("branch", resultset.getString("branch")); //Osäker på vad händer ifall branch är tom?


            }
            JSONObject course = new JSONObject();
            JSONArray Taken = new JSONArray();

            PreparedStatement psSQL = conn.prepareStatement(Sql_Taken);
            psSQL.setString(1,student);
            resultset = psSQL.executeQuery();

            while (resultset.next()){
                course.put("course",resultset.getString("name"));
                course.put("code", resultset.getString("course"));
                course.put("credits",resultset.getString("credits"));
                course.put("grade",resultset.getInt("grade"));


                Taken.put(course);
            }
            json.put("finished", Taken);


            JSONArray regged = new JSONArray();

            psSQL = conn.prepareStatement(Sql_RegStatus);
            psSQL.setString(1, student);
            psSQL.setString(2, student);
            resultset = psSQL.executeQuery();

            if (resultset.next()){
                course.put("course",resultset.getString("name"));
                course.put("code", resultset.getString("course"));
                course.put("status", resultset.getString("status"));
                course.put("position", resultset.getString("position"));

                regged.put(course);
            }

            json.put("registered", regged);

            psSQL = conn.prepareStatement(Sql_PathToGrad);
            psSQL.setString(1, student);
            resultset = psSQL.executeQuery();

            if (resultset.next()){
                json.put("seminarCourses", resultset.getInt("seminarCourses"));
                json.put("mathCredits", resultset.getFloat("mathCredits"));
                json.put("researchCredits", resultset.getFloat("researchCredits"));
                json.put("totalCredits", resultset.getFloat("totalCredits"));
                json.put("canGraduate", resultset.getBoolean("qualified"));

            }

        } catch (JSONException e) {
            e.printStackTrace();
        }
        return json.toString();
    }

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.
    public static String getError(SQLException e){
       String message = e.getMessage();
       int ix = message.indexOf('\n');
       if (ix > 0) message = message.substring(0, ix);
       message = message.replace("\"","\\\"");
       return message;
    }
}
