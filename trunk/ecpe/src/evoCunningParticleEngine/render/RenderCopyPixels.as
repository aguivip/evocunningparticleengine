package evoCunningParticleEngine.render
{
	import evoCunningParticleEngine.light.Light;
	import evoCunningParticleEngine.material.IMaterialParticle;
	import evoCunningParticleEngine.material.meta.MetaParticle;
	import evoCunningParticleEngine.particle.Particle;
	
	import flash.display.BitmapData;
	import flash.geom.Vector3D;
	
	public class RenderCopyPixels extends Renderer
	{
		private var q0:Vector.<Particle> = new Vector.<Particle>(256, true);
		private var q1:Vector.<Particle> = new Vector.<Particle>(256, true);
		
		public function RenderCopyPixels()
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
			
			var s:int, k:int, i:int = 256;
			var offset:BitmapData, source:BitmapData;
			var meta:MetaParticle;
			var _fl:Light, light:Light;
			
			var material:IMaterialParticle;
			
			// Z-SORT
			/**
			 * Radix sort by Rob Bateman http://www.infiniteturtles.co.uk/blog/
			 * Modified slightly to get even more performance
			 **/
			
			var q0:Vector.<Particle> = this.q0.concat();
			var q1:Vector.<Particle> = this.q1.concat();
			
			var p:Particle, c:Particle = firstP;
			while (c) 
			{
				c.sort = q0[k = int(255 & -(c._z+10000))];
				q0[k] = c;
				c = c.next;
			}
			
			while (i--) 
			{
				c = q0[i];
				while (c) 
				{
					p = c.sort;
					c.sort = q1[k = int(65280 & -(c._z+10000)) >> 8];
					q1[k] = c;
					c = p;
				}
			}
			
			while (i++ < 255) 
			{
				c = q1[i];
				while (c) 
				{
					if(hasmodifier) modifier(c);
					
					if(c.functio != null) c.functio();
					
					material = c.material;
					
					if( 0 < (c._z = focalLength + c.x * m02 + c.y * m06 + c.z * m10 + m14) )
					{
						if((s = int( c._z * material.renderRange + (material.resolution * (1-c.size)) ) ) < c.material.resolution)
						{
							//s = s > material.resolution ? material.resolution : (s < 0 ? 0 : s) //unnecessary
							
							meta = material.meta[s];
							
							// LEARNED A LOT 3D TRICKS FROM JOA EBERT’S PARTICLE CODE
							// http://blog.joa-ebert.com/2009/04/03/massive-amounts-of-3d-particles-without-alchemy-and-pixelbender/
							
							_pt.x = ( w = focalLength / c._z ) * ( c.x * m00 + c.y * m04 + c.z * m08 + m12) + _tx - meta.split;
							
							_pt.y = w * ( c.x * m01 + c.y * m05 + c.z * m09 + m13 ) + _ty - meta.split;
							
							if(_pt.x > -meta.width && _pt.x < _w && _pt.y > -meta.width && _pt.y < _h)
							{
								// LIGTH
								c.light = hasLight ? material.lightResolution : 0;
								
								_fl = firstL;
								while(_fl)
								{
									dx = _fl.x-c.x;
									dy = _fl.y-c.y;
									dz = _fl.z-c.z;
									
									if((di = dx*dx + dy*dy + dz*dz) < _fl.power) c.light -= int(material.lightResolution * (1 - di * _fl.dive));
									
									_fl = _fl.next;
								}
								
								c.light = (c.light < 0) ? 0 : c.light;
								
								source = material.data[c.light][s];
								
								this._bit.copyPixels(source, meta.rect, _pt, null, null, false);
								
								//if(f.hasColor) // When will adobe fix this bug?
								//{
								//	offset = source;
								//	offset.applyFilter(offset, meta.rect, _point, c.cmf);
								//	this._bit.copyPixels(offset, meta.rect, _pt, null, null, false);
								//	offset.copyPixels(source, meta.rect, _point);
								//}
								//else
								//{
								//	this._bit.copyPixels(source, meta.rect, _pt, null, null, false);
								//}
								//
								//meta.rect.x = pt.x;
								//meta.rect.y = pt.y;
								//this.bit.fillRect(meta.rect, 0xFFFFFF);
							}
						}
					}
					
					c = c.sort;
				}
				
			}
		}
	}
}