package lib.component
{
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import flashx.textLayout.operations.InsertTextOperation;
	
	import lib.component.skins.TimeFieldSkin;
	import lib.utils.Debounce;
	import lib.utils.date.DateUtils;
	import lib.utils.date.FormatType;
	
	import mx.binding.utils.BindingUtils;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.formatters.DateFormatter;
	import mx.utils.StringUtil;
	
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.TextOperationEvent;
	import spark.formatters.DateTimeFormatter;
	
	
	/**
	 *
	 */
	[Event(name="change", type="flash.events.Event")]
	public class TimeField extends SkinnableComponent {
		
		/**
		 * Flag to indicate if text is set to empty by user then time is reset to 00:00
		 */
		[Bindable]
		public var timeResetWhenTextIsEmpty:Boolean = true;
		
		
		[SkinPart(required="true")]
		[Bindable]
		public var textInput:TextInput;
		
		[Bindable]
		public var selectedTime:Date;
		
		[Bindable]
		public var selectedInternalTime:Date;
		
		[Bindable]
		public var prompt:String="HH:MM";
		
		[Bindable]
		public var displayPrompt:Boolean=false;
		
		[Bindable]
		public var label:String;
		
		private var _selectableRange:Object;
		
		[Bindable]
		[Inspectable(enumeration="left,right,center")]
		public var textAlign:String = 'center';
		
		
		[Bindable(event="selectableRangeChange")]
		public function get selectableRange():Object
		{
			return _selectableRange;
		}
		
		public function set selectableRange(value:Object):void
		{
			if( _selectableRange !== value)
			{
				_selectableRange = value;
				validateTime();
				dispatchEvent(new Event("selectableRangeChange"));
			}
		}
		
		private function validateTime():void
		{
			if(selectableRange){
				if("rangeStart" in selectableRange && selectableRange.rangeStart is Date){
					if(selectedInternalTime && (selectedInternalTime.time < (selectableRange.rangeStart as Date).time)){
						errorString = "Time should be after "+DateUtils.formatDD_MMM_YYYY_HH_MM(selectableRange.rangeStart);
					}else{
						errorString = null;
					}
				}
				if("rangeEnd" in selectableRange && selectableRange.rangeEnd is Date){
					if(selectedInternalTime && (selectedInternalTime.time > (selectableRange.rangeEnd as Date).time)){
						errorString = "Time should be before "+DateUtils.formatDD_MMM_YYYY_HH_MM(selectableRange.rangeEnd);
					}else{
						errorString = null;
					}
				}
			}
		}
		
		
		public function TimeField() {
			super();
			width = 60;
			setStyle("skinClass", lib.component.skins.TimeFieldSkin);
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteListener);
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, propertyChanged);
			editable = true;
		}
		
		private var stopPropagation:Boolean = false;
		protected function propertyChanged(event:PropertyChangeEvent):void {
			if ((event.property == "selectedTime" || event.property == "gmtDiff") && !stopPropagation) {
				stopPropagation = true;
				selectedInternalTime = selectedTime;	
				updateText();
				validateTime();
				stopPropagation = false;
			}
			if (event.property == "selectedInternalTime" && !stopPropagation) {
				stopPropagation = true;
				selectedTime = selectedInternalTime;	
				updateText();
				validateTime();
				stopPropagation = false;
				dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			}
			if (event.property == 'displayPrompt') {
				updateText();
			}
		}
		
		protected function creationCompleteListener(event:FlexEvent):void {
			updateText();
			dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			if (instance == textInput) {
				textInput.addEventListener(TextOperationEvent.CHANGING, textChanging);
				textInput.addEventListener(TextOperationEvent.CHANGE, textChanged);
				textInput.addEventListener(FocusEvent.FOCUS_OUT, updateSelectedTimeFromText);
				textInput.addEventListener(MouseEvent.CLICK, focusedIn);
				textInput.addEventListener(FlexEvent.VALUE_COMMIT, textInputValueCommit);
				BindingUtils.bindProperty(textInput,'editable',this,'editable');
			}
		}
		
		protected function textInputValueCommit(event:FlexEvent):void {
			dispatchEvent(event);
		}
		
		override protected function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			if (instance == textInput) {
				textInput.removeEventListener(TextOperationEvent.CHANGING, textChanging);
				textInput.removeEventListener(TextOperationEvent.CHANGE, textChanged);
				textInput.removeEventListener(FocusEvent.FOCUS_OUT, updateSelectedTimeFromText);
				textInput.removeEventListener(MouseEvent.CLICK, focusedIn);
				textInput.removeEventListener(FlexEvent.VALUE_COMMIT, textInputValueCommit);
			}
		}
		
		protected function focusedIn(event:Event):void {
			textInput.selectAll();
		}
		
		
		protected function updateSelectedTimeFromText(event:FocusEvent):void {
			updateText();
		}
		
		protected function textChanged(event:TextOperationEvent):void {
			var text:String=textInput.text;
			var newDate:Boolean = text && text.length > 0 && (text.indexOf(":") < 0 && text.length == 4);
			var updateDate:Boolean = text && text.length > 0 && (text.indexOf(":") >= 0 && text.length >= 5);
			if (newDate || updateDate) {
				var hours:String="";
				var minutes:String="";
				if  (newDate){
					hours=text.substr(0, 2);
					minutes=text.substr(2, 2);
				}else if (updateDate) {
					hours=text.substr(0, text.indexOf(":"));
					minutes=text.substr(text.indexOf(":")+1, text.length - text.indexOf(":"));
				}
				var newTime:Date=new Date();
				if (selectedInternalTime) {
					newTime.time=selectedInternalTime.time;
				}
				newTime.hours=parseInt(hours);
				newTime.minutes=parseInt(minutes);
				newTime.seconds=0;
				newTime.milliseconds=0;
				selectedInternalTime=newTime;
				text= DateUtils.formatHH_MM(selectedInternalTime);
				dispatchEvent(new Event("change"));
			} else if ((text == null || text.length == 0 ) && selectedInternalTime) {
				// we reset the data
				if(timeResetWhenTextIsEmpty){
					selectedInternalTime.milliseconds = selectedInternalTime.seconds = selectedInternalTime.minutes = selectedInternalTime.hours = 0;	
				}else{
					selectedInternalTime = null;
				}
				dispatchEvent(new Event("change"));
			} 
			// clean up if the user tried to input more than 5 character
			if (textInput.text.length >= 5) {
				textInput.text=textInput.text.substr(0, 5);
				textInput.selectRange(5, 5);
			}
		}
		
		protected function textChanging(event:TextOperationEvent):void {
			if (event.operation is InsertTextOperation) {
				var text:String=(event.operation as InsertTextOperation)._text;
				
				if (!(parseInt(text) >= 0)) {
					event.preventDefault();
				}
				
			}
		}
		
		private function updateText():void {
			if (textInput) {
				if (selectedInternalTime && !displayPrompt) {
					var newText:String= DateUtils.formatHH_MM(selectedInternalTime);
					if (textInput.text != newText) {
						textInput.text=newText;
						textInput.selectRange(5, 5);
					}
					
				} else {
					textInput.text="";
				}
				
			}
		}
		
		[Bindable]
		public var editable:Boolean;
		
	}
	
	
}
