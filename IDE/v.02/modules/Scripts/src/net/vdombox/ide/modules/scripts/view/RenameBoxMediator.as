package net.vdombox.ide.modules.scripts.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.editors.parsers.base.Controller;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.scripts.events.RenameBoxEvent;
	import net.vdombox.ide.modules.scripts.model.GoToPositionProxy;
	import net.vdombox.ide.modules.scripts.view.components.RenameBox;
	import net.vdombox.ide.modules.scripts.view.components.RenameTreeItemRenderer;
	import net.vdombox.ide.modules.scripts.view.components.ScriptArea;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class RenameBoxMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "RenameBoxMediator";
		
		private var pages : Array;
		
		private var findProgress : Boolean;
		private var pagesCountInput : int;
		
		private var goToDefenitionProxy : GoToPositionProxy;
		
		public function RenameBoxMediator( viewComponent : ScriptArea )
		{
			super( NAME, viewComponent );
		}
		
		override public function onRegister() : void
		{
			addHandlers();
			
			goToDefenitionProxy = facade.retrieveProxy( GoToPositionProxy.NAME ) as GoToPositionProxy;
		}
		
		override public function onRemove() : void
		{
			removeHandlers();
		}
		
		public function get scriptArea() : ScriptArea
		{
			return viewComponent as ScriptArea;
		}
		
		public function get renameBox() : RenameBox
		{
			return scriptArea.renameBox;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( Notifications.OPEN_RENAME_IN_SCRIPT);
			//interests.push( Notifications.PAGES_GETTED );
			
			//interests.push( Notifications.ALL_SERVER_ACTIONS_GETTED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			switch ( name )
			{
				case Notifications.OPEN_RENAME_IN_SCRIPT:
				{
					if ( scriptArea.currentState != "rename" )
					{
						scriptArea.currentState = "rename";
					}
					
					renameBox.oldName = body.oldName;
					renameBox.actionVO = body.actionVO;
					renameBox.controller = body.controller;
					
					var global : Boolean = body.global;
					
					if ( global )
					{
						findProgress = true;
						pagesCountInput = 0;
						
						var pageVO : PageVO;
						for each ( pageVO in pages )
						{
							sendNotification( Notifications.GET_ALL_SERVER_ACTIONS, pageVO );
						}
					}
					else
					{
						renameBox.getRenameData();
					}
					
					break;
				}
					
				case Notifications.PAGES_GETTED:
				{
					pages = body as Array;
					
					break;
				}
					
				case Notifications.ALL_SERVER_ACTIONS_GETTED:
				{					
					renameBox.findStringInServerActions( body );
					
					pagesCountInput++;
					
					/*if ( pagesCountInput == pages.length )
					{
						pagesFindInput = 0;
						pagesStructure = new XMLList();
						
						for each ( var pageVO : PageVO in findBox.containerPages )
						{
							sendNotification( Notifications.GET_STRUCTURE, { pageVO: pageVO, isFind : true } );
						}
						
						sendNotification( Notifications.GET_LIBRARIES, { applicationVO : statesProxy.selectedApplication, isFind : true } );
					}*/
					
					break;
				}
					
			}
		}
		
		private function addHandlers() : void
		{
			if ( !renameBox )
				scriptArea.addEventListener( RenameBoxEvent.CREATION_COMPLETE, addHandlers2, true, 0, true );
			else
				addHandlers2();
		}
		
		private function addHandlers2(event : RenameBoxEvent = null) : void
		{
			renameBox.addEventListener( RenameBoxEvent.RENAME_IN_ACTION, renameInActionHandler );
			renameBox.addEventListener( RenameBoxEvent.DOUBLE_CLICK, openScriptHandler, true, 0, true );
		}
		
		private function removeHandlers() : void
		{
			if ( renameBox )
			{
				renameBox.removeEventListener( FlexEvent.CREATION_COMPLETE, addHandlers2 );
				renameBox.removeEventListener( RenameBoxEvent.RENAME_IN_ACTION, renameInActionHandler );
			}
		}
		
		private function renameInActionHandler( event : RenameBoxEvent ) : void
		{
			sendNotification( Notifications.RENAME_IN_ACTION, { actionVO : renameBox.actionVO, words : event.detail.words, oldName : renameBox.oldName, newName : event.detail.newName } );
		}
		
		private function getServerActionsHandler( event : RenameBoxEvent ) : void
		{
			var pageVO : PageVO;
			for each ( pageVO in pages )
			{
				sendNotification( Notifications.GET_ALL_SERVER_ACTIONS, pageVO );
			}
		}
		
		private function openScriptHandler( event : RenameBoxEvent ) : void
		{
			var findTreeCodeItemRenderer : RenameTreeItemRenderer = event.target as RenameTreeItemRenderer;
			
			var detail : XML = findTreeCodeItemRenderer.data as XML;
			
			if ( !renameBox.actionVO )
				return;
			
			
			goToDefenitionProxy.add( renameBox.actionVO, detail.@index, renameBox.oldName.length );
			
			sendNotification( Notifications.GET_SCRIPT_REQUEST, { actionVO : renameBox.actionVO, check : false } );
		}
	}
}