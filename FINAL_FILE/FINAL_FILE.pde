import controlP5.*;
ControlP5 cp5;

PFont stdFont;
PFont startFont;
PFont smallFont;

final int EVENT_BUTTON_QUERY=1;
final int EVENT_BUTTON_DRAW=2;
final int EVENT_BUTTON_START =5;
final int EVENT_BUTTON_BACK =6;
final int EVENT_BUTTON_EXIT =7;

final int EVENT_BAR = 10;
final int EVENT_SCATTER = 11;
final int EVENT_PIE_CANCELLED = 12;
final int EVENT_PIE_DISTANCE = 13;
final int EVENT_NULL=0;

Table flightData;

Screen introScreen;
Screen mainScreen;
Screen graphScreen;
Screen selectionScreen;

Screen currentScreen;
Screen previousScreen;

TextWidget widgetEntryText;
Widget widgetDrawGraph;
Widget startButton;
Widget introStartButton;
Widget exitButton;
Widget backButton;

Widget buttonBar;
Widget buttonScatter;
Widget buttonPieCancelled;
Widget buttonPieDist;
Widget selectAirlineButton;
Widget selectAirportButton;

TextWidget activeTextWidget = null;

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

void setup(){
  size(1000,700);
  flightData = loadTable("flights2k.csv", "header");

  cp5 = new ControlP5(this);

  DropdownList ddl = cp5.addDropdownList("sort by:")
  .setPosition(100,600)
  .setSize(100,1000)
  .setBackgroundColor(color(100))
  .setBarHeight(20);

  ddl.addItem("airline", 1);
  ddl.addItem("location", 2);
  ddl.addItem("destination", 3);

  stdFont = createFont("Arial", 14);
  startFont = createFont("Arial", 40);
  //smallFont = loadFont("AppleSDGothicNeo-Light-20.vlw");
  textFont(stdFont);
  backButton = new Widget(20,20,100,40,"Back",color(#FF6B6B),stdFont,EVENT_BUTTON_BACK);

// ===== INTRO SCREEN =====
  introScreen = new Screen(color(#A8D8FF));

  introStartButton = new Widget(400,300,200,80,"START",color(#68D1EA),stdFont,EVENT_BUTTON_START);
  exitButton = new Widget(400,420,200,80,"EXIT",color(#DE2D44),stdFont,EVENT_BUTTON_EXIT);

  introScreen.add(introStartButton);
  introScreen.add(exitButton);

  
// ===== SELECTION SCREEN =====
selectionScreen = new Screen(color(#CFF5E7));

selectAirlineButton = new Widget(350,250,300,80,"Select Airline",color(#68D1EA),stdFont,20);
selectAirportButton = new Widget(350,370,300,80,"Select Airport",color(#68D1EA),stdFont,21);

// reuse existing back button
selectionScreen.add(selectAirlineButton);
selectionScreen.add(selectAirportButton);
selectionScreen.add(backButton);

// ===== MAIN SCREEN =====
  mainScreen = new Screen(color(255));

  widgetEntryText = new TextWidget(350,200,300,50,"",color(#68D1EA),stdFont,EVENT_BUTTON_QUERY,20);
  widgetDrawGraph = new Widget(400,300,200,60,"Draw Graph",color(#68D1EA),stdFont,EVENT_BUTTON_DRAW);

  buttonBar = new Widget(40,120,180,50,"Bar Chart",color(120),stdFont,EVENT_BAR);
  buttonScatter = new Widget(40,190,180,50,"Scatter",color(140),stdFont,EVENT_SCATTER);
  buttonPieCancelled = new Widget(40,260,180,50,"Pie Chart",color(160),stdFont,EVENT_PIE_CANCELLED);
  buttonPieDist = new Widget(40,330,180,50,"Pie Chart Dist",color(160),stdFont,EVENT_PIE_DISTANCE);


  mainScreen.add(widgetEntryText);
  mainScreen.add(widgetDrawGraph);
  mainScreen.add(buttonBar);
  mainScreen.add(buttonScatter);
  mainScreen.add(buttonPieCancelled);
  mainScreen.add(buttonPieDist);
  mainScreen.add(backButton);

// ===== GRAPH SCREEN =====
  graphScreen = new Screen(color(255));
  graphScreen.add(backButton);

  currentScreen = introScreen;


  // === GET AIRLINES ===
  for (TableRow row : flightData.rows()) {
    String name = row.getString("MKT_CARRIER");
    if (name != null && !name.equals("") && !airlines.contains(name)) {
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
 
}

void draw(){
  currentScreen.draw();

  if(currentScreen == graphScreen){
    if(graphType == EVENT_BAR && selectedColumn != ""){
      drawBarGraph(selectedColumn);
    }
    //else if(graphType == EVENT_SCATTER){
    //  drawScatterPlot(activeTextWidget.getLabel());
    else if(graphType == EVENT_SCATTER){
      drawScatterPlot(selectedColumn);
    }
    else if(graphType == EVENT_PIE_CANCELLED){
      drawPieChartCancelled();
      drawAirlineButtonsCancelled();
    }
    else if(graphType == EVENT_PIE_DISTANCE){
      drawPieChartDistances();
      drawAirlineButtonsDist();
    }
  }
}

//screen switching
void switchScreen(Screen newScreen){
  previousScreen = currentScreen;
  currentScreen = newScreen;
}

void mousePressed(){

  activeTextWidget = null;

////check if text box was clicked
  for (Object w : currentScreen.getWidgets()) {
    if (w instanceof TextWidget) {
      TextWidget tw = (TextWidget) w;
      if (tw.getEvent(mouseX, mouseY) != EVENT_NULL) {
        activeTextWidget = tw;
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
  if(currentScreen == introScreen){
    switchScreen(selectionScreen);
  } 
  else if(currentScreen == selectionScreen){
    switchScreen(mainScreen);
  }
  break;

case 20: // Select Airline
  selectedColumn = "AIRLINE";  
  switchScreen(mainScreen);
  break;

case 21: // Select Airport
  selectedColumn = "ORIGIN";   
  switchScreen(mainScreen);
  break;

//draw graph button
    case EVENT_BUTTON_DRAW:
      if(widgetEntryText.label.length() > 0){
        selectedColumn = widgetEntryText.label;
        switchScreen(graphScreen);
      }
      break;

//back button
    case EVENT_BUTTON_BACK:
      if(previousScreen != null){
        Screen temp = currentScreen;
        currentScreen = previousScreen;
        previousScreen = temp;
      }
      break;

    case EVENT_BUTTON_EXIT:
      exit();
      break;

//choose graph type 
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
  }
}

//===================KEYBOARD INPUT======================
//type into text box 
void keyPressed(){
  if (activeTextWidget != null){
    activeTextWidget.append(key);
  }
}

//===================DRAWBARGRAPH FUNCTOIN======================
void drawBarGraph(String columnName) {
  // --- Count frequencies ---
  HashMap<String, Integer> counts = new HashMap<String, Integer>();
  for (TableRow row : flightData.rows()) {
    String val = row.getString(columnName);
    counts.put(val, counts.getOrDefault(val, 0) + 1);
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

  //int cancelled = 0;
  //int notCancelled = 0;

  ////counts cancelled/not cancelled
  //for (TableRow row : flightData.rows()) {
  //  if (row.getInt("CANCELLED") == 1) cancelled++;
  //  else notCancelled++;
  //}
  
  
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

//=================== SCATTER PLOT ======================
void drawScatterPlot(String input) {

  int marginL = 260, marginT = 60;

  //draw axes
  line(marginL, height-100, width-50, height-100);
  line(marginL, marginT, marginL, height-100);

  //plot points
  for (TableRow row : flightData.rows()) {
    float xVal = row.getFloat("DISTANCE");
    float yVal = row.getFloat(input);

    float x = map(xVal, 0, 3000, marginL, width-50);
    float y = map(yVal, 0, 2400, height-100, marginT);

    //hover
    boolean hover = dist(mouseX, mouseY, x, y) < 5;

    fill(hover ? color(70, 130, 200) : color(100, 160, 220));
    ellipse(x, y, hover ? 8 : 5, hover ? 8 : 5);
  }

  //labels
  fill(0);
  textAlign(CENTER);
  text(input, marginL + 300, 30);

  text("Distance", marginL + 350, height - 80);

  pushMatrix();
  translate(30, height/2);
  rotate(-HALF_PI);
  text(input, 10, 220);
  popMatrix();
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

// ================= TEXT WIDGET =================
class TextWidget extends Widget {

  int maxlen;

  TextWidget (int x, int y, int width, int height, String label,
    color widgetColor, PFont font, int event, int maxlen) {

    super (x, y, width, height, label, widgetColor, font, event);
    this.maxlen = maxlen;
  }
  
  String getLabel(){
    return label;
  }

  void draw() {
    fill(widgetColor);
    rect(x, y, width, height);

    fill(0);
    textAlign(LEFT, CENTER);
    text(label, x + 5, y + height/2);
  }

  void append(char s) {
    if (s == BACKSPACE) {
      if (label.length() > 0) {
        label = label.substring(0, label.length()-1);
      }
    } else if (s != ENTER && s != RETURN && label.length() < maxlen) {
      label += s;
    }
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
