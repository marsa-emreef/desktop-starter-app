package lib.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	[Event(name="complete", type="flash.events.Event")]
	public class Resolveable extends EventDispatcher
	{
		public var resolveValue:Object;
		private var status:String;
		public function Resolveable()
		{
			status = 'new';
		}
		public function resolve(value:Object=true):void{
			if(status == 'new'){
				this.resolveValue = value;
				dispatchEvent(new Event('complete'));	
			}
			status = 'complete';
		}
		
	}
}