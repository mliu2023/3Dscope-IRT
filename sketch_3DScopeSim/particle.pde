class particle implements Comparable< particle >{
  int speed, r;//speed and radius of particle hardcoded
  int minX, maxX, minY, maxY;//border
  PVector position;
  float dir;
  ArrayList<PVector> path;//store all previous positions for data collection; actually didn't need to use it 
  int id;//just to number all the particles
  float tendency;//direction the cell tends to move in
  long lastRandTime, lastDirTime;//time since last change b/t random and directed motility
  int directedLatency, randomLatency; //latency from when the light turns on to when the cell begins exhibiting directed motility, latency from when the light turns on to when the cell begins exhibiting random motility
  boolean toRandom, toDirected;//true when it just changed from directed to random
  
  particle(int id, int xMinBorder, int yMinBorder, int xMaxBorder, int yMaxBorder){
    this.id = id;
    r = RAD;
    speed = 3;
    minX = xMinBorder;
    maxX = xMaxBorder;
    minY = yMinBorder;
    maxY = yMaxBorder;
    position = new PVector(random(maxX-minX)+minX,random(maxY-minY)+minY);
    dir = random(2*PI);
    path = new ArrayList<PVector>();
    path.add(position);
    tendency = randomGaussian()*3;
    lastRandTime = millis();
    lastDirTime = millis();
    directedLatency = max(0,(int)(randomGaussian()*100+100));
    randomLatency = max(0,(int)(randomGaussian()*100+100));//saying cell retains a "memory" for when the light turned on  
    toRandom = false;
    toDirected = false;
  }
  void next(){
    //store/collect last position to
    if(start){
      XPOS.get(id).add((double)position.x);
      YPOS.get(id).add((double)-position.y);//flip y to resemble x-y axis
    }
    //update position
    if(isDirected){
      toRandom = true;
      lastDirTime = millis();
      if(millis() - lastRandTime > directedLatency){
        if(SIGMOID && toDirected){//change direction randomly when you switch from directed to random motility
          toDirected = false;
          dir = 0;
        }
        directedMovement();
      }
      else
        randomMovement();
    }
    else{
      toDirected = true;
      lastRandTime = millis();
      if(millis() - lastDirTime > randomLatency){
        if(SIGMOID && toRandom){//change direction randomly when you switch from directed to random motility
          toRandom = false;
          dir = random(PI*2);
        }
        randomMovement();
      }
      else
        directedMovement();
    }
    path.add(position);
  }
  void boundDir(){//bound direction to 0 to 2*PI radians 
    if(dir > 2*PI)
      dir -= 2*PI;
    if(dir < 0)
      dir += 2*PI;
  }
  void directedMovement(){//in directed motility, cells tend to veer towards the light; added delay for when they begin exerting directed motility
    /*if(!switchOn)//switch controls box
      wallBounce();*/
    if(!SIGMOID){
      float changeAmt = (randomGaussian()*6+3)*PI/180;
      //if(random(1) < 0.5)
      //  changeAmt = 0;
      if(dir < PI)
        dir -= changeAmt;
      if(dir > PI)
        dir += changeAmt;
    }
    boundDir();
    position.add(new PVector(cos(dir)*speed,-sin(dir)*speed));
  }
  void randomMovement(){//associate a tendency for each cell for how much it veers towards one side on average in random motility
    /*if(!switchOn)//switch controls box
      wallBounce();*/
    if(!SIGMOID){
      float changeAmt = (randomGaussian()*2+tendency)*PI/180;
      if(random(1) < 0.5)
        changeAmt = 0;
      if(dir < PI)
        dir -= changeAmt;
      if(dir > PI)
        dir += changeAmt;
      if(random(1) < 0.01)//sometimes change directions
       dir = random(PI*2);
    }
    boundDir();
    position.add(new PVector(cos(dir)*speed,-sin(dir)*speed));
  }
  void wallBounce(){
    //wall bounce: if hit wall, change the direction accordingly 
    PVector newPos = new PVector(cos(dir)*speed+position.x,-sin(dir)*speed+position.y);
    if(newPos.y - r < minY){
      if(dir > 0 && dir < PI*0.5){//Q1
        dir = 2*PI - dir;
      }
      else if(dir > PI*0.5 && dir < PI){//Q2
        dir = 2*PI - dir;
      }
    }
    else if(newPos.x - r < minX){
      if(dir > PI*0.5 && dir < PI){//Q2
        dir = PI - dir;
      }
      else if(dir > PI && dir < PI*1.5){//Q3
        dir = PI*2-(dir-PI);
      }
    }
    else if(newPos.y + r > maxY){
      if(dir > PI && dir < PI*1.5){//Q3
        dir = PI*2 - dir;
      }
      else if(dir > PI*1.5 && dir < PI*2){//Q4
        dir = PI*2-dir;
      }
    }
    else if(newPos.x + r > maxX){
      if(dir > 0 && dir < PI*0.5){//Q1
        dir = PI - dir;
      }
      else if(dir > PI*1.5 && dir < PI*2){//Q4
       dir = 3*PI - dir;
      }
    }
    boundDir();
  }
  PVector getPosition(){
    return position; 
  }
  void collide(particle otherPart){
    float init = dir, diff;//diff b/t initial direction and calculated direction
    PVector otherPos = otherPart.getPosition();
    if(position.x > otherPos.x){
      dir = atan((position.y-otherPos.y)/(position.x-otherPos.x)); 
      if(dir < 0){
        dir = 2*PI+dir;
      }
    }
    else{
      dir = atan((position.y-otherPos.y)/(position.x-otherPos.x)); 
      if(dir > 0){
        dir = PI + dir;
      }
      else{
        dir = PI + dir;
      }
    }
    //dir points in the direction of the line that goes through the centers of both circles
    if(abs(init - dir) < PI)
      diff = abs(init - dir);
    else
      diff = 2*PI - abs(init - dir);
    dir = diff + dir;
  }
  void draw(){
    color c = color(0,128,0);
    pg.fill(c);
    pg.noStroke();
    pg.ellipse(position.x,position.y,r,r);
  }
  public int compareTo(particle p) {
    if(this.position.x > p.position.x)
       return 1;
    return -1;
  }
}
