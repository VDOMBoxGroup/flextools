package vdom.events {

import flash.events.Event;
	
public class SearchResultEvent extends Event {
	
	// Define static constant.
	public static const SEARCH_OBJECT_SELECTED:String = 'searchObjectSelected';
	public static const SEARCH_CLOSE:String = 'searchClose';
	
	// Define a public variable to hold the state of the enable property.
	public var applicationId:String;
	public var pageId:String;
	public var objectId:String;
	
	// Public constructor.
	public function SearchResultEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
		applicationId:String = null,
		pageId:String = null,
		objectId:String = null):void
	{
		super(type, bubbles, cancelable);
		
		this.applicationId = applicationId;
		this.pageId = pageId;
		this.objectId = objectId;
	}
	
	// Override the inherited clone() method.
	override public function clone():Event {
		
		return new SearchResultEvent(type, bubbles, cancelable, applicationId, pageId, objectId);
	}		
}
}
