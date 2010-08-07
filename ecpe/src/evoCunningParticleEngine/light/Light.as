package evoCunningParticleEngine.light
{
	public class Light
	{
		public var next:Light;
		
		public var x:Number = 0, y:Number = 0, z:Number = 0;
		
		public var dive:Number;
		
		private var _power:Number = 0;
		public function get power():Number
		{
			return _power;
		}

		public function set power(value:Number):void
		{
			_power = value;
			dive = 1/value;
		}
		
		public function Light(power:Number = 100000, x:Number = 0, y:Number = 0, z:Number = 0)
		{
			this.power = power;
			this.x = x;
			this.y = y;
			this.z = z;
		}
	}
}