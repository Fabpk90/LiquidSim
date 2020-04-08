//Some optimizations:
// Pre allocate the matrix used for updating the automaton
//use a automaton that starts at 1, to remove some checks in the loops


int cellsSize = 5; //must be a divisor of the window's size (r must be 0)
int cellAmountX;
int cellAmountY;

//Water properties
final float MaxMass = 1.0; //The normal, un-pressurized mass of a full water cell
final float MaxCompress = 0.02; //How much excess water a cell can store, compared to the cell above it
final float MinMass = 0.0001; //Ignore cells that are almost dry

boolean useNormalGravity = true;
float animStep = 0.5f;

Cell[][] cells;

float [][] cellsMass;

int stepCounter = 0;
int stepTick = 1; // 

void setup()
{
  size(400, 400);
  frameRate(60.0f);
  cellAmountX = width / cellsSize;
  cellAmountY = height / cellsSize;
  

  cells = new Cell[cellAmountX][cellAmountY];
  cellsMass = new float[cellAmountX][cellAmountY];
  
  initSim();
}

void initSim()
{
  for (int i = 0; i < cellAmountY; i++)
  {
    for (int j = 0; j < cellAmountX; j++)
    {
      cells[j][i] = Cell.EMPTY;
    }
  }
}

void draw()
{
  background(255);
  //if (stepCounter++ % stepTick == 0)
    updateAutomaton();

  drawAutomaton();
}

void updateAutomaton()
{

  //copying the actual masses of the automaton
  float[][] copiedMass = new float[cellsMass.length][];
  for (int i = 0; i < cells.length; i++)
  {
    float[] aMatrix = cellsMass[i];
    int aLength = aMatrix.length;
    
    copiedMass[i] = new float[aLength];
    
    System.arraycopy(aMatrix, 0, copiedMass[i], 0, aLength);
  }
  
  float flow = 0.0f;
  
  for(int x = 0; x < cellAmountX; ++x)
  {
     for(int y = 0; y < cellAmountY; ++y)
     {
         Cell c = cells[x][y];
         
         if(c != Cell.EMPTY && c != Cell.BLOCK)
         {
            float currentMass = cellsMass[x][y];
            if(useNormalGravity)
            {
               //can we analyse below and can share some water
              if(y + 1 < cellAmountY && cells[x][y + 1] != Cell.BLOCK)
              {
                //what happens if we transfer all the water ?
                flow = getStableState(currentMass + cellsMass[x][y + 1]);
                
                flow = constrain(flow, 0, currentMass);
                
                //smooth anim
                flow *= animStep;
                
                copiedMass[x][y + 1] += flow;
                copiedMass[x][y] -= flow;
                currentMass -= flow;
              }
            }
            else
            {
              if(y - 1 > 0 && cells[x][y - 1] != Cell.BLOCK)
              {
                //what happens if we transfer all the water ?
                flow = getStableState(currentMass + cellsMass[x][y - 1]);
                
                flow = constrain(flow, 0, currentMass);
                
                //smooth anim
                flow *= animStep;
                
                copiedMass[x][y - 1] += flow;
                copiedMass[x][y] -= flow;
                currentMass -= flow;
              }
            }
           
            
            //we check the left
            if(x - 1 > 0 && cells[x - 1][y] != Cell.BLOCK && currentMass > 0.0f)
            {
                flow = currentMass - cellsMass[x-1][y];
                
                //to make sure that we don't overshare or have less than our neighbor
                flow = constrain(flow, 0, currentMass);
                
                //smooth anim
                flow *= animStep;
              
                copiedMass[x - 1][y] += flow;
                copiedMass[x][y] -= flow;
                currentMass -= flow;
            }
            
            //we check the right
            if(x + 1 < cellAmountX && cells[x + 1][y] != Cell.BLOCK && currentMass > 0.0f)
            {
                flow = currentMass - cellsMass[x + 1][y];
                
                //to make sure that we don't overshare or have less than our neighbor
                flow = constrain(flow, 0, currentMass);
                
                //smooth anim
                flow *= animStep;
              
                copiedMass[x + 1][y] += flow;
                copiedMass[x][y] -= flow;
                currentMass -= flow;
            }
            
            if(useNormalGravity)
            {
                 //we check above, to simulate compressed liquid
               if (y - 1 > 0 && cells[x][y - 1] != Cell.BLOCK)
               {
                   flow = currentMass - getStableState(currentMass + cellsMass[x][y - 1]);
  
                   flow = constrain(flow, 0, currentMass);
                   
                   copiedMass[x][y] -= flow;
                   copiedMass[x][y - 1] += flow;   
                   currentMass -= flow;
               }  
            }
            else 
            {
               //we check above, to simulate compressed liquid
             if (y + 1 < cellAmountY && cells[x][y + 1] != Cell.BLOCK)
             {
                 flow = currentMass - getStableState(currentMass + cellsMass[x][y + 1]);

                 flow = constrain(flow, 0, currentMass);
                 
                 copiedMass[x][y] -= flow;
                 copiedMass[x][y + 1] += flow;   
                 currentMass -= flow;
             }  
            }
                 
         }
     }
  }
  
  //copying back the actual state of the masses
  for (int i = 0; i < cells.length; i++)
  {
    float[] aMatrix = copiedMass[i];
    int aLength = aMatrix.length;
    
    System.arraycopy(aMatrix, 0, cellsMass[i], 0, aLength);
  }
  
  //update the states of the automaton
  
  for(int x = 0; x < cellAmountX; ++x)
  {
     for(int y = 0; y < cellAmountY; ++y)
     {
        if(cells[x][y] != Cell.BLOCK)
        {
          cells[x][y] = cellsMass[x][y] > MinMass ? Cell.LIQUID : Cell.EMPTY;
        }
     }
  }
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

void drawAutomaton()
{
  for (int i = 0; i < cellAmountY; i++)
  {
    for (int j = 0; j < cellAmountX; j++)
    {
      Cell c = cells[j][i];
      if (c != Cell.EMPTY)
      {
        fill(c.getR(), c.getG(), c.getB());
        rect(j * cellsSize, i * cellsSize, cellsSize, cellsSize * -constrain(cellsMass[j][i], 0.0f, 1.0f));
      }
    }
  }
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
