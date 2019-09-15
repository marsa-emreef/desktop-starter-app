package lib.component
{
	import spark.components.supportClasses.ItemRenderer;
	
	public class ItemRenderer extends spark.components.supportClasses.ItemRenderer
	{
		public function ItemRenderer()
		{
			super();
		}
		
		override protected function get hovered():Boolean{
			return false;
		}
	}
}