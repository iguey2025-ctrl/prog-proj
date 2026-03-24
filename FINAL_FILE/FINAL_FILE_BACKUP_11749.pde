ArrayList widgetList;
PFont stdFont;
final int EVENT_BUTTON_QUERY=1;
final int EVENT_BUTTON_DRAW=2;
final int EVENT_NULL=0;
Table flightData;
Screen screen1;
Screen screen2;
Screen currentScreen;
Widget widgetEntryText;
Widget widgetDrawGraph;

int topN = 20;
<<<<<<< HEAD
// izzy test sync
=======

>>>>>>> 3ee4edc633b5798f1c8232dce0c6d519d0404bcf



void setup(){
  
  size(1000,700);
  flightData = loadTable("flights2k.csv", "header");
  



  stdFont=loadFont("AppleBraille-Outline8Dot-48.vlw");
  textFont(stdFont);
  Widget widget1,widget2;
  widgetEntryText=new Widget(100,100,100,40,"Generate Entry Text", color(100), stdFont, EVENT_BUTTON_QUERY);
  widgetDrawGraph=new Widget(100,200,100,40,"Draw Graph",color(150), stdFont, EVENT_BUTTON_DRAW);
  widgetList = new ArrayList();
  widgetList.add(widgetEntryText); widgetList.add(widgetDrawGraph);

  screen1 = new Screen(color(255));
  screen2 = new Screen(color(150));
  screen1.add(widgetEntryText);
  screen1.add(widgetDrawGraph);
  currentScreen = screen1;
  
  
  

}


void draw(){
  
  text(flightData.getRowCount() + " total rows in table", 400,100);
  
  
  drawBarGraph("ORIGIN_CITY_NAME");
  drawBarGraph("ORIGIN");
  drawBarGraph("MKT_CARRIER");
  
  

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
  int marginL = 60, marginR = 30, marginT = 60, marginB = 140;
  int chartW = width  - marginL - marginR;
  int chartH = height - marginT - marginB;

  background(255);

  // --- Gridlines + Y labels ---
  stroke(220); fill(100);
  textAlign(RIGHT, CENTER); textSize(11);
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
    float x  = marginL + i * barW + pad;
    float w  = barW - pad * 2;
    float bh = map(count, 0, maxCount, 0, chartH);
    float y  = marginT + chartH - bh;

    fill(mouseX >= x && mouseX <= x + w ? color(70, 130, 200) : color(100, 160, 220));
    noStroke(); rect(x, y, w, bh, 3);

    fill(60); textAlign(CENTER, BOTTOM); textSize(10);
    text(count, x + w/2, y - 2);

    pushMatrix();
    translate(x + w/2, marginT + chartH + 8);
    rotate(HALF_PI * 0.9);
    textAlign(LEFT, CENTER); textSize(11); fill(50);
    text(k, 0, 0);
    popMatrix();
  }

  // --- Axes ---
  stroke(80); strokeWeight(1.5);
  line(marginL, marginT, marginL, marginT + chartH);
  line(marginL, marginT + chartH, marginL + chartW, marginT + chartH);

  // --- Title ---
  textAlign(CENTER, TOP); textSize(16); fill(30); noStroke();
  text("Frequency of " + columnName, width/2, 18);

  // --- Y axis label ---
  pushMatrix();
  translate(16, marginT + chartH/2); rotate(-HALF_PI);
  textAlign(CENTER, CENTER); textSize(12); fill(80);
  text("Count", 0, 0);
  popMatrix();
}





//========================WIDGET CLASSES=====================
class Widget{
  int x, y, width, height; String label; int event;
  color widgetColor, labelColor, lineColor; PFont widgetFont;
  Widget (int x, int y, int width, int height, String label, 
  color widgetColor, PFont widgetFont, int event){
    this.x = x; this.y = y; this.width = width; this.height = height;
    this.label = label; this.event = event; 
    this.widgetColor = widgetColor; this.widgetFont = widgetFont;
    labelColor = color(0); lineColor = color(0);
  }
  void draw(){
    fill (widgetColor); stroke (lineColor);
    rect(x, y, width, height);
    fill(labelColor);
    text (label, x+10, y+height-10);
    }
    void mouseOver() {
      lineColor = color(255);
    }
    void mouseNotOver() {
      lineColor = color(0);
    }
    int getEvent(int mX, int mY){
      if(mX>x && mX < x+width && mY >y && mY <y+height){
    return event;
    }
    return EVENT_NULL;
  }
}

