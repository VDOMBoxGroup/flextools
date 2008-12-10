package vdom.managers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.ToolTip;
	import mx.core.Application;
	import mx.core.Container;
	import mx.managers.CursorManager;
	import mx.managers.SystemManager;
	import mx.managers.ToolTipManager;
	import mx.styles.StyleManager;
	
	import vdom.containers.IItem;
	import vdom.events.ResizeManagerEvent;
	import vdom.events.TransformMarkerEvent;
	import vdom.managers.resizeClasses.TransformMarker;
	import vdom.utils.DisplayUtil;
	
			
[Event( name="RESIZE_COMPLETE", type="vdom.events.ResizeManagerEvent")]

public class ResizeManager extends EventDispatcher
{
	public var itemDrag : Boolean;
	
	private static var instance : ResizeManager;
	
	private var systemManager : SystemManager = Application.application.systemManager;
	
	private var dataManager : DataManager = DataManager.getInstance();
	
	private var topLevelItem : Canvas;

	private var highlightedItem : IItem;
	private var activeItem : IItem;
	private var _selectedItem : IItem;	

	private var moveCursor : Class = StyleManager.getStyleDeclaration("global").getStyle("moveCursor");
	private var cursorID : int;
	
	private var moveMarker : TransformMarker;
	private var selectMarker : TransformMarker;
	
	private var tip : ToolTip;
	
	private var _itemTransform : Boolean;
	private var itemMoved : Boolean;
	
	
	public function ResizeManager()
	{
		
	}
	
	public static function getInstance() : ResizeManager
	{		
		if ( !instance )
			instance = new ResizeManager();

		return instance;
	}
	
	private function get selectedItem() : IItem
	{
		return _selectedItem;
	}
	
	private function set selectedItem( value : IItem ) : void
	{
		if( value != _selectedItem )
		{
			_selectedItem = value;
			
			var rme : ResizeManagerEvent = new ResizeManagerEvent( ResizeManagerEvent.OBJECT_SELECT );
			rme.item = Container( _selectedItem );
			
			dispatchEvent( rme ) 
		}
	}
	
	public function get itemTransform () : Boolean
	{
		return _itemTransform;
	}
	
	public function set itemTransform ( value : Boolean ) : void
	{
		if ( value != _itemTransform )
		{
			_itemTransform = value;
		}
	}
	
	public function init( container : Canvas ) : void
	{
		topLevelItem = container;
		topLevelItem.addEventListener( MouseEvent.MOUSE_DOWN, topLevelItem_mouseDownHandler, true );
		topLevelItem.addEventListener( MouseEvent.MOUSE_OVER, topLevelItem_mouseOverHandler, true );
		topLevelItem.addEventListener( MouseEvent.MOUSE_UP, topLevelItem_mouseUpHandler );
		topLevelItem.addEventListener( MouseEvent.ROLL_OUT, topLevelItem_rollOutHandler );
		topLevelItem.addEventListener( "vdomScroll", topLevelItem_vdomScrollHandler, true );
		
//		topLevelItem.getChildAt( 0 ).addEventListener( "vdomScroll", scrollHandler, true );
		
		
		CursorManager.removeAllCursors();
		
		if( selectMarker )
		{
			if( selectMarker.parent )
				selectMarker.parent.removeChild( selectMarker );
		}
		else
		{
			selectMarker = new TransformMarker( this );
		}
		
		if( moveMarker )
		{
			if( moveMarker.parent )
				moveMarker.parent.removeChild( moveMarker );
		}
		else
		{
			moveMarker = new TransformMarker( this );
		}
		
		Container( topLevelItem.getChildAt( 0 ) ).addChild( selectMarker );
		Container( topLevelItem.getChildAt( 0 ) ).addChild( moveMarker );
		
		moveMarker.addEventListener( TransformMarkerEvent.TRANSFORM_CHANGING, transformChangingHandler );
		moveMarker.addEventListener( TransformMarkerEvent.TRANSFORM_COMPLETE, transformCompleteHandler );
		
		selectMarker.addEventListener( TransformMarkerEvent.TRANSFORM_COMPLETE, transformCompleteHandler );
		selectMarker.addEventListener( TransformMarkerEvent.TRANSFORM_MARKER_SELECTED, markerSelectedHandler );
		
		createToolTip();
	}
	
