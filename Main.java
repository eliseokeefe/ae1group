import java.util.Scanner; 

public class Main {
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in); 
                System.out.println("Enter the volunteer's name: "); 
                String name = in.nextLine(); 
                System.out.println("Enter the volunteer's contact information: ");
                String contactInfo = in.nextLine(); 
                System.out.println("Enter the volunteer's role"); 
                String role = in.nextLine(); 
                Volunteer v = new Volunteer(name, contactInfo, role); 
                VolunteerFeatures.addVolunteer(v); 
    }
}