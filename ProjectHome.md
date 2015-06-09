## Create great amount of 3D particles in flash. ##

Qualities:
  * Depth of field
  * Image sequence
  * Fast as with actionscript can be


## HelloWorld ##

particleMatMovie = new MaterialParticleMovie(new ParticleMovieImageSequence(),128,64,0,60000, 96, 8,1, 1, 1, 0, true);

engine = new CunningParticleEngine(bit, new RenderCopyPixels());

engine.modifier = this.modifier;

engine.addParticles(5000, particleMatMovie);

light = engine.addLight(150000000); //power

engine.render();


## Engine in action ##
http://www.simppa.fi/blog/category/evocunningparticleengine/