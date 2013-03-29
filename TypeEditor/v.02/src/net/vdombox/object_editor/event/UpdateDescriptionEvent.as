package net.vdombox.object_editor.event
{
	import flash.events.Event;

	public class UpdateDescriptionEvent extends Event
	{

        public static var SELECTED_ATTRIBUTE_CHANGED : String = "selectedAttributeChanged";
        public static var UPDATE_ATTRIBUTES_DESCRIPTIONS : String = "updateAttributesDescriptions";

        public static var ATTRIBUTES_DESCRIPTIONS_UPDATE_COMPLETE : String = "attributesDescriptionsUpdateComplete";

		public function UpdateDescriptionEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new DocumentationSettingsEvent( type, bubbles, cancelable );
		}
	}
}