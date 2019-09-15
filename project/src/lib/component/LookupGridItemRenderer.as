package lib.component
{
	import spark.components.gridClasses.GridItemRenderer;
	
	public class LookupGridItemRenderer extends GridItemRenderer
	{
		public function LookupGridItemRenderer()
		{
			super();
		}
		
		[Bindable]
		public var lookup:Lookup;
	}
}