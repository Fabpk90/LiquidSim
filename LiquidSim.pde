
int cellsSize = 10; //must be a divisor of size (r must be 0)
int cellAmountX;
int cellAmountY;

Cell[] cellsDefinition;

int[][] cells;

int stepCounter = 0;
int stepTick = 1; // 

void setup()
{
  size(400, 400);
  frameRate(60.0f);
  cellAmountX = width / cellsSize;
  cellAmountY = height / cellsSize;
  
  cellsDefinition = new Cell[Cell.values().length];
  
  cellsDefinition[0] = Cell.EMPTY;
  cellsDefinition[1] = Cell.QUARTER;
  cellsDefinition[2] = Cell.HALF;
  cellsDefinition[3] = Cell.FULL;
  cellsDefinition[4] = Cell.BLOCK;

  cells = new int[cellAmountX][cellAmountY];

  for (int i = 0; i < cellAmountY; i++)
  {
    for (int j = 0; j < cellAmountX; j++)
    {
      cells[j][i] = 0;
    }
  }
}

void draw()
{
  background(255);
  if (stepCounter++ % stepTick == 0)
    updateAutomaton();

  drawAutomaton();
}

void updateAutomaton()
{
  //copying the actual state of the automaton
  int[][] copiedState = new int[cells.length][];
  for (int i = 0; i < cells.length; i++)
  {
    int[] aMatrix = cells[i];
    int aLength = aMatrix.length;
    copiedState[i] = new int[aLength];
    System.arraycopy(aMatrix, 0, copiedState[i], 0, aLength);
  }

  for (int i = 0; i < cellAmountY; i++)
  {
    for (int j = 0; j < cellAmountX; j++)
    {
      Cell c = cellsDefinition[cells[j][i]];

      if (c != Cell.BLOCK && c != Cell.EMPTY)
      {
        if (c.getLevel() > 0)
        {
          //check if the cell can fall
          if ( i + 1 < cellAmountY && cellsDefinition[cells[j][i + 1]] == Cell.EMPTY)
          {
            copiedState[j][i + 1] = cells[j][i];
            copiedState[j][i] = 0;
          }
          //now we see if the water can distribute itself
          //we check on the left
          else if( j - 1 >= 0 
          && cellsDefinition[cells[j - 1][i]] != Cell.BLOCK
          && cells[j][i] > 1)
          {
            //if the cell can share water
            if(cells[j - 1][i] != 3
            && cells[j - 1][i] != cells[j][i])
            {
              copiedState[j][i]--;
              copiedState[j - 1][i]++;
            }
          }
        }
      }
    }
  }

  //copying back the actual state of the automaton
  for (int i = 0; i < cells.length; i++)
  {
    int[] aMatrix = copiedState[i];
    int aLength = aMatrix.length;
    System.arraycopy(aMatrix, 0, cells[i], 0, aLength);
  }
}

void drawAutomaton()
{
  for (int i = 0; i < cellAmountY; i++)
  {
    for (int j = 0; j < cellAmountX; j++)
    {
      Cell c = cellsDefinition[cells[j][i]];
      if (c != Cell.EMPTY)
      {
        fill(c.getR(), c.getG(),c.getB());
        rect(j * cellsSize, i * cellsSize, cellsSize, cellsSize * -c.getLevel());
      }
    }
  }
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
      cells[positionX][positionY] = 4;
    else if (mouseButton == RIGHT)
      cells[positionX][positionY] = 3; 
    else if (mouseButton == CENTER)
      cells[positionX][positionY] = 0;
  }
}
