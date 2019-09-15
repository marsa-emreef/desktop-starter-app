package lib.utils.keyboard
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import lib.utils.Debounce;

	[Event(name="keyDown", type="flash.events.Event")]
	[Bindable]
	[DefaultProperty("source")]
	public class KeyboardBinder extends EventDispatcher
	{
		public function KeyboardBinder()
		{
		}
		
		public var keyCode:uint;
		private var _source:Array;
		public function get source():Array
		{
			return _source;
		}

		public function set source(value:Array):void
		{
			_source = value;
			addListener();
		}
		private var addListener:Function = Debounce.create(_addListener);
		
		private function _addListener():void
		{
			if(source && keyCode){
				for (var i:int = 0; i < source.length; i++) 
				{
					if(source[i]){
						(source[i] as EventDispatcher).addEventListener(KeyboardEvent.KEY_DOWN ,onEventListener);	
					}
				}
			}
		}
		
		protected function onEventListener(event:KeyboardEvent):void
		{
			if(event.keyCode == keyCode){
				dispatchEvent(new Event('keyDown'))
			}
		}
		
	}
}