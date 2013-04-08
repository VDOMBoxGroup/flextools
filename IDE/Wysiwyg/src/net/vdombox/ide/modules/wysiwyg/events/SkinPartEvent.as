package net.vdombox.ide.modules.wysiwyg.events
{

	import flash.events.Event;

	public class SkinPartEvent extends Event
	{

		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 * This event is dispatched during partAdded().
		 */
		public static const PART_ADDED : String = "_partAdded";

		/**
		 * @private
		 * This event is dispatched during partRemoved().
		 */
		public static const PART_REMOVED : String = "_partRemoved";

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 * Constructor.
		 */
		public function SkinPartEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false, partName : String = null, instance : Object = null )
		{
			super( type, bubbles, cancelable );

			this.partName = partName;
			this.instance = instance;
		}

		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------

		//----------------------------------
		//  instance
		//----------------------------------

		/**
		 * The skin part being added or removed.
		 */
		public var instance : Object;

		//----------------------------------
		//  partName
		//----------------------------------

		/**
		 * The name of the skin part being added or removed.
		 */
		public var partName : String;

		//--------------------------------------------------------------------------
		//
		//  Overridden methods: Event
		//
		//--------------------------------------------------------------------------

		/**
		 * @private
		 */
		override public function clone() : Event
		{
			return new SkinPartEvent( type, bubbles, cancelable, partName, instance );
		}
	}

}
