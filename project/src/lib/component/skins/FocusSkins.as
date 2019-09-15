package lib.component.skins
{
	import spark.skins.spark.FocusSkin;
	
	public class FocusSkins extends FocusSkin
	{
		public function FocusSkins()
		{
			super();
		}
		
		override protected function get borderWeight() : Number
		{
			return 1;
		}
	}
}