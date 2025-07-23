import java.util.ArrayList;
import java.util.Random;

int cx, cy;
float clockRadius;
boolean isSummerTime;
ArrayList<WaterParticle> waterParticles = new ArrayList<WaterParticle>();
PGraphics buffer;
boolean chinaSelected = false;
boolean ukSelected = false;
float zoomProgress = 0;
final float ANIMATION_SPEED = 0.05;

color[] currentColors = new color[4]; 
int colorChangeSpeed = 1000; 
int lastColorChangeTime = 0;
boolean isColorChanging = false;
int clickCount = 0;
Random rand = new Random();

void setup() {
  size(800, 400, P2D);
  smooth(8);
  cx = width / 4;
  cy = height / 2;
  clockRadius = min(width, height) * 0.3;
  isSummerTime = isBritishSummerTime();
  buffer = createGraphics(width, height, P2D);
  buffer.smooth(8);
  
  resetColors();
}

void resetColors() {
  currentColors[0] = color(240); 
  currentColors[1] = color(255); 
  currentColors[2] = color(0);   
  currentColors[3] = color(0);   
  colorChangeSpeed = 1000;
  isColorChanging = false;
  clickCount = 0;
}

void draw() {
  if (chinaSelected || ukSelected) {
    zoomProgress = min(zoomProgress + ANIMATION_SPEED, 1);
  } else {
    zoomProgress = max(zoomProgress - ANIMATION_SPEED, 0);
  }

  if (isColorChanging && millis() - lastColorChangeTime > colorChangeSpeed) {
    changeColors();
    lastColorChangeTime = millis();
  }

  buffer.beginDraw();
  buffer.background(currentColors[0]);
  
  java.time.ZonedDateTime beijingTime = java.time.ZonedDateTime.now(java.time.ZoneId.of("Asia/Shanghai"));
  java.time.ZonedDateTime londonTime = java.time.ZonedDateTime.now(
    isSummerTime ? 
      java.time.ZoneId.of("Europe/London") : 
      java.time.ZoneOffset.UTC
  );
  
  if (zoomProgress == 0) {
    drawDualClockView(buffer, beijingTime, londonTime);
  } else {
    drawSingleClockView(buffer, 
                       chinaSelected ? beijingTime : londonTime, 
                       chinaSelected, 
                       zoomProgress);
  }
  
  drawControlButton(buffer);
  
  buffer.endDraw();
  image(buffer, 0, 0);
}

void drawControlButton(PGraphics pg) {
  float buttonX = width - 60;
  float buttonY = height - 60;
  float buttonSize = 50;
  
  pg.noStroke();
  pg.fill(100, 100, 255, 150);
  pg.ellipse(buttonX + 3, buttonY + 3, buttonSize, buttonSize);
  
  pg.fill(100, 150, 255);
  pg.ellipse(buttonX, buttonY, buttonSize, buttonSize);
  
  pg.fill(255);
  pg.ellipse(buttonX - 8, buttonY - 5, 10, 10); // 左眼
  pg.ellipse(buttonX + 8, buttonY - 5, 10, 10); // 右眼
  
  if (isColorChanging) {
    pg.noFill();
    pg.stroke(255);
    pg.strokeWeight(2);
    pg.arc(buttonX, buttonY + 5, 20, 15, 0, PI);
  } else {
    pg.stroke(255);
    pg.strokeWeight(2);
    pg.line(buttonX - 10, buttonY + 5, buttonX + 10, buttonY + 5);
  }
  
  pg.noStroke();
  pg.fill(255, 200);
  pg.ellipse(buttonX - 10, buttonY - 10, 8, 8);
}

