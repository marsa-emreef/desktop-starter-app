package lib.page.dialog
{
	import flash.events.Event;
	
	import lib.utils.Promise;
	
	import spark.components.Group;

	[Event(name="beforeOpen", type="lib.utils.PromiseEvent")]
	[Event(name="afterOpen", type="flash.events.Event")]
	[Event(name="beforeClose", type="lib.utils.PromiseEvent")]
	[Event(name="afterClose", type="flash.events.Event")]
	[Event(name="closeDialog", type="flash.events.Event")]
	public class DialogPanelBase extends Group
	{
		public var promise:Promise;
		
		[Bindable]
		public var isClosed:Boolean;
		
		public function DialogPanelBase()
		{
			super();
			isClosed = false;
		}
		
		
		public function closePanel():void{
			dispatchEvent(new Event('closeDialog',true));
			isClosed = true;
		}
	}
	
}