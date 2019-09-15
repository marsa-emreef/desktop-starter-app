package lib.utils
{
	import flash.events.Event;
	
	import mx.events.PropertyChangeEvent;

	public class EventPayloadPropertyChange extends Event
	{
		public var payload:PropertyChangeEvent;
		
		public function EventPayloadPropertyChange(type:String,payload:PropertyChangeEvent, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.payload = payload;
		}
	}
}