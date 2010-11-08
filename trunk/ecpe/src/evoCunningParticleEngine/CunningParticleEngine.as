package evoCunningParticleEngine
{
	import evoCunningParticleEngine.camera.Camera3D;
	import evoCunningParticleEngine.light.Light;
	import evoCunningParticleEngine.material.IMaterialParticle;
	import evoCunningParticleEngine.particle.Particle;
	import evoCunningParticleEngine.render.RenderCopyPixels;
	import evoCunningParticleEngine.render.Renderer;
	
	import flash.display.BitmapData;
	import flash.geom.PerspectiveProjection;

	public class CunningParticleEngine
	{
		public var camera:Camera3D;
		public var bit:BitmapData;
		
		public var particles:Vector.<Particle>;
		public var lights:Vector.<Light>;
		
		public var particleCount:int = 0;
		
		public var materials:Vector.<IMaterialParticle>;
		
		private var _renderer:Renderer;
		public function get renderer():Renderer
		{
			return _renderer;
		}

		public function set renderer(value:Renderer):void
		{
			_renderer = value;
			_renderer.setup(this.bit, this.camera);
			this.render = _renderer.renderFunction;
		}
		
		
		private var perspectiveProjection:PerspectiveProjection;
		private var _fl:Number;
		public function set fl(value:Number):void
		{
			_fl = value;
			if(!perspectiveProjection) perspectiveProjection = new PerspectiveProjection();
			perspectiveProjection.fieldOfView = value;
			renderer.focalLength = perspectiveProjection.focalLength;
		}
		public function get fl():Number
		{
			return _fl;
		}
		
		
		public function set modifier(value:Function):void
		{
			this.renderer.modifier = value;
			this.renderer.hasmodifier = Boolean(value);
		}
		public function get modifier():Function
		{
			return this.renderer.modifier;
		}
		
		
		public function get zSort():Boolean
		{
			return this.renderer.zSort;
		}
		public function set zSort(value:Boolean):void
		{
			this.renderer.zSort = value;
		}
		
		
		public function CunningParticleEngine(bit:BitmapData, renderer:Renderer = null)
		{
			this.camera = new Camera3D();
			
			this.bit = bit;
			
			this.renderer = (renderer != null) ? renderer : new RenderCopyPixels();
			
			this.fl = 60;
		}
		
		
		/**
		 * ADD PARTICLE
		 **/
		public function addParticles(count:int, material:IMaterialParticle = null, particleClass:Class = null):void
		{
			if(particleClass == null) particleClass = Particle;
			
			if(material)
			{
				if(!materials) materials = new Vector.<IMaterialParticle>();
				var mat:IMaterialParticle;
				materials.push(mat = material);
				mat.renderRange = mat.resolution / mat.range;
			}
			
			var partcl:Vector.<Particle> = new Vector.<Particle>(count);
			var l:int = int(count-1);
			for(var i:int = l; i > -1; i--)
			{
				partcl[i] = new particleClass();
				partcl[i].material = mat;
				partcl[i].i = particleCount;
				if(i < l) 
				{
					partcl[i].next = partcl[int(i+1)];
					partcl[int(i+1)].prev = partcl[i];
				}
				particleCount++;
			}
			
			if(!particles) 
			{
				particles = new Vector.<Particle>();
			}
			else
			{
				var pc:int = int(particles.length-1);
				particles[pc].next = partcl[0];
				partcl[0].prev = particles[pc];
			}
			
			particles = particles.concat(partcl);
			
			renderer.firstP = particles[0];
			renderer.particles = particles;
		}
		
		
		/**
		 * ADD LIGHT
		 **/
		public function addLight(power:Number = 10000, x:Number = 0, y:Number = 0, z:Number = 0):Light
		{
			if(!lights) lights = new Vector.<Light>();
			var l:Light = new Light(power, x, y, z);
			if(!renderer.firstL) {
				renderer.firstL = l;
			}else{
				lights[int(lights.length-1)].next = l;
			}
			lights.push(l);
			this.renderer.hasLight = true;
			return l;
		}
		
		/**
		 * REMOVE LIGHTS
		 **/
		public function removeAllLights():void
		{
			var light:Light;
			var l:int = lights.length;
			for(var i:int = 0; i < l; i++)
			{
				light = lights[i];
				light.next = null;
				light = null;
			}
			
			lights = null;
			this.renderer.firstL = null;
			this.renderer.hasLight = false;
		}
		
		
		/**
		 * RENDER FUNCTION
		 **/
		public var render:Function;
		
		
		/**
		 * DISPOSE & REMOVE
		 **/
		public function dispose():void
		{
			if(particles)
			{
				var l:int = particles.length;
				var particle:Particle;
				for(var i:int = 0; i < l; i++)
				{
					particle = particles[i];
					particle.material = null; 
					particle.sort = null;
					particle.functio = null;
					particle.next = null;
					particle.prev = null;
				}
				particles = null;
			}
			particleCount = 0;
			this.renderer.firstP = null;
			this.renderer.particles = null;
			
			materials = null;
			
			removeAllLights();
		}
		
		public function remove():void
		{
			dispose();
			bit = null;
		}
	}
}