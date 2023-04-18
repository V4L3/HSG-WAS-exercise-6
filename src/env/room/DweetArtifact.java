package room;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import cartago.Artifact;
import cartago.OPERATION;

/**
 * A CArtAgO artifact that provides an operation for sending messages to agents
 * with KQML performatives using the dweet.io API
 */
public class DweetArtifact extends Artifact {

    private String url = "https://dweet.io/dweet/for/friend-of-the-user?message=please-wake-me-up";

    @OPERATION
    void sendMessage() {

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .GET()
                .build();

        try {
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            System.out.println("RESPONSE: " + response);
        } catch (IOException | InterruptedException e) {
            System.out.println("Something went wrong while dweeting: " + e.getMessage());
        }

    }
}
