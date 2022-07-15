void setLight(){
  if(!start){//base light off toggle
    isDirected = false;
  }
  else{//base light off predesignated on and off times
    if(currOn){
      if(millis() - lastReset > onTimeFinal){//time to switch light
        currOn = !currOn;
        lastReset = millis();
      }
      isDirected = true;
    }
    else{
      if(millis() - lastReset > offTimeFinal){
        currOn = !currOn;
        lastReset = millis();
      }
      isDirected = false;
    }
  }
}

void correlationVsTime(){//timeLoc goes from 0 to the number of recorded correlations for each cell - 1
  if(trianglePressed){
      timeLoc = (int)((mouseX - gX)/(float)gW*corr.get(0).size()+0.5);
      if(timeLoc < 0)
        timeLoc = 0;
      if(timeLoc > corr.get(0).size()-1)
        timeLoc = corr.get(0).size()-1;
  }
  int circleDia = 2;
  //print out background
  noStroke();
  fill(144,238,144);//light green
  for(int j = 0; j < onOff.size(); j++){
    if(onOff.get(j))
      rect(gX+gW*(j-0.5)/(float)corr.get(0).size(),gY,gW/(float)(XPOS.get(0).size()-1)+1,gH);
    if(j == timeLoc){//add thin red line
      fill(255,165,0);
      rect(gX+gW*j/(float)corr.get(0).size()-1,gY,2,gH,0.5);
      fill(144,238,144);
    }  
  }
  fill(255,0,0);
  triangleX = gX+gW*timeLoc/(float)corr.get(0).size();
  triangleY = gY-7;
  pushMatrix();
  translate(gX+gW*timeLoc/(float)corr.get(0).size(), gY);
  triangle(0,-1,10,-14,-10,-14);
  popMatrix();
  //print out axis
  noFill();
  stroke(120);
  strokeWeight(1);
  line(gX,gY+gH/2,gX+gW,gY+gH/2);
  //print out upper and lower horizontal lines
  stroke(200);
  line(gX,gY,gX+gW,gY);
  line(gX,gY+gH,gX+gW,gY+gH);
  fill(0);
  textSize(15);
  text("1",gX-20,gY+5);
  text("0",gX-20,gY+gH/2+5);
  text("-1",gX-20-8,gY+gH+5);
  stroke(0);
  //print out points
  int time = 0;
  double pointAvgCorr = 0;//average correlation at the red line
  for(int j = 0; j < corr.get(0).size(); j++){
    double avgCorr = 0;//average correlation for time stamp j
    for(int c = 0; c < numPart; c++){
      avgCorr += corr.get(c).get(j); 
    }
    avgCorr /= numPart;
    if(j == timeLoc)
      pointAvgCorr = avgCorr;
    circle(gX+gW*j/(float)(XPOS.get(0).size()-1),gY+gH/2+(float)-avgCorr*gH/2,circleDia);
  }
  time = graphTime.get(timeLoc);
  //create pie
  int pRad = 150, pX = 400, pY = 560;
  noFill();
  stroke(0);
  strokeWeight(2);
  arc(pX, pY, pRad*2,pRad*2,PI,PI*2,PIE);
  float numDegPerSeg = 3;
  ArrayList<Integer> numOccDeg = new ArrayList<Integer>();//number of occurances of each degree count
  for(int i = 0; i < 180/numDegPerSeg; i++)
    numOccDeg.add(0);
  for(int c = 0; c < numPart; c++){
    int idx = (int)(dTheta.get(c).get(timeLoc)*180/PI/numDegPerSeg);
    if(idx > numOccDeg.size() - 1)
      idx = numOccDeg.size() - 1;
    numOccDeg.set(idx,numOccDeg.get(idx)+1);
  }
  noStroke();
  for(int i = 0; i < 180/numDegPerSeg; i++){
    fill(0,255*numOccDeg.get(i)/numPart*1/10*180/numDegPerSeg,0);
    arc(pX,pY,pRad*2,pRad*2,2*PI-(i+1)*numDegPerSeg/180*PI,2*PI-i*numDegPerSeg/180*PI+0.005, PIE);
  }
  fill(0);
  textSize(20);
  text("Correlation vs. Time",300,70);
  text("Distribution of deltaTheta",270,370);
  textSize(15);
  text("0",560,560);
  text("90",385,402);
  text("180",215,560);
  pointAvgCorr = (int)(pointAvgCorr*100);
  pointAvgCorr /= 100.0;
  text("(" + time + "," + pointAvgCorr + ")",gX+gW*timeLoc/(float)corr.get(0).size()-1,320);
}
