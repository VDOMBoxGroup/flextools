package net.vdombox.ide.modules.dataBase.view.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mx.collections.ArrayList;
	import mx.events.CloseEvent;
	
	import net.vdombox.ide.common.events.PopUpWindowEvent;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
	import net.vdombox.ide.common.view.components.VDOMImage;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.common.view.components.windows.NameObjectWindow;
	import net.vdombox.ide.modules.dataBase.events.TableElementEvent;
	import net.vdombox.ide.modules.dataBase.view.skins.TableElementSkin;
	import net.vdombox.utils.WindowManager;
	
	import spark.components.Label;
	import spark.components.SkinnableContainer;
	import spark.components.VGroup;

	public class TableElement extends SkinnableContainer
	{
		
		
		private var _objectVO : ObjectVO;
		private var _attributesVO : VdomObjectAttributesVO;
		
		private var mouseOffcetX : int;
		private var mouseOffcetY : int;
		
		[SkinPart( required="true" )]
		public var attributes : VGroup;
		
		public function TableElement( object : ObjectVO )
		{
			alpha = 0;
			_objectVO = object;
			
			contextMenu = new ContextMenu();
			
			var newItem : ContextMenuItem = new ContextMenuItem("resourceManager.getString( 'DataBase_General', 'table_element_rename' )");
			newItem.addEventListener( Event.SELECT, newSubItemSelectHandler, false, 0, true );
			contextMenu.addItem( newItem );
			
			var gotoItem : ContextMenuItem = new ContextMenuItem("resourceManager.getString( 'DataBase_General', 'table_element_go_to_table' )");
			gotoItem.addEventListener( Event.SELECT, gotoItemSelectHandler, false, 0, true );
			contextMenu.addItem( gotoItem );
			
			var delItem : ContextMenuItem = new ContextMenuItem("resourceManager.getString( 'DataBase_General', 'table_element_delete' )");
			delItem.addEventListener( Event.SELECT, delItemSelectHandler, false, 0, true );
			contextMenu.addItem( delItem );
		}
		
		private function newSubItemSelectHandler( event : Event ) : void
		{
			openRenameWindow();
		}
		
		private function gotoItemSelectHandler( event : Event ) : void
		{
			sendGoToTable();
		}
		
		private function delItemSelectHandler( event : Event ) : void
		{
			Alert.setPatametrs( "Delete", "Cancel", VDOMImage.Delete );
			
			Alert.Show(resourceManager.getString( "DataBase_General", "delete_table" ) + "?" ,AlertButton.OK_No, parentApplication, closeHandler);
			
			function closeHandler( event : CloseEvent ) : void
			{
				if (event.detail == Alert.YES)
					dispatchEvent( new TableElementEvent ( TableElementEvent.DELETE ) );
			}
		}
		
		public function get attributesVO():VdomObjectAttributesVO
		{
			return _attributesVO;
		}

		public function set attributesVO(value:VdomObjectAttributesVO):void
		{
			_attributesVO = value;
			
			refresh();
		}

		[Bindable]
		public function get objectVO():ObjectVO
		{
			return _objectVO;
		}
		
		public function set objectVO(value:ObjectVO):void
		{
			_objectVO = value;
			//dispatchEvent( new TableElementEvent( TableElementEvent.CHANGE ) );
		}
		
		public function get objectID():String
		{
			return _objectVO.id;
		}
		
		override public function stylesInitialized():void 
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", TableElementSkin );
		}
		
		private function getAttributeByName( _name : String ) : AttributeVO
		{
			for each ( var attribute : AttributeVO in _attributesVO.attributes )
			{
				if ( attribute.name == _name )
					return attribute;
			}
			
			return null;
		}
		
		private function refresh() : void
		{
			var attributeVO : AttributeVO;
			
			
			attributeVO = getAttributeByName( "width" );
			
			if ( attributeVO )
				width = int( attributeVO.value );
			
			attributeVO = getAttributeByName( "height" );
			
			if ( attributeVO )
				height = int( attributeVO.value );
			
			attributeVO = getAttributeByName( "top" );
			
			if ( attributeVO )
				y = int( attributeVO.value );
			
			attributeVO = getAttributeByName( "left" );
			
			if ( attributeVO )
				x = int( attributeVO.value );
			
			alpha = 1;
		}
		
		public function  sendCreationCompleteTable():void
		{
			dispatchEvent( new TableElementEvent( TableElementEvent.CREATION_COMPLETE ) );
		}
		
		public function mouseDownHandler() : void
		{
			stage.addEventListener( MouseEvent.MOUSE_UP, stage_mouseUpHandler );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler );
			
			mouseOffcetX = mouseX;
			mouseOffcetY = mouseY;
		}
		
		protected function stage_mouseMoveHandler( event : MouseEvent ) : void
		{
			var newX : int = parent.mouseX - mouseOffcetX;
			var newY : int = parent.mouseY - mouseOffcetY;
			
			if ( newX < 0 )
				newX = 0;
			x = newX;
			
			if ( newY < 0 )
				newY = 0;
			y = newY;
			
			attributesVO.getAttributeVOByName("left").value = x.toString();
			attributesVO.getAttributeVOByName("top").value = y.toString();
		}
		
		protected function stage_mouseUpHandler( event : MouseEvent ) : void
		{
			if ( !stage )
				return;
			
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler );
			stage.removeEventListener( MouseEvent.MOUSE_UP, stage_mouseUpHandler );
			
			var eventSave : TableElementEvent = new TableElementEvent( TableElementEvent.SAVE );
			eventSave.value = attributesVO;
			dispatchEvent( eventSave );
		}
		
		public function mouseDownAngleHandler( event : MouseEvent ) : void
		{
			
			stage.addEventListener( MouseEvent.MOUSE_UP, stage_mouseUpAngleHandler );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, stage_mouseMoveAngleHandler );
			
			mouseOffcetX = 15 - event.localX;
			mouseOffcetY = 15 - event.localY;
		}
		
		protected function stage_mouseMoveAngleHandler( event : MouseEvent ) : void
		{
			var newW : Number = parent.mouseX - x + mouseOffcetX;
			var newH : Number = parent.mouseY - y + mouseOffcetY;
			
			if ( newW < 1 )
				newW = 1;
			width = newW;
			
			if ( newH < 1 )
				newH = 1;
			height = newH;
			
			attributesVO.getAttributeVOByName("width").value = width.toString();
			attributesVO.getAttributeVOByName("height").value = height.toString();
		}
		
		protected function stage_mouseUpAngleHandler( event : MouseEvent ) : void
		{
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, stage_mouseMoveAngleHandler );
			stage.removeEventListener( MouseEvent.MOUSE_UP, stage_mouseUpAngleHandler );
			
			var eventSave : TableElementEvent = new TableElementEvent( TableElementEvent.SAVE );
			eventSave.value = attributesVO;
			dispatchEvent( eventSave );
		}
		
		public function openRenameWindow() : void
		{
			var renameWindow : NameObjectWindow = new NameObjectWindow( _objectVO.name, resourceManager.getString( "DataBase_General", "renaem_table_window_title" ) );	
			renameWindow.addEventListener( PopUpWindowEvent.APPLY, applyHandler );
			renameWindow.addEventListener( PopUpWindowEvent.CANCEL, cancelHandler );
			
			WindowManager.getInstance().addWindow(renameWindow, this.skin, true);
			
			function applyHandler( event : PopUpWindowEvent ) : void
			{
				_objectVO.name = event.name;
				WindowManager.getInstance().removeWindow( renameWindow );
				dispatchEvent( new TableElementEvent ( TableElementEvent.NAME_CHANGE ) );
			}
			
			function cancelHandler( event : PopUpWindowEvent ) : void
			{
				WindowManager.getInstance().removeWindow( renameWindow );
			}
		}
		
		public function sendGoToTable() : void
		{
			dispatchEvent( new TableElementEvent ( TableElementEvent.GO_TO_TABLE ) );
		}
		
		public function setTableHeaders( tableStructureXML : XML ):void 
		{
			attributes.removeAllElements();
			var i : int = 0;
			for each (var xmlHeader:XML in tableStructureXML.column) 
			{
				var labelAttribute : ColumnElement = new ColumnElement();
				labelAttribute.columnXML = xmlHeader;
				if ( ++i == 2 )
				{
					i = 0;
					labelAttribute.fon = true;
				}
				attributes.addElement( labelAttribute );
					
			}

			
			
		}
		
	}
}