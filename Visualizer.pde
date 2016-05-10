import ddf.minim.*;
import ddf.minim.analysis.*;
import javax.swing.JFrame;

//PFrame f;
//secondApplet s;
Minim minim;
AudioInput song;
FFT fft;

float offset;
float offset2;
float offset3;
float offset4;


/////////////////////////////
float[][] maximum;
float total;
boolean test;
int T;
float total2;
/////////////////////////////

void setup()
{
  size(515, 200);
  //size( displayWidth, displayHeight);
  if (frame != null) {
    frame.setResizable(true);

    //PFrame f = new PFrame();
  }

  minim = new Minim(this);

  song= minim.getLineIn(Minim.STEREO, 1024);
  // specify 512 for length of sample buffers                       ^
  // default buffer size is 1024                                    |

  fft = new FFT(song.bufferSize(), song.sampleRate());

  //------------------------------------beat detection setup
  maximum = new float[64][45];
  for (int y=0; y <45; y++)
  {
    for (int x=0; x < 64; x++)
    {
      maximum[x][y] = 0.0;
    }
  }
  //------------------------------------beat detection end
}

void draw()
{
  offset =6; // frquency band    bigger number means bigger symbol       2
  offset2 =6;  // sound wave                                             3
  offset3 = 4;   // bar                                                300
  offset4 = 4;  //circle                                               300

  background(1, 13, 21, 255);

  fft.forward(song.mix);  // 'mix' is the type of buffer, can be left or right too
  //will perform an FFT on the song's buffer


  for (int i = 0; i < song.bufferSize() -1; i++)    //sound wave
  {
    stroke(0, 42, 86, 180);
    line(i, 100, i, 50 + song.left.get(i)*50 * offset2/5);
    stroke(0, 42, 86, 90);
    line(i, 100, i, 150 + song.right.get(i)*50 * offset2/5);
  }

  float tall = 0;   //constant used to scale most shapes
  
  
  stroke(130, 202, 253, 255);
  for (int i = 0; i < fft.specSize()-128; i++)    // frequency band
  {
    line(i, height/2 - fft.getBand(i)*2*(offset/10), i, height/2 + fft.getBand(i)*2*(offset/10));
    tall = tall + fft.getBand(i)/10;
  }



  stroke(0, 126, 255, 255);       // bar
  fill(0, 126, 255, 128);
  rect(width/2 - 10, height - (tall* tall)* offset3/200, 20, (tall* tall)*offset3/200);



  stroke(0, 210, 255, 255);    // blue circle
  fill(0, 210, 255, 128);
  ellipse(width/2 + width/4, height/2, (tall* tall)* offset4/400, (tall* tall)* offset4/400);




  //beat detection------------------------------------------------------
  for (int j = 0; j < 64; j++) //Shifts the array values
  {
    for (int i = 0; i < 44; i++)
    {
      maximum[j][i] = maximum[j][i+1];
    }
  }

  int change = 0;
  int counter = 1;
  int counter2 = 0;
  total = 0;  //With this here, as the frequency increases it has to exceed the average energy of all lower requencies combined
  for (int i = 0; i < 64; i++) // Adds new frequency value
  {
    int shift = 0;  
    if ( change == 0) {
      counter++;
    }
    if ( i == 63) {
      counter= fft.specSize() - counter2;
    }

    for (int j = 0; j < counter; j++)
    {
      shift = counter2;
      //int shift = (fft.specSize()-128)/64*i;
      total = total + sq(fft.getBand(j + shift));
    }

    counter2 = counter2 + counter;

    maximum[i][44] = total;

    if (change < 4) {
      change++;
    } else {
      change= 0;
    }
  } 

  test = false;
  T = 0;
  total2 = 0;
  for (int i = 0; i <64; i++) // Tests new value against avarage
  {
    total = 0;
    for (int j = 0; j < 44; j++)
    {
      total = total + maximum[i][j];
    }
    total = total/ 44;
    total2 = total2 + total;
    if (maximum[i][44] > total)
    { 
      test = true;
      T = int((1/total2) * 10000);
    }
  }
  if (test) {
    stroke(200, 0, 40, 255);
    fill(200, 0, 40, 90);
    ellipse(width/2, height/2, 100, 100);
  }
  //beat detection ends----------------------------------------------------

  //s.background(0);
}





void stop()
{
  minim.stop();

  super.stop();
}






//public class PFrame extends JFrame{
//  public PFrame(){
//    setBounds(400,displayHeight/2,400,300);
//    s = new secondApplet();
//    add(s);
//    s.init();
//    show();
//  }
//}

//public class secondApplet extends PApplet{
//  public void setup(){
//    size(400,300);
//  }
//  public void draw(){
//  }
//}