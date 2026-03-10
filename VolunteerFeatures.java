import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class VolunteerFeatures {

    public static void addVolunteer(Volunteer v){

        String sqlCommand = "INSERT INTO Volunteers(Name, ContactInfo, Role) VALUES(?, ?, ?)";

        try {
            Connection c = DatabaseConnection.connect();
            PreparedStatement statement = c.prepareStatement(sqlCommand);
            statement.setString(1, v.getName());
            statement.setString(2, v.getContactInfo());
            statement.setString(3, v.getRole());
            statement.executeUpdate();
            System.out.println("Volunteer added successfully.");
            c.close();

        } 
        catch (SQLException e) {
            e.printStackTrace();
        }

         
    }

    public static void readVolunteers(){
        String sqlCommand = "SELECT * FROM Volunteers";

        try {
            Connection c = DatabaseConnection.connect(); 
            PreparedStatement statement = c.prepareStatement(sqlCommand); 
            ResultSet results = statement.executeQuery(); 
            while(results.next()){
                int id = results.getInt("VolunteerID");
                String name = results.getString("Name"); 
                String contactInfo = results.getString("ContactInfo"); 
                String role = results.getString("Role"); 

                Volunteer v = new Volunteer(id, name, contactInfo, role); 

                System.out.println("ID: " + v.getId() + "," + "Name: " + v.getName() + "," + "Contact Information: " + v.getContactInfo() + "," + "Role: " + v.getRole());

            }

            c.close(); 
        } 
        catch (SQLException e) {
            e.printStackTrace(); 
        }
    }

    public static void deleteVolunteer(int id){ 
        String sqlCommand = "DELETE FROM Volunteers WHERE VolunteerID = ?";

    try {
        Connection c = DatabaseConnection.connect();
        PreparedStatement statement = c.prepareStatement(sqlCommand);

        statement.setInt(1, id);

        int rowsAffected = statement.executeUpdate();

        if(rowsAffected > 0){
            System.out.println("Volunteer deleted successfully.");
        } else {
            System.out.println("No volunteer found with that ID.");
        }

        c.close();

    } catch (SQLException e) {
        e.printStackTrace();
    }

    }
}