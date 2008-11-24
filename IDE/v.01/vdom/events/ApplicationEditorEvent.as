package vdom.events {

import flash.events.Event;

import vdom.controls.ApplicationDescription;
	
public class ApplicationEditorEvent extends Event {
	
	public static const APPLICATION_PROPERTIES_CHANGED:String = 'ApplicationPropertiesChanged';
	public static const APPLICATION_PROPERTIES_CANCELED:String = 'ApplicationPropertiesCanceled';
	
	public var applicationDescription:ApplicationDescription;
	
	public function ApplicationEditorEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
		applicationDescription:ApplicationDescription = null):void {
		
		super(type, bubbles, cancelable);
		
		this.applicationDescription = applicationDescription;
	}
	
	override public function clone():Event {
		
		return new ApplicationEditorEvent(type, bubbles, cancelable, applicationDescription);
	}		
}
}