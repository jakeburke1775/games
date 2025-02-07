// Inherit the parent event
event_inherited();

dir = 0

/*
rotSpd = 360 / 180
radius = 28 
*/

// Enum to define states
enum State {
    Oscillate,
    Spin
}

// Initial state variable
var state;

// Start event
function start() {
    // Determine initial state
    if (random(1) < 0.5) {
        state = State.Oscillate;
    } else {
        state = State.Spin;
    }
    
    // Perform action based on state
    switch (state) {
        case State.Oscillate:
            // Code to initialize oscillation
            show_debug_message("Oscillate state selected.");
            break;
        case State.Spin:
            // Code to initialize spinning
            show_debug_message("Spin state selected.");
            break;
    }
}

// Call the start function in the Start event
start();
