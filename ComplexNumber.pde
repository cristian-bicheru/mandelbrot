class ComplexNumber {
  double real, img;
  
  ComplexNumber() {
    real = 0;
    img = 0;
  }
  
  ComplexNumber(double r, double i) {
    real = r;
    img = i;
  }
  
  void printMe() {
    if (img >= 0) {
      println(real+"+"+img+"i");
    } else {
      println(real+"-"+(-img)+"i");
    }
  }
  
  double magSq() {
    return real*real+img*img;
  }
  
  void inPlaceSquare() {
    double k = real;
    real = real*real - img*img;
    img = 2.d*k*img;
  }
  
  void inPlaceAdd(ComplexNumber b) {
    real += b.real;
    img += b.img;
  }
  
  void setFromCoordinate(double x, double y) {
    real = x*mX + bX;
    img = y*mY + bY;
  }
  
  void set(double a, double b) {
    real = a;
    img = b;
  }
}
