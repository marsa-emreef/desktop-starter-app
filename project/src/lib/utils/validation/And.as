package lib.utils.validation
{
	import flash.events.Event;
	
	import lib.utils.Debounce;
	import lib.utils._;
	
	import mx.core.UIComponent;

	[DefaultProperty("children")]
	[Event(name="allValidChange", type="flash.events.Event")]
	public class And extends Valid
	{
		private var _children:Array;
		
		public function And()
		{
		}

		public function get children():Array
		{
			return _children;
		}
		
		[ArrayElementType("lib.utils.validation.Valid")]
		public function set children(value:Array):void
		{
			clearListener();
			_children = value;
			registerListener();
		}
		
		private function registerListener():void
		{
			_.forEach(_children,function(valid:Valid):void{
				valid.addEventListener("expectedChange",onExpectedChange);
			});
		}
		
		private function clearListener():void
		{
			_.forEach(_children,function(valid:Valid):void{
				valid.removeEventListener("expectedChange",onExpectedChange);
			});
		}
		
		protected var onExpectedChange:Function = Debounce.create(_onConditionChange,100);
		
		protected function _onConditionChange(event:Event):void
		{
			validateAllChildren();
		}
		
		private function validateAllChildren(highlightComponent:Boolean = false):void
		{
			var validity:Object = _.reduce(children,function(validity:Object,valid:Valid,index:*,source:*):*{
				if(highlightComponent){
					valid.highlightComponentIfNeeded();
				}
				return {
					isValid : validity.isValid && valid.expected,
					errors : valid.expected ? validity.errors : (validity.errors as Array).concat([valid.errorMessage])
				};
			},{isValid:true,errors:[]});
			expected = validity.isValid;
			errorMessage = (validity.errors as Array).join('\n');
			
		}
		
		public function allValid(highlightComponent:Boolean = true):Boolean
		{
			validateAllChildren(highlightComponent);
			return expected;
		}
		
		public function clearErrorMessage():void{
			_.forEach(children,function(valid:Valid):void{
				_.forEach(valid.componentToHighlightTheError,function(comp:ComponentToHighlightTheError):void{
					if(comp && comp.component){
						comp.component.errorString = '';	
					}
				});
			});
		}
	}
}