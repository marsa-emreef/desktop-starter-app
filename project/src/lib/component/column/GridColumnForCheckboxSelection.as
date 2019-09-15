package lib.component.column
{
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	
	import spark.components.gridClasses.GridColumn;
	
	public class GridColumnForCheckboxSelection extends GridColumn
	{
		[Bindable]
		public var selectedData:ArrayCollection;
		
		[Bindable]
		/**
		 *  <p>The function specified to the <code>visibleFunction</code> property 
		 *  must have the following signature:</p>
		 *
		 *  <pre>visibleFunction(item:Object, column:GridColumnForCheckboxSelection):Boolean</pre>
		 *
		 *  <p>The <code>item</code> parameter is the data provider item for an entire row.  
		 *  The second parameter is this column object.</p>
		 *
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public var visibleFunction:Function;
		
		[Bindable]
		/**
		 *  <p>The function specified to the <code>enabledFunction</code> property 
		 *  must have the following signature:</p>
		 *
		 *  <pre>enabledFunction(item:Object, column:GridColumnForCheckboxSelection):Boolean</pre>
		 *
		 *  <p>The <code>item</code> parameter is the data provider item for an entire row.  
		 *  The second parameter is this column object.</p>
		 *
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public var enabledFunction:Function;
		
		public function GridColumnForCheckboxSelection(columnName:String=null)
		{
			super(columnName);
			selectedData = new ArrayCollection();
			itemRenderer = new ClassFactory(GridColumnForCheckboxSelectionItemRenderer);
			headerRenderer = new ClassFactory(GridColumnForCheckboxSelectionHeaderItemRenderer);
			visibleFunction = defaultTrueFunction;
			enabledFunction = defaultTrueFunction;
			width = 50;
		}
		
		public function defaultTrueFunction(item:Object, column:GridColumnForCheckboxSelection):Boolean{
			return true;
		}
	}
}