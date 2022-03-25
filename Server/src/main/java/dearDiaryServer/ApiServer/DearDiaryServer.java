package dearDiaryServer.ApiServer;

import io.javalin.Javalin;

import java.net.Inet4Address;
import java.net.UnknownHostException;

public class DearDiaryServer {
    private final Javalin server;

    public DearDiaryServer() {
        server = Javalin.create(config -> {
            config.defaultContentType = "application/json";
        });

        this.server.get("/diaries/{email}", DearDiaryAPIHandler::getAll);
        this.server.get("/login/{email}", DearDiaryAPIHandler::Login);
        this.server.post("/user/{email}", DearDiaryAPIHandler::createUser);
        this.server.post("/diary", DearDiaryAPIHandler::create);

    }

    public static void main(String[] args) throws UnknownHostException {
        DearDiaryServer server = new DearDiaryServer();
        server.start(5000);
        System.out.println("Servers IP Address: " + Inet4Address.getLocalHost());
    }

    public void start(int port) {
        this.server.start(port);
    }

    public void stop() {
        this.server.stop();
    }
}