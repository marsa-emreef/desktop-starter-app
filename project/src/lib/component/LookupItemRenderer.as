package lib.component
{
	import spark.components.supportClasses.ItemRenderer;

	public class LookupItemRenderer extends ItemRenderer
	{
		public function LookupItemRenderer()
		{
			super();
			doubleClickEnabled = true;
		}
		
		[Bindable]
		public var lookup:Lookup;
	}
}