void changeColors() {
  color bgColor = color(rand.nextInt(200), rand.nextInt(200), rand.nextInt(200));
  color clockColor = color(rand.nextInt(200) + 55, rand.nextInt(200) + 55, rand.nextInt(200) + 55);
  color handColor = color(rand.nextInt(200) + 55, rand.nextInt(200) + 55, rand.nextInt(200) + 55);
  color textColor = color(rand.nextInt(200) + 55, rand.nextInt(200) + 55, rand.nextInt(200) + 55);
  
  while (abs(brightness(bgColor) - brightness(clockColor)) < 50 ||
         abs(brightness(clockColor) - brightness(handColor)) < 50 ||
         abs(brightness(handColor) - brightness(textColor)) < 50) {
    bgColor = color(rand.nextInt(200), rand.nextInt(200), rand.nextInt(200));
    clockColor = color(rand.nextInt(200) + 55, rand.nextInt(200) + 55, rand.nextInt(200) + 55);
    handColor = color(rand.nextInt(200) + 55, rand.nextInt(200) + 55, rand.nextInt(200) + 55);
    textColor = color(rand.nextInt(200) + 55, rand.nextInt(200) + 55, rand.nextInt(200) + 55);
  }
  
  currentColors[0] = bgColor;
  currentColors[1] = clockColor;
  currentColors[2] = handColor;
  currentColors[3] = textColor;
}

void mousePressed() {
  float buttonX = width - 60;
  float buttonY = height - 60;
  float buttonSize = 50;
  
  if (dist(mouseX, mouseY, buttonX, buttonY) <= buttonSize/2) {
    if (mouseButton == LEFT) {
      handleLeftButtonClick();
    } else if (mouseButton == RIGHT) {
      resetColors();
    }
    return;
  }
  
  if (zoomProgress == 0) {
    checkFlagClick();
  } else {
    chinaSelected = false;
    ukSelected = false;
  }
}

void handleLeftButtonClick() {
  clickCount++;
  if (clickCount > 2) clickCount = 1;
  
  isColorChanging = true;
  lastColorChangeTime = millis();
  
  switch (clickCount) {
    case 1: colorChangeSpeed = 1000; break;
    case 2: colorChangeSpeed = 100; break;
  }
}

void checkFlagClick() {
  float flagWidth = clockRadius * 0.5;
  float flagHeight = flagWidth * 2/3.0;
  float flagY = cy - clockRadius * 1.45;
  
  float chinaFlagLeft = cx - flagWidth/2;
  float chinaFlagRight = cx + flagWidth/2;
  
  float ukFlagWidth = clockRadius * 0.6;
  float ukFlagLeft = width - cx - ukFlagWidth/2;
  float ukFlagRight = width - cx + ukFlagWidth/2;
  
  if (mouseX >= chinaFlagLeft && mouseX <= chinaFlagRight && 
      mouseY >= flagY && mouseY <= flagY + flagHeight) {
    chinaSelected = true;
    ukSelected = false;
  } else if (mouseX >= ukFlagLeft && mouseX <= ukFlagRight && 
             mouseY >= flagY && mouseY <= flagY + flagHeight) {
    ukSelected = true;
    chinaSelected = false;
  }
}

void drawDualClockView(PGraphics pg, java.time.ZonedDateTime beijingTime, java.time.ZonedDateTime londonTime) {
  drawClockBase(pg, cx, cy, clockRadius, beijingTime, true, "Beijing (UTC+8)");
  drawClockBase(pg, width - cx, cy, clockRadius, londonTime, false, 
               isSummerTime ? "London (BST UTC+1)" : "London (GMT UTC+0)");
  
  drawAllClockHands(pg, cx, cy, clockRadius, beijingTime);
  drawAllClockHands(pg, width - cx, cy, clockRadius, londonTime);
  
  updateWaterParticles(pg);
  
  pg.fill(currentColors[3]);
  pg.textSize(16);
  pg.textAlign(CENTER);
  pg.text("Time difference: Beijing is " + (isSummerTime ? 7 : 8) + " hours ahead", 
         width/2, height - 30);
}

