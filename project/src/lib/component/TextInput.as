package lib.component
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import flashx.textLayout.operations.InsertTextOperation;
	import flashx.textLayout.operations.PasteOperation;
	
	import spark.components.RichEditableText;
	import spark.components.TextInput;
	import spark.events.TextOperationEvent;
	
	public class TextInput extends spark.components.TextInput
	{
		[Bindable]
		public var autoCap:Boolean = true;
		
		[Bindable]
		public var editableBindable:Boolean;
		
		[Bindable]
		public var isFocusedBindable:Boolean;
		
		public function TextInput()
		{
			super();
			addEventListener(TextOperationEvent.CHANGING,onTextChanging);
			addEventListener(Event.PASTE ,onPaste);
			editableBindable = editable;
		}
		
		override protected function focusOutHandler(event:FocusEvent):void{
			super.focusOutHandler(event);
			isFocusedBindable = false;
		}
		
		override protected function focusInHandler(event:FocusEvent):void{
			super.focusInHandler(event);
			isFocusedBindable = true;
			selectAll();
		}
		
		override public function get editable():Boolean
		{
			return super.editable;
		}
		
		/**
		 *  @private
		 */
		override public function set editable(value:Boolean):void
		{
			super.editable = value;
			editableBindable = value;
		}
		
		private function onPaste(event:Event):void
		{
			if(autoCap && !displayAsPassword){
				var ret:RichEditableText = event.target as RichEditableText;
				ret.text = ret.text.toUpperCase();
			}
		}
		
		private function onTextChanging(event:TextOperationEvent):void
		{
			if(event.operation is InsertTextOperation && autoCap && !displayAsPassword){
				var ito:InsertTextOperation = event.operation as InsertTextOperation;
				ito.text = ito.text.toUpperCase();
			}
		}
	}
}