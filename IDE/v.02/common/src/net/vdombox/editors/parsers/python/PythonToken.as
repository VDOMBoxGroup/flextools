package net.vdombox.editors.parsers.python
{
	import flash.utils.Dictionary;

	import net.vdombox.editors.parsers.base.Token;

	public class PythonToken extends Token
	{
		public var otstyp : Object; //used to solve names and types

		public var fromZone : Boolean = false;

		public var importZone : Boolean = false;

		public var importFrom : String = "";

		public static const map : Dictionary = new Dictionary( true );

		static private var count : Number = 0;


		public function PythonToken( string : String, type : String, endPos : uint )
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