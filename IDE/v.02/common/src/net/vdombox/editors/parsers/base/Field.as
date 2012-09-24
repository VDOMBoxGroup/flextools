package net.vdombox.editors.parsers.base
{
	import flash.filesystem.File;
	
	import net.vdombox.ide.common.model._vo.TypeVO;
	
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
		
		public var fieldType : String;
		
		/**
		 * name of the field (e.g. var name)
		 */
		
		public var name:String;
		
		/**
		 * top packages, package classes, class members, function local vars
		 */
		public var members:HashMap/*of Field*/ = new HashMap;
		
		//set at resolve time, late
		public var sourcePath:String;
		
		/**
		 * unresolved type
		 */
		public var type:Multiname;
		
		public var typeVO : TypeVO;
		
		/**
		 * parent scope
		 */
		public var parent:Field;
		
		public var children:Array;
		
		/*
		
		/**
		* public, private, protected, internal or namespace
		*/
		public var access:String = 'public';
		
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
		
		public var isClassMethod:Boolean;
		
		public var indent:String;
		
		/**
		 * unresolved type of extended class
		 */
		public var extendz:Multiname;
		
		
		public var defaultValue:String = '';
		
		public var className : String;
		
		public function isAnnonimus():Boolean
		{
			return name == '(';
		}
		
		public function toString():String
		{
			return fieldType + " " + name;
			//return (access ? access + ' ' : '') + fieldType + ' ' + name + (type? ': '+type.type : '');
		}
		
		public function getField( name : String ) : Field
		{
			if ( params.hasKey( name ) )
				return params.getValue( name );
			else if ( members.hasKey( name ) )
				return members.getValue( name );
			else
				return null;
		}
		
		public function getRecursionField( name : String ) : Field
		{
			if ( members.hasKey( name ) )
				return members.getValue( name );
			else
			{
				if ( parent )
					return parent.getRecursionField( name );
				else
					return null;
			}
		}
		
		public function getLastRecursionField( name : String ) : Field
		{
			var f : Field;
			
			if ( parent )
				f =  parent.getLastRecursionField( name );
			
			if ( f )
				return f;
			else if ( members.hasKey( name ) )
				return members.getValue( name );
			else
				return null;
		}
	}
}