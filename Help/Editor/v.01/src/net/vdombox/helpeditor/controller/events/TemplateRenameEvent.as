package net.vdombox.helpeditor.controller.events
{
	import flash.events.Event;
	
	public class TemplateRenameEvent extends Event
	{
		public static const TEMPLATE_RENAMED	: String = "templateRenamed";
		
		public var oldTemplateName : String = "";
		public var newTemplateName : String = "";
		
		public function TemplateRenameEvent(type:String, oldName:String="", newName:String="", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.oldTemplateName = oldName;
			this.newTemplateName = newName;
		}
		
		override public function clone():Event
		{
			return new TemplateRenameEvent(type, oldTemplateName, newTemplateName, bubbles, cancelable);
		}
		
	}
}