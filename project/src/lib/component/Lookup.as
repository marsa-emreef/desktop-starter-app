package lib.component
{
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import lib.component.skins.DefaultLookupItemRenderer;
	import lib.component.skins.LookupSkin;
	import lib.utils.Debounce;
	import lib.utils.PayloadEvent;
	import lib.utils.PromiseEvent;
	import lib.utils._;
	import lib.utils.encryption.crypto.symmetric.NullPad;
	import lib.utils.label_function.LF;
	
	import modules.config.query.Index;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.DataGroup;
	import spark.components.List;
	import spark.components.PopUpAnchor;
	import spark.components.gridClasses.GridColumn;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.GridEvent;
	import spark.events.IndexChangeEvent;
	import spark.events.RendererExistenceEvent;
	import spark.events.TextOperationEvent;
	import spark.skins.spark.DefaultItemRenderer;
	
	
	[Event(name="changing", type="lib.utils.PromiseEvent")]
	[Event(name="change", type="lib.utils.PayloadEvent")]
	[Event(name="valueCommit", type="flash.events.Event")]
	[Event(name="dataProviderChanged", type="flash.events.Event")]
	[DefaultProperty("columns")]
	public class Lookup extends SkinnableComponent
	{
		
		[SkinPart(required="true")]
		public var textInput:TextInput;
		
		[Bindable]
		public var dataProvider:IList;
		
		[Bindable]
		[ArrayElementType("spark.components.gridClasses.GridColumn")]
		public var columns:Array;
		
		private var _displayPopUp:Boolean;
		
		[SkinPart(required="true")]
		public var popupAnchor:PopUpAnchor;
		
		[Bindable]
		[Inspectable(enumeration="above,below")]
		public var popUpPosition:String = 'below'; 
		
		[Bindable]
		public var filterFunction:Function = filterBasedOnSearchText;
		
		[Bindable(event="displayPopUpChange")]
		public function get displayPopUp():Boolean
		{
			return _displayPopUp;
		}
		
		public function set displayPopUp(value:Boolean):void
		{
			if( _displayPopUp !== value)
			{
				_displayPopUp = value;
				dispatchEvent(new Event("displayPopUpChange"));
			}
		}
		
		private var _labelFunction:Function;
		
		private var _selectedItem:*;
		
		[SkinPart(required="true")]
		public var dataGrid:DataGrid;
		
		[Bindable]
		public var popUpWidthMatchesAnchorWidth:Boolean;
		
		
		[Bindable]
		public var requireSelection:Boolean;
		
		
		[Bindable]
		public var editable:Boolean;
		
		/**
		 * Inorder to use validate selected item with data provider, please define LabelFunction 
		 */
		[Bindable]
		public var validateSelectedItemWithDataProvider:Boolean;
		
		private const SELECTED_ITEM_CHANGE:String = 'selectedItemChange';
		private const LABEL_FUNCTION_CHANGE:String = 'labelFunctionChange';
		
		[Bindable]
		public var popupDelayClosed:Boolean = false;
		
		public function Lookup()
		{
			super();
			setStyle('skinClass',lib.component.skins.LookupSkin);
			popUpWidthMatchesAnchorWidth = false;
			validateSelectedItemWithDataProvider = true;
			addEventListener(FocusEvent.FOCUS_OUT,onFocusOut);
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,onPropertyChangeEvent);
			addEventListener(MouseEvent.CLICK,onMouseClicked);
			addEventListener(KeyboardEvent.KEY_DOWN,onKeyboardDown);
			addEventListener(SELECTED_ITEM_CHANGE,onSelectedItemChange);
			addEventListener(LABEL_FUNCTION_CHANGE,onLabelFunctionChange);
			requireSelection = false;
			editable = true;
		}
		
		protected function onLabelFunctionChange(event:Event):void
		{
			updateSelectedItemByDataProvider();
		}
		
		[Bindable(event="labelFunctionChange")]
		public function get labelFunction():Function
		{
			return _labelFunction;
		}
		
		public function set labelFunction(value:Function):void
		{
			if( _labelFunction !== value)
			{
				_labelFunction = value;
				dispatchEvent(new Event(LABEL_FUNCTION_CHANGE));
			}
		}
		
		protected function onSelectedItemChange(event:Event):void
		{
			updateSelectedItemByDataProvider();
		}
		
		[Bindable(event="selectedItemChange")]
		public function get selectedItem():*
		{
			return _selectedItem;
		}
		
		public function set selectedItem(value:*):void
		{
			if( _selectedItem !== value)
			{
				_selectedItem = value;
				valueCommit();
				dispatchEvent(new Event(SELECTED_ITEM_CHANGE));
				updateText();
			}
		}
		
		protected function onKeyboardDown(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.TAB){
				if(displayPopUp){
					displayPopUp = false;
					updateText();
				}
			}
		}
		
		protected function onFocusOut(event:FocusEvent):void
		{
			if(displayPopUp){
				displayPopUp = false;
			}
		}
		
		
		private function updateSelectedItemByDataProvider():void
		{
			if(selectedItem && dataProvider && dataProvider.length > 0 ){
				if(validateSelectedItemWithDataProvider && labelFunction != null){
					var selectedItemLabel:String = labelFunction(selectedItem);
					selectedItem = _.filterFirst(dataProvider,function(item:*):Boolean{
						return labelFunction(item) == selectedItemLabel;
					});	
				}
				updateText();
			}
		}
		
		protected function onDataProviderChanged():void
		{
			
			if(dataProvider && dataProvider.length > 0 && requireSelection && selectedItem == null){
				selectedItem = dataProvider.getItemAt(0);
			}
			updateSelectedItemByDataProvider();
			dispatchEvent(new Event('dataProviderChanged'));
		}
		
		protected function onMouseClicked(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
			event.stopPropagation();
			event.preventDefault();
		}
		
		
		
		protected function onPropertyChangeEvent(event:PropertyChangeEvent):void
		{
			if(event.property == 'dataProvider'){
				onDataProviderChanged();
			}
			if(event.property == 'selectedItem'){
				valueCommit();		
			}
		}
		
		private function valueCommit():void{
			dispatchEvent(new Event('valueCommit'));
		}
		
		private function updateText():void
		{
			if(textInput != null && labelFunction != null){
				textInput.text = selectedItem ? labelFunction(selectedItem) : '';
				if(textInput.text){
					textInput.selectRange(textInput.text.length,textInput.text.length);
				}
			}
		}
		
		
		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			if(instance == textInput){
				textInput.addEventListener(TextOperationEvent.CHANGE,onTextChange);
				textInput.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
				textInput.addEventListener(FocusEvent.FOCUS_IN,onTextFocusedIn);
				textInput.addEventListener(MouseEvent.CLICK,onMouseClick);
				updateText();
			}
			if(instance == dataGrid){
				dataGrid.addEventListener(RendererExistenceEvent.RENDERER_ADD,onRendererAdded);
				dataGrid.addEventListener(RendererExistenceEvent.RENDERER_REMOVE,onRendererRemoved);
				dataGrid.addEventListener(GridEvent.GRID_CLICK,onListClicked);
			}
		}
		
		
		protected function onMouseClick(event:MouseEvent):void
		{
			event.preventDefault();
			event.stopPropagation();
			event.stopImmediatePropagation();
			if(!displayPopUp){
				displayPopUp = true;
			}
		}
		
		protected function onTextFocusedIn(event:FocusEvent):void
		{
			if(!displayPopUp){
				displayPopUp = true;
			}
		}
		
		protected function onListClicked(event:MouseEvent):void
		{
			event.preventDefault();
			event.stopPropagation();
			event.stopImmediatePropagation();
			updateSelectedItemByListSelection();
		}
		
		protected function onRendererRemoved(event:RendererExistenceEvent):void
		{
			(event.renderer as LookupGridItemRenderer).lookup = null;
		}
		
		protected function onRendererAdded(event:RendererExistenceEvent):void
		{
			(event.renderer as LookupGridItemRenderer).lookup = this;
		}
		
		protected function onKeyDown(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.DOWN){
				++dataGrid.selectedIndex;
				dataGrid.ensureCellIsVisible(dataGrid.selectedIndex);
			}
			if(event.keyCode == Keyboard.UP){
				--dataGrid.selectedIndex;
				dataGrid.ensureCellIsVisible(dataGrid.selectedIndex);
			}
			if(event.keyCode == Keyboard.ENTER){
				updateSelectedItemByListSelection();
			}
		}
		
		private function updateSelectedItemByListSelection():void
		{
			if(dataGrid.selectedIndex<0){
				return;
			}
			if(hasEventListener('changing')){
				var changingEvent:PromiseEvent = new PromiseEvent('changing',dataGrid.selectedItem);
				changingEvent.then(function(res:*):void{
					if(!res.success){
						dataGrid.selectedItem = selectedItem;
					}
					_updateSelectedItemByListSelection();
				});
				dispatchEvent(changingEvent);
			}else{
				_updateSelectedItemByListSelection();
			}
			if(displayPopUp){
				displayPopUp = false;	
			}
		}
		
		private function _updateSelectedItemByListSelection():void{
			if(dataGrid.selectedItem !== selectedItem){
				selectedItem = dataGrid.selectedItem;
				updateText();
				dispatchEvent(new PayloadEvent('change',selectedItem));
			}
			
		}
		
		
		private function get dataProviderArrayCollection():ArrayCollection{
			if(dataProvider is ArrayCollection){
				return dataProvider as ArrayCollection;
			}
			return null;
		}
		
		
		protected function onTextChange(event:TextOperationEvent):void
		{
			if(dataProviderArrayCollection){
				if(textInput.text){
					dataProviderArrayCollection.filterFunction = filterFunction;	
				}else{
					dataProviderArrayCollection.filterFunction = null;
				}
				dataProviderArrayCollection.refresh();
			}
			if((textInput.text == null || textInput.text == '') && selectedItem){
				selectedItem = null;
				dispatchEvent(new PayloadEvent('change',selectedItem));
			}
			if(!displayPopUp){
				displayPopUp = true;
			}
		}
		
		private function filterBasedOnSearchText(item:Object):Boolean
		{
			for each (var column:GridColumn in columns) 
			{
				if(column.labelFunction != null){
					var text:String = column.labelFunction.apply(column,[item, column]);	
					if(text.toUpperCase().indexOf(textInput.text) >= 0){
						return true;
					}
				}else if(column.dataField != null){
					var text_:String = item[column.dataField] != null ? item[column.dataField].toString() : '';	
					if(text_.toUpperCase().indexOf(textInput.text) >= 0){
						return true;
					}
				}
			}
			return false;
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
			if(instance == textInput){
				textInput.removeEventListener(TextOperationEvent.CHANGE,onTextChange);
			}
			if(instance == dataGrid){
				dataGrid.removeEventListener(RendererExistenceEvent.RENDERER_ADD,onRendererAdded);
				dataGrid.removeEventListener(RendererExistenceEvent.RENDERER_REMOVE,onRendererRemoved);
				dataGrid.removeEventListener(MouseEvent.DOUBLE_CLICK,onRendererAdded);
			}
		}
		
	}
}