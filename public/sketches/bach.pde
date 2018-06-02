
float o_curtain, curtainSpeed;

ArrayList springs = new ArrayList();
ArrayList squares = new ArrayList();

int toss, t, m;
float bg, bgspeed;
float rFactor, gFactor, bFactor;
float rFactorSpeed, gFactorSpeed, bFactorSpeed;

float scaleX = 1;
float scaleY = 1;


void setup() {
  size($(window).width(), $(window).height());
  smooth();

  toss = 0;
  t = 0;

  m = 0;
  o_curtain = 0;
  curtainSpeed = 0.1;
	  
  bg = random()*255;  	
  bgspeed = 0.1;
  
  rFactor = random()*1;
  rFactorSpeed = 0.001;
  gFactor = random()*255;
  gFactorSpeed = 0.001;
  bFactor = random()*2;
  bFactorSpeed = 0.001;
  
  noLoop();
}

void draw() {
  scale(scaleX, scaleY);
  rFactor += rFactorSpeed;
  if(rFactor < 0 || rFactor > 1) rFactorSpeed *= -1;  
  gFactor += gFactorSpeed;
  if(gFactor < 0 || gFactor > 255) gFactorSpeed *= -1;
  bFactor += bFactorSpeed
  if(bFactor < 1 || bFactor > 3) bFactorSpeed *= -1;
  	  
  bg+=bgspeed;
  if(bg<0 || bg>255) bgspeed*=-1;
  bg=constrain(bg, 0, 255);

  background(bg*rFactor, gFactor-bg, bg/bFactor);
  
  //Create squares (at a slow rate)
  initialize();

  //Constantly change size, rotation, opacity and strength of springs for each square
  for (int i = 0; i < springs.size(); i++) {
    Spring thisSpring = (Spring)springs.get(i);
    Square thisSquare = (Square)squares.get(i);

    thisSquare.wave();
    thisSquare.turn();
    thisSquare.grow();
    thisSquare.fade();
    thisSquare.pull();

    PVector thisSpring_force = thisSpring.connect(thisSquare);
    thisSquare.applyForce(thisSpring_force);

    thisSquare.update();
    thisSquare.display();

    //If squares reach right side of window, kill it.
    if (thisSquare.die() == true) {
      springs.remove(thisSpring);
      squares.remove(thisSquare);
    }
  }

  curtain();
}

void initialize() {                                              // create new springs and squares at a controlled rate using toss
  toss = int(random(1000));
  if(toss%33 == 0) {
    springs.add(new Spring((noise(t+random(10))*width*-1), (noise(t+random(100))*noise(t)*random(0.01))));
    squares.add(new Square((noise(t+random(100))*250)));
    t += random (-1, 5);
  }
}

void curtain() {                                               // if music is playing, count seconds until...

	fill(gFactor-bg, bg/bFactor, bg*rFactor, o_curtain);
	rectMode(CORNER);
	rect(0, 0, width, height);  
	o_curtain += curtainSpeed;
	if(o_curtain < 0 || o_curtain > 255) curtainSpeed *= -1;
	o_curtain = constrain(o_curtain, 0, 255);
}

void resize(float _scaleX, float _scaleY) {
	scaleX = _scaleX;
	scaleY = _scaleY;
}

class Spring {
  PVector anchor;
  float x_anchor, k, len;


  Spring(float x_anchor_, float k_) {
    x_anchor = x_anchor_;
    anchor = new PVector(x_anchor, height/2);
    k = k_;
    len = abs(x_anchor);
  }

  PVector connect(Square square) {                                    // calculate spring force, anchor position is set when created
    PVector spr_force = PVector.sub(square.location, anchor);

    float d = spr_force.mag();
    float stretch = d - len;

    spr_force.normalize();
    spr_force.mult(-1 * k * stretch);

    return spr_force;
  }
}

class Square {
  PVector location, velocity, acceleration, pull;
  float w_square, h_square, o_square;
  float c_angle, r_angle, v_angle, a_angle, r;
  float freq, amp;

  Square(float amp_) {
    location = new PVector(0, height/2);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    
    freq = 1;    
    amp = amp_;

    c_angle = radians(0);
    r_angle = radians(0);
        
  }

  void wave() {                                   // move the square up and down according to sine wave
    location.y = height/2 + (sin(c_angle)*amp);   // amplitude of wave is set when square is created

    c_angle += .01*freq;                          // increase angle
    freq = noise(t)*10;                           // frequence fluctuates every time through draw
  }

  void turn() {                                   // turn the square
    r_angle -= noise(t)*random(0.375);
  }

  void grow() {                                   // grow the square
    w_square += noise(t)*random(-10, 10);
    h_square += noise(t)*random(-10, 10);

    w_square = constrain(w_square, 0, 50);        // constrain square size
    h_square = constrain(h_square, 0, 50);
  }

  void fade() {                                   // fade the square
    o_square += noise(t)*random(-10, 10);
    o_square = constrain(o_square, 100, 255);
  }

  void pull() {                                   // pull the square (equivalent to pulling the bob on the spring)
    acceleration.x = sin(r_angle)*noise(t)*random(-3,5);
  }  

  boolean die() {                                  // kill the square if it exits to the right
    
    if(location.x > width) {
      return true;
    }
    
    return false;    
  }
  
  void applyForce(PVector spr_force) {            // apply spring force
    PVector app_force = spr_force.get();
    acceleration.add(app_force);
  }

  void update() {                                 // update location, vel and re-set acceleration
    location.add(velocity);
    velocity.add(acceleration);
    acceleration.mult(0);
  }

  void display() {                               // draw the square

    pushMatrix();
    translate(location.x, location.y);
    rotate(r_angle);

    rectMode(CENTER);
    noStroke();
    fill(gFactor-bg, bg*rFactor, bg*bFactor, o_square);

    rect(0, 0, w_square, h_square);

    popMatrix();
  }
}


