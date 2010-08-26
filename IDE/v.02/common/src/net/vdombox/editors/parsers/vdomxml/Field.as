package net.vdombox.editors.parsers.vdomxml
{
	
	import ro.victordramba.util.HashList;
	import ro.victordramba.util.HashMap;

	public class Field
	{
		public function Field(fieldType:String='', pos:uint=0, name:String='')
		{
			this.fieldType = fieldType;
			this.pos = pos;
			this.name = name;
		}
		
		//set at resolve time, late
		public var sourcePath:String;

		public var pos:uint;

		/**
		 * can be: top,package,class,function,get,set,var
		 */
		public var fieldType:String;

		/**
		 * unresolved type
		 */
		public var type:Multiname;


		/**
		 * name of the field (e.g. var name)
		 */
		public var name:String;


		/**
		 * parent scope
		 */
		public var parent:Field;

		/*

		/**
		 * public, private, protected, internal or namespace
		 */
		public var access:String = 'internal';

		/**
		 * top packages, package classes, class members, function local vars
		 */
		public var members:HashMap/*of Field*/ = new HashMap
		
		public function addMember(field:Field, isStatic:Boolean):void
		{
			field.isStatic = isStatic;
			members.setValue(field.name, field);
		}


		/**
		 * function parameters
		 */
		public var params:HashList/*of Field*/ = new HashList;


		public var hasRestParams:Boolean = false;
		
		public var isGetter:Boolean;
		
		public var isStatic:Boolean;
		
		public var indent:String;
		
		/**
		 * unresolved type of extended class
		 */
		public var extendz:Multiname;
		

		public var defaultValue:String = '';
		
		public function isAnnonimus():Boolean
		{
			return name == '(';
		}
		
		public function toString():String
		{
			return (access ? access + ' ' : '') + fieldType + ' ' + name + (type? ': '+type.type : '');
		}
	}
}