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
			return FileUtils.OS == FileUtils.OS_MAC;
		}
		
		public static function equalArrays (array1:Array, array2:Array) : Boolean
		{
			if (!array1 && !array2)
				return true;
			
			if ((array1 && !array2) || (array2 && !array1))
				return false;
			
			if (array1.length != array2.length)
				return false;
			
			if (array1 == array2)
				return true;
			
			for each(var i:Object in array1) 
			{
				if (array2.indexOf(i) == -1)
					return false;
			}
			
			for each(i in array2) 
			{
				if (array1.indexOf(i) == -1)
					return false;
			}
			
			return true;
				
		}
		
	}
}