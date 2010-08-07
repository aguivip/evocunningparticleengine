package evoCunningParticleEngine.material
{
	import evoCunningParticleEngine.material.meta.MetaParticle;
	
	import flash.display.BitmapData;

	public interface IMaterialParticle
	{
		function get data():Vector.<Vector.<BitmapData>>;
		function get meta():Vector.<MetaParticle>;
		function get resolution():int;
		function get lightResolution():int;
		function get range():int;
		function set renderRange(value:Number):void;
		function get renderRange():Number;
	}
}