package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.events.Event;
	
	import mx.events.DragEvent;
	
	import net.vdombox.components.tabNavigatorClasses.Tab;
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.ItemEvent;
	import net.vdombox.ide.modules.wysiwyg.events.TransformMarkerEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.ObjectRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.PageEditor;
	import net.vdombox.ide.modules.wysiwyg.view.components.TypeItemRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.WorkArea;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Group;

	public class WorkAreaMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "WorkAreaMediator";

		public function WorkAreaMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var sessionProxy : SessionProxy;

		private var isActive : Boolean;

		public function get workArea() : WorkArea
		{
			return viewComponent as WorkArea;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			addHandlers();

//			isSelectedPageVOChanged = true;
//			
//			if( workArea && workArea.stage )
//				isAddedToStage = true;
//
//			commitProperties();
		}

		override public function onRemove() : void
		{
			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;

			switch ( name )
			{
				case ApplicationFacade.BODY_START:
				{
					if ( sessionProxy.selectedApplication )
					{
						isActive = true;

						break;
					}
				}

				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					var pe : PageEditor;
					var pageVO : PageVO = body as PageVO;
					
					if( !pageVO )
						break;
					
					var tab : Tab = workArea.getTabByID( pageVO.id );
					
					if( !tab )
					{
						tab = new Tab();
						tab.id = pageVO.id;
						tab.label = pageVO.name;
						
						workArea.addTab( tab );
						
						 pe = new PageEditor();
						 facade.registerMediator( new PageEditorMediator( pe ) );
						 
						tab.addElement( pe );
					}
					
					workArea.selectedTab = tab;
						
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			workArea.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true );
			workArea.addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			workArea.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
			workArea.addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );
		}

		private function clearData() : void
		{
			removeHandlers();
			
			facade.removeMediator( NAME );
		}

		private function addedToStageHandler( event : Event ) : void
		{
		}

		private function removedFromStageHandler( event : Event ) : void
		{
			clearData();
		}
	}
}