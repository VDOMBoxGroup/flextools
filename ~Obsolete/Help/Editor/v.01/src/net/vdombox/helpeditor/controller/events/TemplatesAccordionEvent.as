package net.vdombox.helpeditor.controller.events
{
	import flash.events.Event;
	
	import net.vdombox.helpeditor.view.components.TemplatesAccordionHeader;
	
	public class TemplatesAccordionEvent extends Event
	{
		public static const FOLDER_REMOVE_CLICK			: String = "folderRemoveClick";
		public static const FOLDER_NEW_LABEL_ENTERED	: String = "folderNewNameEntered";
		public static const FOLDER_NEW_LABEL_ACCEPTED	: String = "folderNewNameAccepted";
		
		public static const SELECTED_TEMPLATE_CHANGED	: String = "selectedTemplateChanged";
		
		public static const TEMPLATE_NEW_NAME_ENTERED	: String = "templateNameEntered";
		public static const TEMPLATE_NEW_NAME_ACCEPTED	: String = "templateNameAccepted";
		
		public static const NEW_TEMPLATE_ADDED			: String = "newTemplateAdded";
		
		public var templatesAccordionHeader : TemplatesAccordionHeader;
		
		public function TemplatesAccordionEvent(type:String, header:TemplatesAccordionHeader=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			templatesAccordionHeader = header;
		}
		
		override public function clone():Event
		{
			return new TemplatesAccordionEvent(type, templatesAccordionHeader, bubbles, cancelable);
		}
		
	}
}