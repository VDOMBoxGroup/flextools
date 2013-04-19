/*
	Class OpenMediator is a wrapper over the openButton in ObjectEditor2.mxml.
*/
package net.vdombox.object_editor.view.mediators
{
import flash.display.DisplayObject;
import flash.events.Event;

import mx.containers.ViewStack;
import mx.controls.Alert;

import net.vdombox.object_editor.event.UpdateDescriptionEvent;

import net.vdombox.object_editor.event.UpdateDescriptionEvent;
import net.vdombox.object_editor.model.proxy.FileProxy;
import net.vdombox.object_editor.model.proxy.LaTexProxy;
import net.vdombox.object_editor.model.proxy.componentsProxy.LanguagesProxy;
import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
import net.vdombox.object_editor.model.vo.ActionVO;
import net.vdombox.object_editor.model.vo.AttributeVO;
import net.vdombox.object_editor.model.vo.BaseVO;
import net.vdombox.object_editor.model.vo.DescriptionListItemVO;
import net.vdombox.object_editor.model.vo.EventVO;
import net.vdombox.object_editor.view.DescriptionUpdateView;

import net.vdombox.object_editor.view.popups.DescriptionsUpdateWindow;

    import org.puremvc.as3.interfaces.IMediator;
    import org.puremvc.as3.patterns.mediator.Mediator;

public class DescriptionsUpdateWindowMediator extends Mediator implements IMediator
	{		
		public static const NAME:String = "DescriptionsUpdateWindowMediator";

		public function DescriptionsUpdateWindowMediator( viewComponent:Object )
		{			
			super( NAME, viewComponent );
		}

        protected function get view() : DescriptionsUpdateWindow
        {
            return viewComponent as DescriptionsUpdateWindow;
        }

        override public function onRegister() : void
        {
            addHandlers();
        }

        private function addHandlers() : void
        {
            view.addEventListener( Event.CLOSE, closeHandler );
            view.addEventListener( UpdateDescriptionEvent.DESCRIPTIONS_FILL_VALUES, descriptionsFillValuesHandler, true );

            view.addEventListener( UpdateDescriptionEvent.UPDATE_ATTRIBUTES_DESCRIPTIONS, updateAttributesDescriptionsEventHandler );
            view.addEventListener( UpdateDescriptionEvent.UPDATE_EVENTS_DESCRIPTIONS, updateEventsDescriptionsEventHandler );
            view.addEventListener( UpdateDescriptionEvent.UPDATE_ACTIONS_DESCRIPTIONS, updateActionsDescriptionsEventHandler );
        }

        private function removeHandlers() : void
        {
            view.removeEventListener( Event.CLOSE, closeHandler );
            view.removeEventListener( UpdateDescriptionEvent.DESCRIPTIONS_FILL_VALUES, descriptionsFillValuesHandler, true );

            view.removeEventListener( UpdateDescriptionEvent.UPDATE_ATTRIBUTES_DESCRIPTIONS, updateAttributesDescriptionsEventHandler );
            view.removeEventListener( UpdateDescriptionEvent.UPDATE_EVENTS_DESCRIPTIONS, updateEventsDescriptionsEventHandler );
            view.removeEventListener( UpdateDescriptionEvent.UPDATE_ACTIONS_DESCRIPTIONS, updateActionsDescriptionsEventHandler );
        }

        private function closeHandler( event : Event ) : void
        {
            facade.removeMediator( mediatorName );
        }

        override public function onRemove() : void
        {
            removeHandlers();
        }

        private function descriptionsFillValuesHandler( event : UpdateDescriptionEvent ) : void
        {
            var listItemVO : DescriptionListItemVO = event.listItemVO;
			var propertyVO : BaseVO = listItemVO.data;

            listItemVO.oldValue = getItemDescriptionWord( propertyVO );
            listItemVO.newValue =  getPropertyLaTexDescription( propertyVO );
        }

        private function getItemDescriptionWord( baseVO : BaseVO ) : String
        {
            if (!baseVO)
                return "";

            var langID : String = languagesProxy.getRegExpID(baseVO.help);

            return languagesProxy.getWord( view.typeVO.languages, langID, "en_US" );
        }

        private function getPropertyLaTexDescription( baseVO : BaseVO ) : String
        {
            if (!baseVO)
                return "";

            if (!baseVO.laTexFilePath)
                return "";

            var propertyLaTexFileContent : String = fileProxy.readFile(baseVO.laTexFilePath);

            return laTexProxy.getPropertyDescription( propertyLaTexFileContent );
        }

        private function updateAttributesDescriptionsEventHandler ( event : UpdateDescriptionEvent ) : void
        {
            updateCheckedAttributesDescriptions();
        }

        private function updateCheckedAttributesDescriptions() : void
        {
            for each ( var item : DescriptionListItemVO in view.checkedAttributes )
            {
                if (!item)
                    continue;

                if ( !(item.data is AttributeVO) )
                    continue;

                var attributeVO : AttributeVO = item.data as AttributeVO;

                objectTypeProxy.updatePropertyDescription( attributeVO, view.typeVO, getItemDescription( item ) );
            }

            sendNotification(UpdateDescriptionEvent.ATTRIBUTES_DESCRIPTIONS_UPDATE_COMPLETE);

            Alert.show( "Attributes descriptions update complete.", "Update", Alert.OK, view );
        }

        private function updateEventsDescriptionsEventHandler ( event : UpdateDescriptionEvent ) : void
        {
            updateCheckedEventsDescriptions();
        }

        private function updateCheckedEventsDescriptions() : void
        {
            for each ( var item : DescriptionListItemVO in view.checkedEvents )
            {
                if (!item)
                    continue;

                if ( !(item.data is EventVO) )
                    continue;

                var eventVO : EventVO = item.data as EventVO;

                objectTypeProxy.updatePropertyDescription( eventVO, view.typeVO, getItemDescription( item ) );
            }

            sendNotification(UpdateDescriptionEvent.EVENTS_DESCRIPTIONS_UPDATE_COMPLETE);

            Alert.show( "Events descriptions update complete.", "Update", Alert.OK, view );
        }

        private function updateActionsDescriptionsEventHandler ( event : UpdateDescriptionEvent ) : void
        {
            updateCheckedActionsDescriptions();
        }

        private function updateCheckedActionsDescriptions() : void
        {
            for each ( var item : DescriptionListItemVO in view.checkedActions )
            {
                if (!item)
                    continue;

                if ( !(item.data is ActionVO) )
                    continue;

                var actionVO : ActionVO = item.data as ActionVO;

                objectTypeProxy.updatePropertyDescription( actionVO, view.typeVO, getItemDescription( item ) );
            }

            sendNotification(UpdateDescriptionEvent.ACTIONS_DESCRIPTIONS_UPDATE_COMPLETE);

            Alert.show( "Actions descriptions update complete.", "Update", Alert.OK, view );
        }

        private function getItemDescription( attributeItem : DescriptionListItemVO ) : String
        {
            if (!attributeItem)
                return "";

            if (!attributeItem.descriptionUpdateView)
                return getPropertyLaTexDescription( attributeItem.data as AttributeVO );

            return attributeItem.descriptionUpdateView.newValue;
        }

        private function get objectTypeProxy () : ObjectTypeProxy
        {
            return facade.retrieveProxy(ObjectTypeProxy.NAME) as ObjectTypeProxy;
        }

        private function get laTexProxy () : LaTexProxy
        {
            return facade.retrieveProxy(LaTexProxy.NAME) as LaTexProxy;
        }

        private function get fileProxy () : FileProxy
        {
            return facade.retrieveProxy(FileProxy.NAME) as FileProxy;
        }

        private function get languagesProxy () : LanguagesProxy
        {
            return facade.retrieveProxy(LanguagesProxy.NAME) as LanguagesProxy;
        }

	}
}