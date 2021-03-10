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

          prettyPrint(c.unregister("1111111111" ,"CCC333' OR 'a' = 'a"));
          pause();

          prettyPrint(c.getInfo("1111111111")); //Test 1
          pause();

          prettyPrint(c.register("1111111111", "CCC111")); //Test 2
          pause();

          prettyPrint(c.unregister("1111111111" ,"CCC111' OR 'a' = 'a"));
          pause();

          prettyPrint(c.getInfo("1111111111")); //Test 1
          pause();

          prettyPrint(c.register("1111111111", "CCC111")); //Test 2
          pause();

          prettyPrint(c.getInfo("1111111111")); //Test 2
          pause();

          prettyPrint(c.register("1111111111", "CCC111")); //Test 3 -> Should give an error msg
          pause();

          prettyPrint(c.unregister("1111111111", "CCC111")); //Test 4 unregg
          pause();

          prettyPrint(c.unregister("1111111111", "CCC111")); //Test 4 unregg agin but get an error msg
          pause();

          prettyPrint(c.register("1111111111", "'CCC333'")); // Test 5 Reg for a course dont have prereq

          prettyPrint(c.getInfo("1111111111"));
          pause();

          prettyPrint(c.getInfo("2222222222"));
          pause();

          prettyPrint(c.unregister("2222222222", "CCC333"));
         pause();

         prettyPrint(c.getInfo("2222222222")); 
         pause();

         prettyPrint(c.register("2222222222", "CCC333"));
         pause();



         prettyPrint(c.getInfo("2222222222"));
         pause();

      
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
