package PowerPack.com.mdm
{
	import mdm.Menu;
	import mdm.*;
	
	public class MDMContextMenu
	{
		// Context menu types
		public static const CMT_CANVAS:String = "GraphCanvas";
		public static const CMT_NODE:String = "GraphNode";
		public static const CMT_ARROW:String = "GraphArrow";
		
		public static var curObject:Object = null; 

		public static var contextMenuItems:Array = new Array(
	       	{caption:"Add State", type:CMT_CANVAS, added:false},
	       	{caption:"Paste", type:CMT_CANVAS, added:false},
	       		
			{caption:"Add Transition", type:CMT_NODE, added:false},
			{caption:"Delete Node", type:CMT_NODE, added:false},
			{caption:"Copy Node", type:CMT_NODE, added:false},

			{caption:"divider", type:CMT_NODE, added:false},
			
			{caption:"Initial", type:CMT_NODE, added:false},
			{caption:"Terminal", type:CMT_NODE, added:false},

			{caption:"divider", type:CMT_NODE, added:false},
			
			{caption:"Normal", type:CMT_NODE, added:false},
			{caption:"Sub Graph", type:CMT_NODE, added:false},
			{caption:"Command", type:CMT_NODE, added:false},
			
			{caption:"Select Transition", type:CMT_ARROW, added:false},
			{caption:"Delete Arrow", type:CMT_ARROW, added:false},
			{caption:"Enable Arrow", type:CMT_ARROW, added:false},
			{caption:"Highlight Arrow", type:CMT_ARROW, added:false}
		);	
		
		public static function addMenuItemsByType(type:String):void
		{
			for(var i:int=0; i<contextMenuItems.length; i++)
			{
				if(type==contextMenuItems[i].type)
				{
					if(contextMenuItems[i].caption=="divider")
						mdm.Menu.Context.insertDivider();
					else
		       			mdm.Menu.Context.insertItem(contextMenuItems[i].caption);	
		       		contextMenuItems[i].added = true;		       	
			 	}
			}
		}
		
		public static function getMenuItemEventName(item:String):String
		{
 			var rePattern:RegExp = /\.| /gi;  
 			var caption:String;
 			
 			caption = "onContextMenuClick_" + item.replace(rePattern, "_");

			return caption;			
		}
		
		public static function refreshMenu(object:Object):void
		{
			curObject = object;
			var enabledMenu:Boolean = false;			
			
			for(var i:int=0; i<contextMenuItems.length; i++)
			{
				if(!contextMenuItems[i].added)
					continue;
				
				if(contextMenuItems[i].caption == "divider")
					continue;
					
				if(curObject && curObject.className==contextMenuItems[i].type)
				{
					enabledMenu = true;	
					mdm.Menu.Context.itemVisible(contextMenuItems[i].caption, true);				
				}
				else
				{
					mdm.Menu.Context.itemVisible(contextMenuItems[i].caption, false);
				}
			}
			
			if(enabledMenu)
				Menu.Context.enable();
			else
				Menu.Context.disable();
		}
	}
}