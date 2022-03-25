package dearDiaryServer.Models;

public class Diary {
    private String text;
    private String name;
    private String date;

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    /**
     * Use this convenient factory method to create a new quote.
     * Warning the ID will be null!
     * @param text the text of the quote
     * @param name the name of the person that said the text
     * @return a Quote object
     */
    public static Diary create(String text, String name, int id, String date) {
        Diary diary = new Diary();
        diary.setText(text);
        diary.setName(name);
        diary.setDate(date);
        return diary;
    }
}