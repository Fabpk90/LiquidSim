int cellsSize = 5; //must be a divisor of the window's size (r must be 0)


void setup()
{
  size(400, 400);
  frameRate(60.0f);
  
  
}

void draw()
{
  background(255);
}



//Returns the amount of water that should be in the bottom cell.
//To tweak to have a different liquid behavior
float getStableState(float total_mass)
{
  if ( total_mass <= 1 )
  {
    return 1;
  } 
  else if(total_mass < 2 * MaxMass + MaxCompress) //lower should get MaxMass + (upper_cell / MaxMass) * MaxCompress
  {
    return (MaxMass*MaxMass + total_mass * MaxCompress) / (MaxMass + MaxCompress);
  } 

  return (total_mass + MaxCompress) / 2; // the lower should get upper + MaxCompress
}

void keyPressed()
{
  if(key == 'g')
    useNormalGravity = !useNormalGravity;
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
  int positionX = mouseX / cellsSize;
  int positionY = mouseY / cellsSize;

  //out of bound checking
  if (positionX >= 0 && positionX < cellAmountX
    && positionY >= 0 && positionY < cellAmountY)
  {
    //TODO: make sure the cell can be placed
    if (mouseButton == LEFT)
    {
      cells[positionX][positionY] = Cell.BLOCK;
      cellsMass[positionX][positionY] = 1.0f;
    }
    else if (mouseButton == RIGHT)
    {
      cellsMass[positionX][positionY] = 1.0f; 
      cells[positionX][positionY] = Cell.LIQUID;
    }
    else if (mouseButton == CENTER)
      cells[positionX][positionY] = Cell.EMPTY;
  }
}
