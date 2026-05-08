package com.example;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

class AppTest {

    @Test
    void greeting_defaultsToWorld_whenNameIsNull() {
        assertEquals("Hello, world!", App.greeting(null));
    }

    @Test
    void greeting_defaultsToWorld_whenNameIsBlank() {
        assertEquals("Hello, world!", App.greeting("   "));
    }

    @Test
    void greeting_usesProvidedName() {
        assertEquals("Hello, Dhanush!", App.greeting("Dhanush"));
    }
}
