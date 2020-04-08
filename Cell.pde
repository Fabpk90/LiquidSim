public enum Cell
{
  EMPTY(255, 255, 255), LIQUID(0, 0, 255), BLOCK( 0, 0, 0);
  
  private final int r;
  private final int g;
  private final int b;
  
  private Cell(int r, int g, int b)
  {
     this.r =r;
     this.g = g;
     this.b = b;
  }
  
  public int getR()
  {
     return r; 
  }
  
  public int getG()
  {
     return g; 
  }
  
  public int getB()
  {
     return b; 
  }
};
