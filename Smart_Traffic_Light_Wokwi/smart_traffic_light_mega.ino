/*
  Smart Traffic Light Control System
  Simulation-oriented Arduino project based on the supplied internship brief.

  4 lanes are represented by 2 IR-sensor inputs per lane.
  Each sensor represents one vehicle-detection point:
    LOW = vehicle detected
    HIGH = no vehicle

  Density score = number of active sensors in the lane (0..2).
  The controller gives the green signal to the lane with the highest density.
  Ties are resolved round-robin to provide fairness.

  For a real prototype, replace the simulated inputs with IR/ultrasonic sensors.
*/

const byte NUM_LANES = 4;

// Each lane has two simulated IR sensors.
const byte irPins[NUM_LANES][2] = {
  {2, 3},   // Lane 1
  {4, 5},   // Lane 2
  {6, 7},   // Lane 3
  {8, 9}    // Lane 4
};

// LED pins: Red, Yellow, Green for each lane.
const byte redPins[NUM_LANES]    = {10, 13, A0, A3};
const byte yellowPins[NUM_LANES] = {11, A1, A4, A5};
const byte greenPins[NUM_LANES]  = {12, A2, A6, A7};

// Timing
const unsigned long GREEN_TIME = 5000;
const unsigned long YELLOW_TIME = 1500;
const unsigned long ALL_RED_TIME = 500;

enum Phase { GREEN_PHASE, YELLOW_PHASE, ALL_RED_PHASE };
Phase phase = ALL_RED_PHASE;

byte activeLane = 0;
byte nextLane = 0;
unsigned long phaseStart = 0;

int density[NUM_LANES] = {0, 0, 0, 0};

void setup() {
  Serial.begin(9600);

  for (byte lane = 0; lane < NUM_LANES; lane++) {
    for (byte s = 0; s < 2; s++) {
      pinMode(irPins[lane][s], INPUT_PULLUP);
    }

    pinMode(redPins[lane], OUTPUT);
    pinMode(yellowPins[lane], OUTPUT);
    pinMode(greenPins[lane], OUTPUT);
  }

  allRed();
  phaseStart = millis();

  Serial.println("SMART TRAFFIC LIGHT CONTROL SYSTEM");
  Serial.println("-----------------------------------");
}

void loop() {
  readTrafficDensity();

  unsigned long elapsed = millis() - phaseStart;

  if (phase == ALL_RED_PHASE) {
    if (elapsed >= ALL_RED_TIME) {
      activeLane = selectLane();
      setGreen(activeLane);
      phase = GREEN_PHASE;
      phaseStart = millis();
      printStatus("GREEN");
    }
  }
  else if (phase == GREEN_PHASE) {
    if (elapsed >= GREEN_TIME) {
      setYellow(activeLane);
      phase = YELLOW_PHASE;
      phaseStart = millis();
      printStatus("YELLOW");
    }
  }
  else if (phase == YELLOW_PHASE) {
    if (elapsed >= YELLOW_TIME) {
      allRed();
      phase = ALL_RED_PHASE;
      phaseStart = millis();
      nextLane = (activeLane + 1) % NUM_LANES;
    }
  }
}

// LOW means the simulated IR sensor sees a vehicle.
void readTrafficDensity() {
  for (byte lane = 0; lane < NUM_LANES; lane++) {
    density[lane] = 0;
    for (byte s = 0; s < 2; s++) {
      if (digitalRead(irPins[lane][s]) == LOW) {
        density[lane]++;
      }
    }
  }
}

// Highest density wins.
// Round-robin tie-breaking prevents one lane from starving.
byte selectLane() {
  int maxDensity = -1;

  for (byte i = 0; i < NUM_LANES; i++) {
    if (density[i] > maxDensity) {
      maxDensity = density[i];
    }
  }

  for (byte offset = 0; offset < NUM_LANES; offset++) {
    byte lane = (nextLane + offset) % NUM_LANES;
    if (density[lane] == maxDensity) {
      return lane;
    }
  }

  return 0;
}

void allRed() {
  for (byte lane = 0; lane < NUM_LANES; lane++) {
    digitalWrite(redPins[lane], HIGH);
    digitalWrite(yellowPins[lane], LOW);
    digitalWrite(greenPins[lane], LOW);
  }
}

void setGreen(byte lane) {
  for (byte i = 0; i < NUM_LANES; i++) {
    digitalWrite(redPins[i], i == lane ? LOW : HIGH);
    digitalWrite(yellowPins[i], LOW);
    digitalWrite(greenPins[i], i == lane ? HIGH : LOW);
  }
}

void setYellow(byte lane) {
  for (byte i = 0; i < NUM_LANES; i++) {
    digitalWrite(redPins[i], i == lane ? LOW : HIGH);
    digitalWrite(yellowPins[i], i == lane ? HIGH : LOW);
    digitalWrite(greenPins[i], LOW);
  }
}

void printStatus(const char* state) {
  Serial.print(state);
  Serial.print(" | Selected lane: ");
  Serial.print(activeLane + 1);
  Serial.print(" | Density: ");

  for (byte lane = 0; lane < NUM_LANES; lane++) {
    Serial.print("L");
    Serial.print(lane + 1);
    Serial.print("=");
    Serial.print(density[lane]);
    if (lane < NUM_LANES - 1) Serial.print(", ");
  }

  Serial.println();
}
