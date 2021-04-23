PImage img;
PImage bg;
ArrayList<Particle> particles = new ArrayList<Particle>();
int particle_count = 160000;
int min_lifetime = 30;
int max_lifetime = 70;
float[] v_map;
color[] c_map = {#643ABD, #D97ECA, #F2AED5, #DE50D4, #FF73A2, #643ABD};

void setup(){
  colorMode(HSB);
  loadPixels();
  v_map = new float[img.width*img.height];
  image(img, 0,0);
  loadPixels();
  for (int y = 0 ; y < height; y++) {
    for (int x = 0 ; x < width; x++){
      v_map[x+width*y] = map_brightness(pixels[x+width*y]);
    }
  }
  for (int i = 0; i < particle_count; i++){
   int p_x = int(random(0,width));
   int p_y = int(random(0,height));
   particles.add(new Particle(p_x,p_y));
  }
  image(bg,0,0);
}

void settings(){
  img = loadImage("img.jpg");
  bg = loadImage("Hippopx_dark.jpg");
  size(img.width,img.height);
}

void draw(){
  for (int i = 0; i < particles.size(); i++){
    Particle P = particles.get(i);
    if (P.dead){
      particles.remove(i);
    }
    P.update(v_map);
    P.show();
  }
  if (particles.size() < particle_count){
    for (int i = 0; i < particle_count-particles.size(); i++){
      int p_x = int(random(0,width));
      int p_y = round(random(0,height));
      particles.add(new Particle(p_x,p_y));
    }
  }
  fill(20, 80);
  noStroke();
  tint(255, 80);
  image(bg, 0, 0);
  noTint();
  saveFrame("frames/##.png");
}

float map_brightness(int a){
  colorMode(HSB);
  float b = brightness(a);
  float theta = lerp(0, TWO_PI, b/100);
  colorMode(RGB);
  return theta;
}

class Particle{
  
  PVector p = new PVector(0,0);
  PVector v = new PVector(0,0);
  float v_mag;
  boolean dead;
  int age = 0;
  int lifetime;

  Particle (int pos_x, int pos_y){
    this.p.x = pos_x;
    this.p.y = pos_y;
    this.v_mag = 1;
    this.v = (PVector.fromAngle(random(0, TWO_PI))).mult(this.v_mag);
    this.dead = false;
    this.lifetime = int(random(min_lifetime, max_lifetime));
  }
  
  void update(float[] vmap){
    if (int(this.p.x)+int(this.p.y)*width > vmap.length-1){
      this.dead = true;
      return;
    }
    if (this.p.x < 0 || this.p.x > width){
      this.dead = true;
      return;
    }
    else if  ((this.p.y < 0) || this.p.y > height){
      this.dead = true;
      return;
    }
    if (this.age > lifetime){
      this.dead = true;
      return;
    }
    this.v = PVector.fromAngle(vmap[int(this.p.x)+int(this.p.y)*width]).mult(this.v_mag);
    this.p.add(this.v);
    this.age++;
  }
  
  void show(){
    float v_lerp = map(abs(this.v.heading()), 0, TWO_PI, 0, 6);
    int high_idx = ceil(v_lerp);
    int low_idx = floor(v_lerp);
    float diff = v_lerp - low_idx;
    color c = lerpColor(c_map[low_idx], c_map[high_idx], diff);
    stroke(c, 110);
    strokeWeight(1);
    point(this.p.x, this.p.y);
  }
}
