package net.vdombox.ide.modules.tree.view
{
	import flash.display.DisplayObjectContainer;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.modules.tree.events.LinkageEvent;
	import net.vdombox.ide.modules.tree.events.TreeElementEvent;
	import net.vdombox.ide.modules.tree.events.WorkAreaEvent;
	import net.vdombox.ide.modules.tree.model.StatesProxy;
	import net.vdombox.ide.modules.tree.model.StructureProxy;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeLevelVO;
	import net.vdombox.ide.modules.tree.view.components.Linkage;
	import net.vdombox.ide.modules.tree.view.components.TreeElement;
	import net.vdombox.ide.modules.tree.view.components.WorkArea;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Group;
	import spark.effects.Move;
	import spark.effects.easing.EaseInOutBase;

	public class WorkAreaMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "TreeCanvasMediator";

		public function WorkAreaMediator( viewComponent : WorkArea )
		{
			super( NAME, viewComponent );
		}

		private var statesProxy : StatesProxy;
		private var structureProxy : StructureProxy;

		private var isActive : Boolean;

		public function get workArea() : WorkArea
		{
			return viewComponent as WorkArea;
		}

		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			structureProxy = facade.retrieveProxy( StructureProxy.NAME ) as StructureProxy;

			isActive = false;

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );

			interests.push( Notifications.PAGE_DELETED );
			interests.push( StatesProxy.SELECTED_TREE_LEVEL_CHANGED );
			interests.push( StatesProxy.SELECTED_APPLICATION_CHANGED );

			interests.push( Notifications.TREE_ELEMENTS_CHANGED );
			interests.push( Notifications.TREE_ELEMENT_ADD );
			interests.push( Notifications.LINKAGES_CHANGED );
			interests.push( Notifications.LINKAGES_INDEX_UPDATE );

			interests.push( Notifications.APPLICATION_STRUCTURE_SETTED );
			
			interests.push( Notifications.CHECK_SAVE_IN_WORKAREA );
			interests.push( Notifications.SAVE_CHANGED );
			
			return interests;
		}
		
		private function setSelectTreeElement( treeElVO : TreeElementVO ) : void
		{
			var elements:Array = workArea.getTreeElements();
			for each (var t:TreeElement in elements)
			{
				if ( t.treeElementVO == treeElVO )
				{
					t.selected = true;
					break;
				}				
			}	
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != Notifications.BODY_START )
				return;

			switch ( name )
			{
				case Notifications.BODY_START:
				{
					if ( statesProxy.selectedApplication )
					{
						isActive = true;

						workArea.selectedTreeLevelVO = statesProxy.selectedTreeLevel;

						if ( structureProxy.treeElements )
							workArea.treeElements = structureProxy.treeElements;

						sendNotification( Notifications.GET_APPLICATION_STRUCTURE, statesProxy.selectedApplication );
						/*if ( structureProxy.linkages )
							workArea.linkages = structureProxy.linkages;*/

						if ( statesProxy.selectedPage )
						{
							statesProxy.selectedTreeElement = structureProxy.getTreeElementByVO(statesProxy.selectedPage); // VO
							setSelectTreeElement( statesProxy.selectedTreeElement );
						}
						break;
					}
				}
				case StatesProxy.SELECTED_APPLICATION_CHANGED:
				{
					clearData();
					
					break; 
				}
				case Notifications.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case Notifications.PAGE_DELETED:
				{
					var pageVO : PageVO = body.pageVO;

					break;
				}

				case StatesProxy.SELECTED_TREE_LEVEL_CHANGED:
				{
					workArea.selectedTreeLevelVO = statesProxy.selectedTreeLevel;
					
					break;
				}
					
				case Notifications.TREE_ELEMENTS_CHANGED:
				{					
					workArea.treeElements = body as Array;					
					
					break;			
				}

				case Notifications.TREE_ELEMENT_ADD:
				{					
					workArea.treeElements = body as Array;					
					
					setSelectTreeElement( workArea.treeElements[workArea.treeElements.length - 1]);
					
					break;			
				}

				case Notifications.LINKAGES_CHANGED:
				{
					workArea.linkages = body as Array;

					break;
				}
					
				case Notifications.LINKAGES_INDEX_UPDATE:
				{
					workArea.updateLinkageIndex();
					
					break;
				}
					
				case Notifications.CHECK_SAVE_IN_WORKAREA:
				{
					if ( workArea.skin.currentState == "unsaved" )
						sendNotification( Notifications.SAVE_IN_WORKAREA_CHECKED, { applicationVO : statesProxy.selectedApplication, object : body , saved : false } );
					else
						sendNotification( Notifications.SAVE_IN_WORKAREA_CHECKED, { applicationVO : statesProxy.selectedApplication, object : body , saved : true } );
					
					break;
				}
					
				case Notifications.SAVE_CHANGED:
				{
					saveHandler();
					
					break;
				}
					
				case Notifications.APPLICATION_STRUCTURE_SETTED:
				{
					workArea.skin.currentState = "normal"; //TODO: добавить public свойство для изменения внутреннего state;
					
					break;
				}	
					
//				case Notifications.CREATE_LINKAGE_REQUEST:
//				{
//					shadowLinkage = new Linkage();
//
//					shadowLinkageVO = new LinkageVO();
//
//					var sourceTreeElementVO : TreeElementVO = body as TreeElementVO;
//					shadowTargetTreeElementVO = new TreeElementVO( sourceTreeElementVO.pageVO );
//
//					shadowLinkageVO.source = sourceTreeElementVO;
//					shadowLinkageVO.target = shadowTargetTreeElementVO;
//					shadowLinkageVO.level = selectedTreeLevelVO;
//
//					shadowLinkage.linkageVO = shadowLinkageVO;
//
//					shadowLinkage.alpha = 0.4;
//
//					workArea.linkagesContainer.addElement( shadowLinkage );
//
//					workArea.stage.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
//					workArea.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
//					workArea.addEventListener( MouseEvent.MOUSE_OVER, mouseOverHandler, true );
//
//					break;
//				}
			}
		}

		private function addHandlers() : void
		{
			workArea.addEventListener( TreeElementEvent.CREATED, treeElement_createdHandler, true, 0, true );
			workArea.addEventListener( TreeElementEvent.REMOVED, treeElement_removedHandler, true, 0, true );
			
			
			workArea.addEventListener( LinkageEvent.CREATED, linkage_createdHandler, true, 0, true );
			workArea.addEventListener( LinkageEvent.REMOVED, linkage_removedHandler, true, 0, true );
			
			workArea.addEventListener( WorkAreaEvent.SAVE, saveHandler, false, 0, true );
			workArea.addEventListener( WorkAreaEvent.UNDO, undoHandler, false, 0, true );

			workArea.addEventListener( WorkAreaEvent.CREATE_PAGE, createPageHandler, false, 0, true );

			workArea.addEventListener( WorkAreaEvent.EXPAND_ALL, expandAllHandler, false, 0, true );
			workArea.addEventListener( WorkAreaEvent.COLLAPSE_ALL, collapseAllHandler, false, 0, true );

			workArea.addEventListener( WorkAreaEvent.SHOW_SIGNATURE, showSignatureHandler, false, 0, true );
			workArea.addEventListener( WorkAreaEvent.HIDE_SIGNATURE, hideSignatureHandler, false, 0, true );
			
			workArea.addEventListener( WorkAreaEvent.SET_START, makeStartPageHandler, false, 0, true );
			
			workArea.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler, true, 0, true );
			workArea.addEventListener( LinkageEvent.CLICK, signatureGroupClick, true, 0, true );
			workArea.addEventListener( LinkageEvent.INDEX_CHANGE, indexChangeHandler, true, 0, true );
		}

		private function removeHandlers() : void
		{
			workArea.removeEventListener( WorkAreaEvent.SAVE, saveHandler );
			workArea.removeEventListener( WorkAreaEvent.UNDO, undoHandler );

			workArea.removeEventListener( TreeElementEvent.CREATED, treeElement_createdHandler, true );
			workArea.removeEventListener( TreeElementEvent.REMOVED, treeElement_removedHandler, true );

			workArea.removeEventListener( LinkageEvent.CREATED, linkage_createdHandler, true );
			workArea.removeEventListener( LinkageEvent.REMOVED, linkage_removedHandler, true );
			
			workArea.removeEventListener( WorkAreaEvent.CREATE_PAGE, createPageHandler );

			workArea.removeEventListener( WorkAreaEvent.CREATE_PAGE, createPageHandler );
			workArea.removeEventListener( WorkAreaEvent.EXPAND_ALL, expandAllHandler );

			workArea.removeEventListener( WorkAreaEvent.SHOW_SIGNATURE, showSignatureHandler );
			workArea.removeEventListener( WorkAreaEvent.HIDE_SIGNATURE, hideSignatureHandler );
			
			workArea.removeEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler, true );
			workArea.removeEventListener( LinkageEvent.CLICK, signatureGroupClick, true );
			workArea.removeEventListener( LinkageEvent.INDEX_CHANGE, indexChangeHandler, true );
		}

		private function clearData() : void
		{
			workArea.treeElements = null;
			workArea.linkages = null;
			workArea.linkagesLayer.removeAllElements();
			workArea.removeAllElements();
		}

		private function saveHandler( event : WorkAreaEvent = null ) : void
		{
			sendNotification( Notifications.SAVE_REQUEST );
		}
		
		private function undoHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( Notifications.UNDO_REQUEST );
		}
		
		private function createPageHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( Notifications.OPEN_CREATE_PAGE_WINDOW_REQUEST, workArea );
		}

		private function treeElement_createdHandler( event : TreeElementEvent ) : void
		{
			sendNotification( Notifications.TREE_ELEMENT_CREATED, event.target as TreeElement );
		}

		private function treeElement_removedHandler( event : TreeElementEvent ) : void
		{
			sendNotification( Notifications.TREE_ELEMENT_REMOVED, event.target as TreeElement );
		}
		
		private function linkage_createdHandler( event : LinkageEvent ) : void
		{
			sendNotification( Notifications.LINKAGE_CREATED, event.target as Linkage );
		}
		
		private function linkage_removedHandler( event : LinkageEvent ) : void
		{
			sendNotification( Notifications.LINKAGE_REMOVED, event.target as Linkage );
		}
		
		private function expandAllHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( Notifications.EXPAND_ALL_TREE_ELEMENTS );
		}

		private function collapseAllHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( Notifications.COLLAPSE_ALL_TREE_ELEMENTS );
		}

		private function showSignatureHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( Notifications.SHOW_SIGNATURE );
		}

		private function hideSignatureHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( Notifications.HIDE_SIGNATURE );
		}
		
		private function makeStartPageHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( Notifications.SET_APPLICATION_INFORMATION, { applicationVO : statesProxy.selectedApplication, pageID : statesProxy.selectedPage.id } );
		}
		
		private function keyDownHandler( event : KeyboardEvent ) : void
		{
			if( event.keyCode == Keyboard.F5 )
			{
				if ( workArea.skin.currentState == "unsaved" )
				{
					Alert.setPatametrs( "Ok" );
					Alert.Show( "First press to Save!!", AlertButton.OK, workArea.parentApplication, null );
				}
				else
				{
					facade.sendNotification( Notifications.GET_PAGES, { applicationVO: statesProxy.selectedApplication} );
					facade.sendNotification( Notifications.GET_APPLICATION_STRUCTURE, { applicationVO: statesProxy.selectedApplication} );
				}
			}
			
			if( !event.ctrlKey )
				return;
			
			if ( event.keyCode == Keyboard.S )
				saveHandler();
		}
		
		private function signatureGroupClick( event : LinkageEvent ) : void
		{
			var linkage : Linkage = event.target as Linkage;
			
			workArea.openIndexList( structureProxy.linkages, linkage, event.detail );
		}
		
		private function indexChangeHandler( event : LinkageEvent ) : void
		{			
			structureProxy.exchange( event.detail.firstLinkageVO, event.detail.secondLinkageVO );
		}
		
		
	}
}