//draws toggle from directed to undirected motility
void drawToggles(){
  //draw the button
  pg.noStroke();
  //draw start button
  if(!start){//has not started yet
    if(mouseX > sbX && mouseX < sbX + bW && mouseY > sbY && mouseY < sbY + bH)//if hovering over button
          pg.fill(color(58,81,156));
        else
          pg.fill(navy);
  }
  else{
    if(mouseX > sbX && mouseX < sbX + bW && mouseY > sbY && mouseY < sbY + bH)//if hovering over button
      pg.fill(color(250,129,129));
    else
      pg.fill(color(247,60,60));
  }
  pg.rect(sbX,sbY,bW,bH,barEdge,barEdge,barEdge,barEdge);
  //draw data button
  if(mouseX > dbX && mouseX < dbX + bW && mouseY > dbY && mouseY < dbY + bH)//if hovering over button
        pg.fill(color(58,81,156));
      else
        pg.fill(navy);
  if(!doneOnce)
    pg.fill(200);//light gray
  pg.rect(dbX,dbY,bW,bH,barEdge,barEdge,barEdge,barEdge);
  //draw the bars
  if(onBarPressed){
     onTimeBar.update(mouseX);
     onTime = (int)(onTimeBar.knobLoc*(maxOnTime-minOnTime)+minOnTime);
  }
  if(offBarPressed){
     offTimeBar.update(mouseX);
     offTime = (int)(offTimeBar.knobLoc*(maxOffTime-minOffTime)+minOffTime);
  }
  onTimeBar.drawBar(blueGray);
  offTimeBar.drawBar(blueGray);
  //draw the switch
  pg.pushMatrix();
  pg.translate(toggleX,toggleY+20);
  pg.noStroke();
  if(switchOn)
    pg.fill(color(0,128,0));
  else
    pg.fill(125);
  pg.rect(0, 0, 40, 30);
  pg.ellipse(20, 0, 40, 40);
  pg.ellipse(20, 30, 40, 40);
  pg.fill(255);
  if(switchOn)
    pg.ellipse(20, 00, 35, 35);
  else
    pg.ellipse(20, 30, 35, 35);
  pg.popMatrix();
}

void drawBackButton(){
  if(mouseX > bbX && mouseX < bbX + bW && mouseY > bbY && mouseY < bbY + bH)//if hovering over button
    fill(color(255,140,0));
  else
    fill(color(255,80,0));
  rect(bbX,bbY,bW,bH,barEdge,barEdge,barEdge,barEdge);
  fill(0);
  textSize(25);
  text("Back",bbX+32,bbY+32);
}

void writeTextP0(){
  pg.fill(0);
  pg.textSize(22);
  pg.text("On Time: " + onTime + "ms", 270, 72);
  pg.text("Off Time: " + offTime + "ms", 270, 152);
  pg.textSize(25);
  if(start){
    pg.text("End",347,253);
  }
  else{
    pg.fill(255);
    pg.text("Start",340,253);
  }
  pg.fill(255);
  pg.text("Data",512,253);
}
