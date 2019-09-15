package lib.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.events.PropertyChangeEvent;

	[DefaultProperty("children")]
	
	[Event(name="change", type="lib.utils.EventPayloadPropertyChange")]
	[Bindable]
	public class ListenOnPropertyChange extends EventDispatcher
	{
		public var component:EventDispatcher;
		public var property:String;
		
		public var enable:Boolean;
		
		[Inspectable(arrayType="lib.utils.ListenOnPropertyChange")]
		public var children:Array;
		
		public function ListenOnPropertyChange()
		{
			enable = true;
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,onPropertyChanged);
		}
		
		protected function onPropertyChanged(propChangeEvent:PropertyChangeEvent):void
		{
			if(propChangeEvent.property == 'component'){
				if(propChangeEvent.oldValue){
					(propChangeEvent.oldValue as EventDispatcher).removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,onEventTriggered);
				}
				if(propChangeEvent.newValue){
					(propChangeEvent.newValue as EventDispatcher).addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,onEventTriggered);
				}
			}
			if(propChangeEvent.property == 'children'){
				var oldVal:Array = propChangeEvent.oldValue as Array;
				var newVal:Array = propChangeEvent.newValue as Array;
				_.forEach(oldVal,function(prop:ListenOnPropertyChange):void{
					prop.removeEventListener("change",onChildChangeTriggered);
				});
				_.forEach(newVal,function(prop:ListenOnPropertyChange):void{
					prop.addEventListener("change",onChildChangeTriggered);
				});
			}
		}
		
		protected function onChildChangeTriggered(event:EventPayloadPropertyChange):void
		{
			if(enable){
				dispatchEvent(new EventPayloadPropertyChange('change',event.payload));	
			}
		}
		
		protected function onEventTriggered(event:PropertyChangeEvent):void
		{
			if(event.property.toString() == property && enable){
				dispatchEvent(new EventPayloadPropertyChange('change',event));	
			}
			
		}
		
		public static function once(component:EventDispatcher,eventName:String,callback:Function):void{
			function _callBack(event:*):void{
				callback(event);
				component.removeEventListener(event,_callBack);
			}
			component.addEventListener(eventName,_callBack);
		}
	}
}