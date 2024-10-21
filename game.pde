import java.awt.Rectangle;

class Game extends Rectangle {
  protected int score = 0;
  protected color[] selectedColors;
  protected color textColor;
  protected color nextColor;

  Game() {};
  Game(int colorCount) {
    setSelectedColors(colorCount);
    setNextColor(colorCount);
    setTextColor();
  }
  
  public boolean isFinish(int finishCount){
     return score == finishCount; 
  }
  
  public void setTextColor(){
     textColor = color(100, 149, 237);
  }
  
  public void setNextColor(int colorNum){
     nextColor = selectedColors[int(random(colorNum))];
  }
  
  // limit colors;
  public void setSelectedColors(int colorNum){
     selectedColors = new color[colorNum]; 

    for(int i = 0; i < colorNum; i++){ 
      int r = int(random(180, 255));
      int g = int(random(180, 255));
      int b = int(random(180, 255));
      color selectedColor = color(r, g, b);
      selectedColors[i] = selectedColor;
    }
  }
  
  public void draw(int w, int h) {
    String s = new String("Click Here");
    String f = new String("Congratulation");
    textFont(createFont("Harrington", 24));
    
    if (game.isFinish(bubbleNum)) {
      background(255);
      fill(this.textColor);
      text(f, w/2 - 95, h/2);
    } else {
      fill(this.nextColor);
      text(s, w/2 - 50, underY);
      fill(this.textColor);
      text(game.score, 30, underY);
    }
  }
}

class Bullet extends Game {
  protected color c;
  protected int vx = 0, vy = 0;

  Bullet() {};
  Bullet(color c, int x, int y, int d) {
    setColor(c);
    setRect(x, y, d, d);
  }
  
  public void setColor(color c){ this.c = c; }
  boolean collideTopWall() { return getMinY() < 0; }
  
  public void reset(){
    setRect(width/2, underY, 0, 0);
    vx = 0; vy = 0;
  }

  public void move(){
    y += -30;
    if (collideTopWall()) {
      reset();
      game.setNextColor(colorNum);
    }
    draw();
  }

  public void draw(){
    fill(c);
    ellipseMode(CORNER);
    ellipse(x, y, width, height);
  }
} 

class Bubble extends Bullet {
  private int maxSpeed;

  Bubble() {};
  Bubble(color c, int x, int y, int d, int speed) {
    setColor(c);
    setRect(x, y, d, d);
    setMaxSpeed(speed);
    setRandomVelocity();
  }

  public void setVelocity(int vx, int vy){ this.vx = vx; this.vy = vy; }
  public void setMaxSpeed(int s){ maxSpeed = s; }
  public void setRandomVelocity(){
    int m = ceil(sqrt(maxSpeed));
    do {
        vx = int(random(-m, m));
        vy = int(random(-m, m));
    } while(vx == 0 || vy == 0);
  }

  boolean collideLeftWall(){ return getMinX() < 0; }
  boolean collideRightWall(int w){ return getMaxX() > w; }
  boolean collideBottomWall(int h) { return getMaxY() > h; }

  public void move(int w, int h, Bullet bullet, Game game){
    x += vx; y += vy;
    if(collideLeftWall() || collideRightWall(w)){
      vx *= -1;
      if(collideLeftWall()) x *= -1;
      else x = 2 * (w - width) - x;
    }

    if(collideTopWall()){
      vy *= -1;
      y *= -1;
    } else if(collideBottomWall(h)){
      vy *= -1;
    } else if(bullet != null && intersects(bullet) && this.c == bullet.c){
      game.score++;
      reset();
    }
    draw();
  }

  public void draw(){
    fill(c);
    ellipseMode(CORNER);
    ellipse(x, y, width, height);
  }
}

Game game;
Bubble[] bubble;
Bullet bullet;
final int bubbleNum = 20; 
final int colorNum = 10;
final int mouse = mouseX;
final int underY = 450;
color bubbleColor;
color[] bubbleColors;

void setup() {
  size(322, 500);
  noStroke();
  randomSeed(second());
  
  game = new Game(colorNum);
  
  bubble = new Bubble[bubbleNum];
  for(int i = 0; i < bubbleNum; i++){ 
    int d = int(random(20, 40));
    int x = int(random(width - d));
    int y = int(random(height - d - 150));
    int speed = int(random(100, 200)); 
    // limit 10 colors
    bubble[i] = new Bubble(game.selectedColors[int(random(colorNum))], x, y, d, speed);
  }
  frameRate(15);
}

void mouseClicked(){
  int x = mouseX - 5;
  int bulletD = 100;
  bullet = new Bullet(game.nextColor, x, underY, bulletD);
}

void draw() {
  background(255);
  game.draw(width, height);
  for(int i = 0; i < bubbleNum; i++){
    bubble[i].move(width, height - 150, bullet, game);
  }
  if (bullet != null) {    
    bullet.move();
  }
}
