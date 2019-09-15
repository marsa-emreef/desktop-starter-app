package lib.component
{
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import flashx.textLayout.operations.DeleteTextOperation;
	import flashx.textLayout.operations.InsertTextOperation;
	
	import lib.utils.encryption.crypto.symmetric.NullPad;
	
	import mx.binding.utils.BindingUtils;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.states.OverrideBase;
	
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.TextOperationEvent;
	import spark.formatters.NumberFormatter;
	
	[Event(name="change", type="flash.events.Event")]
	[Event(name="valueCommit", type="mx.events.FlexEvent")]
	public class NumberField extends SkinnableComponent
	{
		
		private var _number:Number;
		
		[Bindable]
		public var numberFormatter:NumberFormatter;
		
		[Bindable]
		public var fractionalDigits:Number;
		
		private var _decimalSeparator:String;
		
		[SkinPart(required="true")]
		public var textInput:TextInput;
		
		[Bindable]
		public var editable:Boolean;
		
		public function NumberField()
		{
			super();	
			_decimalSeparator = '.';
			editable = true;
			numberFormatter = new NumberFormatter();
			numberFormatter.decimalSeparator = decimalSeparator;
			numberFormatter.fractionalDigits = fractionalDigits;
			BindingUtils.bindProperty(numberFormatter,'fractionalDigits',this,'fractionalDigits');
			BindingUtils.bindProperty(numberFormatter,'decimalSeparator',this,'decimalSeparator');
			allowedCharacter.push(decimalSeparator);
		}
		
		override protected function partAdded(partName:String, instance:Object):void{
			if(instance == textInput){
				textInput.addEventListener(TextOperationEvent.CHANGING,onTextChanging);
				textInput.addEventListener(TextOperationEvent.CHANGE,onTextChange);
				textInput.setStyle('textAlign','right');
				if(!isNaN(_number)){
					textInput.text = numberFormatter.format(_number);
				}
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void{
			if(instance == textInput){
				textInput.removeEventListener(TextOperationEvent.CHANGING,onTextChanging);
				textInput.removeEventListener(TextOperationEvent.CHANGE,onTextChange);
			}
		}
		
		private var allowedCharacter:Array = ['0','1','2','3','4','5','6','7','8','9','-'];
		
		private var workingOnDecimal:Boolean;
		
		[Bindable(event="decimalSeparatorChange")]
		public function get decimalSeparator():String
		{
			return _decimalSeparator;
		}
		
		public function set decimalSeparator(value:String):void
		{
			if( _decimalSeparator !== value)
			{
				allowedCharacter.splice(allowedCharacter.indexOf(_decimalSeparator),1);
				_decimalSeparator = value;
				allowedCharacter.push(_decimalSeparator);
				dispatchEvent(new Event("decimalSeparatorChange"));
			}
		}
		
		[Bindable(event="valueCommit")]
		public function get selectedNumber():Number
		{
			return _number;
		}
		
		public function set selectedNumber(value:Number):void
		{
			if( _number !== value)
			{
				_number = value;
				if(textInput){
					textInput.text = numberFormatter.format(_number);
				}
				dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			}
		}
		
		protected function onTextChanging(event:TextOperationEvent):void
		{
			workingOnDecimal = textInput.selectionActivePosition > textInput.text.indexOf(decimalSeparator) && numberFormatter.fractionalDigits > 0;
			if(event.operation is InsertTextOperation && textInput.autoCap && !textInput.displayAsPassword){
				var ito:InsertTextOperation = event.operation as InsertTextOperation;
				if(allowedCharacter.indexOf(ito.text)<0){
					event.preventDefault();
					event.stopImmediatePropagation();
					event.stopPropagation();
					return;
				}
				if(ito.text == decimalSeparator &&  textInput.text.indexOf(decimalSeparator)>0){
					event.preventDefault();
					event.stopImmediatePropagation();
					event.stopPropagation();
					textInput.selectRange(textInput.text.indexOf(decimalSeparator)+1,textInput.text.indexOf(decimalSeparator)+1);
					return;
				}
				if(ito.text == decimalSeparator &&  numberFormatter.fractionalDigits < 1){
					event.preventDefault();
					event.stopImmediatePropagation();
					event.stopPropagation();
					return;
				}
			}
			
			if(event.operation is DeleteTextOperation ){
				var dto:DeleteTextOperation = event.operation as DeleteTextOperation;
				var _dotIndex:String = textInput.text.substring(dto.absoluteStart,dto.absoluteEnd);
				var indexOfDot:Number = _dotIndex.indexOf(decimalSeparator);
				if(indexOfDot>=0){
					event.preventDefault();
					event.stopImmediatePropagation();
					event.stopPropagation();
					textInput.selectRange(dto.absoluteStart,dto.absoluteStart);
					return;
				}
			}
		}
		
		protected function onTextChange(event:TextOperationEvent):void
		{
			_number = beforePersistNumber(numberFormatter.parseNumber(textInput.text));
			var _originalTextLength:Number = textInput.text.length;
			var _carretPositionFromRight:Number = _originalTextLength - textInput.selectionActivePosition;
			if(!isNaN(_number)){
				var _hasDecimal:Boolean = textInput.text.indexOf(decimalSeparator)>0;
				textInput.text = numberFormatter.format(_number);
				if(!workingOnDecimal){
					var _newCarretPosition:Number = textInput.text.length - _carretPositionFromRight;
					// kalau sebelumnya tidak ada decimal dan sekarang ada decimal maka kt
					if((!_hasDecimal) && textInput.text.indexOf(decimalSeparator)>0){
						_newCarretPosition = _newCarretPosition - (textInput.text.length - (textInput.text.indexOf(decimalSeparator)))
					}
					textInput.selectRange(_newCarretPosition,_newCarretPosition);
				}
			}
			dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			dispatchEvent(new Event("change"));
		}
		
		protected function beforePersistNumber(input:Number):Number{
			return input;
		}
		
	}
}