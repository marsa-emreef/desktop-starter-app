package lib.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import lib.page.Navigator;
	
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	[Event(name="lookupComplete", type="flash.events.Event")]
	public class ParentLookup extends EventDispatcher
	{
		public function ParentLookup()
		{
		}
		
		private var _component:IVisualElement;
		
		private var _property:String;
		
		private var _parentType:Class;
		
		public function set parentClass(value:Class):void{
			_parentType = value;
			findProperty();
		}
		
		
		public function set property(value:String):void{
			_property = value;
		}
		
		private var findProperty:Function = Debounce.create(_findProperty);
		
		private function _findProperty():void
		{
			if(_component && _parentType && _property){
				get(_component,_parentType).then(function(value:*):void{
					_component[_property] = value;
					dispatchEvent(new Event('lookupComplete'));
				});
			}
		}
		
		public function set component(value:IVisualElement):void
		{
			_component = value;
			findProperty();
		}
		
		public static function get(element:IVisualElement,parentType:Class):Promise{
			return new Promise(function(resolve:Function):void{
				if(element.parent == null){
					element.addEventListener(FlexEvent.CREATION_COMPLETE,function(event:FlexEvent):void{
						if(element is parentType){
							resolve((element as Object));
						}else if(element.parent is IVisualElement){
							resolve(get(element.parent as IVisualElement,parentType));
						}	
					});
				}else{
					if(element is parentType){
						resolve((element as Object));
					}else if(element.parent is IVisualElement){
						resolve(get(element.parent as IVisualElement,parentType));
					}	
				}
			});
		}
	}
}