package lib.component
{
	
	import lib.component.skins.LabeledSkin;
	
	import spark.components.SkinnableContainer;
	
	
	
	public class Labeled extends SkinnableContainer
	{
		[Bindable]
		public var label:String;
		
		public function Labeled()
		{
			super();
			setStyle('skinClass',LabeledSkin);
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
		
	}
}