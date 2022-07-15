//data starts recording when start button pressed
//assuming every cell is recorded for the entire time frame (e.g. starts at time 0)

import java.util.Collections;

//for cell movement pattern
boolean SIGMOID = true;


particleSystem ps;
PGraphics pg;
int page = 0;//0 is the main page, 1 is the data page

final int numPart = 150; 
boolean isDirected = false, switchOn = false;
Bar onTimeBar, offTimeBar;
boolean onBarPressed, offBarPressed;
int onTime = 1000, offTime = 1000, minOnTime = 0, maxOnTime = 5000, minOffTime = 0, maxOffTime = 5000;//in millis
boolean start = false, currOn = false;//start button not pressed yet; these variables are for predesignated times
int onTimeFinal, offTimeFinal;//set when start button pressed
long lastReset = 0;//last time light toggled 

//
//for drawing
//
int RAD = 10;//radius of algae
color backgroundColor = color(255,255,255);
int border = 50, xMin = border, yMin = 250 + border, xMax, yMax;
int toggleX = 100, toggleY = 110;//top left hand corner of toggle
int barWidth = 16, barEdge = 15;//for rounding edges
int sbX = 310,sbY = 220,dbX = 480, dbY =220, bbX = 340, bbY = 680, bW = 120,bH = 50;//start button (first page), data button (first page), back button (on second page)
color blueGray = color(124,169,215), navy = color(46,59,101), orange = color(255,165,0);
float triangleX = -10, triangleY = -10;//center of the red triangle
boolean trianglePressed = false;

//
//for recording/viewing data
//
PrintWriter output;
ArrayList<ArrayList<Double> > XPOS, YPOS, dTheta, corr;//stores particle positions
ArrayList<Integer> graphTime;
long startGraphTime;
ArrayList<Boolean> onOff;//keep track of whether light was on and off for given recorded data
boolean done = false, doneOnce = false;//doneOnce means a iteration of start-stop has been completed
int timeLoc = 0;
int gX = 100, gY = 100, gH = 200, gW = 600;//graph dimensions

void setup() {
  size(800, 800);
  xMax = width - border;
  yMax = height - border;
  pg = createGraphics(width, height);
  background(backgroundColor);
  ps = new particleSystem(numPart, xMin, yMin, xMax, yMax);
  onTimeBar = new Bar(100,260,width - 140,(onTime-minOnTime)/(float)maxOnTime);
  offTimeBar = new Bar(180,260,width - 140,(offTime-minOffTime)/(float)maxOffTime);
}

void draw() {
  println(isDirected);
  if(page == 0){
    setLight();
    pg.beginDraw(); 
    pg.clear();
    pg.background(backgroundColor);
    ps.next();
    ps.draw();//draw cells
    drawToggles();
    writeTextP0();
    pg.endDraw();
    image(pg, 0, 0);
    /*if(!switchOn){    //switch controls box
      noFill();
      stroke(0);
      strokeWeight(3);
      rect(xMin, yMin, xMax - xMin, yMax - yMin);
    }*/
    if(done){
      doneOnce = true;
      process();
      done = false;
    }
  }
  else if(page == 1){
    background(backgroundColor);
    drawBackButton();
    correlationVsTime();
  }
}

void mouseReleased() {
  onBarPressed = false;
  offBarPressed = false;
  trianglePressed = false;
}
void mousePressed() {
  if(page == 0 && mouseX > sbX && mouseX < sbX + bW && mouseY > sbY && mouseY < sbY + bH){//if start/end button clicked
    if(!start){//now starting
       output = createWriter("positions.csv"); 
       XPOS = new ArrayList<ArrayList<Double> >();//list of cells, each cell has a list of x positions
       YPOS = new ArrayList<ArrayList<Double> >();
       dTheta = new ArrayList<ArrayList<Double> >();
       corr = new ArrayList<ArrayList<Double> >();
       onOff = new ArrayList<Boolean>();
       graphTime = new ArrayList<Integer>();
       for(int i = 0; i < numPart; i++){
         XPOS.add(new ArrayList<Double>());
         YPOS.add(new ArrayList<Double>());
         dTheta.add(new ArrayList<Double>());
         corr.add(new ArrayList<Double>());
       }
       startGraphTime = millis();
    }
    else{
      done = true;
    }
    start = !start;
    lastReset = millis();
    onTimeFinal = onTime;
    offTimeFinal = offTime;
  }
  if(page == 0 && doneOnce == true && start == false && mouseX > dbX && mouseX < dbX + bW && mouseY > dbY && mouseY < dbY + bH){//if data button clicked
    page = 1;
  }
  if(page == 1 && mouseX > bbX && mouseX < bbX + bW && mouseY > bbY && mouseY < bbY + bH){//if back button clicked
    page = 0;
  }
  if(page == 1 && abs(mouseX-triangleX) < 10 && abs(mouseY-triangleY) < 10){//check if triangle clicked
    trianglePressed = true;
  }
  if(page == 0 && mouseX > toggleX && mouseX < toggleX + 40 && mouseY > toggleY && mouseY < toggleY + 80){//if switch clicked
    switchOn = !switchOn;
    SIGMOID = !SIGMOID;
  }
  if(onTimeBar.clicked(mouseX,mouseY))
    onBarPressed = true;
  if(offTimeBar.clicked(mouseX,mouseY))
    offBarPressed = true;
}

void process(){
  PVector source = new PVector(1,0);
  for(int j = 0; j < XPOS.get(0).size()-1; j++){
    for(int c = 0; c < numPart; c++){
      PVector v = new PVector((float)(XPOS.get(c).get(j+1) - XPOS.get(c).get(j)),(float)(YPOS.get(c).get(j+1) - YPOS.get(c).get(j)));
      v.normalize();
      dTheta.get(c).add((double)PVector.angleBetween(source,v));
      corr.get(c).add((double)cos(dTheta.get(c).get(j).floatValue())); 
    }
  }
  //write to file and close it
  for(int c = 0; c < XPOS.size(); c++){
    output.print("Cell " + c);
    for(int j = 0; j < XPOS.get(c).size(); j++){
      output.print("," + XPOS.get(c).get(j) + "," + YPOS.get(c).get(j));
      if(j < XPOS.get(c).size()-1)
        output.print("," + dTheta.get(c).get(j) + "," + corr.get(c).get(j));
      output.println();
    }
    output.println();
  }
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
}
