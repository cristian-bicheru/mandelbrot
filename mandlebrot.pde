import java.lang.Math;

// Variable Parameters
double aMin = -1.5;
double aMax = 0.5;
double bMin = -1;
double bMax = 1;
color[] fillColors = {color(0, 6, 92), color(235, 235, 255), color(255, 128, 0), color(0, 6, 92)}; // must be cyclic to look right
color containedColor = color(0, 0, 0); // within the set
int nMax = 1000;
float colorPow = 0.3;   // hard to spot differences in color since the range is very small,
                        //so it is raised to a power less than one
double zoomA = -0.761574;
double zoomB = -0.0847596;
double zoomFactor = 0.04;
int numThreads = 8;
int colorModulo = 60;
color[] colorCycle;


// Derived Parameters
double mX;
double bX;
double mY;
double bY;
double log2;
float lerpNDiv;
RenderThread[] renderthreads;

void setup() {
  size(1000, 1000);
  fill(0);
  loadPixels();
  renderthreads = new RenderThread[numThreads];
  log2 = Math.log(2);
  colorCycle = new color[colorModulo+1];
  int lerpPer = colorModulo/fillColors.length;
  for (int i = 0; i < fillColors.length-1; i++) {
    int jstart = i*lerpPer;
    for (int j = jstart; j < jstart+lerpPer; j++) {
      colorCycle[j] = lerpColor(fillColors[i], fillColors[i+1], (j-jstart)/float(lerpPer));
    }
  }
}

void draw() {
  clear();

  mX = (aMax-aMin)/width;
  mY = (bMax-bMin)/height;
  bX = aMin;
  bY = bMin;
  lerpNDiv = nMax;
  
  for (int i = 0; i < numThreads; i++) {
    renderthreads[i] = new RenderThread(floor(width/float(numThreads)*i),
                                        floor(width/float(numThreads)*(i+1)), 0, height);
    renderthreads[i].start();
  }
  
  for (RenderThread x : renderthreads) {
    try {
      x.join();
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
  }
  
  updatePixels();
  saveFrame();
  
  aMax -= (aMax-zoomA)*zoomFactor;
  aMin -= (aMin-zoomA)*zoomFactor;
  bMax -= (bMax-zoomB)*zoomFactor;
  bMin -= (bMin-zoomB)*zoomFactor;
  nMax *= 1+zoomFactor;
}

class RenderThread extends Thread {
  int x0, x1, y0, y1;

  public RenderThread(int xMin, int xMax, int yMin, int yMax){
    x0 = xMin;
    x1 = xMax;
    y0 = yMin;
    y1 = yMax;
  }
  
  public void run(){
    ComplexNumber z = new ComplexNumber();
    ComplexNumber c = new ComplexNumber();
    int n;
    double log_zn; // see https://en.wikipedia.org/wiki/Plotting_algorithms_for_the_Mandelbrot_set#Continuous_(smooth)_coloring
    double nu; // ^
    int i;
    
    for (int x = x0; x < x1; x++) {
      for (int y = y0; y < y1; y++) {
        z.setFromCoordinate(x, y);
        c.set(z.real, z.img);
        
        n = 0;
        do {
          z.inPlaceSquare();
          z.inPlaceAdd(c);
          n++;
        } while (n < nMax && z.magSq() < 4);
        
        if (n < nMax) {
          log_zn = Math.log(z.magSq()) / 2.d;
          nu = Math.log(log_zn / log2) / log2;
          nu = n + 1 - nu;
          i = Math.toIntExact(Math.round(Math.floor(nu)))%colorModulo;
          pixels[y*width + x] = lerpColor(colorCycle[i], colorCycle[i+1], (float) nu%1.f);
        } else {
          pixels[y*width + x] = containedColor;
        }
      }
    }
  }
}
