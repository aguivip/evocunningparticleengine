package evoCunningParticleEngine.render
{
	import evoCunningParticleEngine.particle.Particle;
	
	import flash.geom.Vector3D;
	
	public class RenderConnect2D extends Renderer
	{
		private var connectRange:int = 1000;
		
		private var posGrid:Vector.<Vector.<Particle>>;
		private var gridSize:int = 64;
		private var loopsize:int;
		
		private var colors:Vector.<uint>;
		
		public function RenderConnect2D()
		{
		}
		
		override protected function initialize() : void
		{
			posGrid = new Vector.<Vector.<Particle>>();
			
			loopsize = 0;
			for(var _x:int = 0; _x < gridSize+1; _x++)
			{
				for(var _y:int = 0; _y < gridSize+1; _y++)
				{
					posGrid[loopsize] = new Vector.<Particle>();
					loopsize++;
				}
			}
			
			colors = new Vector.<uint>(connectRange);
			var col:Number;
			var r:int, g:int, b:int;
			for(var i:int = 0; i < connectRange; i++)
			{
				col = 1 - (i / connectRange);
				r = col * 255 * 1 //(128 + 127*Math.sin(i*.001 * Math.PI));
				g = col * 255 * .9 //(128 + 127*Math.cos(i*.001 * Math.PI));
				b = col * (128 + 127*Math.cos(i*.001 * Math.PI));
				colors[i] = (r << 16 | g << 8 | b)
			}
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
				var n:Particle, e:Particle, p:Particle, c:Particle;
				c = f.next;
				while(c) {
					n = c.next;
					p = c.prev;
					if (c._z > p._z) {
						e = p;
						while(e.prev) {
							if (c._z > e.prev._z) {
								e = e.prev;
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
						if (e == f) {
							c.prev = null;
							c.next = e;
							e.prev = c;
							f = c;
						}else{
							c.prev = e.prev;
							e.prev.next = c;
							c.next = e;
							e.prev = c;
						}
					}
					c = n;
				}
			}
			
			var x:int, y:int, pos:int, xp:int, yp:int, yp0:int, yp1:int;
			
			firstP = f;
			while(f)
			{
				if(hasmodifier) modifier(f);
				
				if( 0 < (f._z = focalLength + f.x * m02 + f.y * m06 + f.z * m10 + m14) )
				{
					f.dx = int( ( w = focalLength / f._z ) * ( f.x * m00 + f.y * m04 + f.z * m08 + m12) + _tx );
					f.dy = int( w * ( f.x * m01 + f.y * m05 + f.z * m09 + m13 ) + _ty );
					
					if(f.dx > 0 && f.dx < _w && f.dy > 0 && f.dy < _h)
					{
						// PLACE ON GRID
						
						xp = int(f.dx / _w * gridSize);
						yp = int(f.dy / _h * gridSize);
						
						pos = int(xp + yp * gridSize);
						
						posGrid[pos].push(f);
						
						if(xp > 0)
						{
							posGrid[int(pos-1)].push(f);
						}
						
						if(xp < gridSize)
						{
							posGrid[int(pos+1)].push(f);
						}
						
						if(yp > 0)
						{
							yp0 = int(pos-gridSize);
							posGrid[yp0].push(f);
							
							if(xp > 0)
							{
								posGrid[int(yp0-1)].push(f);
							}
							if(xp < gridSize)
							{
								posGrid[int(yp0+1)].push(f);
							}
						}
						
						if(yp < gridSize)
						{
							yp1 = int(pos+gridSize);
							posGrid[yp1].push(f);
							
							if(xp > 0)
							{
								posGrid[int(yp1-1)].push(f);
							}
							if(xp < gridSize)
							{
								posGrid[int(yp1+1)].push(f);
							}
						}
						
						//this._bit.setPixel(f.dx, f.dy, f.color);
					}
				}
				
				f = f.next;
			}
			
			var o:Particle;
			var dist:Number, dx:Number, dy:Number;
			var l:int, j:int, k:int;
			for(var i:int = 0; i < loopsize; ++i)
			{
				l = posGrid[i].length;
				
				for(j = 0; j < l; ++j)
				{
					p = posGrid[i][j];
					p.count = 0;
					
					for(k = 0; k < l; ++k)
					{
						if(k > j)
						{
							o = posGrid[i][k];
							
							if(o.count > 1) break;
							dx = o.dx - p.dx;
							dy = o.dy - p.dy;
							
							if((dist = dx*dx + dy*dy) < connectRange)
							{
								p.count++;
								o.count++;
								efla(p.dx, p.dy, o.dx, o.dy, colors[int(dist)]);
							}
							
						}
					}
					
				}
				
				if(l) posGrid[i].length = 0;
			}
			
		}
		
		
		private function efla(x:int, y:int, x2:int, y2:int, color:uint):void
		{
			var shortLen:int = y2-y;
			var longLen:int = x2-x;
			
			if((shortLen ^ (shortLen >> 31)) - (shortLen >> 31) > (longLen ^ (longLen >> 31)) - (longLen >> 31))
			{
				shortLen ^= longLen;
				longLen ^= shortLen;
				shortLen ^= longLen;
				
				var yLonger:Boolean = true;
			}
			else
			{
				yLonger = false;
			}
			
			var inc:int = longLen < 0 ? -1 : 1;
			
			var multDiff:Number = longLen == 0 ? shortLen : shortLen / longLen;
			
			if (yLonger) 
			{
				for (var i:int = 0; i != longLen; i += inc) 
				{
					this._bit.setPixel(x + i*multDiff, y+i, color);
				}
			} 
			else 
			{
				for (i = 0; i != longLen; i += inc) 
				{
					this._bit.setPixel(x+i, y+i*multDiff, color);
				}
			}
		}
		
	}
}