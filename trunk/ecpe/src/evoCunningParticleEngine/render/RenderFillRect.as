package evoCunningParticleEngine.render
{
	import evoCunningParticleEngine.light.Light;
	import evoCunningParticleEngine.material.IMaterialParticle;
	import evoCunningParticleEngine.material.meta.MetaParticle;
	import evoCunningParticleEngine.particle.Particle;
	
	import flash.geom.Vector3D;
	
	public class RenderFillRect extends Renderer
	{
		public function RenderFillRect()
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
			var dx:Number, dy:Number, dz:Number, di:Number, w:Number, m00:Number = _matrix.rawData[ 0x0 ], m01:Number = _matrix.rawData[ 0x1 ], m02:Number = _matrix.rawData[ 0x2 ], m04:Number = _matrix.rawData[ 0x4 ], m05:Number = _matrix.rawData[ 0x5 ], m06:Number = _matrix.rawData[ 0x6 ], m08:Number = _matrix.rawData[ 0x8 ], m09:Number = _matrix.rawData[ 0x9 ], m10:Number = _matrix.rawData[ 0xa ], m12:Number = _matrix.rawData[ 0xc ], m13:Number = _matrix.rawData[ 0xd ], m14:Number = _matrix.rawData[ 0xe ];
			
			var s:int;
			var meta:MetaParticle;
			var light:Light;
			
			var material:IMaterialParticle;
			
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
			
			var _fl:Light;
			
			firstP = f;
			while(f)
			{
				if(hasmodifier) modifier(f);
				
				//if(f.functio != null) f.functio();
				
				//f.light = hasLight ? material.lightResolution : 0;
				
				if( 0 < (f._z = focalLength + f.x * m02 + f.y * m06 + f.z * m10 + m14) )
				{
					material = f.material;
					
					s = int( f._z * material.renderRange + (material.resolution * (1-f.size)) ) ;
					
					s = s > material.resolution ? material.resolution : (s < 0 ? 0 : s);
					
					meta = material.meta[s];
					
					meta.rect.x = ( w = focalLength / f._z ) * ( f.x * m00 + f.y * m04 + f.z * m08 + m12) + _tx - meta.split;
					
					meta.rect.y = w * ( f.x * m01 + f.y * m05 + f.z * m09 + m13 ) + _ty - meta.split;
					
					if(meta.rect.x > -meta.width && meta.rect.x < _w && meta.rect.y > -meta.width && meta.rect.y < _h)
					{
						// LIGTH
						/*
						_fl = firstL;
						while(_fl)
						{
							dx = _fl.x-f.x;
							dy = _fl.y-f.y;
							dz = _fl.z-f.z;
							
							if((di = dx*dx + dy*dy + dz*dz) < _fl.power) f.light -= int(material.lightResolution * (1 - di * _fl.dive));
							
							_fl = _fl.next;
						}
						
						f.light = (f.light < 0) ? 0 : f.light;
						*/
						this._bit.fillRect(meta.rect, f.color);
						
					}
					
				}
				
				f = f.next;
			}
		}
	}
}