class TextWidget extends Widget{
int maxlen;
TextWidget (int x, int y, int width, int height, String label,
color widgetColor, PFont font, int event, int maxlen){
  super (x, y, width, height, label, widgetColor, font, event);
  this.x = x; this.y = y; this.width = width; this.height = height;
  this.label = label; this.event = event; 
  this.widgetColor = widgetColor; this.widgetFont = font;
  labelColor = color(0); this.maxlen = maxlen;
  }
  void append(char s){
    if (s==BACKSPACE){
      if (!label.equals(""))
      label = label.substring(0, label.length()-1);
    }
    else if (label.length() < maxlen)
    label = label + str(s);
  }
}


class DataPoint {
  /*FlightDate flightDate;
  IATA_Code_Marketing_Airline IATACode;
  Flight_Number_Marketing_Airline flightNumber;
  Origin origin;
  OriginState originState;
  OriginWac originWac;
  Dest dest;
  DestCityName destCityName; */
  DestState destState;
  DestWac destWac;
  CRSDepTime crsDep;
  DepTime depTime;
  CRSArrTime crsArr;
  ArrTime arrTime;
  CancelledFlight cancFlight;
  DivertedFlight divFlight;
  Distance dist;

  /* FlightDate getFlightDate(){return flightDate;}
  IATA_Code_Marketing_Airline getIATA(){return IATACode;}
  Flight_Number_Marketing_Airline getFlightNumber(){return flightNumber;}
  Origin getOrigin(){return origin;}
  OriginState getOriginState(){return originState;}
  OriginWac getOriginWac(){return originWac;}
  Dest getDest(){return dest;}
  DestCityName getDestCityName(){return destCityName;}  */
  DestState getDestState(){return destState;}
  DestWac getDestWac(){return destWac;}
  CRSDepTime getCrsDep(){return crsDep;}
  DepTime getDepTime(){return depTime;}
  CRSArrTime getCrsArr(){return crsArr;}
  ArrTime getArrTime(){return arrTime;}
  CancelledFlight getCancFlight(){return cancFlight;}
  DivertedFlight getDivFlight(){return divFlight;}
  Distance getDist(){return dist;}
/*
  String getFlightCode(){
    return IATACode + flightNumber;
  }
*/
}


class Screen {
  ArrayList screenWidgets;
  color screenColor;
  Screen(color screenColor){
    screenWidgets=new ArrayList();
    this.screenColor=screenColor;
  }
  void add(Widget w){
    screenWidgets.add(w);
  }
  void draw(){
    background(screenColor);
    for(int i = 0; i<screenWidgets.size(); i++){
      Widget aWidget = (Widget)screenWidgets.get(i);
      aWidget.draw();
    }
  }

  int getEvent(int mx, int my){
    for(int i = 0; i<screenWidgets.size(); i++){
      Widget aWidget = (Widget) screenWidgets.get(i);
      int event = aWidget.getEvent(mouseX,mouseY);
      if(event != EVENT_NULL){
        return event;
      }
    }
    return EVENT_NULL;
  }
  ArrayList getWidgets()
  {
    return screenWidgets;
  }
}

class FlightDate{
  int year;
  int month;
  int day;
} 

class IATACodeMarketingAirline{
  String airlineCode;

  String getCode(){
    return airlineCode;
  }
}

class FlightNumberMarketingAirline{
  int flightNumber;

/*  String getNumber(){
    return flightNumber;
  }
  
  */
}

class Origin {
  String airport;
  String city;

  String getAirportAndCity(){
    return airport + ", " + city;
  }
}

// Classes Akira
class originState {
  String originAirport;
  String stateCode;
}

class originWAC {
  String originAirport;
  int worldAreaCode;
}

class destination {
  String destinationAirport;
}

class destinationCityName {
  String destinationAirport;
  String cityName;
}


// classes Naz 
class DestState{
  String destinationAirport;
  String stateCode;
}

class DestWac{
  String destinationAirport;
  int wac;
}

class CRSDepTime{
  int hour;
  int minute; 
}

class DepTime{
  int hour;
  int minute;
}

class CRSArrTime {
  int hour;
  int minute;
}

class ArrTime {
  int hour;
  int minute;
}

class CancelledFlight {
  boolean cancelled;
}

class DivertedFlight {
  boolean diverted;
}

class Distance {
  int distance;
}
 
