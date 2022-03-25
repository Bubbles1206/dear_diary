package dearDiaryServer.Database;

import dearDiaryServer.Models.Diary;
import dearDiaryServer.Models.User;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SQL_Management{
    private static final String CONN = "jdbc:sqlite:DearDiaryDB.db";
    private static Connection connect() {


        Connection conn = null;
        if(isSuitableDriverAvailable()) {
            try {
                conn = DriverManager.getConnection(CONN);
            } catch (SQLException e) {
                System.out.println(e.getMessage());
            }
        } else {
            System.err.println("The driver was not correctly loaded and execution was aborted");
        }
        return conn;
    }


    private static boolean isSuitableDriverAvailable() {
        try {
            Class.forName("org.sqlite.JDBC");
        } catch(ClassNotFoundException ex) {
            return false;
        }
        return true;
    }


    public static User getUser(String email){
        String sql = "SELECT * FROM Users where Email = " + email;
        User user = new User();
        try (Connection conn = connect();
             Statement stmt  = conn.createStatement();
             ResultSet rs    = stmt.executeQuery(sql)){
            // loop through the result set
            while (rs.next()) {
                user.setEmail(rs.getString("Email"));
                user.setPassword(rs.getString("Password"));
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        return  user;
    }


    public static void createUser(String email, String password){
        String sql2 = """
                INSERT INTO Users (
                                       Email,
                                       Password
                                   )
                                   VALUES (
                                       ?,
                                       ?
                                   );""";
        try (Connection conn = connect();
             PreparedStatement preSTMT = conn.prepareStatement(sql2)){
            preSTMT.setString(1, email);
            preSTMT.setString(2, password);
            preSTMT.executeUpdate();
        } catch (SQLException ex){
            System.out.println(ex.getMessage());
        }
    }


    public static List<Diary> getQuotes(String email){
        String sql = "SELECT * FROM Entries where Email = " + email;
        List<Diary> diaryList = new ArrayList<>();
        Diary newDiary = new Diary();
        Diary addDiary;
        try (Connection conn = connect();
             Statement stmt  = conn.createStatement();
             ResultSet rs    = stmt.executeQuery(sql)){
            // loop through the result set
            while (rs.next()) {
                newDiary.setName(rs.getString("Name"));
                newDiary.setText(rs.getString("Text"));
                newDiary.setDate(rs.getString("date"));
                addDiary = newDiary;
                newDiary = new Diary();
                diaryList.add(addDiary);
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }

        return diaryList;
    }


    public static void insert(String name, String text, String date) {
        String sql2 = """
                INSERT INTO Entries (
                                       Email,
                                       Text,
                                       Date
                                   )
                                   VALUES (
                                       ?,
                                       ?,
                                       ?
                                   );""";
        try (Connection conn = connect();
             PreparedStatement preSTMT = conn.prepareStatement(sql2)){
            preSTMT.setString(1, name);
            preSTMT.setString(2, text);
            preSTMT.setString(3, date);
            preSTMT.executeUpdate();
        } catch (SQLException ex){
            System.out.println(ex.getMessage());
        }
    }


    public static List<Diary> all(String email) {
        return getQuotes(email);
    }


    public static Diary add(Diary diary) {
        insert(diary.getName(), diary.getText(), diary.getDate());
        return diary;
    }
}