	public function selectItem( item : IItem = null, showMarker : Boolean = true ) : IItem
	{
		var newSelectedItem : IItem;
		
		if( item == _selectedItem )
			return _selectedItem;
		
		if( item && Container( item ).parent )
		{
			highlightItem( null );
			
			if( Container( item ).parent == topLevelItem )
				showMarker = false;
				
			if( showMarker )
			{
				try
				{
					var objectType : XML = dataManager.getTypeByObjectId( item.objectId );
				
					var itemMoveable : Boolean = 
						( objectType.Information.Moveable == "1" ) ? TransformMarker.MOVE_TRUE : TransformMarker.MOVE_FALSE;
						
					var itemResizable : uint = uint( objectType.Information.Resizable )								
					
//					Container( topLevelItem.getChildAt( 0 )).addChild( selectMarker ); //topLevelItem.addChild( selectMarker );
					
					selectMarker.item = Container( item );
					selectMarker.resizeMode = itemResizable;
					selectMarker.moveMode = itemMoveable;
					
					bringOnTop();
				}
				catch( error : Error )
				{
					selectMarker.item = null;
				}
			}
			else
			{
				selectMarker.item = null;
			}
			
			newSelectedItem = item;
		}
		else
		{
			newSelectedItem = null;
			
			if( selectMarker )
				selectMarker.item = null;
		}
		
		selectedItem = newSelectedItem;
			
		return newSelectedItem;
	}
	
	public function refresh() : void
	{
		if( selectMarker && selectMarker.item )
			selectMarker.refresh();
	}
	
	private function highlightItem( item : IItem, showMarker : Boolean = true ) : IItem
	{	
		if( item == highlightedItem )
			return highlightedItem;
		
		if( cursorID )
		{
			CursorManager.removeCursor( cursorID );
			cursorID = NaN;
		}
		
		if( highlightedItem )
			highlightedItem.drawHighlight( "none" );
		
		if(
			!item ||
			!showMarker || 
			item == selectedItem ||
			Container( item ).parent == topLevelItem
		)
		{
			showToolTip();
			return highlightedItem = item;
		}
		
		var tipText : String = "";
		var moveable : String = "select" ;
		
		try
		{
			var objectDescription : XML = dataManager.getObject( item.objectId );
			var type : XML = dataManager.getTypeByObjectId( item.objectId );
			
			tipText = "Name: " + objectDescription.@Name;
			moveable = ( type.Information.Moveable == "1" ) ? "move" : "select";
		}
		catch( error : Error ) {}
		
		switch( moveable )
		{
			case "move":
			{
				cursorID = CursorManager.setCursor( moveCursor, 2, -10, -10 );
			}
			case "select":
			{
				item.drawHighlight( "0x777777" );
			}
		}
		
		showToolTip( tipText );
		return highlightedItem = item;
	}
	
	private function moveItem( item : IItem ) : void
	{
		if( item && Container( item ).parent )
		{
			//if( moveMarker.parent )
				//moveMarker.parent.removeChild( moveMarker )
			
			var objectType : XML = dataManager.getTypeByObjectId( item.objectId );
			
			var activeItemMoveable : Boolean = 
				( objectType.Information.Moveable == "1") ? TransformMarker.MOVE_TRUE : TransformMarker.MOVE_FALSE;
			
			Container( topLevelItem.getChildAt( 0 ) ).addChild( moveMarker );
			
			moveMarker.item = Container( item );
			moveMarker.resizeMode = TransformMarker.RESIZE_NONE;
			moveMarker.moveMode = activeItemMoveable;
//			moveMarker.visible = true;
			
		}
		else
		{
//			moveMarker.visible = false;
			moveMarker.item = null;
		}
	}
	
	private function showToolTip( text : String = "") : void
	{
		if( text != "")
		{
			systemManager.addEventListener(
				MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler );
			
			tip.text = text;
			tip.visible = true;
		}
		else
		{
			systemManager.removeEventListener(
				MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler );
			
			tip.visible = false;
		}
	}
	
	private function bringOnTop() : void
	{
		if( !selectMarker || !selectMarker.parent )
			return;
		
		var selectMarkerIndex : int = selectMarker.parent.getChildIndex( selectMarker );
		var topIndex : int = selectMarker.parent.numChildren-1;		
		
		if( selectMarkerIndex != topIndex )
		{
			selectMarker.parent.setChildIndex( selectMarker, topIndex );
		}
	}
	
