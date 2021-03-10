
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

       String Sql_regiter = "INSERT INTO Registrations (?,?)";

        PreparedStatement statement = conn.prepareStatement(Sql_regiter); //Om error sätt in i Try Claus
        try {
            statement.setString(1, student);
            statement.setString(2, courseCode);

            System.out.println(statement);

            result =  statement.executeUpdate(); //Shows how many rows were affected
            if (result > 0){
                System.out.println("Insertion Okay");
            }

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



       String Sql_unregister = "DELETE FROM Registrations WHERE student = "+ student +" AND course = " + courseCode +"";
       // String Sql_unregister = "DELETE FROM Registrations WHERE student = ? AND course = ?";
       PreparedStatement statement = conn.prepareStatement(Sql_unregister);

       // String sql_unregister = "DELETE FROM Registrations WHERE student = ? AND course = ?";

       // Statement statement = conn.createStatement(Sql_unregister);


        try{
            statement.setString(1, student);
            statement.setString(2,courseCode);

            System.out.println(statement);

            result = statement.executeUpdate();//How many rows were affected

            return "{\"success\":true}";

        }  catch (SQLException e) {
        return "{\"success\":false, \"error\":\"" + getError(e) + "\"}";
    }
        //return "{\"success\":false, \"error\":\"Unregistration is not implemented yet :(\"}";
    }

    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{
        
        String Sql_BasicInformation =   "SELECT  idnr, Students.name, login, Students.program, StudentBranches.branch \n" +
                                         "FROM Students\n" +
                                          "LEFT JOIN StudentBranches\n" +
                                           "ON (StudentBranches.program = Students.program AND \n" +
                                            " StudentBranches.student = Students.idnr) WHERE Students.idnr = ?";


        String Sql_Taken            = "SELECT student, course, grade, credits\n" +
                                        "FROM Courses, Taken\n" +
                                         "WHERE course = code AND student = ?";


        String Sql_RegStatus        = "SELECT student, course, 'registered' as status\n" +
                                        " FROM Registered \n" +
                                          "UNION\n" +
                                           "SELECT student, course, 'waiting' as status\n" +
                                             "FROM WaitingList WHERE student = ?";

        String Sql_PathToGrad       = "SELECT * FROM PathToGraduation WHERE student = ?";


        JSONObject json = new JSONObject();

        PreparedStatement psSQLBasicInfo = conn.prepareStatement(Sql_BasicInformation);

        try(psSQLBasicInfo){

            psSQLBasicInfo.setString(1, student);
            
            ResultSet resultset = psSQLBasicInfo.executeQuery();
            
            if(resultset.next() != false){
                json.put("student", resultset.getString("idnr"));
                json.put("Students name", resultset.getString("name"));
                json.put("login", resultset.getString("login"));
                json.put("Students program", resultset.getString("program"));
                json.put("branch", resultset.getString("branch")); //Osäker på vad händer ifall branch är tom?

            }
            JSONObject course = new JSONObject();
            JSONArray Taken = new JSONArray();

            PreparedStatement psSQL = conn.prepareStatement(Sql_Taken);
            psSQL.setString(1,student);
            resultset = psSQL.executeQuery();

            while (resultset.next()){ //KSK WHILE
                course.put("student", resultset.getString("student"));
                course.put("course",resultset.getString("course"));
                course.put("grade",resultset.getInt("grade"));
                course.put("credits",resultset.getString("credits"));

                Taken.put(course);
            }
            json.put("Finished", Taken);


            JSONArray regged = new JSONArray();

            psSQL = conn.prepareStatement(Sql_RegStatus);
            psSQL.setString(1, student);
            resultset = psSQL.executeQuery();

            if (resultset.next()){
                course.put("course",resultset.getString("course"));
                course.put("status", resultset.getString("status"));
                regged.put(course);
            }

            json.put("Registered", regged);

            psSQL = conn.prepareStatement(Sql_PathToGrad);
            psSQL.setString(1, student);
            resultset = psSQL.executeQuery();

            if (resultset.next()){
                json.put("isQualified", resultset.getBoolean("qualified"));
                json.put("totalCredits", resultset.getFloat("totalCredits"));
                json.put("researchCredits", resultset.getFloat("researchCredits"));
                json.put("mathCredits", resultset.getFloat("mathCredits"));
                json.put("mandatoryLeft", resultset.getInt("mandatoryLeft"));
                json.put("seminarCourses", resultset.getInt("seminarCourses"));
                //json.put("recommendedCredits", resultset.getFloat("recommendedCredits"));
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
