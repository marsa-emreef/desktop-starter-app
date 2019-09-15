package lib.component {
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import lib.component.skins.DateChooser;
	import lib.component.skins.DateFieldSkin;
	
	import mx.controls.DateChooser;
	import mx.events.CalendarLayoutChangeEvent;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.formatters.DateFormatter;
	import mx.utils.ObjectUtil;
	
	import spark.components.ComboBox;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.TextOperationEvent;
	import spark.formatters.DateTimeFormatter;
	
	
	/**
	 * @author gal2729
	 */
	[Event(name="change", type="flash.events.Event")]
	[Event(name="valueCommit", type="mx.events.FlexEvent")]
	public class DateField extends SkinnableComponent {
		
		/**
		 * Return the selectedDate, this property is Bindable.
		 * @return
		 *
		 */
		[Bindable]
		public var selectedDate:Date;
		
		/**
		 * Return the selectedInternalDate, this property is Bindable.
		 * @return
		 *
		 */
		[Bindable]
		public var selectedInternalDate:Date;
		
		/**
		 * date chooser panel
		 */
		[SkinPart(required="true")]
		public var dateChooser:lib.component.skins.DateChooser;
		
		[Bindable]
		public var popUpWidthMatchesAnchorWidth:Boolean = true;
		
		/**
		 * Skin state to manage the skin of date field
		 */
		public var skinState:String="normal";
		
		
		/**
		 * Component Label
		 */
		[Bindable]
		public var label:String;
		
		/**
		 * Component Label
		 */
		[Bindable]
		public var prompt:String;
		
		[Bindable]
		public var dateStart:Date;
		
		[Bindable]
		public var dateEnd:Date;
		
		[Bindable]
		public var backgroundColor:uint = 0xFFFFFF;
		
		/**
		 * Skin part of text input
		 */
		[SkinPart(required="true")]
		public var textInput:TextInput;
		
		[Bindable]
		public var textAlign:String = 'left';
		
		[Bindable]
		public var calendarFont:String = 'OpenSans';
		
		private static var dateTimeFormat:DateTimeFormatter=new DateTimeFormatter();
		
		/**
		 * Constructor on NGDateFieldTwo
		 */
		public function DateField() {
			super();
			width=100;
			setStyle("skinClass", DateFieldSkin);
			addEventListener(FocusEvent.FOCUS_IN, openDateDropDown);
			addEventListener(FocusEvent.FOCUS_OUT, updateTextWithSelectedDate);
			addEventListener(MouseEvent.CLICK, openDateDropDown);
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, propertyChanged);
			addEventListener("closeDateChooser", closeDateChooserHandler);
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteListener);
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStageListener);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemovedFromStage);
			dateTimeFormat.dateTimePattern="dd-MMM-yyyy HH:mm";
			width = 130;
			editable=true;
		}
		
		protected function onRemovedFromStage(event:Event):void
		{
			if(stage){
				stage.removeEventListener('viewPortPositionChanged',viewPortPostionChanged);
			}
		}
		
		protected function onAddedToStageListener(event:Event):void
		{
			if(stage){
				stage.addEventListener('viewPortPositionChanged',viewPortPostionChanged);
			}
		}
		
		protected function creationCompleteListener(event:FlexEvent):void {
			// update the textInput with valid selectedDate
			updateTextWithSelectedDate();
			// dispatch value commit
			dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			// update the selectable range
			updateSelectableRange();
			// uppercase text
			updateToUpperCase();
		}
		
		/**
		 * Close dateChooser and update text with selected date;
		 */
		protected function closeDateChooserHandler(event:Event=null):void {
			updateTextWithSelectedDate();
		}
		private var stopPropagation:Boolean = false;
		protected function propertyChanged(event:PropertyChangeEvent):void {
			if ((event.property == "selectedDate" || event.property == "gmtDiff") && !stopPropagation) {
				stopPropagation = true;
				
				selectedInternalDate = selectedDate;
				updateTextWithSelectedDate();
				stopPropagation = false;
			}
			
			if (event.property == "selectedInternalDate" && !stopPropagation) {
				stopPropagation = true;
				selectedDate = selectedInternalDate;	
				updateTextWithSelectedDate();
				stopPropagation = false;
				dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			}
			
			if (event.property == "dateStart") {
				updateSelectableRange();
			}
			
			if (event.property == "dateEnd") {
				updateSelectableRange();
			}
		}
		
		/**
		 * Setting the selectable range.
		 */
		private function updateSelectableRange():void {
			if (dateChooser) {
				var range:Object = {};
				if(dateStart){
					range.rangeStart = dateStart;
				}
				if(dateEnd){
					range.rangeEnd = dateEnd;
				}
				if(dateStart || dateEnd){
					dateChooser.selectableRange=range;
				}else{
					dateChooser.selectableRange = null;
				}
				
			}
		}
		
		
		/**
		 * Get Current Skin State
		 * @return skinState
		 *
		 */
		override protected function getCurrentSkinState():String {
			return !enabled ? "disabled" : skinState;
		}
		
		override protected function partAdded(partName:String, instance:Object):void {
			super.partAdded(partName, instance);
			if (instance == textInput) {
				textInput.addEventListener(TextOperationEvent.CHANGE, textChange);
				textInput.addEventListener(KeyboardEvent.KEY_DOWN, filterKeyboard);
				textInput.addEventListener(FlexEvent.VALUE_COMMIT, textValueCommitListener);
			}
			if (instance == dateChooser) {
				dateChooser.addEventListener(CalendarLayoutChangeEvent.CHANGE, dateSelectedChangeListener);
				updateSelectableRange();
			}
		}
		
		protected function viewPortPostionChanged(event:Event):void
		{
			closeDateChooserHandler();
		}
		
		override protected function partRemoved(partName:String, instance:Object):void {
			super.partRemoved(partName, instance);
			if (instance == textInput) {
				textInput.removeEventListener(TextOperationEvent.CHANGE, textChange);
				textInput.removeEventListener(KeyboardEvent.KEY_DOWN, filterKeyboard);
				textInput.removeEventListener(FlexEvent.VALUE_COMMIT, textValueCommitListener);
			}
			if (instance == dateChooser) {
				dateChooser.removeEventListener(CalendarLayoutChangeEvent.CHANGE, dateSelectedChangeListener);
				dateChooser.selectableRange=null;
			}
		}
		
		protected function textValueCommitListener(event:FlexEvent):void {
			dispatchEvent(event);
		}
		
		protected function filterKeyboard(event:KeyboardEvent):void {
			if (event.shiftKey) {
				event.preventDefault();
			}
		}
		
		/**
		 * Date selection change listener
		 * @param event
		 *
		 */
		private function dateSelectedChangeListener(event:CalendarLayoutChangeEvent):void {
			selectedInternalDate=event.newDate;
			updateTextWithSelectedDate();
			dispatchEvent(new Event("change"));
		}
		
		private function textChange(event:TextOperationEvent):void {
			
			if (textInput) {
				if (textInput.text == null || textInput.text.length == 0) {
					selectedInternalDate=null;
					dispatchEvent(new Event("change"));
					return;
				}
				var texts:Array=textInput.text.split(" ");
				if (texts.length < 3) {
					texts=textInput.text.split("-");
				}
				if (texts.length == 3) {
					var date:Number=parseInt(texts[0]);
					var month:Number=findMonth(texts[1].toString());
					if(month < 0){
						return;
					}
					var year:Number=parseInt(texts[2]);
					if (0 <= date <= 32 && 0 <= month <= 11 && 1900 < year) {
						var newDate:Date=new Date();
						newDate.fullYear=year;
						newDate.month=month;
						newDate.date=date;
						newDate.hours=0;
						newDate.minutes=0;
						newDate.seconds=0;
						newDate.milliseconds=0;
						selectedInternalDate= isValid(newDate) ? newDate :null;
						dispatchEvent(new Event("change"));
					}
				}
			}
		}
		
		private function isValid(newDate:Date):Boolean
		{
			if(dateStart){
				var startDate:Date = new Date(dateStart.fullYear,dateStart.month,dateStart.date) ;
				startDate.hours=0;
				startDate.minutes=0;
				startDate.seconds=0;
				startDate.milliseconds=0;
				if(newDate < startDate){
					return false;	
				}
			}
			if(dateEnd){
				var endDate:Date = new Date(dateEnd.fullYear,dateEnd.month,dateEnd.date);
				endDate.hours=0;
				endDate.minutes=0;
				endDate.seconds=0;
				endDate.milliseconds=0;
				if(newDate > endDate){
					return false;	
				}
			}
			return true;
		}
		
		private function findMonth(month:String):Number {
			switch (month.substr(0, 3).toUpperCase()) {
				case 'JAN':  {
					return 0;
				}
				case 'FEB':  {
					return 1;
				}
				case 'MAR':  {
					return 2;
				}
				case 'APR':  {
					return 3;
				}
				case 'MAY':  {
					return 4;
				}
				case 'JUN':  {
					return 5;
				}
				case 'JUL':  {
					return 6;
				}
				case 'AUG':  {
					return 7;
				}
					
				case 'SEP':  {
					return 8;
				}
				case 'OCT':  {
					return 9;
				}
				case 'NOV':  {
					return 10;
				}
				case 'DEC':  {
					return 11;
				}
					
				default:  {
					break;
				}
			}
			return -1;
		}
		
		protected function updateTextWithSelectedDate(event:Event=null):void {
			if (textInput) {
				if (selectedInternalDate) {
					var textShouldbe:String=formatter.format(selectedInternalDate).toUpperCase();
					if (textInput.text != textShouldbe) {
						textInput.text=textShouldbe;
					}
				} else {
					// selected date is null then we need to cleanup this !
					if (textInput.text) {
						textInput.text=null;
					}
				}
				
			}
			if (skinState != "normal") {
				skinState="normal";
				invalidateSkinState();
			}
		}
		
		
		private function openDateDropDown(event:Event):void {
			if (skinState != "open" && textInput && textInput.editable && editable) {
				skinState="open";
				invalidateSkinState();
			}
		}
		
		public function closeDropDown():void{
			skinState="normal";
			invalidateSkinState();
		}
		
		
		
		public static const formatter:DateTimeFormatter=new DateTimeFormatter();
		formatter.dateTimePattern="dd-MMM-yyyy";
		
		private var _text:String;
		
		public function set text(value:String):void {
			_text=value;
			updateToUpperCase();
		}
		
		private function updateToUpperCase():void {
			if (textInput && _text) {
				textInput.text=_text.toUpperCase();
			}
		}
		
		public function get dateFromText():Date {
			var date:Date=new Date();
			var result:Array=_text.split("-");
			date.date=parseInt(result[0]);
			date.month=findMonth(result[1]);
			date.fullYear=parseInt(result[2]);
			date.hours=0;
			date.minutes=0;
			date.seconds=0;
			date.milliseconds=0;
			return date;
		}

		[Bindable]
		public var editable:Boolean;
		
		
	}
}
