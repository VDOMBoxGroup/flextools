package net.vdombox.object_editor.model.vo
{
	public class ObjectTypeVO
	{	
		public var filePath:String;
		public var sourceCode:String;
		
		public var actions:Array;
		public var atributes:Array = [];
		public var events:Array;
		public var language:Array;
		public var libraris:Array;
		public var resourses:Array;
		
		//Information
		public var name			:String = "";
		public var className	:String = "";
		public var category		:String = "";
		public var id			:String = "";
		public var version		:String = "";
		public var dynamic		:Boolean = false;	
		public var moveable		:Boolean = false;
		public var resizable	:uint = 0;
		public var container	:uint = 0;		
		public var interfaceType:uint = 0;
		public var optimizationPriority	:uint = 0;
					
		public function ObjectTypeVO()
		{				
		}		
	}
}