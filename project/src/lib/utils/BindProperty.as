package lib.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.core.UIComponent;
	import mx.events.PropertyChangeEvent;
	
	[Bindable]
	[Event(name="change", type="flash.events.Event")]
	[Event(name="beforeValueSet", type="flash.events.Event")]
	public class BindProperty extends EventDispatcher
	{
		private var _component:Object;
		private var _property:String;
		private var _value:*;
		private var _triggerBy:IEventDispatcher;
		private var _triggerEvent:String;
		
		public function get triggerEvent():String
		{
			return _triggerEvent;
		}

		public function set triggerEvent(value:String):void
		{
			clearTriggerEvent();
			_triggerEvent = value;
			registerTriggerEvent();
		}
		
		private function registerTriggerEvent():void
		{
			if(triggerBy && triggerEvent){
				triggerBy.addEventListener(triggerEvent,updateValueByComponentChange);
			}
		}
		
		public function get triggerBy():IEventDispatcher
		{
			return _triggerBy;
		}

		public function set triggerBy(value:IEventDispatcher):void
		{
			clearTriggerEvent();
			_triggerBy = value;
			registerTriggerEvent();
		}
		
		private function clearTriggerEvent():void
		{
			if(triggerBy && triggerEvent){
				triggerBy.removeEventListener(triggerEvent,updateValueByComponentChange);
			}
		}
		
		public function set value(val:*):void{
			dispatchEvent(new Event('beforeValueSet'));
			this._value = val;
			if(triggerBy == null){
				updateValueByComponentChange();	
			}
		}
		
		public function get value():*{
			return this._value;
		}
		
		private function updateValueByComponentChange(event:Event = null):void{
			if(this._component && this._property && this._property in this._component){
				this._component[this._property] = this._value;
				dispatchEvent(new Event('change'));	
			}
		}
		
		public function set component(val:Object):void{
			this._component= val;
			if(triggerBy == null){
				updateValueByComponentChange();	
			}
		}
		
		public function get component():Object{
			return this._component;
		}
		
		public function set property(val:String):void{
			this._property= val;
			updateValueByComponentChange();
		}
		
		public function get property():String{
			return this._property;
		}
		
	}
}