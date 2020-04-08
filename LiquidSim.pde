int cellsSize = 5; //must be a divisor of the window's size (r must be 0)

Automata a;

void setup()
{
  size(400, 400);
  frameRate(60.0f);
  
  a = new Automata(cellsSize, 1.0f, 0.02f, 0.0001f, 0.5f);
}

void draw()
{
  background(255);
  
  a.updateAutomaton();
  a.draw();
}


void keyPressed()
{
  if(key == 'g')
     a.toggleGravity();
}

void mouseClicked()
{
  handleMouse();
}

void mouseDragged()
{
  handleMouse();
}

void handleMouse()
{
  if (mouseButton == LEFT)
  {
    a.setCell(Cell.BLOCK, mouseX, mouseY);
    a.setCellMass(1.0f, mouseX, mouseY);
  }
  else if (mouseButton == RIGHT)
  {
    a.setCell(Cell.LIQUID, mouseX, mouseY);
    a.setCellMass(1.0f, mouseX, mouseY);
  }
  else if (mouseButton == CENTER)
    a.setCell(Cell.EMPTY, mouseX, mouseY);
}
