import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException; 

public class VolunteerFeatures {

    public static void addVolunteer(Volunteer v){

        String sqlCommand = 
        "INSERT INTO Volunteers(Name, ContactInfo, Role) VALUES(?, ?, ?)";

        try {
            Connection c = DatabaseConnection.connect();
            PreparedStatement stmt = c.prepareStatement(sqlCommand);
            stmt.setString(1, v.getName());
            stmt.setString(2, v.getContactInfo());
            stmt.setString(3, v.getRole());
            stmt.executeUpdate();
            System.out.println("Volunteer added successfully.");

        } 
        catch (SQLException e) {
            e.printStackTrace();
        }
    }
}