//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;

	public class ObjectsTreePanelEvent extends Event
	{
		public static var CHANGE : String      = "otpe_change";

		public static var EYE_CHANGED : String = "eyeChanged";

		public static var OPEN : String        = "otpe_open";
		
		public static var DELETE : String        = "otpe_delete";
		public static var COPY : String        = "otpe_copy";
		public static var PASTE : String        = "otpe_paste";
		public static const CREATE_NEW_CLICK : String = 'createNewClick';

		public function ObjectsTreePanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true, pageID : String = null,
											   objectID : String = null )
		{
			super( type, bubbles, cancelable );
			this.pageID = pageID;
			this.objectID = objectID;
		}

		public var objectID : String;

		public var pageID : String;

		override public function clone() : Event
		{
			return new ObjectsTreePanelEvent( type, bubbles, cancelable, pageID, objectID );
		}
	}
}
