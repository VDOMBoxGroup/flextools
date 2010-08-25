/* license section

   Flash MiniBuilder is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Flash MiniBuilder is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.


   Author: Victor Dramba
   2009
 */


package parsers.xml
{
	import flash.utils.Dictionary;

	import ro.victordramba.util.HashMap;

	internal class Token
	{
		public static const TAGNAME : String = "tagName";
		public static const ATTRIBUTENAME : String = "attributeName";
		public static const ATTRIBUTEVALUE : String = "attributeValue";
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