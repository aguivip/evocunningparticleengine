package evoCunningParticleEngine.render
{
	import evoCunningParticleEngine.light.Light;
	import evoCunningParticleEngine.material.IMaterialParticle;
	import evoCunningParticleEngine.material.meta.MetaParticle;
	import evoCunningParticleEngine.particle.Particle;
	
	import flash.display.BitmapData;
	import flash.geom.Vector3D;
	
	public class RenderCopyPixelsVectorBased extends Renderer
	{
		private var q0:Vector.<Particle> = new Vector.<Particle>(256, true);
		private var q1:Vector.<Particle> = new Vector.<Particle>(256, true);
		
		public function RenderCopyPixelsVectorBased()
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
			
			var s:int, k:int, i:int = 0;//256;
			var offset:BitmapData, source:BitmapData;
			var meta:MetaParticle;
			var _fl:Light, light:Light;
			
			var material:IMaterialParticle;
			
			// Z-SORT
			/**
			 * Radix sort of Rob Bateman http://www.infiniteturtles.co.uk/blog/
			 * Modified slightly to gain performance
			 **/
			
			//var time:int = getTimer();
			//38 39
			var q0:Vector.<int> = new Vector.<int>(256, true);
			var q1:Vector.<int> = new Vector.<int>(256, true);
			var np0:Vector.<int> = new Vector.<int>(particles.length + 1, true);
			var np1:Vector.<int> = new Vector.<int>(particles.length + 1, true);
			var data:Vector.<int> = new Vector.<int>(particles.length, true);
			
			var c:Particle;
			
			var length:int = particles.length;
			var j:int = 0;
			
			while (i < length) 
			{
				c = particles[i];
				np0[int(i+1)] = q0[k = (255 & (data[i] = int(c._z+10000)))];
				q0[k] = int(++i);
			}
			
			i = 0;
			while (i < 256) 
			{
				j = q0[i];
				while (j) {
					np1[j] = q1[k = (65280 & data[int(j-1)]) >> 8];
					j = np0[q1[k] = j];
				}
				i++
			}
			
			i = 256;
			k = 0;
			while (i--)
			{
				j = q1[i];
				while (j) 
				{
					c = particles[int(j-1)];
					
					material = c.material;
					
					if(hasmodifier) modifier(c);
					
					if(c.functio != null) c.functio();
					
					c.light = hasLight ? material.lightResolution : 0;
					
					if( 0 < (c._z = focalLength + c.x * m02 + c.y * m06 + c.z * m10 + m14) )
					{
						s = int( c._z * material.renderRange + (material.resolution * (1-c.size)) ) ;
						
						s = s > material.resolution ? material.resolution : (s < 0 ? 0 : s);
						
						meta = material.meta[s];
						
						_pt.x = ( w = focalLength / c._z ) * ( c.x * m00 + c.y * m04 + c.z * m08 + m12) + _tx - meta.split;
						
						_pt.y = w * ( c.x * m01 + c.y * m05 + c.z * m09 + m13 ) + _ty - meta.split;
						
						if(_pt.x > -meta.width && _pt.x < _w && _pt.y > -meta.width && _pt.y < _h)
						{
							// LIGTH
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
							
							//if(f.hasColor)
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
					
					j = np1[j];
				}
			}
					
			
			
			
			/*
			firstP = f;
			while(f)
			{
			if(hasmodifier) modifier(f);
			
			if(f.functio != null) f.functio();
			
			f.light = hasLight ? material.lightResolution : 0;
			
			if( 0 < (f._z = focalLength + f.x * m02 + f.y * m06 + f.z * m10 + m14) )
			{
			s = int( f._z * range + (material.resolution * (1-f.size)) ) ;
			
			s = s > material.resolution ? material.resolution : (s < 0 ? 0 : s);
			
			meta = material.meta[s];
			
			_pt.x = ( w = focalLength / f._z ) * ( f.x * m00 + f.y * m04 + f.z * m08 + m12) + _tx - meta.split;
			
			_pt.y = w * ( f.x * m01 + f.y * m05 + f.z * m09 + m13 ) + _ty - meta.split;
			
			if(_pt.x > -meta.width && _pt.x < _w && _pt.y > -meta.width && _pt.y < _h)
			{
			// LIGTH
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
			
			source = material.data[f.light][s];
			
			this._bit.copyPixels(source, meta.rect, _pt, null, null, false);
			
			//if(f.hasColor)
			//{
			//	offset = source;
			//	offset.applyFilter(offset, meta.rect, _point, f.cmf);
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
			
			f = f.next;
			}
			//*/
		}
	}
}