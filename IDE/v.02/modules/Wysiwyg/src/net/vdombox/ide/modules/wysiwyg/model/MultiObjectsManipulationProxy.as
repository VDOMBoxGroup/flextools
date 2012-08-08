package net.vdombox.ide.modules.wysiwyg.model
{
	import flash.system.System;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class MultiObjectsManipulationProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "MultiObjectsManipulationProxy";
		
		public function MultiObjectsManipulationProxy()
		{
			super( NAME );
		}
		
		private var _objectsForManipulation : Object;
		private var renderer : RendererBase;
		private var needSendNotification : Boolean = false;
		
		private var _objectsForPaste : Array;
		private var object : IVDOMObjectVO;
		
		private var needSendPasteNotification : Boolean = false; 
		
		public function saveObjectsPosition( multiSelectRenderers : Object ) : void
		{
			if( !_objectsForManipulation )
				_objectsForManipulation = [];
			
			needSendNotification = false;
			for each ( renderer in multiSelectRenderers )
			{
				needSendNotification = true;
				_objectsForManipulation[ renderer.vdomObjectVO.id ] = multiSelectRenderers[ renderer.vdomObjectVO.id ];
			}
			
			if ( needSendNotification )
				sendNotification( Notifications.MULTI_OBJECTS_POSITION_SAVING );
			
			saveNextObject();
		}
		
		public function saveNextObject() : void
		{
			needSendNotification = true;
			for each ( renderer in _objectsForManipulation )
			{
				needSendNotification = false;
				renderer.savePosition();
				if ( renderer.vdomObjectVO )
					delete _objectsForManipulation[ renderer.vdomObjectVO.id ];
				break;
			}
			
			if ( needSendNotification )
				sendNotification( Notifications.MULTI_OBJECTS_POSITION_SAVED );
		}
		
		public function pasteObjects( objects : Array, rend : Object ) : void
		{
			if ( _objectsForPaste )
				_objectsForPaste = new Array();
			
			needSendPasteNotification = false;
			_objectsForPaste = objects;
			
			var sourceInfo : Array = _objectsForPaste[0].split( " " );
			
			if ( sourceInfo.length != 4 || sourceInfo[0] != "Vlt+VDOMIDE2+" )
				return;
			
			object = rend is RendererBase ? rend.vdomObjectVO : rend as IVDOMObjectVO;
			if ( object is ObjectVO && rend is RendererBase &&
				rend.typeVO.container != 2 && rend.renderVO.parent )
				object = rend.renderVO.parent.vdomObjectVO;
			
			if ( sourceInfo.length > 0 )
				sendNotification( Notifications.MULTI_OBJECTS_POSITION_SAVING );
			
			pasteNextObject();
		}
		
		public function hasNextObjectForPaste() : Boolean
		{
			if ( needSendPasteNotification )
			{
				sendNotification( Notifications.MULTI_OBJECTS_POSITION_SAVED );
				needSendPasteNotification = false;
			}
			if ( !_objectsForPaste || _objectsForPaste.length == 0 ) 
				return false;
			else
				return true;
		}
		
		public function pasteNextObject() : void
		{
			if ( !_objectsForPaste || _objectsForPaste.length == 0 ) 
				return;
			
			var sourceString : String = _objectsForPaste.pop();
			
			if ( _objectsForPaste.length == 0 )
				needSendPasteNotification = true;
			
			var sourceInfo : Array = sourceString.split( " " );
			var sourceAppId : String = sourceInfo[1] as String;
			var sourceObjId : String = sourceInfo[2] as String;
			var typeObject : String = sourceInfo[3] as String;
			
			trace( "Name " + object.name );
			
			if ( typeObject == "1" )
			{
				var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
				sendNotification( Notifications.COPY_REQUEST, { applicationVO : statesProxy.selectedApplication, sourceID : sourceString } );
			}
			else if ( object is PageVO )
				sendNotification( Notifications.COPY_REQUEST, { pageVO : object, sourceID : sourceString } );
			else if ( object is ObjectVO )
				sendNotification( Notifications.COPY_REQUEST, {  objectVO : object, sourceID : sourceString } );
		}
	}
}