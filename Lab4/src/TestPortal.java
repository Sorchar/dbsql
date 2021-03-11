public class TestPortal {

   // enable this to make pretty printing a bit more compact
   private static final boolean COMPACT_OBJECTS = false;

   // This class creates a portal connection and runs a few operation

   public static void main(String[] args) {
      try{
         PortalConnection c = new PortalConnection();
         // Write your tests here. Add/remove calls to pause() as desired. 
         // Use println instead of prettyPrint to get more compact output (if your raw JSON is already readable)

         // "Det ska gå att göra en injection via webb-portalen, alltså bör det gå att skriva t.ex. "CCC111' OR 'a' = 'a" i fältet för ett kurs, för att ta bort alla kurser."




          //-----test1------------------------------------

          prettyPrint(c.getInfo("1111111111")); //Test 1
          pause();


         //   -----------------------------Test2-------------------------------


          prettyPrint("TEST 2");

          prettyPrint(c.register("1111111111", "CCC111"));
          pause();


          prettyPrint(c.getInfo("1111111111"));
          pause();

          //   -----------------------------Test3------------------------------------

          prettyPrint("TEST 3");
          prettyPrint(c.register("1111111111", "CCC111")); //ERROR borde komma up
          pause();

          //   -----------------------------Test4------------------------------------

          prettyPrint("TEST 4");

          prettyPrint(c.unregister("1111111111", "CCC111"));
          pause();


                                    //--UNREG AGAIN--//
          prettyPrint(c.unregister("1111111111", "CCC111"));
          pause();


          //   -----------------------------Test5----------------------------------------

          prettyPrint("TEST 5");

          prettyPrint(c.register("1111111111", "CCC333")); // Test 5 Reg for a course dont have prereq

          pause();
          //   -----------------------------Test6-----------------------------------------

          prettyPrint("TEST 6");

          prettyPrint(c.register("5555555555", "CCC333")); //iNSERION 1
          pause(); //REG

          prettyPrint(c.register("6666666666", "CCC333")); //iNSERION 2
          pause(); //REG

          prettyPrint(c.register("7777777777", "CCC333")); //iNSERION 3
          pause(); //WL

          prettyPrint(c.register("8888888888", "CCC333")); //iNSERION 4
          pause(); //WL

          //MAY NEED GETINFO HERE BUT IDK

          prettyPrint(c.unregister("5555555555", "CCC333"));
          pause(); //stud 7 goes to reg, stud 8 first in WL (and ofc stud 5 unregged)

          prettyPrint(c.register("5555555555", "CCC333"));
          pause(); //Should be last in WL (pos 2)

          //   -----------------------------Test7-----------------------------------------

          prettyPrint("TEST 7");

          //UNREGG ALL
          prettyPrint(c.unregister("5555555555", "CCC333"));
          pause();



          //REGG 2 FIRst
          prettyPrint(c.register("5555555555", "CCC333"));
          pause(); //REG




          //   -----------------------------Test8-----------------------------------------

         prettyPrint("TEST 8");

         pause();

         prettyPrint(c.register("7777777777", "CCC555"));

         pause();

         prettyPrint(c.unregister("8888888888", "CCC555"));

        pause();

         //   -----------------------------SQL INJECTION CODE-----------------------------------------

          prettyPrint("TEST 9 SQL");

          pause();
          prettyPrint(c.unregisterVul("1111111111" ,"x' OR 'a' = 'a"));
          pause(); // SQL INJECTION CODE


      } catch (ClassNotFoundException e) {
         System.err.println("ERROR!\nYou do not have the Postgres JDBC driver (e.g. postgresql-42.2.18.jar) in your runtime classpath!");
      } catch (Exception e) {
         e.printStackTrace();
      }
   }

   public static void pause() throws Exception{
     System.out.println("PRESS ENTER");
     while(System.in.read() != '\n');
   }
   
   // This is a truly horrible and bug-riddled hack for printing JSON. 
   // It is used only to avoid relying on additional libraries.
   // If you are a student, please avert your eyes.
   public static void prettyPrint(String json){
      System.out.print("Raw JSON:");
      System.out.println(json);
      System.out.println("Pretty-printed (possibly broken):");
      
      int indent = 0;
      json = json.replaceAll("\\r?\\n", " ");
      json = json.replaceAll(" +", " "); // This might change JSON string values :(
      json = json.replaceAll(" *, *", ","); // So can this
      
      for(char c : json.toCharArray()){
        if (c == '}' || c == ']') {
          indent -= 2;
          breakline(indent); // This will break string values with } and ]
        }
        
        System.out.print(c);
        
        if (c == '[' || c == '{') {
          indent += 2;
          breakline(indent);
        } else if (c == ',' && !COMPACT_OBJECTS) 
           breakline(indent);
      }
      
      System.out.println();
   }
   
   public static void breakline(int indent){
     System.out.println();
     for(int i = 0; i < indent; i++)
       System.out.print(" ");
   }   
}
