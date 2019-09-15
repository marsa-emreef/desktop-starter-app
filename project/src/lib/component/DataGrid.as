package lib.component
{
	import flash.events.Event;
	
	import lib.component.skins.DataGridSkin;
	import lib.utils.date.DateUtils;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.effects.AnimateProperty;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;
	
	import spark.components.DataGrid;
	import spark.components.Label;
	import spark.events.GridSortEvent;
	
	public class DataGrid extends spark.components.DataGrid
	{
		[Bindable]
		public var showFooter:Boolean = true;
		
		public var auditField:String;
		
		public var createdByField:String = 'createdBy';	
		public var createdByIdField:String = 'createdById';	
		public var createdOnField:String = 'createdOn';
		
		public var modifiedByField:String = 'modifiedBy';	
		public var modifiedByIdField:String = 'modifiedById';	
		public var modifiedOnField:String = 'modifiedOn';
		
		[SkinPart(required="true")]
		public var auditLabel:Label;
		
		public function DataGrid()
		{
			super();
			setStyle('skinClass',DataGridSkin);
			addEventListener(FlexEvent.VALUE_COMMIT,onValueCommit);
			addEventListener('dataProviderChanged',onDataProviderChanged);
			addEventListener(GridSortEvent.SORT_CHANGE,onSortChange);
			
		}
		
		protected function onSortChange(event:GridSortEvent):void
		{
			grid.verticalScrollPosition = 0;
		}
		
		override protected function partAdded(partname:String,instance:Object):void{
			super.partAdded(partname,instance);
			if(instance == auditLabel){
				auditLabel.text = composeAudit(selectedItem);
			}
		}
		
		protected function onDataProviderChanged(event:Event):void
		{
			if(auditLabel){
				auditLabel.text = '';
			}
		}
		
		protected function onValueCommit(event:FlexEvent):void
		{
			if(auditLabel){
				auditLabel.text = composeAudit(selectedItem);	
			}
		}
		
		override public function set selectedItem(value:Object):void
		{
			super.selectedItem = value;
			if(auditLabel){
				auditLabel.text = composeAudit(selectedItem);
			}
		}
		
		
		public function composeAudit(item:Object):String{
			if(item == null){
				return '';
			}
			var createdBy:String = createdByField in item ? item[createdByField] : '';
			var createdById:String = createdByIdField in item ? item[createdByIdField] : '';
			var createdOn:String = createdOnField in item ? item[createdOnField] : '';
			
			var modifiedBy:String = modifiedByField in item ? item[modifiedByField] : '';
			var modifiedById:String = modifiedByIdField in item ? item[modifiedByIdField] : '';
			var modifiedOn:String = modifiedOnField in item ? item[modifiedOnField] : '';
			
			var text:Array = [];
			if(createdBy){
				text.push('Created by '+createdById+' - '+createdBy+' on '+DateUtils.formatDD_MMM_YYYY_HH_MM(createdOn));
			}
			if(modifiedBy){
				text.push('Modified by '+modifiedById+' - '+modifiedBy+' on '+DateUtils.formatDD_MMM_YYYY_HH_MM(modifiedOn));
			}
			return text.join('\n');
		}
	}
}