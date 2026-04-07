

PFont stdFont;
PFont startFont;
PFont smallFont;

final int EVENT_BUTTON_QUERY=1;
final int EVENT_BUTTON_DRAW=2;
final int EVENT_BUTTON_START =5;
final int EVENT_BUTTON_BACK =6;
//final int EVENT_BUTTON_EXIT =7;

final int EVENT_BAR = 10;
final int EVENT_SCATTER = 11;
final int EVENT_PIE_CANCELLED = 12;
final int EVENT_PIE_DISTANCE = 13;
final int EVENT_NULL=0;
final int EVENT_PIE_CITY_DIST = 21;

// NEW EVENTS
final int EVENT_SELECT_AIRLINE_SCREEN = 50;
final int EVENT_CONFIRM_AIRLINES = 51;
final int EVENT_SHOW_DISTANCES = 52;

Table flightData;

Screen introScreen;
Screen AirlineScreen;
Screen AirportScreen;
Screen graphScreen;
Screen selectionScreen;
Screen airlineSelectScreen;

Screen currentScreen;
ArrayList<Screen> screenHistory = new ArrayList<Screen>();

Widget widgetDrawGraph;
Widget startButton;
Widget introStartButton;
//Widget exitButton;
Widget backButton;
Widget confirmAirlinesButton;
Widget showDistancesButton;

Widget buttonBar;
Widget buttonScatter;
Widget buttonPieCancelled;
Widget buttonPieDist;
Widget selectAirlineButton;
Widget selectAirportButton;

Widget[] airlineCheckboxes;
ArrayList<String> selectedAirlines = new ArrayList<String>();

int topN = 20;
String selectedColumn = "";
int graphType = EVENT_BAR;

ArrayList<String> airlines = new ArrayList<String>();
String selectedAirlineDist;
String selectedAirlineCancelled;
int[] countsDist;
int[] countsCancelled;
Widget[] airlineButtonsDist;
Widget[] airlineButtonsCancelled;

PImage planeImage, title, planeIcon;