void drawSingleClockView(PGraphics pg, java.time.ZonedDateTime time, boolean isChina, float progress) {
  float targetRadius = min(width, height) * 0.4;
  float currentRadius = lerp(clockRadius, targetRadius, progress);
  float centerX = width/2;
  float centerY = height/2;
  
  drawClockBase(pg, centerX, centerY, currentRadius, time, isChina, 
               isChina ? "Beijing (UTC+8)" : 
               isSummerTime ? "London (BST UTC+1)" : "London (GMT UTC+0)");
  
  drawAllClockHands(pg, centerX, centerY, currentRadius, time);
  
  updateWaterParticles(pg);
  
  pg.fill(currentColors[3]);
  pg.textSize(14);
  pg.textAlign(CENTER);
  pg.text("Click anywhere to return", width/2, height - 20);
}

void drawClockBase(PGraphics pg, float centerX, float centerY, float radius, 
                  java.time.ZonedDateTime time, boolean isChina, String label) {
  pg.fill(currentColors[1]);
  pg.stroke(currentColors[2]);
  pg.strokeWeight(2);
  pg.ellipse(centerX, centerY, radius * 2, radius * 2);
  
  drawClockTicks(pg, centerX, centerY, radius);
  
  float flagWidth = isChina ? radius * 0.5 : radius * 0.6;
  float flagHeight = flagWidth * (isChina ? 2/3.0 : 1/2.0);
  float flagY = centerY - radius * 1.45;
  if (isChina) {
    drawChinaFlag(pg, centerX - flagWidth/2, flagY, flagWidth, flagHeight);
  } else {
    drawUKFlag(pg, centerX - flagWidth/2, flagY, flagWidth, flagHeight);
  }
  
  pg.fill(currentColors[3]);
  pg.textSize(14);
  pg.text(label, centerX, centerY + radius * 1.2);
}

void drawAllClockHands(PGraphics pg, float centerX, float centerY, float radius, 
                      java.time.ZonedDateTime time) {
  int second = time.getSecond();
  int minute = time.getMinute();
  int hour = time.getHour();
  
  float secAngle = map(second, 0, 60, 0, TWO_PI) - HALF_PI;
  float minAngle = map(minute + norm(second, 0, 60), 0, 60, 0, TWO_PI) - HALF_PI;
  float hrAngle = map(hour % 12 + norm(minute, 0, 60), 0, 12, 0, TWO_PI) - HALF_PI;
  
  if (frameCount % 60 == 0) {
    float tipX = centerX + cos(secAngle) * radius * 0.9;
    float tipY = centerY + sin(secAngle) * radius * 0.9;
    for (int i = 0; i < 8; i++) {
      waterParticles.add(new WaterParticle(
        tipX, tipY,
        random(-1, 1),  
        random(-4, -2),
        random(3, 8)    
      ));
    }
  }
  
  pg.stroke(currentColors[2]);
  pg.strokeWeight(4);
  pg.line(centerX, centerY, 
          centerX + cos(hrAngle) * radius * 0.5, 
          centerY + sin(hrAngle) * radius * 0.5);
  
  pg.strokeWeight(2);
  pg.line(centerX, centerY, 
          centerX + cos(minAngle) * radius * 0.7, 
          centerY + sin(minAngle) * radius * 0.7);
  
  pg.stroke(255, 0, 0);
  pg.strokeWeight(1);
  pg.line(centerX, centerY, 
          centerX + cos(secAngle) * radius * 0.9, 
          centerY + sin(secAngle) * radius * 0.9);
  pg.stroke(currentColors[2]); 
}

class WaterParticle {
  float x, y;
  float vx, vy;
  float size;
  float life = 0.8;
  color particleColor;
  
  WaterParticle(float x, float y, float vx, float vy, float size) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.size = size;
    this.particleColor = color(
      random(100, 200),  // R
      random(150, 230),  // G
      random(200, 255),  // B
      180             
    );
  }
  
  void update() {
    vy += 0.1; 
    vx *= 0.98; 
    vy *= 0.98;
    
    x += vx;
    y += vy;
    
    life -= 1.0/60; 
  }
  
  void display(PGraphics pg) {
    pg.noStroke();
    pg.fill(
      red(particleColor), 
      green(particleColor), 
      blue(particleColor), 
      life * 225 
    );
    pg.ellipse(x, y, size, size);
  }
}

