package dearDiaryServer.ApiServer;

import dearDiaryServer.Database.SQL_Management;
import dearDiaryServer.Models.Diary;
import dearDiaryServer.Models.User;
import io.javalin.http.Context;
import io.javalin.http.HttpCode;

import java.util.List;

public class DearDiaryAPIHandler {
//    private static final QuoteDB database = new TestDatabase();

    /**
     * Get all quotes
     *
     * @param context The Javalin Context for the HTTP GET Request
     */
    public static void getAll(Context context) {
        System.out.println(context.body());
        String email = context.pathParamAsClass("email", String.class).get();
        List<Diary> diaries = SQL_Management.all(email);
        context.json(diaries);
    }

    /**
     * Create a new quote
     *
     * @param context The Javalin Context for the HTTP POST Request
     */
    public static void create(Context context) {
        System.out.println(context.body());
        Diary diary = context.bodyAsClass(Diary.class);
        Diary newDiary = SQL_Management.add(diary);
//        context.header("Location", "/quote/" + newDiary.getId());
        context.status(HttpCode.CREATED);
        context.json(newDiary);
    }

    public static void Login(Context context) {
        System.out.println(context.body());
        User user = context.bodyAsClass(User.class);
        String email = context.pathParamAsClass("email", String.class).get();
        User usercheck = SQL_Management.getUser(email);
        if (user.getPassword().equals(usercheck.getPassword())){
            context.json(usercheck);
        }
    }

    public static void createUser(Context context) {
        System.out.println(context.body());
        User user = context.bodyAsClass(User.class);
        context.status(HttpCode.CREATED);
        SQL_Management.createUser(user.getEmail(), user.getPassword());
    }
}