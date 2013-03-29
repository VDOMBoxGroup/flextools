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
import net.vdombox.object_editor.model.proxy.FileProxy;
import net.vdombox.object_editor.model.proxy.LaTexProxy;
import net.vdombox.object_editor.model.proxy.componentsProxy.LanguagesProxy;
import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
import net.vdombox.object_editor.model.vo.AttributeVO;
import net.vdombox.object_editor.model.vo.DescriptionListItemVO;
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
            view.addEventListener( UpdateDescriptionEvent.UPDATE_ATTRIBUTES_DESCRIPTIONS, updateAttributesDescriptionsEventHandler );
            view.addEventListener( UpdateDescriptionEvent.SELECTED_ATTRIBUTE_CHANGED, selectedAttributeChangedHandler );
        }

        private function removeHandlers() : void
        {
            view.removeEventListener( Event.CLOSE, closeHandler );
            view.removeEventListener( UpdateDescriptionEvent.UPDATE_ATTRIBUTES_DESCRIPTIONS, updateAttributesDescriptionsEventHandler );
            view.removeEventListener( UpdateDescriptionEvent.SELECTED_ATTRIBUTE_CHANGED, selectedAttributeChangedHandler );
        }

        private function closeHandler( event : Event ) : void
        {
            facade.removeMediator( mediatorName );
        }

        override public function onRemove() : void
        {
            removeHandlers();
        }

        private function selectedAttributeChangedHandler( event : UpdateDescriptionEvent ) : void
        {
            var selectedItem : DescriptionListItemVO = selectedAttributeItem;

            var descriptionView : DescriptionUpdateView = getDescriptionUpdateView( selectedAttributeItem );

            if (!descriptionView) {
                descriptionsStack.visible = false;
                return;
            }

            descriptionsStack.visible = true;
            descriptionsStack.selectedChild = descriptionView;
        }

        private function getDescriptionUpdateView(listItemVO:DescriptionListItemVO):DescriptionUpdateView {
            if (!listItemVO)
                return null;

            return listItemVO.descriptionUpdateView || createNewDescriptionUpdateView(listItemVO);
        }

        private function createNewDescriptionUpdateView( listItemVO : DescriptionListItemVO ) : DescriptionUpdateView
        {
            var descriptionUpdateView : DescriptionUpdateView = new DescriptionUpdateView();

            descriptionUpdateView.oldValue = getItemDescriptionWord( listItemVO );
            descriptionUpdateView.newValue = getAttributeLaTexDescription( listItemVO.data as AttributeVO);

            descriptionsStack.addChild(descriptionUpdateView);

            listItemVO.descriptionUpdateView = descriptionUpdateView;

            return descriptionUpdateView;
        }

        private function getItemDescriptionWord( listItemVO : DescriptionListItemVO ) : String
        {
            var langID : String = languagesProxy.getRegExpID(listItemVO.data.help);

            return languagesProxy.getWord( view.typeVO.languages, langID, "en_US" );
        }

        private function getAttributeLaTexDescription( attributeVO : AttributeVO ) : String
        {
            if (!attributeVO)
                return "";

            if (!attributeVO.laTexFilePath)
                return "";

            var attributeLaTexFileContent : String = fileProxy.readFile(attributeVO.laTexFilePath);

            return laTexProxy.getAttributeDescription( attributeLaTexFileContent );
        }

        private function get selectedAttributeItem() : DescriptionListItemVO
        {
             return view.attributesList.selectedItem;
        }

        private function updateAttributesDescriptionsEventHandler ( event : UpdateDescriptionEvent ) : void
        {
            updateCheckedAttributesDescriptions();
        }

        private function updateCheckedAttributesDescriptions() : void
        {
            for each ( var attributeItem : DescriptionListItemVO in view.checkedAttributes )
            {
                if (!attributeItem)
                    continue;

                if ( !(attributeItem.data is AttributeVO) )
                    continue;

                var attributeVO : AttributeVO = attributeItem.data as AttributeVO;

                objectTypeProxy.updateAttributeDescription( attributeVO, view.typeVO, getItemDescription( attributeItem ) );
            }

            sendNotification(UpdateDescriptionEvent.ATTRIBUTES_DESCRIPTIONS_UPDATE_COMPLETE);

            Alert.show( "Descriptions update complete.", "Update", Alert.OK, view );
        }

        private function getItemDescription( attributeItem : DescriptionListItemVO ) : String
        {
            if (!attributeItem)
                return "";

            if (!attributeItem.descriptionUpdateView)
                return getAttributeLaTexDescription( attributeItem.data as AttributeVO);;

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

        private function get descriptionsStack() : ViewStack
        {
            return view.descriptionsStack;
        }

	}
}