package com.example;

import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;

public class App {

    static String greeting(String name) {
        if (name == null || name.isBlank()) {
            return "Hello, world!";
        }
        return "Hello, " + name + "!";
    }

    public static void main(String[] args) throws IOException {
        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8000"));
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);

        server.createContext("/", exchange -> {
            String name = exchange.getRequestURI().getQuery();
            String body = greeting(name);
            byte[] bytes = body.getBytes();
            exchange.sendResponseHeaders(200, bytes.length);
            try (OutputStream os = exchange.getResponseBody()) {
                os.write(bytes);
            }
        });

        server.setExecutor(null);
        server.start();
        System.out.println("Listening on port " + port);
    }
}
