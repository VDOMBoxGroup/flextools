package vdom.components.treeEditor
{
	public class TreeObj extends Object
	{
		
		public var name:String ='';
		public var depth:int;
		public var mapX:int;
		public var mapY:int;
		private var masChilds:Array = null ;
		private var _parent:TreeObj = null;
		
		public function TreeObj(str:String)
		{
			name = str;
			//trace(name);
		}

		public function set child(trChld:TreeObj):void
		{
			if (masChilds == null) masChilds = new Array();
			masChilds[trChld.name] = trChld;
			//trace(name +' have child: ' + masChilds[trChld.name].name);
		}
		
		public function get childs():Array
		{
			return masChilds;
			//trace(name +' have child: ' + masChilds[trChld.name].name);
		}
		
		public function set parent(trChld:TreeObj):void
		{
			_parent = trChld;
		}
		
		public function get parent():TreeObj
		{
			return _parent;
		}
	}
}