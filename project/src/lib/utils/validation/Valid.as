package lib.utils.validation
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import lib.utils.Promise;
	import lib.utils._;
	
	import mx.core.IUIComponent;
	import mx.events.ValidationResultEvent;
	import mx.utils.StringUtil;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	
	
	[Bindable]
	[Event(name="expectedChange", type="flash.events.Event")]
	[Event(name="valid", type="flash.events.Event")]
	[Event(name="invalid", type="flash.events.Event")]
	[DefaultProperty("componentToHighlightTheError")]
	public class Valid extends EventDispatcher
	{
		private var _expected:Boolean;
		public var errorMessage:String;
		
		[Inspectable(arrayType="lib.utils.validation.ComponentToHighlightTheError")]
		public var componentToHighlightTheError:Array;
		
		private var _componentToTriggerTheError:IEventDispatcher;
		
		public var componentEventToTriggerTheError:String;
		
		public var enabled:Boolean = true;
		
		public function Valid()
		{
		}
		
		public function get componentToTriggerTheError():IEventDispatcher
		{
			return _componentToTriggerTheError;
		}

		public function set componentToTriggerTheError(value:IEventDispatcher):void
		{
			if(_componentToTriggerTheError){
				_componentToTriggerTheError.removeEventListener(componentEventToTriggerTheError,highlightComponentIfNeeded);
			}
			_componentToTriggerTheError = value;
			if(_componentToTriggerTheError){
				_componentToTriggerTheError.addEventListener(componentEventToTriggerTheError,highlightComponentIfNeeded);
			}
		}
		
		
		public function get expectedAsync():Promise
		{
			return null;
		}
		
		public function set expectedAsync(value:Promise):void
		{
			if(value && enabled){
				value.then(function(res:*):void{
					expected = res;
					if(componentEventToTriggerTheError != null && componentToTriggerTheError != null){
						highlightComponentIfNeeded();	
					}
				});
			}
		}
		
		[Bindable(event="expectedChange")]
		public function get expected():Boolean
		{
			if(enabled){
				return _expected;	
			}
			return true;
		}
		
		public function set expected(value:Boolean):void
		{
			if(!enabled){
				return;
			}
			if( _expected !== value)
			{
				_expected = value;
				dispatchEvent(new Event("expectedChange"));
				if(componentEventToTriggerTheError == null && componentToTriggerTheError == null){
					highlightComponentIfNeeded();	
				}
				if(expected){
					dispatchEvent(new Event('valid'));
				}else{
					dispatchEvent(new Event('invalid'));
				}
			}
		}
		
		public function highlightComponentIfNeeded(event:Event = null):void
		{
			if(componentToHighlightTheError && componentEventToTriggerTheError.length > 0 && enabled){
				_.forEach(componentToHighlightTheError,function(comp:ComponentToHighlightTheError):*{
					var originalCompErrorMessage:Array = _.filter(comp.component.errorString.split('\n'),function(text:String):Boolean{
						return text.replace(' ','') != '';
					});
					if(expected && originalCompErrorMessage.indexOf(errorMessage) >= 0){
						originalCompErrorMessage.splice(originalCompErrorMessage.indexOf(errorMessage),1);
						comp.component.errorString = originalCompErrorMessage.join('\n');
					}else if((!expected) && originalCompErrorMessage.indexOf(errorMessage) < 0){
						originalCompErrorMessage.push(errorMessage);
						comp.component.errorString = originalCompErrorMessage.join('\n');
					}else{
						comp.component.errorString = originalCompErrorMessage.join('\n');
					}
				});
			}
		}
		
	}
}