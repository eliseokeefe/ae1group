import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

    static String link = "jdbc:sqlite:database/foodwaste.db";

    public static Connection connect() {
        try {
            Class.forName("org.sqlite.JDBC");  
            Connection c = DriverManager.getConnection(link);
            System.out.println("Connected!");
            return c;
        }

        catch (ClassNotFoundException e) {
            System.out.println("Can't find JDBC driver");
            e.printStackTrace();
        }

        catch (SQLException e) {
            System.out.println("Connection failed");
            e.printStackTrace();
        }

        return null;
      
    }
}