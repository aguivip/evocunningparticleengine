package evoCunningParticleEngine.material
{
	import evoCunningParticleEngine.material.meta.MetaParticle;
	
	import flash.display.BitmapData;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;

	public class MaterialParticle implements IMaterialParticle
	{
		private var _data:Vector.<Vector.<BitmapData>>;
		private var _meta:Vector.<MetaParticle>;
		private var _resolution:int;
		private var _lightResolution:int;
		private var _range:int;
		
		public function MaterialParticle(bit:BitmapData, resolution:int = 128, lightResolution:int = 16, lightAmbient:Number = 0, range:int = 1000, maxSize:Number = 0, dof:Number = 0, r:Number = 1, g:Number = 1, b:Number = 1, brightness:Number = 0, alpha:Boolean = true)
		{
			this._resolution = int(resolution - 1);
			this._lightResolution = int(lightResolution - 1);
			this._range = range;
			var row:Vector.<BitmapData> = new Vector.<BitmapData>(resolution, true);
			
			var s:Number, w:Number;
			var source:BitmapData;
			var matrix:Matrix = new Matrix();
			
			if(maxSize == 0)
			{
				maxSize = bit.width;
			}else
			{
				s = maxSize / bit.width;
				matrix = new Matrix(s, 0, 0, s);
				var offset:BitmapData = bit.clone();
				bit = new BitmapData(maxSize, maxSize, alpha, 0);
				bit.draw(offset, matrix);
			}
			
			_meta = new Vector.<MetaParticle>(resolution);
			
			var margin:Number = dof; 
			
			// CREATE THE PARTICLE
			for(var i:int = 0; i < resolution; i++)
			{
				s = i/resolution;
				w = s*maxSize;
				
				source = row[i] = new BitmapData(1 + w + margin, 1 + w + margin, alpha, 0);
				
				_meta[i] = new MetaParticle();
				_meta[i].width = source.rect.width;
				_meta[i].split = source.rect.width >> 1; 
				_meta[i].rect = source.rect;
				
				matrix.d = matrix.a = s;
				matrix.tx = matrix.ty = dof >> 1;
				
				source.draw(bit, matrix, null, null, null, true);
				
				var blr:Number = (1 - Math.sin(Math.PI * s)) * dof;
				
				if(dof) source.applyFilter(source, source.rect, new Point(0,0), new BlurFilter(blr, blr, 3));
			}
			
			_meta.reverse();
			row.reverse();
			
			_data = new Vector.<Vector.<BitmapData>>(lightResolution, true);
			
			matrix = new Matrix();
			var ct:ColorTransform;
			var a:Number = 1;
			var am0:Number = 1 - lightAmbient;
			var am1:Number = lightAmbient;
			
			// CREATE THE LIGTHS
			var j:int, k:int;
			for(i = 0; i < lightResolution; i++)
			{
				_data[i] = new Vector.<BitmapData>(resolution, true);
				k = _data[i].length;
				
				a = am1 + (1 - (i / lightResolution)) * am0 + brightness;
				ct = new ColorTransform(a*r, a*g, a*b, 1);
				
				for(j = 0; j < k; j++)
				{
					_data[i][j] = new BitmapData(row[j].width, row[j].height, true, 0);
					_data[i][j].draw(row[j], matrix, ct);
				}
			}
			
		}
		
		public function get data():Vector.<Vector.<BitmapData>>
		{
			return _data;
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
			return _lightResolution;
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