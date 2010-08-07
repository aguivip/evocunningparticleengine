package evoCunningParticleEngine.render
{
	import evoCunningParticleEngine.camera.Camera3D;
	import evoCunningParticleEngine.light.Light;
	import evoCunningParticleEngine.material.IMaterialParticle;
	import evoCunningParticleEngine.particle.Particle;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix3D;
	import flash.geom.Point;

	public class Renderer
	{
		protected const _matrix:Matrix3D = new Matrix3D();
		protected const _matrixRotation:Matrix3D = new Matrix3D();
		protected const _pt:Point = new Point();
		protected const _point:Point = new Point();
		
		protected var _w:int;
		protected var _h:int;
		protected var _tx:Number = 0;
		protected var _ty:Number = 0;
		
		protected var _bit:BitmapData;
		protected var _camera:Camera3D;
		
		public var firstP:Particle;
		public var firstL:Light;
		
		public var focalLength:Number;
		public var hasLight:Boolean = false;
		public var zSort:Boolean = true;
		public var hasmodifier:Boolean = false;
		public var modifier:Function = null;
		
		//public var material:IMaterialParticle;
		
		public var renderFunction:Function;
		public var particles:Vector.<Particle>;
		
		public function Renderer()
		{
		}
		
		public function setup(bit:BitmapData, camera:Camera3D):void
		{
			this._bit = bit;
			this._w = bit.width;
			this._h = bit.height;
			this._tx = bit.width >> 1;
			this._ty = bit.height >> 1;
			this._camera = camera;
			this.renderFunction = this.render;
			
			initialize();
		}
		
		protected function initialize():void
		{
			
		}
		
		public function render():void
		{
			throw('--#Renderer[render]:: this method[render] must be overridden in implementation.');
		}
		
	}
}