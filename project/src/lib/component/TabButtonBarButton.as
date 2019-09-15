package lib.component
{
	import flash.events.MouseEvent;
	
	import lib.component.skins.TabBarButtonSkin;
	
	import spark.components.ButtonBarButton;
	import spark.components.Label;
	
	public class TabButtonBarButton extends ButtonBarButton
	{
		
		public function TabButtonBarButton()
		{
			super();
			setStyle('skinClass',TabBarButtonSkin);
		}
		
		override protected function partAdded(partName:String, instance:Object):void{
			super.partAdded(partName,instance);
		}
		
	}
}