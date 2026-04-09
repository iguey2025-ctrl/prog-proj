import processing.sound.*;
SoundFile file;
SoundFile file2;
SoundFile file3;
SoundFile doubleClick;
SoundFile airplane;
SoundFile pop;
SoundFile startSound;

DraggingPic planeIcon;
PFont stdFont;
PFont startFont;
PFont smallFont;

//===========for map
boolean continuePressed = false;
boolean arrSelection = false;
boolean depSelection = false;
String selectedArrState = "";
String selectedDepState = "";

boolean selectAllChecked = false;

final int EVENT_BUTTON_QUERY=1;
final int EVENT_BUTTON_DRAW=2;
final int EVENT_BUTTON_START =5;
final int EVENT_BUTTON_BACK =6;
final int EVENT_BUTTON_CONTINUE = 40;
//final int EVENT_BUTTON_EXIT =7;

final int EVENT_BAR = 10;
//final int EVENT_SCATTER = 11;
final int EVENT_PIE_CANCELLED = 12;
final int EVENT_PIE_DISTANCE = 13;
final int EVENT_NULL=0;
final int EVENT_PIE_CITY_DIST = 21;

// NEW EVENTS
final int EVENT_SELECT_AIRLINE_SCREEN = 50;
final int EVENT_CONFIRM_AIRLINES = 51;
final int EVENT_SHOW_DISTANCES = 52;

final int EVENT_MAP_BUTTON = 30;
final int EVENT_DEP_TIME = 31;
final int EVENT_ARR_TIME = 32;

//============MANUALLY DOING EVERY STATE + BUTTONS
final int WA_BUTTON = 100;
final int OR_BUTTON = 101;
final int CA_BUTTON = 102;
final int AK_BUTTON = 103;
final int ID_BUTTON = 104;
final int NV_BUTTON = 105;
final int MT_BUTTON = 106;
final int ND_BUTTON = 107;
final int MN_BUTTON = 108;
final int WY_BUTTON = 109;
final int SD_BUTTON = 110;
final int WI_BUTTON = 111;
final int MI_BUTTON = 112;
final int ME_BUTTON = 113;
final int UT_BUTTON = 114;
final int CO_BUTTON = 115;
final int NE_BUTTON = 116;
final int IA_BUTTON = 117;
final int IL_BUTTON = 118;
final int IN_BUTTON = 119;
final int OH_BUTTON = 120;
final int PA_BUTTON = 121;
final int NY_BUTTON = 122;
final int VT_BUTTON = 123;
final int NH_BUTTON = 124;
final int AZ_BUTTON = 125;
final int NM_BUTTON = 126;
final int KS_BUTTON = 127;
final int MO_BUTTON = 128;
final int KY_BUTTON = 129;
final int WV_BUTTON = 130;
final int VA_BUTTON = 131;
final int MD_BUTTON = 132;
final int DE_BUTTON = 133;
final int NJ_BUTTON = 134;
final int CT_BUTTON = 135;
final int RI_BUTTON = 136;
final int MA_BUTTON = 137;
final int OK_BUTTON = 138;
final int AR_BUTTON = 139;
final int TN_BUTTON = 140;
final int NC_BUTTON = 141;
final int SC_BUTTON = 142;
final int TX_BUTTON = 143;
final int LA_BUTTON = 144;
final int MS_BUTTON = 145;
final int AL_BUTTON = 146;
final int GA_BUTTON = 147;
final int FL_BUTTON = 148;
final int HI_BUTTON = 149;

String[] stateNames = {"AK",
    "WA", "ID", "MT", "ND", "MN",
    "OR", "NV", "WY", "SD", "WI", "MI", "ME",
    "CA", "UT", "CO", "NE", "IA", "IL", "IN", "OH", "PA", "NY", "VT", "NH",
    "AZ", "NM", "KS", "MO", "KY", "WV", "VA", "MD", "DE", "NJ", "CT", "RI", "MA",
    "OK", "AR", "TN", "NC", "SC",
    "TX", "LA", "MS", "AL", "GA",
    "FL",
    "HI"};

