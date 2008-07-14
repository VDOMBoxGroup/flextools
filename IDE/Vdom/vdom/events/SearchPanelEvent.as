package vdom.events {

import flash.events.Event;
	
public class SearchPanelEvent extends Event {
	
	// Define static constant.
	public static const SEARCH_PARAM_CHANGED:String = 'searchParamChanged';
	
	// Define a public variable to hold the state of the enable property.
	public var applicationId:String;
	public var searchString:String;
	
	// Public constructor.
	public function SearchPanelEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
		applicationId:String = null,
		searchString:String = null):void
	{
		super(type, bubbles, cancelable);
		
		this.applicationId = applicationId;
		this.searchString = searchString;
	}
	
	// Override the inherited clone() method.
	override public function clone():Event {
		
		return new SearchPanelEvent(type, bubbles, cancelable, applicationId, searchString);
	}		
}
}
