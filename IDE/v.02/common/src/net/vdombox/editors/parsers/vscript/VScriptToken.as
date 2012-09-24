package net.vdombox.editors.parsers.vscript
{
	import flash.utils.Dictionary;
	
	import net.vdombox.editors.parsers.base.Field;
	import net.vdombox.editors.parsers.base.Token;
	
	import ro.victordramba.util.HashMap;

	public class VScriptToken extends Token
	{		
		public var fromZone:Boolean = false;
		public var importZone:Boolean = false;
		public var importFrom:String = "";
		public var blockType : String = "";
		public var mainBlockType : String = "";
		public var blockClosed : Boolean = false;
		public var createConstruction : Boolean = false;
		public var className : String;
		
		public static const map:Dictionary = new Dictionary(true);
		
		static private var count:Number = 0;
		
		
		public function VScriptToken(string:String, type:String, endPos:uint) 
		{
			this.string = string;
			this.type = type;
			this.pos = endPos - string.length;
			id = count++;
			map[id] = this;
		}
		
		public function toString():String 
		{
			return string;
		}
	}
}