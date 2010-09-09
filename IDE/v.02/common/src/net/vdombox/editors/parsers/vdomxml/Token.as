package net.vdombox.editors.parsers.vdomxml
{
	import flash.utils.Dictionary;

	import ro.victordramba.util.HashMap;

	internal class Token
	{
		public static const TAGNAME : String = "tagName";
		public static const OPENTAG : String = "openTag";
		public static const CLOSETAG : String = "closeTag";
		public static const ATTRIBUTENAME : String = "attributeName";
		public static const ATTRIBUTEVALUE : String = "attributeValue";
		public static const EQUAL : String = "equal";
		public static const PROCESSING_INSTRUCTIONS : String = "processingInstructions";
		public static const CDATA : String = "cdata";
		public static const COMMENT : String = "comment";
		public static const SYMBOL : String = "symbol";

		public var string : String;
		public var type : String;
		public var pos : uint;
		public var id : uint;

		public var children : Array /*of Token*/;
		public var parent : Token;

		public var scope : Field; //lexical scope
		public var imports : HashMap; //used to solve names and types

		public static const map : Dictionary = new Dictionary( true );

		static private var count : Number = 0;


		public function Token( string : String, type : String, endPos : uint )
		{
			this.string = string;
			this.type = type;
			this.pos = endPos - string.length;
			id = count++;
			map[ id ] = this;
		}

		public function toString() : String
		{
			return string;
		}
	}
}