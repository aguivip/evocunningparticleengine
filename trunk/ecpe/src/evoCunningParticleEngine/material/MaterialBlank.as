package evoCunningParticleEngine.material
{
	import evoCunningParticleEngine.material.meta.MetaParticle;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	public class MaterialBlank implements IMaterialParticle
	{
		private var _meta:Vector.<MetaParticle>;
		private var _resolution:int;
		private var _range:int;
		
		public function MaterialBlank(size:int = 128, resolution:int = 128, range:int = 1000)
		{
			this._resolution = int(resolution - 1);
			this._range = range;
			
			var s:Number, w:Number;
			
			_meta = new Vector.<MetaParticle>(resolution);
			
			// CREATE THE PARTICLE
			for(var i:int = 0; i < resolution; i++)
			{
				s = i/resolution;
				w = s*size;
				
				_meta[i] = new MetaParticle();
				_meta[i].width = w;
				_meta[i].split = w >> 1; 
				_meta[i].rect = new Rectangle(0,0,1 + w,1 + w)
				
			}
			
			_meta.reverse();
			
		}
		
		public function get data():Vector.<Vector.<BitmapData>>
		{
			return null;
		}
		public function get meta():Vector.<MetaParticle>
		{
			return _meta;
		}
		public function get resolution():int
		{
			return _resolution;
		}
		public function get lightResolution():int
		{
			return 0;
		}
		public function get range():int
		{
			return _range;
		}
		
		
		private var _renderrange:Number;
		public function set renderRange(value:Number):void
		{
			_renderrange = value;
		}
		
		public function get renderRange():Number
		{
			return _renderrange;
		}
		
	}
}