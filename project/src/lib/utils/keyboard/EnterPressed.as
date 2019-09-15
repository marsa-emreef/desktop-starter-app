package lib.utils.keyboard
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class EnterPressed extends KeyboardBinder
	{
		public function EnterPressed()
		{
			super();
			keyCode = Keyboard.ENTER;
		}
	}
}