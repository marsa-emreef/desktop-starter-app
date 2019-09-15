package lib.component
{
	
	import lib.component.skins.GlobalFilterSkin;
	import lib.utils.Debounce;
	import lib.utils._;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.gridClasses.GridColumn;
	import spark.components.supportClasses.SkinnableComponent;
	
	
	[Bindable]
	public class GlobalFilter extends SkinnableComponent
	{
		
		[SkinPart(required="true")]
		public var textInput:lib.component.TextInput;
		
		public var dataGrid:DataGrid;
		
		public var filterBefore:Function;
		public var filterAfter:Function;
		public var text:String;
		public function GlobalFilter()
		{
			super();
			setStyle('skinClass',GlobalFilterSkin);
		}
		
		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
		public var onFilterChange:Function = Debounce.create(_onFilterChange,300);
		
		public function _onFilterChange(dp:ArrayCollection=null):void{
			if(dataGrid && dp){
				var collection:ArrayCollection = dp;
				collection.filterFunction = combinationFilterFunction;
				collection.refresh();
				dataGrid.dataProvider = collection;
			}else if(dataGrid != null && dataGrid.dataProvider && dataGrid.dataProvider is ArrayCollection){
				var collection_:ArrayCollection = dataGrid.dataProvider as ArrayCollection;
				collection_.filterFunction = combinationFilterFunction;
				collection_.refresh();
			}
		}
		
		private function combinationFilterFunction(item:*):Boolean
		{
			if(filterBefore != null && !filterBefore.apply(null,[item])){
				return false;
			}
			if(filterFunction.apply(null,[item])){
				if(filterAfter != null && (!filterAfter.apply(null,[item]))){
					return false;
				}
				return true;
			}
			return false;
		}
		
		protected function filterFunction(item:*):Boolean{
			
			if(textInput.text == ''){
				return true;
			}
			if(textInput.text != null && textInput.text.length > 0){
				var text:String = '';
				for (var i:int = 0; i < dataGrid.columns.length; i++) 
				{
					var column:GridColumn = dataGrid.columns.getItemAt(i) as GridColumn;
					if(column.labelFunction != null){
						text = column.labelFunction.apply(null,[item,column]);
						if(text && text.toUpperCase().indexOf(textInput.text) >= 0){
							return true;
						}
					}
					if(column.dataField && column.dataField in item){
						text = item[column.dataField];
						if(text && text.toUpperCase().indexOf(textInput.text) >= 0){
							return true;
						}
					}
				}
			}
			return false;
		}
	}
}