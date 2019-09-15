package lib.component
{
	import modules.context.AppContext;
	
	import spark.modules.Module;
	
	public class BaseModule extends Module
	{
		[Bindable]
		public var title:String;
		
		[Bindable]
		public var address:String;
		
		[Bindable]
		public var query:Object;
		
		[Bindable]
		public var appContext:AppContext;
		
		public function BaseModule()
		{
			super();
		}
	}
}