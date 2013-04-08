package vdom.events
{
	import flash.events.Event;
	

public class ClosablePanelEvent extends Event
{
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------
	
	
	public static const PANEL_COLLAPSE:String = "panelCollapse";
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	public function ClosablePanelEvent(type:String, bubbles:Boolean = false,
							  cancelable:Boolean = false)
	{
		super(type, bubbles, cancelable);
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  opening
	//----------------------------------

	/**
	 *  Used for an <code>PANEL_OPENING</code> type events only.
	 *  Indicates whether the item 
	 *  is opening <code>true</code>, or closing <code>false</code>.
	 */
	public var collapse:Boolean;

	//----------------------------------
	//  triggerEvent
	//----------------------------------

	/**
	 *  The low level MouseEvent or KeyboardEvent that triggered this
	 *  event or <code>null</code> if this event was triggered programatically.
	 */
	public var triggerEvent:Event;

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Event
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override public function clone():Event
	{
		return new ClosablePanelEvent(type, bubbles, cancelable);
	}
}
}
