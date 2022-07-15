class particleSystem {
  ArrayList<particle> particles;
  particleSystem(int numPart, int xMinBorder, int yMinBorder, int xMaxBorder, int yMaxBorder){
    particles = new ArrayList<particle>();
    for(int i = 0; i < numPart; i++)
      particles.add(new particle(i,xMinBorder, yMinBorder, xMaxBorder, yMaxBorder));
  }
  void next(){
    //check for particle collisions and change particle directions accordingly 
    if(!SIGMOID){
      Collections.sort(particles);
      for(int i = 0; i < particles.size(); i++){
        for(int j = i + 1; j < particles.size(); j++){
          if(sqrt(pow(abs(particles.get(i).position.x - particles.get(j).position.x),2)+pow(abs(particles.get(i).position.y - particles.get(j).position.y),2)) < RAD*2){
            particles.get(i).collide(particles.get(j));
            particles.get(j).collide(particles.get(i));
          }
        }
      }
    }
    //move particles
    if(start){
      graphTime.add((int)(millis() - startGraphTime));
      onOff.add(isDirected);
    }
    for(particle p : particles)
      p.next();
    //update excel
    /*if(start){
      for(int i = 0; i < particles.size(); i++)
        output.print(XPOS.get(i) + "," + YPOS.get(i) + ",,");
      output.println();
    }*/
    
  }
  void draw(){
    for(particle p : particles)
      p.draw();
  }
}
