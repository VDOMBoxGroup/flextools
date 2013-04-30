package com.zavoo.svg.events {
	import flash.events.Event;

	public class SVGMutationEvent extends Event {		
		//public static const DOM_SUBTREE_MODIDFIED:String = 'DOMSubtreeModified';
		public static const DOM_NODE_INSERTED:String = 'DOMNodeInserted';
		public static const DOM_NODE_REMOVED:String = 'DOMNodeRemoved';
		//public static const DOM_NODE_REMOVED_FROM_DOCUMENT:String = 'DOMNodeRemovedFromDocument';
		//public static const DOM_NODE_INSERTED_INTO_DOCUMENT:String = 'DOMNodeInsertedIntoDocument';
		//public static const DOM_ATTR_MODIEFIED:String = 'DOMAttrModified';
		public static const DOM_CHARACTER_DATA_MODIFIED:String = 'DOMCharacterDataModified';
		
		private var _target:Object;
		
		public function SVGMutationEvent(target:Object, type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this._target = target;	
		}
		
		override public function get target():Object {
			return this._target;
		}
		
	}
}