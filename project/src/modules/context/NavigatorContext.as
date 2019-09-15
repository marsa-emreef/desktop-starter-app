package modules.context
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import lib.page.dialog.DialogContainer;
	import lib.page.dialog.DialogPanel;
	import lib.page.dialog.DialogPanelBase;
	import lib.utils.ColorCoding;
	import lib.utils.IconsChar;
	import lib.utils.PayloadEvent;
	import lib.utils.Promise;
	
	import spark.components.Group;

	[Bindable]
	[Event(name="historyBackward", type="flash.events.Event")]
	[Event(name="historyForward", type="flash.events.Event")]
	[Event(name="loadModule", type="lib.utils.PayloadEvent")]
	public class NavigatorContext extends Group
	{
		public function NavigatorContext()
		{
			super();
		}
		
		public var dialogContainer:DialogContainer;
		
		public function loadModule(module:String):void{
			dispatchEvent(new PayloadEvent('loadModule',module));
		}
		
		public function historyBack():void{
			dispatchEvent(new Event('historyBackward'));
		}
		
		public function historyForward():void{
			dispatchEvent(new Event('historyForward'));
		}
		
		public function showConfirmation(text:String,type:uint):Promise
		{
			return dialogContainer.show(text,IconsChar.help_outline,type,ColorCoding.YELLOW);
		}
		
		public function showWarning(text:String,type:uint):Promise
		{
			return dialogContainer.show(text,IconsChar.warning,type,ColorCoding.RED);
		}
		
		public function showError(text:String):Promise
		{
			return dialogContainer.show(text,IconsChar.error_outline,DialogPanel.OK,ColorCoding.RED);
		}
		
		public function showDialogPanel(panel:DialogPanelBase):Promise
		{
			return dialogContainer.showDialog(panel);
		}
	}
}