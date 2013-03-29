/*
	Class OpenMediator is a wrapper over the openButton in ObjectEditor2.mxml.
*/
package net.vdombox.object_editor.view.mediators
{

import flash.events.Event;

import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.events.FlexEvent;

import net.vdombox.object_editor.event.DocumentationSettingsEvent;
import net.vdombox.object_editor.model.proxy.FileProxy;
import net.vdombox.object_editor.model.proxy.LaTexProxy;
import net.vdombox.object_editor.view.popups.DocumentationSettingsWindow;

import org.puremvc.as3.interfaces.IMediator;
import org.puremvc.as3.patterns.mediator.Mediator;

public class DocumentationSettingsWindowMediator extends Mediator implements IMediator
	{		
		public static const NAME:String = "DocumentationSettingsWindowMediator";

		public function DocumentationSettingsWindowMediator( viewComponent:Object )
		{			
			super( NAME, viewComponent );
		}

        protected function get view() : DocumentationSettingsWindow
        {
            return viewComponent as DocumentationSettingsWindow;
        }

        override public function onRegister() : void
        {
            addHandlers();
        }

        private function addHandlers() : void
        {
            view.addEventListener( Event.CLOSE, closeHandler );
            view.addEventListener( FlexEvent.CREATION_COMPLETE, viewCreationCompleteHandler );
            view.addEventListener( DocumentationSettingsEvent.SAVE_DOC_SETTINGS, saveDocumentationSettingsHandler );
            view.addEventListener( DocumentationSettingsEvent.CANCEL_DOC_SETTINGS, cancelDocumentationSettingsHandler );
        }

        private function removeHandlers() : void
        {
            view.removeEventListener( Event.CLOSE, closeHandler );
            view.removeEventListener( FlexEvent.CREATION_COMPLETE, viewCreationCompleteHandler );
            view.removeEventListener( DocumentationSettingsEvent.SAVE_DOC_SETTINGS, saveDocumentationSettingsHandler );
            view.removeEventListener( DocumentationSettingsEvent.CANCEL_DOC_SETTINGS, cancelDocumentationSettingsHandler );
        }

        private function closeHandler( event : Event ) : void
        {
            facade.removeMediator( mediatorName );
        }

        override public function onRemove() : void
        {
            removeHandlers();
        }

        private function viewCreationCompleteHandler ( event : FlexEvent ) : void
        {
            view.typesDocFolderBox.path = laTexProxy.typesDocPath;
        }

        private function saveDocumentationSettingsHandler (event : DocumentationSettingsEvent) : void
        {
            var docPath : String = view.typesDocFolderBox.path;

            var isCorrectDocPath : Boolean = laTexProxy.isCorrectTypesDocPath(docPath);

            if (isCorrectDocPath)
            {
                laTexProxy.typesDocPath = docPath;
                view.close();
            }
            else
            {
                  Alert.show("Incorrect folder. ", "Error", Alert.OK, view, alertCloseHandler);
            }

            function alertCloseHandler ( event : CloseEvent) : void
            {
                view.typesDocFolderBox.path = laTexProxy.typesDocPath;
            }
        }

        private function cancelDocumentationSettingsHandler (event : DocumentationSettingsEvent) : void
        {
            view.close();
        }

        private function get fileProxy () : FileProxy
        {
            return facade.retrieveProxy(FileProxy.NAME) as FileProxy;
        }

        private function get laTexProxy() : LaTexProxy
        {
            return facade.retrieveProxy(LaTexProxy.NAME) as LaTexProxy;
        }

	}
}