package net.vdombox.object_editor.model.vo
{
	import mx.collections.ArrayCollection;

	public class ObjectTypeVO
	{	
		public var filePath:String;
		public var sourceCode:String;

		public var events     : ArrayCollection = new ArrayCollection();
		public var actions    : ArrayCollection = new ArrayCollection();
		[Bindable]
		public var languages  : ArrayCollection = new ArrayCollection();
		public var libraris   : ArrayCollection = new ArrayCollection();
		public var resourses  : ArrayCollection = new ArrayCollection();
		public var attributes : ArrayCollection = new ArrayCollection();

		//Information
		public var id			:String = "";
		[Bindable] 
		public var name			:String = "";
		public var dynamic		:Boolean = false;	
		public var version		:String = "";
		public var moveable		:Boolean = false;
		public var category		:String = "";
		public var className	:String = "";
		public var resizable	:uint = 0;
		public var container	:uint = 0;		
		public var interfaceType:uint = 0;
		public var optimizationPriority	:uint = 0;

		public function ObjectTypeVO()
		{				
		}		
	}
}

