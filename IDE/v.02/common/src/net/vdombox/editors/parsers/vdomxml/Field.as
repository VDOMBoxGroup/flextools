package net.vdombox.editors.parsers.vdomxml
{

	import ro.victordramba.util.HashList;
	import ro.victordramba.util.HashMap;

	public class Field
	{
		public function Field( fieldType : String = "", pos : uint = 0, name : String = "" )
		{
			this.fieldType = fieldType;
			this.pos = pos;
			this.name = name;
		}

		public var pos : uint;

		/**
		 * can be: top,package,class,function,get,set,var
		 */
		public var fieldType : String;

		/**
		 * name of the field (e.g. var name)
		 */
		public var name : String;


		/**
		 * top packages, package classes, class members, function local vars
		 */
		public var members : HashMap /*of Field*/ = new HashMap

		public function addMember( field : Field ) : void
		{
			members.setValue( field.name, field );
		}

		public function toString() : String
		{
			return fieldType + " " + name;
		}
	}
}