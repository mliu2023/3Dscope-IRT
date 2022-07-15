class Bar{
  int y;
  int xStart;
  int xEnd;
  float knobLoc;
  Bar(int yVal, int xStartVal, int xEndVal, float knobLocVal){
    y = yVal;
    xStart = xStartVal;
    xEnd = xEndVal;
    knobLoc = knobLocVal;
  }
  boolean clicked(int mX, int mY){//see if mouse is clicking bar
    if(mX > xStart - 20 && mX < xEnd + 20 && abs(mY-y) < 35)
      return true;
    return false;
  }
  void update(int mX){
    knobLoc = (mX - xStart)/(float)(xEnd - xStart);
    if(knobLoc > 1)
      knobLoc = 1;
    if(knobLoc < 0)
      knobLoc = 0;
  }
  void drawBar(color c){
    pg.noStroke();
    pg.fill(c);
    pg.rect(xStart, y-barWidth/2, xEnd - xStart, barWidth,barEdge,barEdge,barEdge,barEdge);
    pg.strokeWeight(1);
    pg.stroke(0);
    pg.fill(255);
    pg.ellipse(xStart + knobLoc*(xEnd-xStart),y,35,35);
  }
  float getKnobLoc(){
    return knobLoc;
  }
}
