package net.vdombox.object_editor.model.vo
{
	import mx.collections.ArrayCollection;

	public class ObjectTypeVO
	{	
		public var filePath:String;
		public var sourceCode:String;

		[Bindable]
		public var events     : ArrayCollection = new ArrayCollection();
		[Bindable]
		public var actionContainers    : ArrayCollection = new ArrayCollection();

		[Bindable]
		public var languages  : LanguagesVO		= new LanguagesVO();
		[Bindable]
		public var libraries  : ArrayCollection = new ArrayCollection();
		public var resources  : ArrayCollection = new ArrayCollection();
		[Bindable]
		public var attributes : ArrayCollection = new ArrayCollection();

		//Information
		public var id			:String = "";
		public var category		:String = "";
		public var className	:String = "";
		[Bindable]
		public var container	:uint = 0;
		[Bindable]
		public var containers	:String = "";		

		public var description	:String = "#Lang(002)";
		public var displayName	:String = "#Lang(001)";

		public var dynamic		:Boolean = false;
		public var interfaceType:uint = 0;
		[Bindable] 
		public var name			:String = "";
		public var moveable		:Boolean = false;
		public var optimizationPriority	:uint = 0;
		public var resizable	:uint = 0;
		public var version		:String = "";

		public var XMLScriptName	:String = "";
		public var renderType		:String = "";
		public var remoteMethods	:String = "";
		public var handlers			:String = "";

		// images
		public var icon				:String = "";
		public var editorIcon		:String = "";
		public var structureIcon	:String = "";

		public function ObjectTypeVO()
		{	

		}		
	}
}

