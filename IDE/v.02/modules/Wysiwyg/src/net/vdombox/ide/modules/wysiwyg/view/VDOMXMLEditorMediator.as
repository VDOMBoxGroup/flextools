package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.events.Event;

	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.VDOMXMLEditorEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.VDOMXMLEditor;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class VDOMXMLEditorMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "VDOMXMLEditorMediator";

		public function VDOMXMLEditorMediator( viewComponent : VDOMXMLEditor )
		{
			super( NAME, viewComponent );
		}

		private var sessionProxy : SessionProxy;

		private var isActive : Boolean;

		private var isAddedToStage : Boolean;

		public function get vdomXMLEditor() : VDOMXMLEditor
		{
			return viewComponent as VDOMXMLEditor;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

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

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.XML_PRESENTATION_GETTED );
			interests.push( ApplicationFacade.XML_PRESENTATION_SETTED );

			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );
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

				case ApplicationFacade.XML_PRESENTATION_GETTED:
				{
					vdomXMLEditor.enabled = true;
					vdomXMLEditor.text = body.xmlPresentation as String;

					break;
				}

				case ApplicationFacade.XML_PRESENTATION_SETTED:
				{
//					vdomXMLEditor.enabled = true;

					break;
				}

				case ApplicationFacade.SELECTED_OBJECT_CHANGED:
				{
					getXMLPresentation();

					break;
				}

				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					getXMLPresentation();

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			vdomXMLEditor.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true );
			vdomXMLEditor.addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );

			vdomXMLEditor.addEventListener( VDOMXMLEditorEvent.SAVE, saveHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			vdomXMLEditor.removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
			vdomXMLEditor.removeEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );

			vdomXMLEditor.removeEventListener( VDOMXMLEditorEvent.SAVE, saveHandler );
		}

		private function clearData() : void
		{
			isAddedToStage = false;

			vdomXMLEditor.enabled = false;
			vdomXMLEditor.text = "";
		}

		private function getXMLPresentation() : void
		{
			if ( isAddedToStage )
			{
				vdomXMLEditor.enabled = false;
				vdomXMLEditor.text = "";

				if ( sessionProxy.selectedObject )
					sendNotification( ApplicationFacade.GET_XML_PRESENTATION, { objectVO: sessionProxy.selectedObject } );
				else if ( sessionProxy.selectedPage )
					sendNotification( ApplicationFacade.GET_XML_PRESENTATION, { pageVO: sessionProxy.selectedPage } );
			}
		}

		private function addedToStageHandler( event : Event ) : void
		{
			isAddedToStage = true;

			getXMLPresentation();
		}

		private function removedFromStageHandler( event : Event ) : void
		{
			isAddedToStage = false;

			clearData();
		}

		private function saveHandler( event : Event ) : void
		{
			var xmlPresentation : String = vdomXMLEditor.text;
//			vdomXMLEditor.enabled = false;
			
			if ( sessionProxy.selectedObject )
			{
				sendNotification( ApplicationFacade.SET_XML_PRESENTATION,
					{ objectVO: sessionProxy.selectedObject, xmlPresentation: xmlPresentation } );
			}
			else if ( sessionProxy.selectedPage )
			{
				sendNotification( ApplicationFacade.SET_XML_PRESENTATION, { pageVO: sessionProxy.selectedPage, xmlPresentation: xmlPresentation } );
			}
		}
	}
}