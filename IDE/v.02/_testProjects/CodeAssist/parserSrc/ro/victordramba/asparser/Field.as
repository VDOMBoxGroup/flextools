/*
 * @Author Dramba Victor
 * 2009
 * 
 * You may use this code any way you like, but please keep this notice in
 * The code is provided "as is" without warranty of any kind.
 */

package ro.victordramba.asparser
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


		/**
		 * function parameters
		 */
		public var params:HashList/*of Field*/ = new HashList;


		public var hasRestParams:Boolean = false;
		public var isGetter:Boolean;
		
		public var isStatic:Boolean;
		
		
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
			return fieldType + ' ' + name + (type? ': '+type.type : '');
		}
	}
}