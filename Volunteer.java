public class Volunteer {
    private int id; 
    private String name; 
    private String contactInfo; 
    private String role; 

    public Volunteer(String name, String contactInfo, String role){
        this.name = name; 
        this.contactInfo = contactInfo; 
        this.role = role; 
    }

    public String getName(){
        return name; 
    }

    public String getContactInfo(){
        return contactInfo; 
    }

    public String getRole(){ 
        return role; 
    }
}