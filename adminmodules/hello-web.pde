int i = 0; 
void setup()
{
	size(500, 500); 
	background(255);
	smooth();
	strokeWeight(15);
	frameRate(24);
} 

void draw()
{
	stroke(random(50), random(500), random(500), 100);
	line(i, 0, random(0, width), height);
	if (i < width)
	{
		i++;
	} else
	{
	i = 0; 
	}
}

