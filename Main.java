import java.util.Scanner; 

public class Main {
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in); 
            boolean inUse = true; 
            while(inUse){
                System.out.println("Enter 0 to exit, Enter 1 to create a new volunteer, Enter 2 to read a list of current volunteers, or Enter 3 to delete a current volunteer");
                int ans = in.nextInt(); 
                in.nextLine(); 
                    switch(ans){
                        case 0: 
                            System.out.println("Thank you for using the system!");
                            inUse = false; 
                            break;
                            
                        case 1: 
                            boolean nameBool = false; 
                            String name = "";
                                while(nameBool == false){
                                System.out.println("Enter the volunteer's name: "); 
                                name = in.nextLine(); 
                                if(name.trim().isEmpty()){
                                    System.out.println("The name cannot be empty");
                                }
                                else {
                                    nameBool = true; 
                                }
                                }

                            boolean contactInfoBool = false; 
                            String contactInfo = "";
                                while(contactInfoBool == false){
                                System.out.println("Enter the volunteer's contact information: ");
                                contactInfo = in.nextLine(); 
                                if(contactInfo.trim().isEmpty()){
                                    System.out.println("The contact information cannot be empty");
                                    }
                                else {
                                    contactInfoBool = true; 
                                }
                                }

                            boolean roleBool = false; 
                            String role = "";
                                while(roleBool == false){
                                System.out.println("Enter the volunteer's role"); 
                                role = in.nextLine(); 
                                if(role.trim().isEmpty()){
                                    System.out.println("The role cannot be empty");
                                    }
                                else if (!(role.trim().equals("Sorter") || role.trim().equals("Coordinator") || role.trim().equals("Driver") || role.trim().equals("Admin") || role.trim().equals("Analyst"))){
                                    System.out.println("Please enter a valid role. Valid roles are: Sorter, Coordinator, Driver, Admin, or Analyst");
                                }
                                else {
                                    roleBool = true; 
                                }
                                }

                            Volunteer v = new Volunteer(name, contactInfo, role); 
                            VolunteerFeatures.addVolunteer(v); 
                            break; 
                        
                        case 2: 
                            System.out.println("\nCurrent Volunteers: "); 
                            VolunteerFeatures.readVolunteers();
                            break; 

                        case 3: 
                            System.out.println("Enter the ID of the volunteer you would like to delete: ");
                            int id = in.nextInt(); 
                            VolunteerFeatures.deleteVolunteer(id);
                            break; 

                        default: 
                            System.out.println("Please enter a valid option"); 
                }
            }
                
    }
}