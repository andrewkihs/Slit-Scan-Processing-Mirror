import processing.video.*; 
 
Capture cam;

PGraphics topLayer;
PGraphics topLayer2;
PImage camMirror;

int video_slice_x   = 0;
int draw_position_x = 0; 
int draw_position_y = 0;

boolean firstFlag = true;    // boolean flag to turn on/off first viz 
boolean secondFlag = false;  // boolean flag to turn on/off second viz

void setup() 
{ 
  size(1280, 720); 
  frameRate(60);
  cam = new Capture(this, width, height, 60);         //
  camMirror = new PImage(cam.width, cam.height);      // 
  topLayer = createGraphics(width, height);           // uses PGraphics to have layer above regular camera
  topLayer2 = createGraphics(width, height);          // PGraphics for Layer above
  cam.start();
} 

void draw() { 
  if (cam.available()==true) {
    cam.read();
    cam.loadPixels();    //load pixels to read for mirror + topLayers
    
    for (int y = 0; y < cam.height; y++) {    // loop for regular camera
      for (int x = 0; x < cam.width; x++) {
        int ind = (width-x-1) + y*width;      // reverse pixels for camMirror
        camMirror.pixels[y*width+x] = cam.pixels[ind];
      }
    } 
    
    if(firstFlag){
      topLayer.beginDraw();     //begin draw and load for PGraphics
      topLayer.loadPixels();
    
      for (int y=0; y<cam.height; y++){    //loop for moving scan
         int index = (width-draw_position_x-1) + y*width;
         int setPixelIndex = draw_position_x + y*width;
         topLayer.pixels[setPixelIndex] = cam.pixels[index];
      }
      
      topLayer.updatePixels();  
      topLayer.endDraw();
      draw_position_x++;  //iterate through draw position for x
    }
    
    if (secondFlag){      //bool for this viz
      topLayer2.beginDraw();
      topLayer2.loadPixels();
      for (int x=cam.width-1; x>0; x--){         // loop for moving scan of splayed pixel "sort"d
         int index = (height-draw_position_y-1) + x*height;
         int setPixelIndex = draw_position_y + x*height;
         if (index ==0 || setPixelIndex ==0){    // kind of a hack?
           break;}
         if (index >=cam.pixels.length || setPixelIndex>=cam.pixels.length){  // kind of a hack v2
           break;}                               
         topLayer2.pixels[setPixelIndex] = cam.pixels[index];
      }
      topLayer2.updatePixels();
      topLayer2.endDraw();
      draw_position_y++;
    }

   
     
     camMirror.updatePixels();
     

     if (draw_position_x >= cam.width-1) {
        draw_position_x=1;
        draw_position_y=1;
        firstFlag=false;
        secondFlag=true;
        //println("trigger x");    //flag for testing
     }
     
     
     if (draw_position_y >= cam.width/1.75) {
        draw_position_x=1;
        draw_position_y=1;
        firstFlag=true;
        secondFlag=false;
        //println("trigger y");    //flag for testing
     }
   
     if (firstFlag && secondFlag){
       
         image(camMirror, 0, 0 );
         image(topLayer,0,0);
         image(topLayer2,0,0);
     }
     
     if (!firstFlag & secondFlag){     
         image(camMirror, 0, 0 );
         image(topLayer2,0,0);
       
     }
     
      if (firstFlag & !secondFlag){
         image(camMirror, 0, 0 );
         image(topLayer, 0, 0 );
     }
  }
} 