// ================= SETUP =================
void setup(){
  size(1000,700);
  flightData = loadTable("flights2k.csv", "header");
  planeImage = loadImage("plane.png");
  planeImage.resize(200,100);
  
  planeIcon = loadImage("planeIcon.jpg");
  planeIcon.resize(400,200);
  title = loadImage("title.png");
  
 

  stdFont = createFont("Arial", 14);
  startFont = createFont("Arial", 40);
  textFont(stdFont);

  backButton = new Widget(20,20,100,40,"Back",color(#FF6B6B),stdFont,EVENT_BUTTON_BACK);

  // ===== INTRO SCREEN =====
  introScreen = new Screen(color(#FFFFFF));

  introStartButton = new Widget(400,500,200,50,"START",color(#4D92F0),stdFont,EVENT_BUTTON_START);
  //exitButton = new Widget(400,420,200,80,"EXIT",color(#DE2D44),stdFont,EVENT_BUTTON_EXIT);
  introScreen.add(introStartButton);
  //introScreen.add(exitButton);

  // ===== SELECTION SCREEN =====
  selectionScreen = new Screen(color(#CFF5E7));
  selectAirlineButton = new Widget(350,250,300,80,"Select Airline",color(#68D1EA),stdFont,20);
  selectAirportButton = new Widget(350,370,300,80,"Select Airport",color(#68D1EA),stdFont,21);
  selectionScreen.add(selectAirlineButton);
  selectionScreen.add(selectAirportButton);
  selectionScreen.add(backButton);

  // AIRLINE SELECT SCREEN
  airlineSelectScreen = new Screen(color(255));

  // GRAPH SCREEN
  graphScreen = new Screen(color(255));
  graphScreen.add(backButton);

  currentScreen = introScreen;

  // LOAD AIRLINES
  for (TableRow row : flightData.rows()) {
    String name = row.getString("MKT_CARRIER");
    if (name != null && !airlines.contains(name)) {
      airlines.add(name);
    }
  }

  selectedAirlineDist = airlines.get(0);
  selectedAirlineCancelled = airlines.get(0);
  countsDist = queryAirlineDistances(selectedAirlineDist);
  countsCancelled = queryCancelledByAirport(selectedAirlineCancelled);

    // === CREATE BUTTONS AIRLINES DISTANCES ===
  int n = min(10, airlines.size());
  airlineButtonsDist = new Widget[n];
  
  for (int i = 0; i < n; i++) {
    airlineButtonsDist[i] = new Widget(
      30, 
      80 + i * 50, 
      100, 
      40, 
      airlines.get(i), 
      color(120), 
      stdFont, 
      100 + i
    );
  }
  
    // === CREATE BUTTONS AIRLINES CANCELLED ===
  airlineButtonsCancelled = new Widget[n];
  
  for (int i = 0; i < n; i++) {
    airlineButtonsCancelled[i] = new Widget(
      30, 
      80 + i * 50, 
      100, 
      40, 
      airlines.get(i), 
      color(120), 
      stdFont, 
      100 + i
    );
  }

  // CHECKBOXES
  airlineCheckboxes = new Widget[airlines.size()];
  for (int i = 0; i < airlines.size(); i++) {
    airlineCheckboxes[i] = new Widget(60, 80 + i * 35, 20, 20, airlines.get(i), color(200), stdFont, 1000+i);
  }

  confirmAirlinesButton = new Widget(300,600,200,60,"Show Flights",color(#68D1EA),stdFont,EVENT_CONFIRM_AIRLINES);
  showDistancesButton = new Widget(550,600,200,60,"Show Distances",color(#68D1EA),stdFont,EVENT_SHOW_DISTANCES);

  airlineSelectScreen.add(confirmAirlinesButton);
  airlineSelectScreen.add(showDistancesButton);
  airlineSelectScreen.add(backButton);

  // ===== AIRPORT SCREEN =====
  AirportScreen = new Screen(color(255));

  widgetDrawGraph = new Widget(400,300,200,60,"Draw Graph",color(#68D1EA),stdFont,EVENT_BUTTON_DRAW);

  buttonBar = new Widget(40,120,180,50,"Bar Chart",color(120),stdFont,EVENT_BAR);
  buttonScatter = new Widget(40,190,180,50,"Scatter",color(140),stdFont,EVENT_SCATTER);
  buttonPieCancelled = new Widget(40,260,180,50,"Pie Chart",color(160),stdFont,EVENT_PIE_CANCELLED);
  buttonPieDist = new Widget(40,330,180,50,"Pie Chart Dist",color(160),stdFont,EVENT_PIE_DISTANCE);

  AirportScreen.add(widgetDrawGraph);
  AirportScreen.add(buttonBar);
  AirportScreen.add(buttonScatter);
  AirportScreen.add(buttonPieCancelled);
  AirportScreen.add(buttonPieDist);
  AirportScreen.add(backButton);
}

// ================= DRAW =================
void draw(){
  currentScreen.draw();
  fill(#C12323);
  strokeWeight(2);
  rect(0,0,width,8);
  rect(width-8,0,8,height);
  rect(0,height-8,width,8);
  rect(0,0,8,height);
  if(currentScreen == airlineSelectScreen){
    for(int i=0;i<airlineCheckboxes.length;i++){
      Widget w = airlineCheckboxes[i];

      fill(255);
      stroke(0);
      rect(w.x, w.y, 20, 20);

      if(selectedAirlines.contains(airlines.get(i))){
        line(w.x, w.y, w.x+20, w.y+20);
        line(w.x+20, w.y, w.x, w.y+20);
      }

      fill(0);
      textAlign(LEFT, CENTER);
      text(airlines.get(i), w.x+30, w.y+10);
    }
  }

  if(currentScreen == graphScreen){
    if(graphType == EVENT_BAR){
      drawBarGraph("MKT_CARRIER");
    }
    else if(graphType == EVENT_SCATTER){
      drawScatterPlot(selectedColumn);
    }
    else if(graphType == EVENT_PIE_CANCELLED){
      drawPieChartCancelled();
    }
    else if(graphType == EVENT_PIE_DISTANCE){
      drawPieChartDistances();
      drawAirlineButtonsDist();
    }
  }
  
  if(currentScreen == selectionScreen){
    image(planeImage,100,300);
  }
  if(currentScreen == introScreen){
    title.resize(700,350);
    image(title, 50,50);
    image(planeIcon,550,50);
  }
  
  
}




// ================= MOUSE =================
void mousePressed(){

  if(currentScreen == airlineSelectScreen){
    for (int i = 0; i < airlineCheckboxes.length; i++) {
      Widget w = airlineCheckboxes[i];
      if(mouseX>w.x && mouseX<w.x+20 && mouseY>w.y && mouseY<w.y+20){
        String airline = airlines.get(i);
        if(selectedAirlines.contains(airline)){
          selectedAirlines.remove(airline);
        } else {
          selectedAirlines.add(airline);
        }
      }
    }
  }

  int theEvent = currentScreen.getEvent();

  // ===== AIRLINE DISTANCE BUTTON CLICK =====
  if(graphType == EVENT_PIE_DISTANCE && airlineButtonsDist != null){
    for (int i = 0; i < airlineButtonsDist.length; i++) {
      if(airlineButtonsDist[i].getEvent(mouseX, mouseY) != EVENT_NULL){
        selectedAirlineDist = airlines.get(i);
        countsDist = queryAirlineDistances(selectedAirlineDist);
      }
    }
  }
  
  // ===== AIRLINE CANCELLED BUTTON CLICK =====
  if(graphType == EVENT_PIE_CANCELLED && airlineButtonsCancelled != null){
    for (int i = 0; i < airlineButtonsCancelled.length; i++) {
      if(airlineButtonsCancelled[i].getEvent(mouseX, mouseY) != EVENT_NULL){
        selectedAirlineCancelled = airlines.get(i);
        countsCancelled = queryCancelledByAirport(selectedAirlineCancelled);
      }
    }
  }

  switch(theEvent){

    case EVENT_BUTTON_START:
      switchScreen(selectionScreen);
       
      break;

    case 20:
      switchScreen(airlineSelectScreen);
      break;

    case 21:
      switchScreen(AirportScreen);
      break;

    case EVENT_CONFIRM_AIRLINES:
      graphType = EVENT_BAR;
      switchScreen(graphScreen);
      break;

    case EVENT_SHOW_DISTANCES:
      graphType = EVENT_PIE_DISTANCE;
      switchScreen(graphScreen);
      break;

    case EVENT_BAR:
      graphType = EVENT_BAR;
      break;

    case EVENT_SCATTER:
      graphType = EVENT_SCATTER;
      switchScreen(graphScreen);
      break;

    case EVENT_PIE_CANCELLED:
      graphType = EVENT_PIE_CANCELLED;
      switchScreen(graphScreen);
      break;

    case EVENT_PIE_DISTANCE:
      graphType = EVENT_PIE_DISTANCE;
      switchScreen(graphScreen);
      break;

    case EVENT_BUTTON_BACK:
      if(screenHistory.size() > 0){
        currentScreen = screenHistory.remove(screenHistory.size()-1);
      }
      break;
  }
}

// BAR GRAPH + filtering added
void drawBarGraph(String columnName) {
  // --- Count frequencies ---
  HashMap<String, Integer> counts = new HashMap<String, Integer>();
    for (TableRow row : flightData.rows()) {
    String airline = row.getString("MKT_CARRIER");

    //filter by selected airlines
    if(selectedAirlines.size()==0 || selectedAirlines.contains(airline)){
      String val = row.getString(columnName);
      counts.put(val, counts.getOrDefault(val, 0) + 1);
    }
  }

  // --- Sort by frequency descending, take top N ---
  ArrayList<String> keys = new ArrayList<String>(counts.keySet());
  keys.sort((a, b) -> counts.get(b) - counts.get(a));
  keys = new ArrayList<String>(keys.subList(0, min(topN, keys.size())));

  int maxCount = 0;
  for (String k : keys) maxCount = max(maxCount, counts.get(k));

  // --- Layout ---
  int marginL = 260, marginT = 60, chartW = width - marginL - 50, chartH = height - marginT - 140;
  stroke(220);
  fill(100);
  textAlign(RIGHT, CENTER);

  // --- Gridlines + Y labels ---
  stroke(220);
  fill(100);
  textAlign(RIGHT, CENTER);
  textSize(14);

  for (int i = 0; i <= 5; i++) {
    int val = (int) map(i, 0, 5, 0, maxCount);
    float y = map(val, 0, maxCount, marginT + chartH, marginT);
    line(marginL, y, marginL + chartW, y);
    text(val, marginL - 6, y);
  }

  // --- Bars ---
  float barW = (float) chartW / keys.size();
  float pad  = barW * 0.15;

  for (int i = 0; i < keys.size(); i++) {
    String k = keys.get(i);
    int count = counts.get(k);

    float x = marginL + i * barW + pad;
    float w = barW - pad * 2;
    float h = map(count, 0, maxCount, 0, chartH);
    float y = marginT + chartH - h;

    boolean hover = mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h;

    fill(hover ? color(70, 130, 200) : color(100, 160, 220));
    rect(x, y, w, h, 3);

    fill(0);
    textAlign(CENTER);
    text(count, x + w/2, y - 2);

    pushMatrix();
    translate(x + w/2, marginT + chartH + 10);
    rotate(HALF_PI * 0.9);
    textAlign(LEFT);
    text(k, 0, 0);
    popMatrix();
  }

  // --- Axes ---
  stroke(0);
  line(marginL, marginT, marginL, marginT + chartH);
  line(marginL, marginT + chartH, marginL + chartW, marginT + chartH);

  // --- Title ---
  textAlign(CENTER);
  text("Carrier Frequency", marginL + chartW/2, 30);
}
// ================= NAV =================
void switchScreen(Screen newScreen){
  if(currentScreen != null){
    screenHistory.add(currentScreen);
  }
  currentScreen = newScreen;
}



// ======= QUERY CANCELLED FLIGHTS ===========
int[] queryCancelledByAirport(String airport) {
  int[] counts = new int[2]; 
  for (TableRow row : flightData.rows()) {
    if (row.getString("MKT_CARRIER").equals(airport)) {
      if (row.getInt("CANCELLED") == 1) counts[0]++;
      else counts[1]++;
    }
  }
  return counts;
}

void drawAirlineButtonsCancelled() {
  if(airlineButtonsCancelled == null) return;
  for (Widget w : airlineButtonsCancelled) {
    w.draw();
  }
}
//=================== PIE CHART SUCCESSFUL FLIGHTS ======================
void drawPieChartCancelled() {
  int cancelled = countsCancelled[0];
  int notCancelled = countsCancelled[1];

  float total = cancelled + notCancelled;
  float angle = map(cancelled, 0, total, 0, TWO_PI);

  float cx = 600, cy = 350, r = 150;

  //hover
  float mouseAngle = atan2(mouseY - cy, mouseX - cx);
  if (mouseAngle < 0) mouseAngle += TWO_PI;

  boolean hover1 = mouseAngle < angle;
  boolean hover2 = mouseAngle >= angle;

  //draw slices
  fill(hover1 ? color(70, 130, 200) : color(100, 160, 220));
  arc(cx, cy, r*2, r*2, 0, angle);

  fill(hover2 ? color(70, 200, 200) : color(80, 180, 120));
  arc(cx, cy, r*2, r*2, angle, TWO_PI);

  //labels
  fill(0);
  textAlign(CENTER);
  text("Cancelled/Not Cancelled Flights", cx, 80);

  text("Cancelled: " + cancelled, cx - 120, cy + r + 40);
  text("Not Cancelled: " + notCancelled, cx + 120, cy + r + 40);
}

// ================= SCATTER =================
void drawScatterPlot(String input) {
  int marginL = 260, marginT = 60;

  line(marginL, height-100, width-50, height-100);
  line(marginL, marginT, marginL, height-100);

  for (TableRow row : flightData.rows()) {
    float xVal = row.getFloat("DISTANCE");
    float yVal = row.getFloat(input);

    float x = map(xVal, 0, 3000, marginL, width-50);
    float y = map(yVal, 0, 2400, height-100, marginT);

    ellipse(x, y, 5, 5);
  }
}

// ======== QUERY AIRLENE DISTANCES PIE CHART ==========
int[] queryAirlineDistances(String airline) {
  int[] buckets = new int[4];

  for (TableRow row : flightData.rows()) {
    String name = row.getString("MKT_CARRIER");

    if (name != null && name.equals(airline)) {

      int dist = row.getInt("DISTANCE");

      int bucket = dist / 1000;
      if (bucket >= buckets.length) bucket = buckets.length - 1;

      buckets[bucket]++;
    }
  }

  return buckets;
}

void drawAirlineButtonsDist() {
  if(airlineButtonsDist == null) return;
  for (Widget w : airlineButtonsDist) {
    w.draw();
  }
}

// =======  DRAWING PIE CHART DISTANCES   ====
void drawPieChartDistances() {
  if (countsDist == null) return;

  float diameter = 400;
  float lastAngle = 0;
  int total = 0;

  for (int c : countsDist) total += c;

  color[] palette = {
    color(227, 59, 84), 
    color(235, 163, 63), 
    color(138, 106, 217), 
    color(103, 214, 183)
  };

  for (int i = 0; i < countsDist.length; i++) {
    float angle = map(countsDist[i], 0, total, 0, TWO_PI);

    fill(palette[i]);
    arc(550, 350, diameter, diameter, lastAngle, lastAngle + angle);

    lastAngle += angle;
  }

  // title
  fill(0);
  textAlign(LEFT);
  text("Airline: " + selectedAirlineDist, 600, 80);
  
  //textFont(smallFont);
  fill(227, 59, 84);
  rect(700, 520, 25, 25);
  text("to 1000 km", 740, 540);
  
  fill(235, 163, 63); 
  rect(700, 555, 25, 25);
  text("1000 to 2000 km", 740, 575);

  fill(138, 106, 217); 
  rect(700, 590, 25, 25);
  text("2000 to 3000 km", 740, 610);

  fill(103, 214, 183);
  rect(700, 625, 25, 25);
  text("3000+ km", 740, 645);
}


// ================= WIDGET =================
class Widget {
  int x, y, width, height;
  String label;
  int event;
  color widgetColor;
  PFont widgetFont;

  Widget (int x, int y, int width, int height, String label,
    color widgetColor, PFont widgetFont, int event) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.label = label;
    this.event = event;
    this.widgetColor = widgetColor;
    this.widgetFont = widgetFont;
  }

  void draw() {
    boolean hover = mouseX>x && mouseX<x+width && mouseY>y && mouseY<y+height;
    fill(hover ? color(70, 130, 200) : widgetColor);
    rect(x, y, width, height, 8);
    fill(0);
    textAlign(CENTER, CENTER);
    text(label, x+width/2, y+height/2);
  }

  int getEvent(int mX, int mY) {
    if (mX>x && mX < x+width && mY >y && mY <y+height) {
      return event;
    }
    return EVENT_NULL;
  }
}

// ================= SCREEN =================
class Screen {
  ArrayList screenWidgets;
  color screenColor;

  Screen(color screenColor) {
    screenWidgets=new ArrayList();
    this.screenColor=screenColor;
  }

  void add(Widget w) {
    screenWidgets.add(w);
  }
  
  void addImage(PImage i, int x, int y){
    image(i, x, y);
  }
  void draw() {
    background(screenColor);
    for (int i = 0; i<screenWidgets.size(); i++) {
      Widget aWidget = (Widget)screenWidgets.get(i);
      aWidget.draw();
    }
  }

  int getEvent() {
    for (int i = 0; i<screenWidgets.size(); i++) {
      Widget aWidget = (Widget) screenWidgets.get(i);
      int event = aWidget.getEvent(mouseX, mouseY);
      if (event != EVENT_NULL) {
        return event;
      }
    }
    return EVENT_NULL;
  }
   ArrayList getWidgets() {
    return screenWidgets;
  }
}
