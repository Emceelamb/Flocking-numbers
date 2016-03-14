//Create an array of mosquitoes.
Mosquito[] m;
    int counter;
    int counter2;
    PFont font;
void setup()
{
//Set our window size.
size(500,500);
surface.setResizable(true);
//Set our background color white.
background(255);
//Remember to smooth;
//Even with pngs, it looks much, much better.
smooth();
frameRate(40);
//Initialize our mosquito array
//Change the [100] to increase the swarm.
m=new Mosquito[30];
//Initialize all of the mosquitoes in the array.
for(int i=0; i< m.length;i++)
{
m[i] = new Mosquito();
}
}

void draw()
{
//Don’t forget to redraw the background.
background(255);

//Call the move() function of our Mosquito object
//That’s it’s “draw()” function.
for(int i=0; i< m.length;i++)
{
m[i].move();
}

}

//We set the target position with the mouse
//The mouseX and mouseY are variables that
//throw straight the position of the mouse in the window.

void mouseDragged()
{
//We have a bunch of mosquito trolls
//we have to let all know the new target.
if (mousePressed == true){
for(int i=0; i< m.length;i++)
{
m[i].setTarget(pmouseX,mouseY);
}
}
}
class Mosquito
{
//There are our vectors
//we’ll use them to move our mosquito
//With this object we’ll make an array
//of mosquitos, and let the math do the work.
PVector p,v,a,z;

//This vector will be the position the mosquito
//will want to fly to.
PVector target;

//We need to position the mosquito somewhere
int startx,starty,startz;

//Variables to calculate our starting position.
//The s will be the size of the mosquito.
int w,h,s;

//Load a troll image.
String [] troll  = {
      "11111111", "22222222", "33333333", "44444444", "55555555"
    };


PImage medical;

Mosquito()
{
//We’ll use this image as our mosquito.
//the width and height of our window
w = width;
h = height;
//the size of our mosquito.
s = 4;

//We use temporary x and y position to start the mosquito.
startx = round(random(s,w-s));
starty = round(random(s,h-s));
startz= round(random(-100,100));
//set the postiion vector with our coordinates.
p=new PVector(startx,starty,startz);
//Start with no velocity, acceleration will take care of that.
v=new PVector(0,0,0);
//Start with no accelartion, our target function will take care of that.
a=new PVector(0,0,0);

//Our target position
//we start with the center.
target=new PVector(w/2,h/2,0);
}

//This function is the equivalent of our draw() function.
void move()
{
//We call the target() function to calculate the acceleration needed
//to get to your target.
target();
//Once we got our acceleration we add it to the velocity.
v.add(a);
v.limit(11);
//finally we add the velocity to the position.
p.add(v);

//Eliminate the particle stroke.
noStroke();
//fill the particle to black.
fill(0);
//Draw our mosquito with our position vector
//and our s variable that indicates the size.
//Uncomment the ellipse for a traditional mosquito
//ellipse(p.x,p.y,s,s);

font = createFont("Lucida Console", 24);
textFont(font);


//place our troll image
    if (counter < 4 ) {
       counter++;}
       else {
         counter=0;
       }
     if (counter/8 == 1) 
       counter2++;
       
//text(troll[int(random(5))],p.x,p.y);
text(troll[counter],p.x,p.y);

}

//This function will be used to change
//the vector with the target location.
void setTarget(int inX, int inY)
{
//We recieve x and y and set the vector with those values.
target.set(inX,inY);
}

void target()
{
//We create a temp vector to calculate a vector
//from our position towards the target.
PVector temp;
temp = PVector.sub(target,p);
//Normalize the vector.
temp.normalize();
//Multimply times .5.
temp.mult(.3);
//set our acceleration to that vector.
a = temp;
//Because the acceleration is too big
//the velocity is too big, so it goes so fast
//when it reaches the target position that doesn’t have time to slow down
//That’s how we simulate an axious personality.
}
}