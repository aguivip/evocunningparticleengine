package evoCunningParticleEngine.render
{
	import evoCunningParticleEngine.particle.Particle;
	
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	public class RenderSetVector extends Renderer
	{
		private var buffer:Vector.<uint>;
		private var buffer_offset:Vector.<uint>;
		private var rect:Rectangle;
		private var bufferWidth:int;
		private var bufferMax:int;
		private var bgColor:uint;
		public function RenderSetVector(bgColor:uint = 0x000000)
		{
			this.bgColor = bgColor;
		}
		
		override protected function initialize() : void
		{
			buffer = new Vector.<uint>(_bit.width * _bit.height);
			buffer_offset = new Vector.<uint>(_bit.width * _bit.height, true);
			bufferMax = buffer.length;
			for(var i:int = 0; i < bufferMax; ++i)
			{
				buffer[i] = buffer_offset[i] = bgColor;
			}
			this.bufferWidth = _bit.width;
			this.rect = _bit.rect;
		}
		
		override public function render() : void
		{
			// CAMERA MATRIX
			_matrix.identity();
			
			_matrix.position = _camera;
			
			_matrixRotation.identity();
			var compose:Vector.<Vector3D> = _matrixRotation.decompose();
			compose[1].x = _camera.rotateY;
			compose[1].y = _camera.rotateX;
			compose[1].z = _camera.rotateZ;
			_matrixRotation.recompose(compose);
			
			_matrix.append(_matrixRotation);
			
			
			// RENDER 3D
			var w:Number, m00:Number = _matrix.rawData[ 0x0 ], m01:Number = _matrix.rawData[ 0x1 ], m02:Number = _matrix.rawData[ 0x2 ], m04:Number = _matrix.rawData[ 0x4 ], m05:Number = _matrix.rawData[ 0x5 ], m06:Number = _matrix.rawData[ 0x6 ], m08:Number = _matrix.rawData[ 0x8 ], m09:Number = _matrix.rawData[ 0x9 ], m10:Number = _matrix.rawData[ 0xa ], m12:Number = _matrix.rawData[ 0xc ], m13:Number = _matrix.rawData[ 0xd ], m14:Number = _matrix.rawData[ 0xe ];
			
			// Z-SORT
			var f:Particle = firstP;
			if(zSort)
			{
				var n:Particle, i:Particle, p:Particle, c:Particle;
				c = f.next;
				while(c) {
					n = c.next;
					p = c.prev;
					if (c._z > p._z) {
						i = p;
						while(i.prev) {
							if (c._z > i.prev._z) {
								i = i.prev;
							}else{
								break;
							}
						}
						if (n) {
							p.next = n;
							n.prev = p;
						}
						else {
							p.next = null;
						}
						if (i == f) {
							c.prev = null;
							c.next = i;
							i.prev = c;
							f = c;
						}else{
							c.prev = i.prev;
							i.prev.next = c;
							c.next = i;
							i.prev = c;
						}
					}
					c = n;
				}
			}
			
			
			buffer.length = 0;
			buffer = buffer.concat(buffer_offset);
			
			var x:int, y:int;
			var bufferIndex:int, xi:int, yi:int;
			firstP = f;
			while(f)
			{
				if(hasmodifier) modifier(f);
				
				if( 0 < (f._z = focalLength + f.x * m02 + f.y * m06 + f.z * m10 + m14) )
				{
					x = int( ( w = focalLength / f._z ) * ( f.x * m00 + f.y * m04 + f.z * m08 + m12) + _tx );
					y = int( w * ( f.x * m01 + f.y * m05 + f.z * m09 + m13 ) + _ty );
						
					if(x > 0 && x < _w && y > 0 && y < _h)
					{
						if(-1 < ( bufferIndex = int( x + y * bufferWidth ) ) && bufferIndex < bufferMax) buffer[bufferIndex] = f.color;
					}
				}
				
				f = f.next;
			}
			
			this._bit.setVector(rect, buffer);
			
		}
	}
}