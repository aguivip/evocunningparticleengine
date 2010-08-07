package evoCunningParticleEngine.render
{
	import evoCunningParticleEngine.light.Light;
	import evoCunningParticleEngine.material.meta.MetaParticle;
	import evoCunningParticleEngine.particle.Particle;
	
	import flash.display.BitmapData;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	public class RenderSetPixel extends Renderer
	{
		public function RenderSetPixel()
		{
		}
		
		override protected function initialize() : void
		{
			
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
			
			firstP = f;
			while(f)
			{
				if(hasmodifier) modifier(f);
				
				if( 0 < (f._z = focalLength + f.x * m02 + f.y * m06 + f.z * m10 + m14) )
				{
					this._bit.setPixel(int( ( w = focalLength / f._z ) * ( f.x * m00 + f.y * m04 + f.z * m08 + m12) + _tx ), int( w * ( f.x * m01 + f.y * m05 + f.z * m09 + m13 ) + _ty ), f.color);
				}
				
				f = f.next;
			}
		}
	}
}