Widget WA;
Widget OR;
Widget CA;
Widget AK;
Widget ID;
Widget NV;
Widget MT;
Widget ND;
Widget MN;
Widget WY;
Widget SD;
Widget WI;
Widget MI;
Widget ME;
Widget UT;
Widget CO;
Widget NE;
Widget IA;
Widget IL;
Widget IN;
Widget OH;
Widget PA;
Widget NY;
Widget VT;
Widget NH;
Widget AZ;
Widget NM;
Widget KS;
Widget MO;
Widget KY;
Widget WV;
Widget VA;
Widget MD;
Widget DE;
Widget NJ;
Widget CT;
Widget RI;
Widget MA;
Widget OK;
Widget AR;
Widget TN;
Widget NC;
Widget SC;
Widget TX;
Widget LA;
Widget MS;
Widget AL;
Widget GA;
Widget FL;
Widget HI;

Table flightData;

Screen introScreen;
Screen AirlineScreen;
Screen AirportScreen;
Screen graphScreen;
Screen selectionScreen;
Screen airlineSelectScreen;
Screen depScreen;
Screen arrScreen;
Screen mapScreen;

Screen currentScreen;
ArrayList<Screen> screenHistory = new ArrayList<Screen>();

Widget widgetDrawGraph;
Widget startButton;
Widget introStartButton;
//Widget exitButton;
Widget backButton;
Widget continueButton; // for map Screen
Widget confirmAirlinesButton;
Widget showDistancesButton;
Widget mapButton;
Widget depButton;
Widget arrButton;


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

PImage planeImage, title;
PImage map;
PImage clouds;


