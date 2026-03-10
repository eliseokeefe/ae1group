# ae1group
AE1 DBMS 

# Description 
This project builds on an already created database that measures food waste across university dining halls, as well as tracks volunteers who help with this initiative. This program specifically utilizes a Java based command-line interface that connects to a SQLite database that allows you to interact with the Volunteers table. This interface checks for valid inputs before conducting any action.

# Technology
- Java
- SQLite JDBC Driver: https://github.com/xerial/sqlite-jdbc
- SQLite 

# Features 
- A user can create a new volunteer 
- A user can read a list of current volunteers 
- A user can delete volunteers 

# How to Run 
1. Compile Java files: javac -cp ".;lib/*" *.java
2. Run Application:  java -cp ".;lib/*" Main

# Data Validation 
Before data can be added: 
- Name, contact information, and role cannot be empty 
- Role must be valid (either Sorter, Coordinator, Driver, Admin, or Analyst)
Before data can be deleted: 
- The volunteer's ID must exist in the database to be deleted 