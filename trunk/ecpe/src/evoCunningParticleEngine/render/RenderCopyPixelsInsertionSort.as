package evoCunningParticleEngine.render
{
	import evoCunningParticleEngine.light.Light;
	import evoCunningParticleEngine.material.IMaterialParticle;
	import evoCunningParticleEngine.material.meta.MetaParticle;
	import evoCunningParticleEngine.particle.Particle;
	
	import flash.display.BitmapData;
	import flash.geom.Vector3D;

	public class RenderCopyPixelsInsertionSort extends Renderer
	{
		public function RenderCopyPixelsInsertionSort()
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
			var offset:BitmapData, source:BitmapData;
			var meta:MetaParticle;
			var _fl:Light, light:Light;
			
			var material:IMaterialParticle;
			
			// Z-SORT
			var f:Particle = firstP;
			if(zSort)
			{
				var n:Particle, i:Particle, p:Particle, c:Particle;
				c = f.next;
				while(c) 
				{
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
			//trace("sorted----");
			firstP = f;
			while(f)
			{
				//trace(f.z)
				if(hasmodifier) modifier(f);
				
				if(f.functio != null) f.functio();
				
				material = f.material;
				
				f.light = hasLight ? material.lightResolution : 0;
				
				if( 0 < (f._z = focalLength + f.x * m02 + f.y * m06 + f.z * m10 + m14) )
				{
					s = int( f._z * material.renderRange + (material.resolution * (1-f.size)) ) ;
					
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