package net.vdombox.object_editor.event
{
	import flash.events.Event;

import net.vdombox.object_editor.model.vo.BaseVO;
import net.vdombox.object_editor.model.vo.DescriptionListItemVO;
import net.vdombox.object_editor.view.DescriptionUpdateView;

import net.vdombox.object_editor.view.DescriptionUpdateView;

public class UpdateDescriptionEvent extends Event
	{
        public static var DESCRIPTIONS_FILL_VALUES : String = "descriptionsGetLaTexValues";

        public static var UPDATE_ATTRIBUTES_DESCRIPTIONS : String = "updateAttributesDescriptions";
        public static var UPDATE_EVENTS_DESCRIPTIONS : String = "updateEventsDescriptions";
        public static var UPDATE_ACTIONS_DESCRIPTIONS : String = "updateActionsDescriptions";

        public static var ATTRIBUTES_DESCRIPTIONS_UPDATE_COMPLETE : String = "attributesDescriptionsUpdateComplete";
        public static var EVENTS_DESCRIPTIONS_UPDATE_COMPLETE : String = "eventsDescriptionsUpdateComplete";
        public static var ACTIONS_DESCRIPTIONS_UPDATE_COMPLETE : String = "actionsDescriptionsUpdateComplete";

        public var descriptionUpdateView : DescriptionUpdateView;
        public var listItemVO : DescriptionListItemVO;

		public function UpdateDescriptionEvent( type : String, descriptionUpdateView : DescriptionUpdateView=null, listItemVO:DescriptionListItemVO = null,  bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );

            this.descriptionUpdateView = descriptionUpdateView;
            this.listItemVO = listItemVO;
		}
		
		override public function clone() : Event
		{
			return new DocumentationSettingsEvent( type, bubbles, cancelable );
		}
	}
}