	private function createToolTip() : void
	{
		if( tip )
			ToolTipManager.destroyToolTip( tip );
		
		tip = ToolTip( ToolTipManager.createToolTip( "", 0, 0, null, topLevelItem ));
		tip.setStyle( "backgroundColor", 0xFFFFFF );
		tip.setStyle( "fontSize", 9 );
		tip.setStyle( "cornerRadius", 0 );
		tip.visible = false;
	}
	
	private function getItemUnderMouse() : IItem
	{
		var itemUnderMouse : IItem;
		
		var targetList : Array =
			DisplayUtil.getObjectsUnderMouse( topLevelItem.parent, "vdom.containers::IItem", filterFunction );
		
		if( targetList.length == 0 )
			return itemUnderMouse;
		
		if ( targetList.length > 1 && targetList[ 0 ].contains( targetList[ 1 ] ) )
			itemUnderMouse = targetList[ 1 ];
		else
			itemUnderMouse = targetList[ 0 ];
		
//		if( itemUnderMouse == highlightedItem || itemUnderMouse == selectedItem )
//			itemUnderMouse = null;
		
		return itemUnderMouse;
	}
	
	private function transformChangingHandler( event : TransformMarkerEvent ) : void
	{
		selectMarker.refresh();
	}
	
	private function filterFunction( item : IItem ) : Boolean 
	{
		return !item.isStatic;
	}
	
	private function transformCompleteHandler( event : TransformMarkerEvent ) : void
	{
		var rmEvent : ResizeManagerEvent = new ResizeManagerEvent( ResizeManagerEvent.RESIZE_COMPLETE );
		
		rmEvent.item = event.item;
		rmEvent.properties = event.properties;
		dispatchEvent( rmEvent );
	}
	
	private function markerSelectedHandler( event : TransformMarkerEvent ) : void
	{
		highlightItem( null );
	}
	
	private function topLevelItem_vdomScrollHandler( event : Event ) : void
	{
		if( selectMarker && selectMarker.item )
			selectMarker.refresh();
	}
	
	private function topLevelItem_mouseDownHandler( event : MouseEvent ) : void
	{
		if(!highlightedItem || selectedItem == highlightedItem )
			return;
		
		activeItem = highlightedItem;
		topLevelItem.addEventListener( MouseEvent.MOUSE_MOVE, topLevelItem_mouseMoveHandler, true );
	}
	
	private function topLevelItem_mouseMoveHandler( event : MouseEvent ) : void
	{
		if( 
			event.buttonDown && 
			activeItem && 
			Container( activeItem ).parent != topLevelItem
		)
		{
			highlightItem( null );
			moveItem( activeItem );
			itemMoved = true;
		}
		
		topLevelItem.removeEventListener( MouseEvent.MOUSE_MOVE, topLevelItem_mouseMoveHandler, true );
	}
	
	private function topLevelItem_mouseUpHandler( event : MouseEvent ) : void
	{
		if( !activeItem )
		{
			itemMoved = false;
			return;
		}
		
		var showMarker : Boolean = 
			( Container( activeItem ).parent != topLevelItem ) ? true : false;
		
		if( itemMoved )
		{
			moveItem( null );
			highlightItem( activeItem );
		}
		else
		{
			selectItem( activeItem, showMarker );
		}
		
		itemMoved = false;
		activeItem = null;
	}
	
	private function topLevelItem_rollOutHandler( event : MouseEvent ) : void
	{
		if( tip )
			tip.visible = false;
	}
	
	private function topLevelItem_mouseOverHandler( event : MouseEvent ) : void 
	{
		var itemUnderMouse : IItem;
		var moveable : String;
		
		if(
			selectMarker.item && 
			itemTransform ||
			itemMoved || 
			itemDrag //||
			//selectMarker.markerSelected
		)
		{
			return;
		}
		
		itemUnderMouse = getItemUnderMouse();
		
		highlightItem( itemUnderMouse );
	}
	
	private function systemManager_mouseMoveHandler( event : MouseEvent ) : void 
	{
		tip.x =	systemManager.mouseX + 15;
		tip.y = systemManager.mouseY + 15;
	}
}
}