void updateWaterParticles(PGraphics pg) {
  for (int i = waterParticles.size() - 1; i >= 0; i--) {
    WaterParticle p = waterParticles.get(i);
    p.update();
    p.display(pg);
    if (p.life <= 0) waterParticles.remove(i);
  }
}

void drawClockTicks(PGraphics pg, float centerX, float centerY, float radius) {
  pg.strokeWeight(1);
  for (int i = 0; i < 60; i++) {
    float angle = map(i, 0, 60, 0, TWO_PI);
    float inner = radius * (i % 5 == 0 ? 0.85 : 0.9);
    pg.line(
      centerX + cos(angle) * inner,
      centerY + sin(angle) * inner,
      centerX + cos(angle) * radius,
      centerY + sin(angle) * radius
    );
  }
}

void drawChinaFlag(PGraphics pg, float x, float y, float w, float h) {
  pg.pushMatrix();
  pg.translate(x, y);
  pg.scale(w/900.0);
  pg.fill(222, 41, 16);
  pg.noStroke();
  pg.rect(0, 0, 900, 600);
  
  float bigStarRadius = h * 0.15 * (900/w); 
  float smallStarRadius = h * 0.05 * (900/w);
  drawStar(pg, 225, 150, bigStarRadius, -PI/2, color(255, 255, 0));
  
  float[][] smallStars = {
    {450, 60, atan2(-0.15, 0.25)}, {540, 120, atan2(-0.05, 0.2)},
    {540, 180, atan2(0.05, 0.2)}, {450, 240, atan2(0.15, 0.25)}
  };
  for (float[] star : smallStars) {
    drawStar(pg, star[0], star[1], smallStarRadius, star[2], color(255, 255, 0));
  }
  pg.popMatrix();
}

void drawUKFlag(PGraphics pg, float x, float y, float w, float h) {
  pg.pushMatrix();
  pg.translate(x, y);
  pg.scale(w/1200.0);
  pg.fill(0, 36, 125);
  pg.noStroke();
  pg.rect(0, 0, 1200, 600);
  
  pg.fill(255);
  pg.rect(0, 250, 1200, 100);
  pg.rect(550, 0, 100, 600);
  
  pg.triangle(0, 0, 600, 300, 0, 600);
  pg.triangle(1200, 0, 600, 300, 1200, 600);
  pg.triangle(0, 0, 600, 300, 1200, 0);
  pg.triangle(0, 600, 600, 300, 1200, 600);
  
  pg.fill(207, 20, 43);
  pg.rect(500, 0, 200, 600);
  pg.rect(0, 200, 1200, 200);
  pg.popMatrix();
}

void drawStar(PGraphics pg, float centerX, float centerY, float radius, float rotation, color c) {
  pg.pushMatrix();
  pg.translate(centerX, centerY);
  pg.rotate(rotation);
  pg.beginShape();
  pg.fill(c);
  float angle = TWO_PI / 5;
  float innerRadius = radius * sin(PI/10) / sin(3*PI/10);
  for (int i = 0; i < 5; i++) {
    pg.vertex(radius * cos(i * angle), radius * sin(i * angle));
    pg.vertex(innerRadius * cos((i + 0.5) * angle), innerRadius * sin((i + 0.5) * angle));
  }
  pg.endShape(CLOSE);
  pg.popMatrix();
}

boolean isBritishSummerTime() {
  java.time.LocalDate today = java.time.LocalDate.now();
  java.time.LocalDate lastMarchSunday = today.withMonth(3)
    .with(java.time.temporal.TemporalAdjusters.lastInMonth(java.time.DayOfWeek.SUNDAY));
  java.time.LocalDate lastOctoberSunday = today.withMonth(10)
    .with(java.time.temporal.TemporalAdjusters.lastInMonth(java.time.DayOfWeek.SUNDAY));
  return today.isAfter(lastMarchSunday) && today.isBefore(lastOctoberSunday);
}
