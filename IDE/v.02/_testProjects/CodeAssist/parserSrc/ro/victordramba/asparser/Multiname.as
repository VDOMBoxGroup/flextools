/*
 * @Author Dramba Victor
 * 2009
 * 
 * You may use this code any way you like, but please keep this notice in
 * The code is provided "as is" without warranty of any kind.
 */

package ro.victordramba.asparser
{
	import ro.victordramba.util.HashMap;

	internal class Multiname
	{
		public function Multiname(type:String=null, imports:HashMap=null)
		{
			this.imports = imports;
			this.type = type;
		}
		
		public var resolved:Field;
		public var imports:HashMap;
		public var type:String;
		
		//public var resolved:Field;
		
		public function toString():String
		{
			return '[Multiname '+type+']';
		}
	}
}