package evoCunningParticleEngine.particle
{
	import evoCunningParticleEngine.material.IMaterialParticle;
	
	public class Particle
	{
		public var next:Particle, prev:Particle, sort:Particle;
		public var x:Number = 1, y:Number = 1, z:Number = 1;
		public var ox:Number, oy:Number, oz:Number;
		public var dx:Number, dy:Number, dz:Number;
		public var count:int;
		public var _z:Number = 1000;
		public var size:Number = 1;
		public var material:IMaterialParticle;
		public var light:int = 128;
		public var i:int;
		public var functio:Function = null;
		
		/**
		 *  UNIQUE COLOR OF THIS PARTICLE
		 **/
		///*
		//public var cmf:ColorMatrixFilter;
		//public var hasColor:Boolean = false;
		
		/*
		private var colorMatrix:Array = new Array(20);
		
		private static var r_lum:Number = 0.212671;
		private static var g_lum:Number = 0.715160;
		private static var b_lum:Number = 0.072169;
		
		
		private var _colorAmount:Number = 1;
		public function get colorAmount():Number
		{
		return _colorAmount;
		}
		
		public function set colorAmount(v:Number):void
		{
		_colorAmount = v;
		if(color < 0) this.color = _color;
		}
		*/
		
		
		private var _color:uint = 0xFFFFFF;
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(v:uint):void
		{
			_color = v;
			
		}
		
		/*
		public function set color(v:uint):void
		{
			if(v < 0)
			{
				hasColor = false;
				cmf = null;
				_color = 0xFFFFFF;
			}
			else
			{
				if(!cmf) cmf = new ColorMatrixFilter();
				
				var r:Number = ( ( v >> 16 ) & 0xff ) / 255;
				var g:Number = ( ( v >> 8  ) & 0xff ) / 255;
				var b:Number = (   v         & 0xff ) / 255;
				
				var amount:Number = _colorAmount;
				var inv_amount:Number = 1 - amount;
				
				colorMatrix.length = 0;
				colorMatrix.push(	inv_amount + amount*r*r_lum, amount*r*g_lum,  amount*r*b_lum, 0, 0,
									amount*g*r_lum, inv_amount + amount*g*g_lum, amount*g*b_lum, 0, 0,
									amount*b*r_lum,amount*b*g_lum, inv_amount + amount*b*b_lum, 0, 0,
									0 , 0 , 0 , 1, 0 );
				
				cmf.matrix = colorMatrix;
				
				_color = v;
				
				hasColor = true;
			}
		}
		//*/
	}
}