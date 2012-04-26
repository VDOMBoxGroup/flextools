package net.vdombox.powerpack.utils
{

	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.FileUtils;

	public class GeneralUtils
	{
		public static function isCopyCombination( event : KeyboardEvent ) : Boolean
		{
			return isCtrlKeyPressed(event) && event.keyCode == Keyboard.C;
		}
	
		public static function isCutCombination( event : KeyboardEvent ) : Boolean
		{
			return isCtrlKeyPressed(event) && event.keyCode == Keyboard.X;
		}
	
		public static function isPasteCombination( event : KeyboardEvent ) : Boolean
		{
			return isCtrlKeyPressed(event) && event.keyCode == Keyboard.V;
		}
	
		public static function isSelectAllCombination( event : KeyboardEvent ) : Boolean
		{
			return isCtrlKeyPressed(event) && event.keyCode == Keyboard.A;
		}
		
		public static function isCtrlSpaceCombination( event : KeyboardEvent ) : Boolean
		{
			if (isMac)
				return event.altKey && event.keyCode == Keyboard.ESCAPE;
				
			return isCtrlKeyPressed(event) && event.keyCode == Keyboard.SPACE;
		}
		
		public static function isCtrlKeyPressed (event : KeyboardEvent) : Boolean
		{
			return isMac ? event.commandKey : event.ctrlKey;
		}
		
		private static function get isMac () : Boolean
		{
			return FileUtils.OS == FileUtils.OS_MAC;;
		}
		
		
	}
}