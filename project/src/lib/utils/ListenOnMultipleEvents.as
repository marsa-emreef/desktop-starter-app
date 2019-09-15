package lib.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	[DefaultProperty("children")]
	[Event(name="eventTriggered", type="flash.events.Event")]
	[Event(name="eventBeforeTriggered", type="flash.events.Event")]
	[Event(name="eventAfterTriggered", type="flash.events.Event")]
	[Event(name="change", type="flash.events.Event")]
	public class ListenOnMultipleEvents extends EventDispatcher
	{
		private var _children:Array;
		
		public function ListenOnMultipleEvents()
		{
			
		}

		[Inspectable(arrayType="lib.utils.ListenOnEvent")]
		public function get children():Array
		{
			return _children;
		}

		public function set children(value:Array):void
		{
			removeListener();
			_children = value;
			registerListener();
		}
		
		private function removeListener():void
		{
			for each (var loe:ListenOnEvent in children) 
			{
				loe.removeEventListener("eventTriggered",onChildEventTriggered);
			}
		}
		
		private function registerListener():void
		{
			for each (var loe:ListenOnEvent in children) 
			{
				loe.addEventListener("eventTriggered",onChildEventTriggered);
			}
		}
		
		protected function onChildEventTriggered(event:Event):void
		{
			dispatchEvent(new Event('eventBeforeTriggered'));
			dispatchEvent(new Event('eventTriggered'));
			dispatchEvent(new Event('change'));
			dispatchEvent(new Event('eventAfterTriggered'));
		}
		
	}
}