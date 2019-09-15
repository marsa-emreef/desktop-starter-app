package lib.utils.keyboard
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class EscapePressed extends KeyboardBinder
	{
		public function EscapePressed()
		{
			super();
			keyCode = Keyboard.ESCAPE;
		}
	}
}