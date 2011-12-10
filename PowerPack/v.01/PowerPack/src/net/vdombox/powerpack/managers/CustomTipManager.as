package net.vdombox.powerpack.managers
{

import flash.events.EventDispatcher;

public class CustomTipManager extends EventDispatcher
{

	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private static var instance : CustomTipManager;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public static function getInstance() : CustomTipManager
	{
		if ( !instance )
			instance = new CustomTipManager();

		return instance;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public function CustomTipManager()
	{
		super();

		if ( instance )
			throw new Error( "Instance already exists." );

		this.systemManager = SystemManagerGlobals.topLevelSystemManagers[0] as ISystemManager;
		sandboxRoot = this.systemManager.getSandboxRoot();
		sandboxRoot.addEventListener( InterManagerRequest.TOOLTIP_MANAGER_REQUEST, marshalToolTipManagerHandler, false, 0, true );
		var me : InterManagerRequest = new InterManagerRequest( InterManagerRequest.TOOLTIP_MANAGER_REQUEST );
		me.name = "update";
		// trace("--->update request for ToolTipManagerImpl", systemManager);
		sandboxRoot.dispatchEvent( me );
		// trace("<---update request for ToolTipManagerImpl", systemManager);

	}

}
}