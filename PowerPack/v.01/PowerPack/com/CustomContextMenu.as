package PowerPack.com
{	
	import flash.events.ContextMenuEvent;
	import flash.events.EventDispatcher;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mx.collections.ArrayCollection;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.utils.ObjectProxy;
	
	public class CustomContextMenu extends EventDispatcher
	{
		private static const CHECKED_MARKER:String = "· ";
		private static const UNCHECKED_MARKER:String = "  ";
		
		private var cm:ContextMenu;
		[Bindable]
		public var items:ArrayCollection;		
		
		public function CustomContextMenu(contextMenu:ContextMenu):void
		{
			cm = contextMenu;
			items = new ArrayCollection();
		}
		
		public function addItem(	id:String,
									caption:String,
									listener:Function,
									separatorBefore:Boolean = false, 
									enabled:Boolean = true, 
									visible:Boolean = true,
									checked:Boolean = false,
									group:String = null ):ObjectProxy
		{
			if(!cm)
				return null;
				
			if(!items)
				items = new ArrayCollection();
				
			if(!cm.customItems)
				cm.customItems = [];
				
			var objItem:Object = new Object();
			objItem.id = id;
			objItem.name = caption;
			objItem.contextMenuItem = new ContextMenuItem(caption, separatorBefore, enabled, visible);
			objItem.listener = listener;
			objItem.checked = checked;			
			objItem.group = group;

			if(checked && !group)
				objItem.group = "";
			
        	cm.customItems.push(objItem.contextMenuItem);
        	objItem.contextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, listener);
        	objItem.contextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, selectHandler);				

			var objProxy:ObjectProxy = new ObjectProxy(objItem);
			
			if(group && group.length>0 && checked)
			{
				for each(var item:ObjectProxy in items)
				{
					if(group==item.group)
					{
						item.checked = false;
					}
				}
			}
			
			items.addItem(objProxy);
						
			objProxy.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, updateHandler);
			
			process();
			
			return objProxy;
		}
		
		private function selectHandler(event:ContextMenuEvent):void
  		{
  			var item:ObjectProxy = getItem(ContextMenuItem(event.target));  			
  			
  			process(item);
  		}

		private function updateHandler(event:PropertyChangeEvent):void
  		{	
  			if(event.kind==PropertyChangeEventKind.UPDATE)
  			{
  				var cmItem:ContextMenuItem = ContextMenuItem(event.target.contextMenuItem);
  				
  				if(event.property=="listener")
  				{
  					cmItem.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, Function(event.oldValue));
  					cmItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, Function(event.newValue));
  				}
  				else
  				{
  					process();  				
  				}
  			}
  		}
		
		public function process(item:Object = null):void
		{
			if(item)
			{  			
  				if(item.checked && !item.group)
  				{
  					item.group = "";
  				}

  				if(item.group=="")
  				{
  					item.checked = (item.checked ? false : true);
  				}
  					
  				if(item.group && item.group.length>0 && !item.checked)
  				{
  					for each(var elm:ObjectProxy in items)
  					{
  						if(elm.group==item.group)
  							elm.checked = false;
  					}
  					item.checked = true;  					
  				}
  			}
  			
  			for each(elm in items)
  			{
  				ContextMenuItem(elm.contextMenuItem).caption = 
  					(elm.checked?CHECKED_MARKER:UNCHECKED_MARKER) +
  					elm.name;
  			}  			 			
		}	
			
		public function getItemById(id:String):ObjectProxy
		{
			for each(var item:ObjectProxy in items)
			{
				if(item.id == id)
					return item;
			}
			return null;
		}

		public function getItemByName(name:String):ObjectProxy
		{
			for each(var item:ObjectProxy in items)
			{
				if(item.name == name)
					return item;
			}
			return null;
		}
					
		public function getItemByCaption(caption:String):ObjectProxy
		{
			for each(var item:ObjectProxy in items)
			{
				if(ContextMenuItem(item.contextMenuItem).caption == caption)
					return item;
			}
			return null;
		}
		
		public function getItem(cmItem:ContextMenuItem):ObjectProxy
		{
			for each(var item:ObjectProxy in items)
			{
				if(item.contextMenuItem == cmItem)
					return item;
			}
			return null;
		}	
			
		public function clear():void
		{
			if(items)
			{
				for each(var item:ObjectProxy in items)
				{
					item.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, updateHandler);
					item.contextMenuItem.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, item.listener);
					item.contextMenuItem.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, selectHandler);
					item.contextMenuItem = null;					
				}
				items.removeAll();
				cm.customItems = [];
			}			
		}
	}
}