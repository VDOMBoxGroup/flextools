package PowerPack.com.utils
{
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
	
public class GeneralUtils
{
	public static function isCopyCombination(event:KeyboardEvent):Boolean
	{
		if(event.controlKey && event.keyCode==Keyboard.C)
			return true;
		return false; 
	}
		
	public static function isCutCombination(event:KeyboardEvent):Boolean
	{
		if(event.controlKey && event.keyCode==Keyboard.X)
			return true;
		return false; 
	}

	public static function isPasteCombination(event:KeyboardEvent):Boolean
	{
		if(event.controlKey && event.keyCode==Keyboard.V)
			return true;
		return false; 
	}

	public static function isSelectAllCombination(event:KeyboardEvent):Boolean
	{
		if(event.controlKey && event.keyCode==Keyboard.A)
			return true;
		return false; 
	}
}
}