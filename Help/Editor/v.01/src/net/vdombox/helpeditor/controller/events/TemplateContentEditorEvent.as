package net.vdombox.helpeditor.controller.events
{
	import flash.events.Event;
	
	public class TemplateContentEditorEvent extends Event
	{
		public static const JUMP_TO_TEMPLATE : String = "jumpToTemplate";
		
		public var templateName : String;
		
		public function TemplateContentEditorEvent(type:String, tplName:String="", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			templateName = tplName;
		}
		
		override public function clone():Event
		{
			return new TemplateContentEditorEvent(type, templateName, bubbles, cancelable);
		}
		
	}
}