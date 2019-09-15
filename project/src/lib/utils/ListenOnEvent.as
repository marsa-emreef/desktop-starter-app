package lib.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.events.PropertyChangeEvent;

	[Event(name="eventTriggered", type="flash.events.Event")]
	[Event(name="eventBeforeTriggered", type="flash.events.Event")]
	[Event(name="eventAfterTriggered", type="flash.events.Event")]
	[Bindable]
	public class ListenOnEvent extends EventDispatcher
	{
		public var event:String;
		public var component:*;
		
		public function ListenOnEvent()
		{
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,onPropertyChanged);
		}
		
		protected function onPropertyChanged(propChangeEvent:PropertyChangeEvent):void
		{
			if(propChangeEvent.property == 'component' && event){
				if(propChangeEvent.oldValue){
					propChangeEvent.oldValue.removeEventListener(event,onEventTriggered);
				}
				if(propChangeEvent.newValue){
					propChangeEvent.newValue.addEventListener(event,onEventTriggered);
				}
			}
		}
		
		protected function onEventTriggered(event:Event):void
		{
			dispatchEvent(new Event('eventBeforeTriggered'));
			dispatchEvent(new Event('eventTriggered'));
			dispatchEvent(new Event('eventAfterTriggered'));
		}
		
		public static function once(component:*,eventName:String,callback:Function):void{
			function _callBack(event:*):void{
				callback(event);
				component.removeEventListener(eventName,_callBack);
			}
			component.addEventListener(eventName,_callBack);
		}
	}
}