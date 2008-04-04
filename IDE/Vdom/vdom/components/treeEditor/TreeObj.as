package vdom.components.treeEditor
{
	import mx.messaging.channels.StreamingAMFChannel;
	
	public class TreeObj extends Object
	{
		
		public var name:String ='';
		public var depth:int;
		public var mapX:int;
		public var mapY:int;
		public var marked:Boolean = false;
		private var masChilds:Array = null ;
		private var _parent:TreeObj = null;
		
		public function TreeObj(str:String)
		{
			name = str;
			//trace(name);
		}
// cell flor round
		public function correctPosition():void
		{
			var minX:int = mapX;
			var maxX:int = -1;
			
			if(masChilds == null) return;
			if(masChilds.length == 1) return;
			
			for (var i:String in masChilds)
			{
				if(masChilds[i].mapX > maxX) maxX = masChilds[i].mapX;
				//if(masChilds[i].mapY < minX) minX = masChilds[i].mapY;
			}
			
			mapX = Math.floor((maxX + minX) / 2);
		//	trace( minX+' : '+ maxX +' : '+ mapX);
			
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