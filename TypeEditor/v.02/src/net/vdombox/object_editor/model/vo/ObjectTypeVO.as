package net.vdombox.object_editor.model.vo
{
	import flash.utils.Dictionary;
	import flash.xml.XMLNode;
	
	import mx.utils.UIDUtil;

	public class ObjectTypeVO
	{		
		public var data:XML;
		public var information:XMLList;		
		
//		public var information:Dictionary;
		public var code:Dictionary;
		
		public var actions:Array;
		public var atributes:Array;
		public var events:Array;
		public var language:Array;
		public var libraris:Array;
		public var resourses:Array;
		
		public var name			:String = "";
		public var className	:String = "";
		public var category		:String = "";
		public var id			:String = "";
					
		public function ObjectTypeVO()
		{				
		}		
	}
}