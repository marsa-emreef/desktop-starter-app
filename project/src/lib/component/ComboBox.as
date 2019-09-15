package lib.component
{
	import flash.events.Event;
	
	import lib.utils.Debounce;
	
	import mx.states.OverrideBase;
	
	import spark.components.ComboBox;
	
	public class ComboBox extends spark.components.ComboBox
	{
		private var _editable:Boolean;
		
		public function ComboBox()
		{
			super();
		}

		[Bindable(event="editableChange")]
		public function get editable():Boolean
		{
			return _editable;
		}

		public function set editable(value:Boolean):void
		{
			if( _editable !== value)
			{
				_editable = value;
				onEditableChange();
				dispatchEvent(new Event("editableChange"));
			}
		}
		
		override protected function partAdded(partName:String, instance:Object):void{
			if(instance == textInput){
				onEditableChange();
			}
		}
		private var onEditableChange:Function = Debounce.create(_onEditableChange,300); 
		private function _onEditableChange():void
		{
			if(textInput){
				textInput.editable = editable;
			}
		}
		
	}
}