// ================= SETUP =================
void setup(){
  size(1000,700);
  background(255);
  
  file = new SoundFile(this, "flightsimsong.mp3");
  file2 = new SoundFile(this, "click2.mp3");
  file3 = new SoundFile(this, "click5.mp3");
  doubleClick = new SoundFile(this,"double.wav");
  startSound = new SoundFile(this, "startsound.wav");
  
  airplane = new SoundFile(this, "airplane.mp3");
  pop = new SoundFile(this,"pop.mp3");
  pop.amp(0.7); 
  file.loop();
  //====================IMAGES==================
  flightData = loadTable("flights2k.csv", "header");
  planeImage = loadImage("planeIcon.png");
  planeImage.resize(150,100);
  
  clouds = loadImage("clouds.png");
  planeIcon = new DraggingPic(400,100,"plane.png");
  //planeIcon.resize(400,100);
  title = loadImage("title.png");
  map = loadImage("USMAP.png");

//=========================FONTS==========
  stdFont = createFont("minecraft.ttf", 25);
  startFont = createFont("minecraft.ttf", 40);
  textFont(stdFont);

//===============BUTTONS===========
  backButton = new Widget(20,20,100,40,"Back",color(#FF6B6B),stdFont,EVENT_BUTTON_BACK);
  continueButton = new Widget(860,635,110,42,"Continue", color(#FF6B6B), stdFont, EVENT_BUTTON_CONTINUE);
  // ===== INTRO SCREEN =====
  introScreen = new Screen(color(#B6E8FA));
  
  
  introStartButton = new Widget(400,540,200,50,"START",color(#4D92F0),stdFont,EVENT_BUTTON_START);
  introStartButton.changeTextSize(25);
  //exitButton = new Widget(400,420,200,80,"EXIT",color(#DE2D44),stdFont,EVENT_BUTTON_EXIT);
  //introScreen.add(introStartButton);
  
  //introScreen.add(exitButton);



  // ===== SELECTION SCREEN =====
  selectionScreen = new Screen(color(#BAEBFC));
  selectAirlineButton = new Widget(370,250,250,50,"Airline",color(#68D1EA),stdFont,20);
  selectAirportButton = new Widget(370,320,250,50,"Successful Flights",color(#68D1EA),stdFont,EVENT_PIE_CANCELLED);
  mapButton = new Widget(370,530,250,50,"View Map", color(#68D1EA), stdFont, EVENT_MAP_BUTTON);
  depButton = new Widget(370,390,250,50,"Departure Time", color(#68D1EA), stdFont, EVENT_DEP_TIME);
  arrButton = new Widget(370,460,250,50,"Arrival Time", color(#68D1EA), stdFont, EVENT_ARR_TIME);
  showDistancesButton = new Widget(370,600,250,50,"Distance",color(#68D1EA),stdFont,EVENT_SHOW_DISTANCES);

  selectionScreen.add(showDistancesButton);
  selectionScreen.add(selectAirlineButton);
  selectionScreen.add(selectAirportButton);
  selectionScreen.add(backButton);
  selectionScreen.add(mapButton);
  selectionScreen.add(depButton);
  selectionScreen.add(arrButton);

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
    airlineCheckboxes[i] = new Widget(80, 160 + i * 35, 20, 20, airlines.get(i), color(200), stdFont, 1000+i);
  }

  confirmAirlinesButton = new Widget(300,600,200,60,"Show Flights",color(#68D1EA),stdFont,EVENT_CONFIRM_AIRLINES);

  //airlineSelectScreen.add(confirmAirlinesButton);
  airlineSelectScreen.add(backButton);

  // ===== AIRPORT SCREEN =====
  AirportScreen = new Screen(color(255));

  //widgetDrawGraph = new Widget(400,300,200,60,"Draw Graph",color(#68D1EA),stdFont,EVENT_BUTTON_DRAW);

  //buttonBar = new Widget(40,120,180,50,"Bar Chart",color(120),stdFont,EVENT_BAR);
  //buttonScatter = new Widget(40,190,180,50,"Scatter",color(140),stdFont,EVENT_SCATTER);
  //buttonPieCancelled = new Widget(40,260,180,50,"Pie Chart",color(160),stdFont,EVENT_PIE_CANCELLED);
  //buttonPieDist = new Widget(40,330,180,50,"Pie Chart Dist",color(160),stdFont,EVENT_PIE_DISTANCE);

  //AirportScreen.add(widgetDrawGraph);
  //AirportScreen.add(buttonBar);
  //AirportScreen.add(buttonScatter);
  //AirportScreen.add(buttonPieCancelled);
  //AirportScreen.add(buttonPieDist);
  AirportScreen.add(backButton);
  
  
  
  //==============DEP SCREEN
  depScreen = new Screen(color(255));
  //==============ARR SCREEN
  arrScreen = new Screen(color(255));
  //===============MAP SCREEN
  mapScreen = new Screen(color(255));
  mapScreen.add(backButton);
  mapScreen.add(continueButton);
  
  color squareColor = color(255,255,0);
  WA = new Widget(160,110,40,40," ",color(squareColor), stdFont, WA_BUTTON);
  mapScreen.add(WA);
  OR = new Widget(140,130,40,40,"OR", color(squareColor), stdFont, OR_BUTTON);
  mapScreen.add(WA);
  int x = 160;
  
  for (int i=0; i<50;i++){
    String st = stateNames[i];
    int y = 110 + i*40;
    if(i%5==0){
      x = x+50;
      y = 110;
    }
    
    Widget state = new Widget(x, y, 40,40,st, color(squareColor), stdFont, 100+i);
    mapScreen.add(state);
  }
  
}

// ================= DRAW =================
void draw(){

  currentScreen.draw();
  
  fill(#10259B);
  strokeWeight(2);
  rect(0,0,width,8);
  rect(width-8,0,8,height);
  rect(0,height-8,width,8);
  rect(0,0,8,height);

  planeIcon.display();
  planeIcon.mouseDragged();

  if(currentScreen == airlineSelectScreen){
   pushStyle();

textSize(24);
fill(0);
text("Select Airlines:", 125, 110);

// ===== SELECT ALL CHECKBOX =====
boolean hoverAll = mouseX>80 && mouseX<102 && mouseY>155 && mouseY<177;

// auto-sync state
selectAllChecked = (selectedAirlines.size() == airlines.size());

if(selectAllChecked){
  fill(70,130,200);
} else if(hoverAll){
  fill(220);
} else {
  fill(245);
}

stroke(selectAllChecked ? color(70,130,200) : color(180));
strokeWeight(2);
rect(80, 155, 22, 22, 6);

// checkmark
if(selectAllChecked){
  stroke(255);
  strokeWeight(3);
line(85, 167, 90, 172);
line(90, 172, 97, 161);
}

fill(30);
textAlign(LEFT, CENTER);
textSize(16);
text("Select All", 115, 165);


// ===== NORMAL CHECKBOXES =====
for(int i=0;i<airlineCheckboxes.length;i++){
  Widget w = airlineCheckboxes[i];

  // shift down so it doesn’t overlap
  int yOffset = 30;
  float y = w.y + yOffset;

  boolean hover = mouseX>w.x && mouseX<w.x+22 && mouseY>y && mouseY<y+22;
  boolean selected = selectedAirlines.contains(airlines.get(i));

  if(selected){
    fill(70, 130, 200);
  } else if(hover){
    fill(220);
  } else {
    fill(245);
  }

  stroke(selected ? color(70,130,200) : color(180));
  strokeWeight(2);
  rect(w.x, y, 22, 22, 6);

  if(selected){
    stroke(255);
    strokeWeight(3);
    line(w.x+5, y+12, w.x+10, y+17);
    line(w.x+10, y+17, w.x+17, y+6);
  }

  fill(30);
  textAlign(LEFT, CENTER);
  textSize(14);
  text(airlines.get(i), w.x+35, y+11);
}

popStyle();

    // IF NONE SELECTED
    if(selectedAirlines.size() == 0){
      fill(200,0,0);
      textSize(20);
      text("Please select an airline!", 500, 350);
    } else {
      drawBarGraph("MKT_CARRIER");
    }
  }


  if(currentScreen == graphScreen){
    if(graphType == EVENT_BAR){
      drawBarGraph("MKT_CARRIER");
    }
    //else if(graphType == EVENT_SCATTER){
    //  drawScatterPlot(selectedColumn);
    //}
    else if(graphType == EVENT_PIE_CANCELLED){
      drawPieChartCancelled();
      drawAirlineButtonsCancelled();
    }
    else if(graphType == EVENT_PIE_DISTANCE){
      drawPieChartDistances();
      drawAirlineButtonsDist();
    }
  }
//==============ADDING TO SCREENS
  if(currentScreen == selectionScreen){
    
    noStroke();
    fill(#FFFFFF);
    rect(90,114,830,70, 15);
    strokeWeight(2);
  }
  if(currentScreen == introScreen){
    fill(#FFFFFF);
    noStroke();
    rect(0,480,1000,400);
    strokeWeight(3);
    title.resize(1300,700);
    
    blend(title,0,0,1300,700,100,50,1300,700,DARKEST);
    //image(title, 50,50);
    //image(planeIcon,550,50);
    clouds.resize(1000,700);
    image(clouds,0,-210);
    fill(#11268B);
    strokeWeight(3);
    rect(0,0,width,8);
    rect(width-8,0,8,height);
    rect(0,height-8,width,8);
    rect(0,0,8,height);
    introScreen.add(introStartButton);
    introStartButton.draw();
    
  }
  fill(#000000);
  if(currentScreen == selectionScreen){
    textSize(25);
    text("What category would you like to view the data by?",510,150);
    textSize(15);
  }
  if(currentScreen == mapScreen){
    map.resize(900,600);
    image(map, 50,75);
    mapScreen.add(backButton);
    mapScreen.add(continueButton);
    text("Please click on a departure state", 500,50);
    text("You've selected:   ",500,85);
    fill(#F20515);
    text(selectedDepState, 600,85);
    if(continuePressed ==true){
      fill(255);
      noStroke();
      rect(350,15,300,90);
      stroke(3);
      fill(#000000);
      text("Please click on an arrival state", 500,50);
      text("You've selected: ", 500,85);
      fill(#F20515);
      text(selectedArrState, 600, 85);
    }  
  }
}
void mouseReleased() {
  planeIcon.draggingpicMouseReleased();
}
// ================= MOUSE =================
void mousePressed(){
  planeIcon.draggingpicMousePressed();

  
  if(currentScreen == airlineSelectScreen){
    for (int i = 0; i < airlineCheckboxes.length; i++) {
      Widget w = airlineCheckboxes[i];
      float y = w.y + 30;
      if(mouseX>w.x && mouseX<w.x+22 && mouseY>y && mouseY<y+22){
        pop.play();
        String airline = airlines.get(i);
        if(selectedAirlines.contains(airline)){
          selectedAirlines.remove(airline);
        } else {
          selectedAirlines.add(airline);
        }
      }
    }
    
    // ===== SELECT ALL CLICK =====
if(mouseX>80 && mouseX<102 && mouseY>155 && mouseY<177){
  if(selectedAirlines.size() == airlines.size()){
    selectedAirlines.clear(); // deselect all
  } else {
    selectedAirlines.clear();
    selectedAirlines.addAll(airlines); // select all
  }
  return; //prevent double triggering
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
  if(theEvent != EVENT_NULL && theEvent != EVENT_BUTTON_BACK && theEvent!= EVENT_BUTTON_CONTINUE && theEvent!= EVENT_BUTTON_START){
    file3.play();
  } 
  switch(theEvent){
    
    case EVENT_BUTTON_START:
      startSound.play();
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

    case EVENT_PIE_CANCELLED:
      graphType = EVENT_PIE_CANCELLED;
      switchScreen(graphScreen);
      break;

    case EVENT_PIE_DISTANCE:
      graphType = EVENT_PIE_DISTANCE;
      switchScreen(graphScreen);
      break;

    case EVENT_BUTTON_BACK:
      doubleClick.play();
      continuePressed = false;
      if(screenHistory.size() > 0){
        currentScreen = screenHistory.remove(screenHistory.size()-1);
      }
      break;
    case EVENT_DEP_TIME:
      switchScreen(depScreen);
      break;
    case EVENT_ARR_TIME:
      switchScreen(arrScreen);
      break;
    case EVENT_MAP_BUTTON:
      switchScreen(mapScreen);
      break;
    case EVENT_BUTTON_CONTINUE:
      doubleClick.play();
      continuePressed = true;;
      break;
    case WA_BUTTON:
      if(arrSelection == true){
        selectedArrState = "WA";
      }else if(depSelection == true){
        selectedDepState = "WA";
      }
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

//// ================= SCATTER =================
//void drawScatterPlot(String input) {
//  int marginL = 260, marginT = 60;

//  line(marginL, height-100, width-50, height-100);
//  line(marginL, marginT, marginL, height-100);

//  for (TableRow row : flightData.rows()) {
//    float xVal = row.getFloat("DISTANCE");
//    float yVal = row.getFloat(input);

//    float x = map(xVal, 0, 3000, marginL, width-50);
//    float y = map(yVal, 0, 2400, height-100, marginT);

//    ellipse(x, y, 5, 5);
//  }
//}

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
boolean alreadyPlaying= false;
  void draw() {
    
    boolean hover = mouseX>x && mouseX<x+width && mouseY>y && mouseY<y+height;
    if(hover){
      fill(color(70,130,200));
      if(label.equals("Back") == false && label.equals("Continue")==false){
        if(!alreadyPlaying){
          alreadyPlaying=true;
          doubleClick.play();
          
        }
        if(currentScreen == introScreen){
           textSize(28);
         }else{
           textSize(17.5);
           if(currentScreen==selectionScreen){
             image(planeImage,x-155,y-28);
              
             image(planeImage,x+252,y-28);
           }
       }
      }
      
    }else{
      alreadyPlaying=false;
      fill(widgetColor);
      if(currentScreen==introScreen){
        textSize(23);
      }else{textSize(15);}
      
    }
    rect(x, y, width, height, 8);
    fill(0);
    textAlign(CENTER, CENTER);
    text(label, x+width/2, y+height/2);
  }

  void setX(int x){
    this.x = x;
  }
  void setY(int y){
    this.y = y;
  }
  void changeTextSize(int s){
    textSize(s);
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


class DraggingPic {

  int x;
  int y;
  PImage sample;

  // controls whether we are dragging (holding the mouse)
  boolean hold; 

  // constructor
  DraggingPic(int posx, int posy, 
    String imageNameAsString)
  { 
    x=posx;
    y=posy;
    sample = loadImage(imageNameAsString);
    sample.resize(330,120);
  }// constructor

  void display(){
    image(sample, x, y);
  }

  void draggingpicMousePressed() {
    airplane.loop();
    if (mouseX>x&&
      mouseY>y&&
      mouseX<x+sample.width && 
      mouseY<y+sample.height) {
      hold=true;
    }
  }

  void draggingpicMouseReleased() {
    airplane.stop();
    hold=false;
  }

  void mouseDragged() 
  {
    if (hold) {
      x=mouseX-60; 
      y=mouseY-60;
    }
  }
}
